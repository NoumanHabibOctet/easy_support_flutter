import 'package:easy_support_flutter/easy_support_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = EasySupportConfig(
    sdkBaseUrl: 'https://widget.example.com',
    baseUrl: 'https://api.example.com',
    channelToken: 'api_test_123',
  );

  test('controller moves to ready when repository GET succeeds', () async {
    final controller = EasySupportController(
      repository: _FakeSuccessRepository(),
    );

    expect(controller.value.status, EasySupportInitStatus.initial);
    await controller.initialize(config);
    expect(controller.value.status, EasySupportInitStatus.ready);
  });

  test('controller moves to error when repository GET fails', () async {
    final controller = EasySupportController(
      repository: _FakeFailureRepository(),
    );

    expect(controller.value.status, EasySupportInitStatus.initial);
    await expectLater(controller.initialize(config), throwsException);
    expect(controller.value.status, EasySupportInitStatus.error);
  });
}

class _FakeSuccessRepository implements EasySupportRepository {
  @override
  Future<void> fetchChannelKey(EasySupportConfig config) async {}
}

class _FakeFailureRepository implements EasySupportRepository {
  @override
  Future<void> fetchChannelKey(EasySupportConfig config) async {
    throw const EasySupportApiException(
      message: 'GET failed',
      statusCode: 500,
    );
  }
}
