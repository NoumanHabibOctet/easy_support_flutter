import 'dart:convert';

class EasySupportConfig {
  const EasySupportConfig({
    required this.sdkBaseUrl,
    required this.baseUrl,
    required this.channelToken,
    this.apiBaseUrl,
    this.channelKey,
    this.widgetTitle,
    this.autoOpen = true,
    this.isEmojiEnabled = true,
    this.isMediaEnabled = true,
    this.additionalHeaders = const <String, String>{},
  }) : assert(channelToken != '', 'channelToken cannot be empty.');

  final String sdkBaseUrl;
  final String baseUrl;
  final String channelToken;
  final String? apiBaseUrl;
  final String? channelKey;
  final String? widgetTitle;
  final bool autoOpen;
  final bool isEmojiEnabled;
  final bool isMediaEnabled;
  final Map<String, String> additionalHeaders;

  String get sdkScriptUrl =>
      '${_stripTrailingSlashes(sdkBaseUrl)}/widget/sdk.js';

  String get normalizedBaseUrl => '${_stripTrailingSlashes(baseUrl)}/';

  String get normalizedApiBaseUrl {
    final value = apiBaseUrl;
    if (value == null || value.trim().isEmpty) {
      return '${_stripTrailingSlashes(baseUrl)}/api/v1';
    }
    return _stripTrailingSlashes(value);
  }

  Map<String, dynamic> toJavaScriptOptions() {
    return <String, dynamic>{
      'channelToken': channelToken,
      'baseUrl': normalizedBaseUrl,
      'apiBaseUrl': normalizedApiBaseUrl,
      'autoOpen': autoOpen,
      'isEmojiEnabled': isEmojiEnabled,
      'isMediaEnabled': isMediaEnabled,
      if (channelKey != null && channelKey!.trim().isNotEmpty)
        'channelKey': channelKey!.trim(),
      if (widgetTitle != null && widgetTitle!.trim().isNotEmpty)
        'widgetTitle': widgetTitle!.trim(),
      if (additionalHeaders.isNotEmpty) 'additionalHeaders': additionalHeaders,
    };
  }

  String toJavaScriptOptionsJson() => jsonEncode(toJavaScriptOptions());

  EasySupportConfig copyWith({
    String? sdkBaseUrl,
    String? baseUrl,
    String? channelToken,
    String? apiBaseUrl,
    String? channelKey,
    String? widgetTitle,
    bool? autoOpen,
    bool? isEmojiEnabled,
    bool? isMediaEnabled,
    Map<String, String>? additionalHeaders,
  }) {
    return EasySupportConfig(
      sdkBaseUrl: sdkBaseUrl ?? this.sdkBaseUrl,
      baseUrl: baseUrl ?? this.baseUrl,
      channelToken: channelToken ?? this.channelToken,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      channelKey: channelKey ?? this.channelKey,
      widgetTitle: widgetTitle ?? this.widgetTitle,
      autoOpen: autoOpen ?? this.autoOpen,
      isEmojiEnabled: isEmojiEnabled ?? this.isEmojiEnabled,
      isMediaEnabled: isMediaEnabled ?? this.isMediaEnabled,
      additionalHeaders: additionalHeaders ?? this.additionalHeaders,
    );
  }

  static String _stripTrailingSlashes(String value) {
    return value.trim().replaceFirst(RegExp(r'/+$'), '');
  }
}
