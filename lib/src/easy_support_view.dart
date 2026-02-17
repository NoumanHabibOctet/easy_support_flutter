import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'models/easy_support_channel_configuration.dart';
import 'models/easy_support_config.dart';

typedef EasySupportErrorCallback = void Function(WebResourceError error);

class EasySupportView extends StatefulWidget {
  const EasySupportView({
    super.key,
    required this.config,
    this.channelConfiguration,
    this.onError,
  });

  final EasySupportConfig config;
  final EasySupportChannelConfiguration? channelConfiguration;
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
    final primaryColor = _parseHexColor(
      channel?.widgetColor,
      fallback: const Color(0xFFF50A0A),
    );
    final closeButtonColor = _blend(Colors.white, primaryColor, 0.25);
    final actionButtonColor = _blend(Colors.white, primaryColor, 0.45);
    const screenBackgroundColor = Color(0xFFF2F3F5);
    final title = channel?.name ?? 'Support';
    final heading =
        channel?.welcomeHeading ??
        widget.config.widgetTitle ??
        'Hi there ! How can we help you';
    final tagline =
        channel?.welcomeTagline ??
        channel?.details ??
        'We make it simple to connect with us.';
    final greetingMessage = channel?.isGreetingEnabled == true
        ? channel?.greetingMessage
        : null;
    final form = channel?.chatForm;
    final showForm = channel?.hasActiveForm == true;
    final showFeedback =
        channel?.isFeedbackEnabled == true &&
        (channel?.feedbackMessage?.trim().isNotEmpty ?? false);

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(30)),
      child: Material(
        color: screenBackgroundColor,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: primaryColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(30),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 24, 20, 24),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Material(
                    color: closeButtonColor,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => Navigator.of(context).maybePop(),
                      child: const Padding(
                        padding: EdgeInsets.all(14),
                        child: Icon(Icons.close, color: Colors.white, size: 30),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(28, 18, 28, 20),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    const Text('💬', style: TextStyle(fontSize: 96)),
                    const SizedBox(height: 18),
                    Text(
                      heading,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 27,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tagline,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 18,
                        height: 1.45,
                        color: Color(0xFF6B7280),
                      ),
                    ),
                    if (greetingMessage != null &&
                        greetingMessage.trim().isNotEmpty) ...[
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: const Color(0xFFE5E7EB)),
                        ),
                        child: Text(
                          greetingMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF4B5563),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                    if (showForm && form != null) ...[
                      const SizedBox(height: 24),
                      _buildFormCard(
                        form: form,
                        primaryColor: primaryColor,
                      ),
                    ],
                    if (showFeedback) ...[
                      const SizedBox(height: 16),
                      Text(
                        channel!.feedbackMessage!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF4B5563),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Container(
              color: screenBackgroundColor,
              padding: EdgeInsets.fromLTRB(
                28,
                6,
                28,
                MediaQuery.of(context).padding.bottom + 18,
              ),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () =>
                      _onStartConversationPressed(showForm: showForm),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: actionButtonColor,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor: actionButtonColor,
                    disabledForegroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(56),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(32),
                    ),
                  ),
                  child: const Text(
                    'Start Conversation',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormCard({
    required EasySupportChatFormConfiguration form,
    required Color primaryColor,
  }) {
    final formMessage = form.formMessage;
    final enabledFields = <Widget>[
      if (form.isEmailEnabled == true)
        _buildFormField(
          controller: _emailController,
          label: form.emailFieldLabel ?? 'Email',
          placeholder: form.emailFieldPlaceholder ?? 'emailAddress',
          requiredField: form.isEmailRequired == true,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (form.isEmailRequired == true && text.isEmpty) {
              return '${form.emailFieldLabel ?? 'Email'} is required';
            }
            return null;
          },
          primaryColor: primaryColor,
        ),
      if (form.isNameEnabled == true)
        _buildFormField(
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
        _buildFormField(
          controller: _phoneController,
          label: form.phoneFieldLabel ?? 'Phone Number',
          placeholder: form.phoneFieldPlaceholder ?? 'phoneNumber',
          requiredField: form.isPhoneRequired == true,
          keyboardType: TextInputType.phone,
          validator: (value) {
            final text = value?.trim() ?? '';
            if (form.isPhoneRequired == true && text.isEmpty) {
              return '${form.phoneFieldLabel ?? 'Phone Number'} is required';
            }
            return null;
          },
          primaryColor: primaryColor,
        ),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 20, 22, 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            if (formMessage != null && formMessage.trim().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: Text(
                  formMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ...enabledFields,
          ],
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required String placeholder,
    required bool requiredField,
    required TextInputType keyboardType,
    required String? Function(String?) validator,
    required Color primaryColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4B5563),
              ),
              children: [
                if (requiredField)
                  TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: _blend(Colors.white, primaryColor, 0.1),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            validator: validator,
            decoration: InputDecoration(
              hintText: placeholder,
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 22,
                vertical: 17,
              ),
              hintStyle: const TextStyle(
                color: Color(0xFF9CA3AF),
                fontSize: 17,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: primaryColor),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
              focusedErrorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: Color(0xFFEF4444)),
              ),
            ),
          ),
        ],
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

  static Color _parseHexColor(String? hex, {required Color fallback}) {
    final raw = hex?.trim();
    if (raw == null || raw.isEmpty) {
      return fallback;
    }

    var value = raw.replaceFirst('#', '');
    if (value.length == 3) {
      value = value.split('').map((char) => '$char$char').join();
    }
    if (value.length == 6) {
      value = 'FF$value';
    }
    if (value.length != 8) {
      return fallback;
    }

    final parsed = int.tryParse(value, radix: 16);
    if (parsed == null) {
      return fallback;
    }
    return Color(parsed);
  }

  static Color _blend(Color first, Color second, double amount) {
    return Color.lerp(first, second, amount) ?? second;
  }
}
