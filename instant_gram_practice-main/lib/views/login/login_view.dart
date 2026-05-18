import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import 'package:instagram_clone_qthanh/state/auth/models/auth_result.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/auth_state_provider.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/login/divider_with_margins.dart';
import 'package:instagram_clone_qthanh/views/login/facebook_button.dart';
import 'package:instagram_clone_qthanh/views/login/google_button.dart';
import 'package:instagram_clone_qthanh/views/login/login_view_sign_up_link.dart';

class LoginView extends ConsumerWidget {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isLoading = authState.isLoading;
    final hasError = authState.result == AuthResult.failure;

    return Scaffold(
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Title ──
                const Gap(60),
                _buildTitle(theme, colorScheme)
                    .animate()
                    .fadeIn(duration: 400.ms, curve: Curves.easeOutCubic)
                    .slideY(
                      begin: 0.15,
                      duration: 400.ms,
                      curve: Curves.easeOutCubic,
                    ),

                // ── Divider ──
                const Gap(16),
                const DividerWithMargins()
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: 80.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .slideY(
                      begin: 0.15,
                      duration: 400.ms,
                      delay: 80.ms,
                      curve: Curves.easeOutCubic,
                    ),

                // ── Subtitle ──
                const Gap(16),
                _buildSubtitle(theme, colorScheme)
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: 160.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .slideY(
                      begin: 0.15,
                      duration: 400.ms,
                      delay: 160.ms,
                      curve: Curves.easeOutCubic,
                    ),

                // ── Error Banner ──
                if (hasError) ...[
                  const Gap(16),
                  _buildErrorBanner(context, ref, colorScheme),
                ],

                // ── Buttons Area ──
                const Gap(32),
                if (isLoading)
                  _buildLoadingShimmer(colorScheme)
                      .animate()
                      .fadeIn(duration: 300.ms)
                else
                  _buildButtons(ref, theme, colorScheme)
                      .animate()
                      .fadeIn(
                        duration: 400.ms,
                        delay: 240.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.15,
                        duration: 400.ms,
                        delay: 240.ms,
                        curve: Curves.easeOutCubic,
                      ),

                // ── Sign Up Link ──
                const Gap(40),
                const LoginViewSignUpLink()
                    .animate()
                    .fadeIn(
                      duration: 400.ms,
                      delay: 320.ms,
                      curve: Curves.easeOutCubic,
                    )
                    .slideY(
                      begin: 0.15,
                      duration: 400.ms,
                      delay: 320.ms,
                      curve: Curves.easeOutCubic,
                    ),

                const Gap(40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Title
  // ─────────────────────────────────────────────────────────────
  Widget _buildTitle(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      Strings.welcomeToAppName,
      style: theme.textTheme.headlineMedium?.copyWith(
        color: colorScheme.onSurface,
        fontWeight: FontWeight.bold,
      ),
      textAlign: TextAlign.center,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Subtitle
  // ─────────────────────────────────────────────────────────────
  Widget _buildSubtitle(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      Strings.logIntoYourAcccount,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.7),
        height: 1.4,
      ),
      textAlign: TextAlign.center,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Error Banner (replaces full-screen Lottie error)
  // ─────────────────────────────────────────────────────────────
  Widget _buildErrorBanner(
    BuildContext context,
    WidgetRef ref,
    ColorScheme colorScheme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: colorScheme.onErrorContainer),
          const Gap(12),
          Expanded(
            child: Text(
              'Sign in failed. Please try again.',
              style: TextStyle(color: colorScheme.onErrorContainer),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 300.ms)
        .shakeX(hz: 3, amount: 4, duration: 400.ms);
  }

  // ─────────────────────────────────────────────────────────────
  // Social Buttons (Facebook + Google)
  // ─────────────────────────────────────────────────────────────
  Widget _buildButtons(
    WidgetRef ref,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Facebook Button
        ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            ref.read(authStateProvider.notifier).logInWithFacebook();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const FacebookButton(),
        ),
        const Gap(16),
        // Google Button
        ElevatedButton(
          onPressed: () {
            HapticFeedback.lightImpact();
            ref.read(authStateProvider.notifier).logInWithGoogle();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: colorScheme.surfaceContainerHighest,
            foregroundColor: colorScheme.onSurface,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          child: const GoogleButton(),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Loading Shimmer (inline, covers only button area)
  // ─────────────────────────────────────────────────────────────
  Widget _buildLoadingShimmer(ColorScheme colorScheme) {
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest,
      highlightColor: colorScheme.surfaceContainerLow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          const Gap(16),
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ],
      ),
    );
  }
}
