import 'easy_support_config.dart';

class EasySupportChannelKeyResponse {
  const EasySupportChannelKeyResponse({
    required this.success,
    this.data,
  });

  factory EasySupportChannelKeyResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    return EasySupportChannelKeyResponse(
      success: json['success'] == true,
      data: data is Map<String, dynamic>
          ? EasySupportChannelConfiguration.fromJson(data)
          : data is Map
              ? EasySupportChannelConfiguration.fromJson(
                  Map<String, dynamic>.from(data),
                )
              : null,
    );
  }

  final bool success;
  final EasySupportChannelConfiguration? data;
}

class EasySupportChannelConfiguration {
  const EasySupportChannelConfiguration({
    this.id,
    this.name,
    this.details,
    this.welcomeHeading,
    this.welcomeTagline,
    this.isGreetingEnabled,
    this.greetingMessage,
    this.widgetColor,
    this.widgetPosition,
    this.isFormEnabled,
    this.isEmojiEnabled,
    this.isMediaEnabled,
    this.isFeedbackEnabled,
    this.feedbackMessage,
    this.feedbackDisplayType,
    this.websiteToken,
    this.script,
    this.type,
    this.domain,
    this.token,
    this.workspaceId,
    this.createdAt,
    this.updatedAt,
    this.chatForm,
  });

  factory EasySupportChannelConfiguration.fromJson(Map<String, dynamic> json) {
    return EasySupportChannelConfiguration(
      id: json['id'] as String?,
      name: json['name'] as String?,
      details: json['details'] as String?,
      welcomeHeading: json['welcome_heading'] as String?,
      welcomeTagline: json['welcome_tagline'] as String?,
      isGreetingEnabled: json['is_greeting_enabled'] as bool?,
      greetingMessage: json['greeting_message'] as String?,
      widgetColor: json['widget_color'] as String?,
      widgetPosition: json['widget_position'] as String?,
      isFormEnabled: json['is_form_enabled'] as bool?,
      isEmojiEnabled: json['is_emoji_enabled'] as bool?,
      isMediaEnabled: json['is_media_enabled'] as bool?,
      isFeedbackEnabled: json['is_feedback_enabled'] as bool?,
      feedbackMessage: json['feedback_message'] as String?,
      feedbackDisplayType: json['feedback_display_type'] as String?,
      websiteToken: json['website_token'] as String?,
      script: json['script'] as String?,
      type: json['type'] as String?,
      domain: json['domain'] as String?,
      token: json['token'] as String?,
      workspaceId: json['workspace_id'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
      chatForm: json['chat_form'],
    );
  }

  final String? id;
  final String? name;
  final String? details;
  final String? welcomeHeading;
  final String? welcomeTagline;
  final bool? isGreetingEnabled;
  final String? greetingMessage;
  final String? widgetColor;
  final String? widgetPosition;
  final bool? isFormEnabled;
  final bool? isEmojiEnabled;
  final bool? isMediaEnabled;
  final bool? isFeedbackEnabled;
  final String? feedbackMessage;
  final String? feedbackDisplayType;
  final String? websiteToken;
  final String? script;
  final String? type;
  final String? domain;
  final String? token;
  final String? workspaceId;
  final String? createdAt;
  final String? updatedAt;
  final dynamic chatForm;
}

extension EasySupportConfigRuntimeMerge on EasySupportConfig {
  EasySupportConfig mergeWithChannelConfiguration(
    EasySupportChannelConfiguration channelConfiguration,
  ) {
    return copyWith(
      widgetTitle: channelConfiguration.welcomeHeading ?? widgetTitle,
      isEmojiEnabled: channelConfiguration.isEmojiEnabled ?? isEmojiEnabled,
      isMediaEnabled: channelConfiguration.isMediaEnabled ?? isMediaEnabled,
    );
  }
}
