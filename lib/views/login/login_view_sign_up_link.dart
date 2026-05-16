import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginViewSignUpLink extends StatelessWidget {
  const LoginViewSignUpLink({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final baseStyle = theme.textTheme.bodyMedium?.copyWith(
      color: colorScheme.onSurface.withValues(alpha: 0.7),
      height: 1.6,
    );
    final linkStyle = baseStyle?.copyWith(
      color: colorScheme.primary,
      fontWeight: FontWeight.w600,
    );

    return Text.rich(
      TextSpan(
        style: baseStyle,
        children: [
          const TextSpan(text: Strings.dontHaveAnAccount),
          const TextSpan(text: Strings.signUpOn),
          TextSpan(
            text: Strings.facebook,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(Strings.facebookSignupUrl));
              },
          ),
          const TextSpan(text: Strings.orCreateAnAccountOn),
          TextSpan(
            text: Strings.google,
            style: linkStyle,
            recognizer: TapGestureRecognizer()
              ..onTap = () {
                launchUrl(Uri.parse(Strings.googleSignupUrl));
              },
          ),
        ],
      ),
      textAlign: TextAlign.center,
    );
  }
}
