import 'package:flutter/material.dart';

import 'easy_support_color_utils.dart';

class EasySupportHeroSection extends StatelessWidget {
  const EasySupportHeroSection({
    super.key,
    required this.heading,
    required this.tagline,
    required this.primaryColor,
  });

  final String heading;
  final String tagline;
  final Color primaryColor;

  @override
  Widget build(BuildContext context) {
    final iconBorderColor =
        EasySupportColorUtils.blend(primaryColor, Colors.white, 0.82);

    return Column(
      children: [
        Container(
          width: 122,
          height: 122,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(color: iconBorderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: const Icon(
            Icons.chat_bubble_outline_rounded,
            size: 62,
            color: Color(0xFF111827),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          heading,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 19,
            height: 1.25,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          tagline,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 15,
            height: 1.5,
            color: Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
