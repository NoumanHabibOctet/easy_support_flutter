import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'models/easy_support_config.dart';

abstract class EasySupportSocketService {
  Future<String> joinChat({
    required EasySupportConfig config,
    required String customerId,
  });
}

class EasySupportSocketIoService implements EasySupportSocketService {
  EasySupportSocketIoService({
    Duration timeout = const Duration(seconds: 10),
  }) : _timeout = timeout;

  final Duration _timeout;

  @override
  Future<String> joinChat({
    required EasySupportConfig config,
    required String customerId,
  }) async {
    _log('join_chat start, customer_id=$customerId');
    final socket = _buildSocket(config);
    final completer = Completer<String>();

    void completeWithPayload(dynamic payload) {
      _log('join_chat ack/event payload: $payload');
      if (completer.isCompleted) {
        return;
      }
      final chatId = _extractChatId(payload);
      if (chatId != null) {
        _log('join_chat resolved chat_id=$chatId');
        completer.complete(chatId);
      }
    }

    void failWith(Object error) {
      _log('join_chat failed: $error');
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    void onJoinEvent(dynamic payload) {
      _log('join_chat event payload: $payload');
      completeWithPayload(payload);
    }

    void onAnyEvent(String event, dynamic payload) {
      _log('socket event[$event]: $payload');
      if (event == 'chat_id' || event == 'chatId') {
        completeWithPayload(payload);
      }
    }

    void onAnyOutgoing(String event, dynamic payload) {
      _log('socket outgoing[$event]: $payload');
    }

    socket.onConnect((_) {
      _log('socket connected, emitting join_chat');
      final channelToken = config.channelToken.trim();
      socket.emitWithAck(
        'join_chat',
        <String, dynamic>{
          // 'id': customerId,
          'customer_id': customerId,
          if (channelToken.isNotEmpty) 'channel_token': channelToken,
        },
        ack: completeWithPayload,
      );
    });
    socket.onDisconnect((dynamic reason) {
      _log('socket disconnected: $reason');
    });
    socket.onReconnect((dynamic data) {
      _log('socket reconnect: $data');
    });
    socket.onReconnectAttempt((dynamic data) {
      _log('socket reconnect_attempt: $data');
    });
    socket.onReconnectError((dynamic error) {
      _log('socket reconnect_error: $error');
    });
    socket.onReconnectFailed((dynamic data) {
      _log('socket reconnect_failed: $data');
    });
    socket.onPing((dynamic data) {
      _log('socket ping: $data');
    });
    socket.onPong((dynamic data) {
      _log('socket pong: $data');
    });
    socket.onAny(onAnyEvent);
    socket.onAnyOutgoing(onAnyOutgoing);

    socket.on('join_chat_response', onJoinEvent);
    socket.on('join_chat_success', onJoinEvent);
    socket.on('chat_joined', onJoinEvent);
    socket.on('chat_id', onJoinEvent);
    socket.on('chatId', onJoinEvent);
    socket.onConnectError((dynamic error) {
      failWith(StateError('Socket connect error: $error'));
    });
    socket.onError((dynamic error) {
      failWith(StateError('Socket error: $error'));
    });

    final timer = Timer(_timeout, () {
      failWith(
        TimeoutException(
          'join_chat timed out',
          _timeout,
        ),
      );
    });

    socket.connect();

    try {
      final chatId = await completer.future;
      return chatId;
    } finally {
      timer.cancel();
      socket.offAny(onAnyEvent);
      socket.offAnyOutgoing(onAnyOutgoing);
      socket.off('join_chat_response', onJoinEvent);
      socket.off('join_chat_success', onJoinEvent);
      socket.off('chat_joined', onJoinEvent);
      socket.off('chat_id', onJoinEvent);
      socket.off('chatId', onJoinEvent);
      _log('socket closing for join_chat');
      socket.dispose();
      socket.disconnect();
    }
  }

  io.Socket _buildSocket(EasySupportConfig config) {
    final socketBaseUrl = config.normalizedBaseUrl.replaceFirst(
      RegExp(r'/$'),
      '',
    );

    return io.io(
      socketBaseUrl,
      io.OptionBuilder()
          .setTransports(<String>['websocket'])
          .disableAutoConnect()
          .setExtraHeaders(config.resolvedHeaders)
          .build(),
    );
  }

  static String? _extractChatId(dynamic payload) {
    if (payload is String && payload.trim().isNotEmpty) {
      return payload.trim();
    }

    if (payload is Map) {
      final map = Map<String, dynamic>.from(payload);
      final direct = _readString(
        map,
        const <String>['chat_id', 'chatId', 'id'],
      );
      if (direct != null) {
        return direct;
      }

      final data = map['data'];
      if (data is Map) {
        final fromData = _readString(
          Map<String, dynamic>.from(data),
          const <String>['chat_id', 'chatId', 'id'],
        );
        if (fromData != null) {
          return fromData;
        }
      }

      final chat = map['chat'];
      if (chat is Map) {
        final fromChat = _readString(
          Map<String, dynamic>.from(chat),
          const <String>['chat_id', 'chatId', 'id'],
        );
        if (fromChat != null) {
          return fromChat;
        }
      }
    }

    return null;
  }

  static String? _readString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }

  void _log(String message) {
    debugPrint('EasySupportSocket: $message');
  }
}
