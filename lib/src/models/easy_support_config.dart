import 'dart:convert';

class EasySupportConfig {
  const EasySupportConfig({
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

  factory EasySupportConfig.fromJson(Map<String, dynamic> json) {
    final headers = _parseHeaders(json['additional_headers']);
    final baseUrl = json['base_url'] as String? ?? json['baseUrl'] as String?;
    final channelToken =
        json['channel_token'] as String? ?? json['channelToken'] as String?;
    if (baseUrl == null || baseUrl.trim().isEmpty) {
      throw ArgumentError.value(json, 'json', 'base_url is required');
    }
    if (channelToken == null || channelToken.trim().isEmpty) {
      throw ArgumentError.value(json, 'json', 'channel_token is required');
    }

    return EasySupportConfig(
      baseUrl: baseUrl,
      channelToken: channelToken,
      apiBaseUrl:
          json['api_base_url'] as String? ?? json['apiBaseUrl'] as String?,
      channelKey: json['channelkey'] as String? ??
          json['channel_key'] as String? ??
          json['channelKey'] as String?,
      widgetTitle:
          json['widget_title'] as String? ?? json['widgetTitle'] as String?,
      autoOpen: json['auto_open'] as bool? ?? json['autoOpen'] as bool? ?? true,
      isEmojiEnabled: json['is_emoji_enabled'] as bool? ??
          json['isEmojiEnabled'] as bool? ??
          true,
      isMediaEnabled: json['is_media_enabled'] as bool? ??
          json['isMediaEnabled'] as bool? ??
          true,
      additionalHeaders: headers,
    );
  }

  final String baseUrl;
  final String channelToken;
  final String? apiBaseUrl;
  final String? channelKey;
  final String? widgetTitle;
  final bool autoOpen;
  final bool isEmojiEnabled;
  final bool isMediaEnabled;
  final Map<String, String> additionalHeaders;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'base_url': baseUrl,
      'channel_token': channelToken,
      if (apiBaseUrl != null) 'api_base_url': apiBaseUrl,
      if (channelKey != null) 'channelkey': channelKey,
      if (widgetTitle != null) 'widget_title': widgetTitle,
      'auto_open': autoOpen,
      'is_emoji_enabled': isEmojiEnabled,
      'is_media_enabled': isMediaEnabled,
      if (additionalHeaders.isNotEmpty) 'additional_headers': additionalHeaders,
    };
  }

  String get normalizedBaseUrl => '${_stripTrailingSlashes(baseUrl)}/';

  String get normalizedApiBaseUrl {
    final value = apiBaseUrl;
    if (value == null || value.trim().isEmpty) {
      return '${_stripTrailingSlashes(baseUrl)}/api/v1';
    }
    return _stripTrailingSlashes(value);
  }

  Map<String, String> get resolvedHeaders {
    final headers = _sanitizeHeaders(additionalHeaders);
    headers['channelkey'] = channelToken;
    return headers;
  }

  static Map<String, String> _sanitizeHeaders(Map<String, String> headers) {
    final sanitized = Map<String, String>.from(headers);
    sanitized.remove('channelkey');
    sanitized.remove('channelKey');
    sanitized.remove('channel-key');
    sanitized.remove('channel_key');
    return sanitized;
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
      if (resolvedHeaders.isNotEmpty) 'additionalHeaders': resolvedHeaders,
    };
  }

  String toJavaScriptOptionsJson() => jsonEncode(toJavaScriptOptions());

  EasySupportConfig copyWith({
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

  static Map<String, String> _parseHeaders(dynamic value) {
    if (value is Map<String, String>) {
      return value;
    }
    if (value is Map) {
      final headers = <String, String>{};
      value.forEach((key, dynamic headerValue) {
        if (headerValue != null) {
          headers['$key'] = '$headerValue';
        }
      });
      return headers;
    }
    return const <String, String>{};
  }
}
