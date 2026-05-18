import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/auth_state_provider.dart';
import 'package:instagram_clone_qthanh/state/image_upload/helpers/image_picker_helper.dart';
import 'package:instagram_clone_qthanh/state/image_upload/models/file_type.dart';
import 'package:instagram_clone_qthanh/state/post_settings/providers/post_settings_provider.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/alert_dialog_model.dart';
import 'package:instagram_clone_qthanh/views/components/dialogs/logout_dialog.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';
import 'package:instagram_clone_qthanh/views/create_new_post/create_new_post_view.dart';
import 'package:instagram_clone_qthanh/views/tabs/home/home_view.dart';
import 'package:instagram_clone_qthanh/views/tabs/search/search_view.dart';
import 'package:instagram_clone_qthanh/views/tabs/users_posts/user_posts_view.dart';

// ─────────────────────────────────────────────────────────────
// Riverpod provider to persist active tab index across rebuilds.
// Default: Tab 0 = Profile (matches legacy top TabBar order)
// ─────────────────────────────────────────────────────────────
final _activeTabProvider = StateProvider<int>((_) => 0);

// ─────────────────────────────────────────────────────────────
// KeepAliveWrapper – ensures child views stay alive in
// IndexedStack without modifying the child widgets themselves.
// ─────────────────────────────────────────────────────────────
class _KeepAliveWrapper extends StatefulWidget {
  final Widget child;
  const _KeepAliveWrapper({required this.child});

  @override
  State<_KeepAliveWrapper> createState() => _KeepAliveWrapperState();
}

class _KeepAliveWrapperState extends State<_KeepAliveWrapper>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

// ─────────────────────────────────────────────────────────────
// MainView – Material 3 navigation hub
//
// Tab order (SACRED – matches original top TabBar):
//   Index 0 → UserPostsView  (Profile / Person)
//   Index 1 → SearchView     (Search)
//   Index 2 → HomeView       (Home / All posts)
// ─────────────────────────────────────────────────────────────
class MainView extends ConsumerStatefulWidget {
  const MainView({super.key});

  @override
  ConsumerState<MainView> createState() => _MainViewState();
}

