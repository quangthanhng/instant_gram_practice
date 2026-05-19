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
import 'package:instagram_clone_qthanh/views/theme/page_transitions.dart';

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

class _MainViewState extends ConsumerState<MainView> {

  @override
  Widget build(BuildContext context) {
    final activeTab = ref.watch(_activeTabProvider);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Resolve index for IndexedStack:
    // Tab 0 -> Home (Child 0)
    // Tab 1 -> Search (Child 1)
    // Tab 3 -> Profile (Child 2)
    int stackIndex = 0;
    if (activeTab == 1) {
      stackIndex = 1;
    } else if (activeTab == 3) {
      stackIndex = 2;
    }

    return Scaffold(
      // ── AppBar: Minimal, transparent ──
      appBar: _buildAppBar(theme, colorScheme),

      // ── Body: IndexedStack guarantees zero rebuilds ──
      body: SafeArea(
        child: IndexedStack(
          index: stackIndex,
          children: const [
            _KeepAliveWrapper(child: HomeView()),      // Child 0: Home Feed
            _KeepAliveWrapper(child: SearchView()),    // Child 1: Staggered Search/Explore
            _KeepAliveWrapper(child: UserPostsView()), // Child 2: Profile View
          ],
        ),
      ),

      // ── Premium Bottom Navigation ──
      bottomNavigationBar: _buildBottomNav(theme, colorScheme, activeTab),
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
  // Custom Ultra-Premium Bottom Navigation Bar
  // ─────────────────────────────────────────────────────────────
  Widget _buildBottomNav(ThemeData theme, ColorScheme colorScheme, int activeTab) {
    return Container(
      height: 60 + MediaQuery.paddingOf(context).bottom,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
            width: 0.5,
          ),
        ),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // 1. Home Tab
          _buildNavItem(
            index: 0,
            activeTab: activeTab,
            unselectedIcon: Icons.home_outlined,
            selectedIcon: Icons.home_rounded,
            colorScheme: colorScheme,
            theme: theme,
          ),
          
          // 2. Search Tab
          _buildNavItem(
            index: 1,
            activeTab: activeTab,
            unselectedIcon: Icons.search_rounded,
            selectedIcon: Icons.search_rounded,
            colorScheme: colorScheme,
            theme: theme,
          ),
          
          // 3. Create Tab (Tapping this opens bottom sheet, no tab change!)
          _buildCreateNavItem(colorScheme: colorScheme, theme: theme),
          
          // 4. Profile Tab
          _buildNavItem(
            index: 3,
            activeTab: activeTab,
            unselectedIcon: Icons.person_outline_rounded,
            selectedIcon: Icons.person_rounded,
            colorScheme: colorScheme,
            theme: theme,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required int activeTab,
    required IconData unselectedIcon,
    required IconData selectedIcon,
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    final isSelected = activeTab == index;
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        ref.read(_activeTabProvider.notifier).state = index;
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isSelected ? selectedIcon : unselectedIcon,
              color: isSelected
                  ? colorScheme.primary
                  : colorScheme.onSurface.withValues(alpha: 0.6),
              size: 26,
            )
            .animate(target: isSelected ? 1 : 0)
            .scale(
              begin: const Offset(1, 1),
              end: const Offset(1.12, 1.12),
              duration: 150.ms,
              curve: Curves.easeOutBack,
            ),
            const SizedBox(height: 4),
            // Sleek mini-dot indicator below selected tab
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isSelected ? 4 : 0,
              height: isSelected ? 4 : 0,
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCreateNavItem({
    required ColorScheme colorScheme,
    required ThemeData theme,
  }) {
    return InkWell(
      onTap: () {
        HapticFeedback.mediumImpact();
        _showCreatePostSheet(colorScheme);
      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              colorScheme.primary,
              colorScheme.secondary,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: colorScheme.primary.withValues(alpha: 0.3),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Container(
          padding: const EdgeInsets.all(6.0),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            Icons.add_rounded,
            color: colorScheme.primary,
            size: 20,
          ),
        ),
      ),
    );
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
      SlideBottomPageRoute(
        child: CreateNewPostView(
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
      SlideBottomPageRoute(
        child: CreateNewPostView(
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
