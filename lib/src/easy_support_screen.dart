import 'package:flutter/material.dart';

import 'easy_support_view.dart';
import 'models/easy_support_channel_configuration.dart';
import 'models/easy_support_config.dart';

class EasySupportScreen extends StatelessWidget {
  const EasySupportScreen({
    super.key,
    required this.config,
    this.channelConfiguration,
    this.useSafeArea = true,
    this.onError,
  });

  final EasySupportConfig config;
  final EasySupportChannelConfiguration? channelConfiguration;
  final bool useSafeArea;
  final EasySupportErrorCallback? onError;

  @override
  Widget build(BuildContext context) {
    final content = EasySupportView(
      config: config,
      channelConfiguration: channelConfiguration,
      isFullScreen: true,
      onError: onError,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF2F3F5),
      body: useSafeArea ? SafeArea(child: content) : content,
    );
  }
}
