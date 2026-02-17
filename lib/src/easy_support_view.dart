import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'models/easy_support_channel_configuration.dart';
import 'models/easy_support_config.dart';
import 'widgets/easy_support_action_bar.dart';
import 'widgets/easy_support_color_utils.dart';
import 'widgets/easy_support_form_card.dart';
import 'widgets/easy_support_header.dart';
import 'widgets/easy_support_hero_section.dart';
import 'widgets/easy_support_input_field.dart';
import 'widgets/easy_support_message_card.dart';

typedef EasySupportErrorCallback = void Function(WebResourceError error);

class EasySupportView extends StatefulWidget {
  const EasySupportView({
    super.key,
    required this.config,
    this.channelConfiguration,
    this.isFullScreen = false,
    this.onError,
  });

  final EasySupportConfig config;
  final EasySupportChannelConfiguration? channelConfiguration;
  final bool isFullScreen;
  final EasySupportErrorCallback? onError;

  @override
  State<EasySupportView> createState() => _EasySupportViewState();
}

class _EasySupportViewState extends State<EasySupportView> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final channel = widget.channelConfiguration;
    final primaryColor = EasySupportColorUtils.parseHexColor(
      channel?.widgetColor,
      fallback: const Color(0xFFF50A0A),
    );
    final onPrimaryColor = EasySupportColorUtils.onColor(primaryColor);
    final actionButtonColor =
        EasySupportColorUtils.blend(primaryColor, Colors.white, 0.12);

    final title = channel?.name ?? 'Support';
    final heading = channel?.welcomeHeading ??
        widget.config.widgetTitle ??
        'Hi there ! How can we help you';
    final tagline = channel?.welcomeTagline ??
        channel?.details ??
        'We make it simple to connect with us.';
    final greetingMessage =
        channel?.isGreetingEnabled == true ? channel?.greetingMessage : null;
    final form = channel?.chatForm;
    final showForm = channel?.hasActiveForm == true && form != null;
    final showFeedback = channel?.isFeedbackEnabled == true &&
        (channel?.feedbackMessage?.trim().isNotEmpty ?? false);

    final content = DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF7F8FC),
            Color(0xFFF2F4F8),
          ],
        ),
      ),
      child: Column(
        children: [
          EasySupportHeader(
            title: title,
            primaryColor: primaryColor,
            onPrimaryColor: onPrimaryColor,
            isFullScreen: widget.isFullScreen,
            onClose: () => Navigator.of(context).maybePop(),
          ),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
              child: Column(
                children: [
                  EasySupportHeroSection(
                    heading: heading,
                    tagline: tagline,
                    primaryColor: primaryColor,
                  ),
                  if (greetingMessage != null &&
                      greetingMessage.trim().isNotEmpty) ...[
                    const SizedBox(height: 18),
                    EasySupportMessageCard(
                      message: greetingMessage,
                      primaryColor: primaryColor,
                    ),
                  ],
                  if (showForm) ...[
                    const SizedBox(height: 18),
                    _buildFormCard(
                      form: form,
                      primaryColor: primaryColor,
                    ),
                  ],
                  if (showFeedback) ...[
                    const SizedBox(height: 14),
                    _buildFeedbackPill(
                      channel!.feedbackMessage!,
                      primaryColor: primaryColor,
                    ),
                  ],
                ],
              ),
            ),
          ),
          EasySupportActionBar(
            onPressed: () => _onStartConversationPressed(showForm: showForm),
            label: 'Start Conversation',
            actionColor: actionButtonColor,
            onActionColor: EasySupportColorUtils.onColor(actionButtonColor),
            bottomPadding: MediaQuery.of(context).padding.bottom,
          ),
        ],
      ),
    );

    if (widget.isFullScreen) {
      return content;
    }

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: content,
    );
  }

  Widget _buildFeedbackPill(String message, {required Color primaryColor}) {
    final starColor =
        EasySupportColorUtils.blend(primaryColor, Colors.white, 0.2);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(Icons.star_rounded, color: starColor, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF4B5563),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard({
    required EasySupportChatFormConfiguration form,
    required Color primaryColor,
  }) {
    final fields = <Widget>[
      if (form.isEmailEnabled == true)
        EasySupportInputField(
          controller: _emailController,
          label: form.emailFieldLabel ?? 'Email',
          placeholder: form.emailFieldPlaceholder ?? 'emailAddress',
          requiredField: form.isEmailRequired == true,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final text = value?.trim() ?? '';
            final label = form.emailFieldLabel ?? 'Email';
            if (form.isEmailRequired == true && text.isEmpty) {
              return '$label is required';
            }
            if (text.isNotEmpty && !_isValidEmail(text)) {
              return 'Enter a valid email';
            }
            return null;
          },
          primaryColor: primaryColor,
        ),
      if (form.isNameEnabled == true)
        EasySupportInputField(
          controller: _nameController,
          label: form.nameFieldLabel ?? 'Name',
          placeholder: form.nameFieldPlaceholder ?? 'fullName',
          requiredField: form.isNameRequired == true,
          keyboardType: TextInputType.name,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (form.isNameRequired == true && text.isEmpty) {
              return '${form.nameFieldLabel ?? 'Name'} is required';
            }
            return null;
          },
          primaryColor: primaryColor,
        ),
      if (form.isPhoneEnabled == true)
        EasySupportInputField(
          controller: _phoneController,
          label: form.phoneFieldLabel ?? 'Phone Number',
          placeholder: form.phoneFieldPlaceholder ?? 'phoneNumber',
          requiredField: form.isPhoneRequired == true,
          keyboardType: TextInputType.phone,
          validator: (value) {
            final text = value?.trim() ?? '';
            final label = form.phoneFieldLabel ?? 'Phone Number';
            if (form.isPhoneRequired == true && text.isEmpty) {
              return '$label is required';
            }
            if (text.isNotEmpty && !_isLikelyPhone(text)) {
              return 'Enter a valid phone number';
            }
            return null;
          },
          primaryColor: primaryColor,
        ),
    ];

    return Form(
      key: _formKey,
      child: EasySupportFormCard(
        primaryColor: primaryColor,
        title: form.formMessage,
        children: fields,
      ),
    );
  }

  void _onStartConversationPressed({required bool showForm}) {
    if (showForm) {
      final valid = _formKey.currentState?.validate() ?? false;
      if (!valid) {
        return;
      }
    }
    Navigator.of(context).maybePop();
  }

  static bool _isValidEmail(String email) {
    final emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return emailPattern.hasMatch(email);
  }

  static bool _isLikelyPhone(String phone) {
    final numeric = phone.replaceAll(RegExp(r'[^0-9]'), '');
    return numeric.length >= 7;
  }
}
