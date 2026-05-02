import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/auth_state_provider.dart';
import 'package:instagram_clone_qthanh/views/components/constants/app_colors.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/login/divider_with_margins.dart';
import 'package:instagram_clone_qthanh/views/login/facebook_button.dart';
import 'package:instagram_clone_qthanh/views/login/google_button.dart';
import 'package:instagram_clone_qthanh/views/login/login_view_sign_up_link.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(Strings.appName)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              Text(
                Strings.welcomeToAppName,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const DividerWithMargins(),
              Text(
                Strings.logIntoYourAcccount,
                style: Theme.of(
                  context,
                ).textTheme.titleSmall?.copyWith(height: 1.5),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: ref
                    .read(authStateProvider.notifier)
                    .logInWithFacebook,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.loginButtonColor,
                  foregroundColor: AppColors.loginButtonTextColor,
                ),
                child: const FacebookButton(),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: ref.read(authStateProvider.notifier).logInWithGoogle,
                style: TextButton.styleFrom(
                  backgroundColor: AppColors.loginButtonColor,
                  foregroundColor: AppColors.loginButtonTextColor,
                ),
                child: const GoogleButton(),
              ),
              const DividerWithMargins(),
              const LoginViewSignUpLink(),
            ],
          ),
        ),
      ),
    );
  }
}
