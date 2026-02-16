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
    expect(options['autoOpen'], false);
    expect(options['isEmojiEnabled'], false);
    expect(options['isMediaEnabled'], true);
  });
}
