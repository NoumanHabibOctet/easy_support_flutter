import 'package:easy_support_flutter/easy_support_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = EasySupportConfig(
    baseUrl: 'http://192.168.18.21:3000',
    channelToken: 'api_test_123',
  );

  test('create sends empty body when customer id is not available', () async {
    final repository = _FakeConversationRepository(
      response: const EasySupportCustomerResponse(
        success: true,
        customerId: 'customer_1',
        chatId: 'chat_1',
      ),
    );
    final storage = _FakeCustomerStorage();
    final controller = EasySupportConversationController(
      repository: repository,
      localStorage: storage,
    );

    final session = await controller.startConversation(
      config: config,
      submission: const EasySupportCustomerSubmission(),
    );

    expect(repository.capturedAction, EasySupportCustomerAction.create);
    expect(repository.capturedBody, isEmpty);
    expect(session.customerId, 'customer_1');
    expect(session.chatId, 'chat_1');
    expect(storage.writtenSession?.customerId, 'customer_1');
  });

  test('update sends customer_id and filled fields', () async {
    final repository = _FakeConversationRepository(
      response: const EasySupportCustomerResponse(
        success: true,
        customerId: 'customer_1',
      ),
    );
    final storage = _FakeCustomerStorage();
    final controller = EasySupportConversationController(
      repository: repository,
      localStorage: storage,
    );

    await controller.startConversation(
      config: config,
      submission: const EasySupportCustomerSubmission(
        customerId: 'customer_1',
        name: 'John Doe',
        email: 'john@example.com',
      ),
    );

    expect(repository.capturedAction, EasySupportCustomerAction.update);
    expect(repository.capturedBody['customer_id'], 'customer_1');
    expect(repository.capturedBody['name'], 'John Doe');
    expect(repository.capturedBody['email'], 'john@example.com');
    expect(repository.capturedBody.containsKey('phone'), false);
  });
}

class _FakeConversationRepository implements EasySupportRepository {
  _FakeConversationRepository({
    required EasySupportCustomerResponse response,
  }) : _response = response;

  final EasySupportCustomerResponse _response;
  EasySupportCustomerAction? capturedAction;
  Map<String, dynamic> capturedBody = <String, dynamic>{};

  @override
  Future<EasySupportChannelConfiguration> fetchChannelKey(
    EasySupportConfig config,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<EasySupportCustomerResponse> postCustomer({
    required EasySupportConfig config,
    required EasySupportCustomerAction action,
    required Map<String, dynamic> body,
  }) async {
    capturedAction = action;
    capturedBody = body;
    return _response;
  }
}

class _FakeCustomerStorage implements EasySupportCustomerLocalStorage {
  EasySupportCustomerSession session = const EasySupportCustomerSession();
  EasySupportCustomerSession? writtenSession;

  @override
  Future<EasySupportCustomerSession> readSession() async {
    return session;
  }

  @override
  Future<void> writeSession(EasySupportCustomerSession session) async {
    writtenSession = session;
    this.session = session;
  }
}
