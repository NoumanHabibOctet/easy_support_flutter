import 'package:easy_support_flutter/easy_support_flutter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('normalizes baseUrl and apiBaseUrl', () {
    const config = EasySupportConfig(
      baseUrl: 'https://api.example.com///',
      channelToken: 'api_test_123',
    );

    expect(config.normalizedBaseUrl, 'https://api.example.com/');
    expect(config.normalizedApiBaseUrl, 'https://api.example.com/api/v1');
  });

  test('creates js options with required values', () {
    const config = EasySupportConfig(
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
    expect(options['additionalHeaders'], <String, String>{
      'channel_key': 'api_test_123',
    });
  });

  test('always injects channel_key header from channelToken', () {
    const config = EasySupportConfig(
      baseUrl: 'https://api.example.com',
      channelToken: 'api_test_123',
      additionalHeaders: <String, String>{
        'authorization': 'Bearer token',
        'channel_key': 'wrong_value',
      },
    );

    expect(config.resolvedHeaders, <String, String>{
      'authorization': 'Bearer token',
      'channel_key': 'api_test_123',
    });
  });

  test('uses explicit apiBaseUrl when provided', () {
    const config = EasySupportConfig(
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

  test('parses channel response and merges returned configuration', () {
    final response = EasySupportChannelKeyResponse.fromJson(<String, dynamic>{
      'success': true,
      'data': <String, dynamic>{
        'name': "Noman's Channel",
        'welcome_heading': 'Hi there ! How can we help you ',
        'is_emoji_enabled': false,
        'is_media_enabled': false,
        'token': 'api_nat1ht02fmlq45lps',
        'is_form_enabled': true,
        'chat_form': <String, dynamic>{
          'id': '1bb2b3b5-7f63-46ab-9b8a-f9755d52cf33',
          'form_message': 'testing',
          'is_active': true,
          'is_email_enabled': true,
          'is_email_required': true,
          'email_field_label': 'Email Id',
          'email_field_placeholder': 'emailAddress',
          'is_phone_enabled': true,
          'is_phone_required': true,
          'phone_field_label': 'Phone number',
          'phone_field_placeholder': 'phoneNumber',
          'is_name_enabled': true,
          'is_name_required': true,
          'name_field_label': 'Full name',
          'name_field_placeholder': 'fullName',
        },
      },
    });

    const inputConfig = EasySupportConfig(
      baseUrl: 'https://api.example.com',
      channelToken: 'api_nat1ht02fmlq45lps',
      widgetTitle: 'Default title',
      isEmojiEnabled: true,
      isMediaEnabled: true,
    );

    final mergedConfig = inputConfig.mergeWithChannelConfiguration(
      response.data!,
    );

    expect(response.success, true);
    expect(response.data?.name, "Noman's Channel");
    expect(response.data?.token, 'api_nat1ht02fmlq45lps');
    expect(response.data?.chatForm?.isEmailRequired, true);
    expect(response.data?.chatForm?.emailFieldLabel, 'Email Id');
    expect(response.data?.hasActiveForm, true);
    expect(mergedConfig.widgetTitle, 'Hi there ! How can we help you ');
    expect(mergedConfig.isEmojiEnabled, false);
    expect(mergedConfig.isMediaEnabled, false);
  });
}
