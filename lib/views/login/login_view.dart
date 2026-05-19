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
      body: Container(
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.topLeft,
            radius: 1.5,
            colors: [
              colorScheme.primary.withValues(alpha: 0.12),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            behavior: HitTestBehavior.opaque,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // ── Logo and Title area ──
                  const Gap(80),
                  Center(
                    child: Column(
                      children: [
                        // Stylized Camera Icon with deep neon ambient glow
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                colorScheme.primary,
                                colorScheme.secondary,
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: colorScheme.primary.withValues(alpha: 0.35),
                                blurRadius: 20,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt_rounded,
                            color: Colors.white,
                            size: 42,
                          ),
                        )
                        .animate()
                        .scale(
                          begin: const Offset(0.7, 0.7),
                          end: const Offset(1, 1),
                          duration: 600.ms,
                          curve: Curves.elasticOut,
                        )
                        .fadeIn(duration: 400.ms),
                        
                        const Gap(24),
                        
                        // ShaderMask Gradient Text Title
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: [
                              colorScheme.primary,
                              colorScheme.secondary,
                              const Color(0xFFF77737),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ).createShader(bounds),
                          child: Text(
                            Strings.appName,
                            style: theme.textTheme.displaySmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -1.2,
                            ),
                          ),
                        )
                        .animate()
                        .fadeIn(duration: 500.ms, delay: 100.ms)
                        .slideY(begin: 0.2, end: 0, duration: 500.ms, curve: Curves.easeOutQuad),
                      ],
                    ),
                  ),

                  // ── Divider line (very soft, ambient) ──
                  const Gap(32),
                  const DividerWithMargins()
                      .animate()
                      .fadeIn(
                        duration: 400.ms,
                        delay: 150.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  // ── Subtitle text ──
                  const Gap(12),
                  _buildSubtitle(theme, colorScheme)
                      .animate()
                      .fadeIn(
                        duration: 400.ms,
                        delay: 200.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.1,
                        duration: 400.ms,
                        delay: 200.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  // ── Error Banner ──
                  if (hasError) ...[
                    const Gap(20),
                    _buildErrorBanner(context, ref, colorScheme),
                  ],

                  // ── Social Buttons area ──
                  const Gap(40),
                  if (isLoading)
                    _buildLoadingShimmer(colorScheme)
                        .animate()
                        .fadeIn(duration: 300.ms)
                  else
                    _buildButtons(ref, theme, colorScheme)
                        .animate()
                        .fadeIn(
                          duration: 400.ms,
                          delay: 250.ms,
                          curve: Curves.easeOutCubic,
                        )
                        .slideY(
                          begin: 0.12,
                          duration: 400.ms,
                          delay: 250.ms,
                          curve: Curves.easeOutCubic,
                        ),

                  // ── Sign Up link ──
                  const Gap(48),
                  const LoginViewSignUpLink()
                      .animate()
                      .fadeIn(
                        duration: 400.ms,
                        delay: 300.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .slideY(
                        begin: 0.1,
                        duration: 400.ms,
                        delay: 300.ms,
                        curve: Curves.easeOutCubic,
                      ),

                  const Gap(40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Subtitle
  // ─────────────────────────────────────────────────────────────
  Widget _buildSubtitle(ThemeData theme, ColorScheme colorScheme) {
    return Text(
      Strings.logIntoYourAcccount,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: colorScheme.onSurface.withValues(alpha: 0.5),
        fontSize: 14.5,
        height: 1.5,
      ),
      textAlign: TextAlign.center,
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Error Banner
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
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline_rounded, color: colorScheme.onErrorContainer),
          const Gap(12),
          Expanded(
            child: Text(
              'Sign in failed. Please try again.',
              style: TextStyle(
                color: colorScheme.onErrorContainer,
                fontWeight: FontWeight.w500,
              ),
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
        // Facebook Button (Solid Premium Brand Blue)
        ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(authStateProvider.notifier).logInWithFacebook();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1877F2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: const Color(0xFF1877F2).withValues(alpha: 0.35),
          ),
          child: const FacebookButton(),
        ),
        const Gap(16),
        // Google Button (Solid Premium White)
        ElevatedButton(
          onPressed: () {
            HapticFeedback.mediumImpact();
            ref.read(authStateProvider.notifier).logInWithGoogle();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: const Color(0xFF1F1F1F),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 8,
            shadowColor: Colors.black.withValues(alpha: 0.15),
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
