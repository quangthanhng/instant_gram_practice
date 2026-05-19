import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';
import 'package:gap/gap.dart';

class GoogleButton extends StatelessWidget {
  const GoogleButton({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(
            FontAwesomeIcons.google,
            color: Color(0xFF4285F4),
            size: 22,
          ),
          const Gap(12),
          Text(
            Strings.google.trim(),
            style: const TextStyle(
              color: Color(0xFF1F1F1F),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
