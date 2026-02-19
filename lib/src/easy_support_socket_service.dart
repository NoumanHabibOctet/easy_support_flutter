import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import 'easy_support_chat_socket_connection.dart';
import 'models/easy_support_config.dart';
import 'models/easy_support_chat_emit_payload.dart';
import 'models/easy_support_chat_message.dart';

abstract class EasySupportSocketService {
  Future<String> joinChat({
    required EasySupportConfig config,
    required String customerId,
  });

  Future<EasySupportChatSocketConnection> connectToChat({
    required EasySupportConfig config,
    required String customerId,
    required String chatId,
    required void Function(EasySupportChatMessage message) onMessage,
    void Function(Object error)? onError,
  }) async {
    throw UnimplementedError('connectToChat is not implemented.');
  }

  Future<void> sendChatMessage({
    required EasySupportConfig config,
    required EasySupportChatEmitPayload payload,
  }) async {
    throw UnimplementedError('sendChatMessage is not implemented.');
  }
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
    // socket.on('chatId', onJoinEvent);
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

  @override
  Future<EasySupportChatSocketConnection> connectToChat({
    required EasySupportConfig config,
    required String customerId,
    required String chatId,
    required void Function(EasySupportChatMessage message) onMessage,
    void Function(Object error)? onError,
  }) async {
    final normalizedChatId = chatId.trim();
    if (normalizedChatId.isEmpty) {
      throw StateError('chat_id is required for socket chat connection');
    }

    _log('chat socket connect start, chat_id=$normalizedChatId');
    final socket = _buildSocket(config);

    void onAnyEvent(String event, dynamic payload) {
      _log('socket event[$event]: $payload');
    }

    void onChatEvent(dynamic payload) {
      final message = _extractIncomingMessage(
        payload,
        fallbackChatId: normalizedChatId,
      );
      if (message == null) {
        return;
      }

      final messageChatId = message.chatId?.trim();
      if (messageChatId != null &&
          messageChatId.isNotEmpty &&
          messageChatId != normalizedChatId) {
        return;
      }
      onMessage(message);
    }

    void onAnyOutgoing(String event, dynamic payload) {
      _log('socket outgoing[$event]: $payload');
    }

    void onConnect(dynamic _) {
      _log('chat socket connected, emitting join_chat');
      final channelToken = config.channelToken.trim();
      socket.emit(
        'join_chat',
        <String, dynamic>{
          'customer_id': customerId,
          'chat_id': normalizedChatId,
          if (channelToken.isNotEmpty) 'channel_token': channelToken,
        },
      );
    }

    void onConnectError(dynamic error) {
      final resolvedError = StateError('Socket connect error: $error');
      _log('chat socket connect error: $error');
      onError?.call(resolvedError);
    }

    void onSocketError(dynamic error) {
      final resolvedError = StateError('Socket error: $error');
      _log('chat socket error: $error');
      onError?.call(resolvedError);
    }

    socket.onAny(onAnyEvent);
    socket.onAnyOutgoing(onAnyOutgoing);
    socket.onConnect(onConnect);
    socket.on('chat', onChatEvent);
    socket.on('message', onChatEvent);
    socket.on('new_message', onChatEvent);
    socket.on('chat_message', onChatEvent);
    socket.on('customer_message', onChatEvent);
    socket.on('agent_message', onChatEvent);
    socket.onDisconnect((dynamic reason) {
      _log('chat socket disconnected: $reason');
    });
    socket.onConnectError(onConnectError);
    socket.onError(onSocketError);
    socket.connect();

    return _EasySupportSocketIoChatConnection(
      socket: socket,
      onAnyEvent: onAnyEvent,
      onAnyOutgoing: onAnyOutgoing,
      onConnect: onConnect,
      onConnectError: onConnectError,
      onSocketError: onSocketError,
      onChatEvent: onChatEvent,
      logger: _log,
    );
  }

