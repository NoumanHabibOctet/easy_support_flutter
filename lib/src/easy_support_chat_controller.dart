import 'package:flutter/foundation.dart';

import 'easy_support_repository.dart';
import 'models/easy_support_chat_message.dart';
import 'models/easy_support_config.dart';

enum EasySupportChatStatus {
  initial,
  loading,
  ready,
  error,
}

@immutable
class EasySupportChatState {
  const EasySupportChatState({
    required this.status,
    this.messages = const <EasySupportChatMessage>[],
    this.error,
  });

  const EasySupportChatState.initial()
      : this(status: EasySupportChatStatus.initial);

  final EasySupportChatStatus status;
  final List<EasySupportChatMessage> messages;
  final Object? error;

  bool get isLoading => status == EasySupportChatStatus.loading;
}

class EasySupportChatController extends ValueNotifier<EasySupportChatState> {
  EasySupportChatController({
    required EasySupportRepository repository,
  })  : _repository = repository,
        super(const EasySupportChatState.initial());

  final EasySupportRepository _repository;

  Future<void> loadMessages({
    required EasySupportConfig config,
    required String chatId,
    int limit = 20,
    String sortOrder = 'desc',
    String sortBy = 'created_at',
  }) async {
    value = EasySupportChatState(
      status: EasySupportChatStatus.loading,
      messages: value.messages,
    );

    try {
      final response = await _repository.fetchCustomerChatMessages(
        config: config,
        chatId: chatId,
        limit: limit,
        sortOrder: sortOrder,
        sortBy: sortBy,
      );
      value = EasySupportChatState(
        status: EasySupportChatStatus.ready,
        messages: response.data,
      );
    } catch (error) {
      value = EasySupportChatState(
        status: EasySupportChatStatus.error,
        messages: value.messages,
        error: error,
      );
    }
  }
}
