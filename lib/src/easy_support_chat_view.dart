import 'package:flutter/material.dart';

import 'widgets/easy_support_header.dart';

class EasySupportChatView extends StatelessWidget {
  const EasySupportChatView({
    super.key,
    required this.title,
    required this.primaryColor,
    required this.onPrimaryColor,
    required this.isFullScreen,
    required this.onClose,
  });

  final String title;
  final Color primaryColor;
  final Color onPrimaryColor;
  final bool isFullScreen;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
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
            onClose: onClose,
            isFullScreen: isFullScreen,
          ),
          const Expanded(
            child: Center(
              child: Text(
                'Chat Screen',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