class _MainViewState extends ConsumerState<MainView>
    with SingleTickerProviderStateMixin {
  // FAB press-scale animation
  late final AnimationController _fabScaleController;
  late final Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      reverseDuration: const Duration(milliseconds: 150),
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _fabScaleController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fabScaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(_activeTabProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      // ── AppBar: Minimal, transparent ──
      appBar: _buildAppBar(theme, colorScheme),

      // ── Body: IndexedStack guarantees zero rebuilds ──
      body: SafeArea(
        child: IndexedStack(
          index: activeTab,
          children: const [
            _KeepAliveWrapper(child: UserPostsView()), // Tab 0: Profile
            _KeepAliveWrapper(child: SearchView()),    // Tab 1: Search
            _KeepAliveWrapper(child: HomeView()),      // Tab 2: Home
          ],
        ),
      ),

      // ── FAB: Content creation (floating above bottom nav) ──
      floatingActionButton: _buildFab(colorScheme),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,

      // ── Bottom Navigation ──
      bottomNavigationBar: _buildBottomNav(colorScheme, activeTab),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // AppBar – Minimal with logout action
  // ─────────────────────────────────────────────────────────────
  PreferredSizeWidget _buildAppBar(ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      title: Text(
        Strings.appName,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: -0.5,
        ),
      )
          .animate()
          .fadeIn(duration: 400.ms, curve: Curves.easeOut)
          .slideX(begin: -0.04, end: 0, duration: 400.ms),
      centerTitle: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: colorScheme.surface,
      surfaceTintColor: Colors.transparent,
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 4),
          child: IconButton(
            tooltip: 'Log out',
            style: IconButton.styleFrom(
              minimumSize: const Size(48, 48),
            ),
            onPressed: () async {
              HapticFeedback.lightImpact();
              final shouldLogOut = await const LogoutDialog()
                  .present(context)
                  .then((value) => value ?? false);
              if (shouldLogOut) {
                await ref.read(authStateProvider.notifier).logOut();
              }
            },
            icon: Icon(
              Icons.logout_rounded,
              color: colorScheme.onSurfaceVariant,
              size: 22,
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Bottom Navigation Bar (Material 3)
  //
  // Order: Profile (0) → Search (1) → Home (2)
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav(ColorScheme colorScheme, int activeTab) {
    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: colorScheme.outlineVariant.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
      ),
      child: NavigationBar(
        height: 68,
        elevation: 0,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: colorScheme.primaryContainer.withValues(alpha: 0.7),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        selectedIndex: activeTab,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
        animationDuration: const Duration(milliseconds: 250),
        onDestinationSelected: (index) {
          HapticFeedback.lightImpact();
          ref.read(_activeTabProvider.notifier).state = index;
        },
        destinations: [
          // Index 0 – Profile / User Posts
          NavigationDestination(
            icon: Icon(
              Icons.person_outline_rounded,
              color: colorScheme.onSurfaceVariant,
              semanticLabel: 'Profile tab',
            ),
            selectedIcon: Icon(
              Icons.person_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
            label: 'Profile',
          ),
          // Index 1 – Search
          NavigationDestination(
            icon: Icon(
              Icons.search_outlined,
              color: colorScheme.onSurfaceVariant,
              semanticLabel: 'Search tab',
            ),
            selectedIcon: Icon(
              Icons.search_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
            label: 'Search',
          ),
          // Index 2 – Home / All Posts
          NavigationDestination(
            icon: Icon(
              Icons.home_outlined,
              color: colorScheme.onSurfaceVariant,
              semanticLabel: 'Home tab',
            ),
            selectedIcon: Icon(
              Icons.home_rounded,
              color: colorScheme.onPrimaryContainer,
            ),
            label: 'Home',
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // FAB – Animated scale on press → opens create-post sheet
  // ─────────────────────────────────────────────────────────────
  Widget _buildFab(ColorScheme colorScheme) {
    return GestureDetector(
      onTapDown: (_) => _fabScaleController.forward(),
      onTapUp: (_) {
        _fabScaleController.reverse();
        HapticFeedback.mediumImpact();
        _showCreatePostSheet(colorScheme);
      },
      onTapCancel: () => _fabScaleController.reverse(),
      child: AnimatedBuilder(
        animation: _fabScaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabScaleAnimation.value,
            child: child,
          );
        },
        child: FloatingActionButton.large(
          heroTag: 'createPostFab',
          elevation: 4,
          highlightElevation: 8,
          shape: const CircleBorder(),
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          tooltip: 'Create post',
          onPressed: null, // Handled by GestureDetector
          child: const Icon(Icons.add_rounded, size: 32),
        ),
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0, 0),
          end: const Offset(1, 1),
          duration: 400.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 300.ms);
  }

  // ─────────────────────────────────────────────────────────────
  // Create Post Bottom Sheet
  // ─────────────────────────────────────────────────────────────
  void _showCreatePostSheet(ColorScheme colorScheme) {
    showModalBottomSheet(
      context: context,
      isDismissible: true,
      enableDrag: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: colorScheme.surfaceContainerLow,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Handle bar ──
                Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.onSurfaceVariant.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const Gap(20),
                Text(
                  'Create New Post',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                )
                    .animate()
                    .fadeIn(duration: 250.ms)
                    .slideY(begin: 0.1, end: 0, duration: 250.ms),
                const Gap(24),

                // ── Photo option ──
                _CreatePostOption(
                  icon: Icons.photo_camera_rounded,
                  label: 'Photo',
                  subtitle: 'Choose from gallery',
                  color: colorScheme.primary,
                  colorScheme: colorScheme,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(sheetContext);
                    _pickImageAndNavigate();
                  },
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 50.ms)
                    .slideX(begin: -0.04, end: 0, duration: 300.ms),
                const Gap(12),

                // ── Video option ──
                _CreatePostOption(
                  icon: Icons.videocam_rounded,
                  label: 'Video',
                  subtitle: 'Choose from gallery',
                  color: colorScheme.tertiary,
                  colorScheme: colorScheme,
                  onTap: () {
                    HapticFeedback.selectionClick();
                    Navigator.pop(sheetContext);
                    _pickVideoAndNavigate();
                  },
                )
                    .animate()
                    .fadeIn(duration: 300.ms, delay: 100.ms)
                    .slideX(begin: -0.04, end: 0, duration: 300.ms),
                const Gap(8),
              ],
            ),
          ),
        );
      },
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Image/Video Picker flows (EXACT same logic as original)
  // ─────────────────────────────────────────────────────────────
  Future<void> _pickImageAndNavigate() async {
    final imageFile = await ImagePickerHelper.pickImageFromGallery();
    if (imageFile == null) return;

    // ignore: unused_result
    ref.refresh(postSettingProvider);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNewPostView(
          fileToPost: imageFile,
          fileType: FileType.image,
        ),
      ),
    );
  }

  Future<void> _pickVideoAndNavigate() async {
    final videoFile = await ImagePickerHelper.picKVideoFromGallery();
    if (videoFile == null) return;

    // ignore: unused_result
    ref.refresh(postSettingProvider);

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CreateNewPostView(
          fileToPost: videoFile,
          fileType: FileType.video,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
// Bottom Sheet Option Widget
// ─────────────────────────────────────────────────────────────
class _CreatePostOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final ColorScheme colorScheme;
  final VoidCallback onTap;

  const _CreatePostOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.colorScheme,
    required this.onTap,
    this.subtitle = '',
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        splashColor: color.withValues(alpha: 0.1),
        highlightColor: color.withValues(alpha: 0.05),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              // Icon container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const Gap(16),

              // Label + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: colorScheme.onSurface,
                          ),
                    ),
                    if (subtitle.isNotEmpty) ...[
                      const Gap(2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: colorScheme.onSurfaceVariant,
                            ),
                      ),
                    ],
                  ],
                ),
              ),

              // Chevron
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHigh.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
