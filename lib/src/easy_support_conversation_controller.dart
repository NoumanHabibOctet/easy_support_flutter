import 'easy_support_customer_local_storage.dart';
import 'easy_support_repository.dart';
import 'models/easy_support_config.dart';
import 'models/easy_support_customer_action.dart';
import 'models/easy_support_customer_session.dart';
import 'models/easy_support_customer_submission.dart';

class EasySupportConversationController {
  EasySupportConversationController({
    required EasySupportRepository repository,
    required EasySupportCustomerLocalStorage localStorage,
  })  : _repository = repository,
        _localStorage = localStorage;

  final EasySupportRepository _repository;
  final EasySupportCustomerLocalStorage _localStorage;

  Future<EasySupportCustomerSession> loadSession() {
    return _localStorage.readSession();
  }

  Future<EasySupportCustomerSession> startConversation({
    required EasySupportConfig config,
    required EasySupportCustomerSubmission submission,
  }) async {
    final action = submission.hasCustomerId
        ? EasySupportCustomerAction.update
        : EasySupportCustomerAction.create;
    final requestBody = submission.toRequestBody(action: action);
    final response = await _repository.postCustomer(
      config: config,
      action: action,
      body: requestBody,
    );

    final resolvedCustomerId = response.customerId ?? submission.customerId;
    if (resolvedCustomerId == null || resolvedCustomerId.trim().isEmpty) {
      throw const EasySupportApiException(
        message: 'Customer API response is missing customer_id',
        statusCode: -1,
      );
    }
    final session = EasySupportCustomerSession(
      customerId: resolvedCustomerId,
      chatId: response.chatId,
    );

    await _localStorage.writeSession(session);
    return session;
  }
}