  @override
  Future<void> sendChatMessage({
    required EasySupportConfig config,
    required EasySupportChatEmitPayload payload,
  }) async {
    _log('chat emit start, chat_id=${payload.chatId}');
    final socket = _buildSocket(config);
    final completer = Completer<void>();

    void complete() {
      if (!completer.isCompleted) {
        completer.complete();
      }
    }

    void failWith(Object error) {
      _log('chat emit failed: $error');
      if (!completer.isCompleted) {
        completer.completeError(error);
      }
    }

    void onAnyEvent(String event, dynamic data) {
      _log('socket event[$event]: $data');
    }

    void onAnyOutgoing(String event, dynamic data) {
      _log('socket outgoing[$event]: $data');
    }

    socket.onAny(onAnyEvent);
    socket.onAnyOutgoing(onAnyOutgoing);
    socket.onConnect((_) {
      _log('socket connected, emitting chat');
      socket.emit('chat', payload.toJson());
      complete();
    });
    socket.onConnectError((dynamic error) {
      failWith(StateError('Socket connect error: $error'));
    });
    socket.onError((dynamic error) {
      failWith(StateError('Socket error: $error'));
    });

    final timer = Timer(_timeout, () {
      failWith(
        TimeoutException(
          'chat emit timed out',
          _timeout,
        ),
      );
    });

    socket.connect();

    try {
      await completer.future;
    } finally {
      timer.cancel();
      socket.offAny(onAnyEvent);
      socket.offAnyOutgoing(onAnyOutgoing);
      _log('socket closing for chat emit');
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
          .setTransports(<String>['websocket', 'polling'])
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

  static EasySupportChatMessage? _extractIncomingMessage(
    dynamic payload, {
    required String fallbackChatId,
  }) {
    if (payload is List) {
      for (final item in payload) {
        final parsed = _extractIncomingMessage(
          item,
          fallbackChatId: fallbackChatId,
        );
        if (parsed != null) {
          return parsed;
        }
      }
      return null;
    }

    final map = _asMap(payload);
    if (map == null) {
      return null;
    }

    final nestedData = _asMap(map['data']);
    if (nestedData != null) {
      final fromNested = _extractIncomingMessage(
        nestedData,
        fallbackChatId: fallbackChatId,
      );
      if (fromNested != null) {
        return fromNested;
      }
    }

    final content =
        _readString(map, const <String>['content', 'body', 'message']) ?? '';
    final type = _readString(map, const <String>['type']) ?? 'message';
    final normalizedContent = content.trim();
    final isNotification = type == 'notification';
    if (normalizedContent.isEmpty && !isNotification) {
      return null;
    }

    return EasySupportChatMessage(
      id: _readString(map, const <String>['id']),
      chatId: _readString(map, const <String>['chat_id', 'chatId']) ??
          fallbackChatId,
      customerId: _readString(map, const <String>['customer_id', 'customerId']),
      agentId: _readString(map, const <String>['agent_id', 'agentId']),
      content: normalizedContent,
      type: type,
      isSeen: _readBool(map, const <String>['is_seen', 'isSeen']),
      createdAt: _readString(map, const <String>['created_at', 'createdAt']) ??
          DateTime.now().toIso8601String(),
    );
  }

  static bool? _readBool(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      if (value is bool) {
        return value;
      }
    }
    return null;
  }

  static Map<String, dynamic>? _asMap(dynamic value) {
    if (value is Map<String, dynamic>) {
      return value;
    }
    if (value is Map) {
      return Map<String, dynamic>.from(value);
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

class _EasySupportSocketIoChatConnection
    implements EasySupportChatSocketConnection {
  _EasySupportSocketIoChatConnection({
    required io.Socket socket,
    required void Function(String event, dynamic payload) onAnyEvent,
    required void Function(String event, dynamic payload) onAnyOutgoing,
    required void Function(dynamic data) onConnect,
    required void Function(dynamic error) onConnectError,
    required void Function(dynamic error) onSocketError,
    required void Function(dynamic payload) onChatEvent,
    required void Function(String message) logger,
  })  : _socket = socket,
        _onAnyEvent = onAnyEvent,
        _onAnyOutgoing = onAnyOutgoing,
        _onConnect = onConnect,
        _onConnectError = onConnectError,
        _onSocketError = onSocketError,
        _onChatEvent = onChatEvent,
        _logger = logger;

  final io.Socket _socket;
  final void Function(String event, dynamic payload) _onAnyEvent;
  final void Function(String event, dynamic payload) _onAnyOutgoing;
  final void Function(dynamic data) _onConnect;
  final void Function(dynamic error) _onConnectError;
  final void Function(dynamic error) _onSocketError;
  final void Function(dynamic payload) _onChatEvent;
  final void Function(String message) _logger;

  @override
  Future<void> dispose() async {
    _logger('chat socket closing');
    _socket.offAny(_onAnyEvent);
    _socket.offAnyOutgoing(_onAnyOutgoing);
    _socket.off('connect', _onConnect);
    _socket.off('connect_error', _onConnectError);
    _socket.off('error', _onSocketError);
    _socket.off('chat', _onChatEvent);
    _socket.off('message', _onChatEvent);
    _socket.off('new_message', _onChatEvent);
    _socket.off('chat_message', _onChatEvent);
    _socket.off('customer_message', _onChatEvent);
    _socket.off('agent_message', _onChatEvent);
    _socket.dispose();
    _socket.disconnect();
  }
}
