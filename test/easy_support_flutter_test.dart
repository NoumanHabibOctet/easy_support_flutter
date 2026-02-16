import 'package:easy_support_flutter/easy_support_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes URLs for sdk script and baseUrl', () {
    const config = EasySupportConfig(
      sdkBaseUrl: 'https://widget.example.com///',
      baseUrl: 'https://api.example.com',
      channelToken: 'api_test_123',
    );

    expect(config.sdkScriptUrl, 'https://widget.example.com/widget/sdk.js');
    expect(config.normalizedBaseUrl, 'https://api.example.com/');
    expect(config.normalizedApiBaseUrl, 'https://api.example.com/api/v1');
  });

  test('accepts direct sdk script URL', () {
    const config = EasySupportConfig(
      sdkBaseUrl: 'https://widget.example.com/widget/sdk.js',
      baseUrl: 'https://api.example.com',
      channelToken: 'api_test_123',
    );

    expect(config.sdkScriptUrl, 'https://widget.example.com/widget/sdk.js');
  });

  test('creates js options with required values', () {
    const config = EasySupportConfig(
      sdkBaseUrl: 'https://widget.example.com',
      baseUrl: 'https://api.example.com',
      channelToken: 'api_test_123',
      autoOpen: false,
      isEmojiEnabled: false,
    );

    final options = config.toJavaScriptOptions();

    expect(options['channelToken'], 'api_test_123');
    expect(options['baseUrl'], 'https://api.example.com/');
    expect(options['apiBaseUrl'], 'https://api.example.com/api/v1');
    expect(options['autoOpen'], false);
    expect(options['isEmojiEnabled'], false);
    expect(options['isMediaEnabled'], true);
  });

  test('uses explicit apiBaseUrl when provided', () {
    const config = EasySupportConfig(
      sdkBaseUrl: 'https://widget.example.com',
      baseUrl: 'https://socket.example.com',
      apiBaseUrl: 'https://backend.example.com/api/v1/',
      channelToken: 'api_test_123',
    );

    expect(config.normalizedApiBaseUrl, 'https://backend.example.com/api/v1');
    expect(
      config.toJavaScriptOptions()['apiBaseUrl'],
      'https://backend.example.com/api/v1',
    );
  });
}
