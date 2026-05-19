import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/user_id_provider.dart';
import 'package:instagram_clone_qthanh/state/posts/provider/user_posts_provider.dart';
import 'package:instagram_clone_qthanh/state/user_info/providers/user_info_model_providers.dart';
import 'package:instagram_clone_qthanh/views/components/animations/empty_contents_with_text_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/animations/error_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/animations/loading_animation_view.dart';
import 'package:instagram_clone_qthanh/views/components/avatar_widget.dart';
import 'package:instagram_clone_qthanh/views/components/edit_profile_sheet.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_card.dart';
import 'package:instagram_clone_qthanh/views/components/post/post_sliver_grid_view.dart';
import 'package:instagram_clone_qthanh/views/constants/strings.dart';
import 'package:share_plus/share_plus.dart';

class UserPostsView extends HookConsumerWidget {
  const UserPostsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(userPostsProvider);
    final userId = ref.watch(userIdProvider);
    final theme = Theme.of(context);
    
    // Toggle state between Grid and List view
    final isGridView = useState(true);

    if (userId == null) {
      return const SizedBox();
    }

    final userInfoAsync = ref.watch(userInfoModelProvider(userId));

    return RefreshIndicator(
      onRefresh: () {
        ref.refresh(userPostsProvider);
        return Future.delayed(const Duration(seconds: 1));
      },
      child: userInfoAsync.when(
        data: (userInfo) {
          return postsAsync.when(
            data: (posts) {
              return CustomScrollView(
                slivers: [
                  // 1. Profile Header Section
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              // Avatar with premium Story ring
                              AvatarWidget(
                                userId: userId,
                                displayName: userInfo.displayName,
                                radius: 40.0,
                              ),
                              const Spacer(),
                              
                              // Stats Row - ONLY showing actual Posts count (no fictional stats!)
                              _buildStatColumn('Posts', posts.length.toString(), theme),
                              const SizedBox(width: 12),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Real Display Name
                          Text(
                            userInfo.displayName,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 16,
                            ),
                          ),
                          
                          // Real Email (if available) - No fictional bio!
                          if (userInfo.email != null && userInfo.email!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              userInfo.email!,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.onSurface.withValues(alpha: 0.55),
                                fontSize: 13.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          
                          // Action Buttons
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (context) => EditProfileSheet(
                                        currentDisplayName: userInfo.displayName,
                                        userId: userId,
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: Text(
                                    'Edit Profile',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () {
                                    HapticFeedback.lightImpact();
                                    final shareMessage =
                                        'Hey! Check out my profile on ${Strings.appName}\n'
                                        'Name: ${userInfo.displayName}\n'
                                        'Email: ${userInfo.email ?? "No email"}';
                                    // ignore: deprecated_member_use
                                    Share.share(shareMessage);
                                  },
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(
                                      color: theme.colorScheme.outline.withValues(alpha: 0.15),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                  child: Text(
                                    'Share Profile',
                                    style: theme.textTheme.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 13.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          
                          // Grid / List View Toggle Tab
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              IconButton(
                                onPressed: () => isGridView.value = true,
                                icon: Icon(
                                  Icons.grid_on_rounded,
                                  color: isGridView.value 
                                      ? theme.colorScheme.primary 
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                              IconButton(
                                onPressed: () => isGridView.value = false,
                                icon: Icon(
                                  Icons.list_alt_rounded,
                                  color: !isGridView.value 
                                      ? theme.colorScheme.primary 
                                      : theme.colorScheme.onSurface.withValues(alpha: 0.4),
                                ),
                              ),
                            ],
                          ),
                          const Divider(height: 1, thickness: 0.5),
                        ],
                      ),
                    ),
                  ),
                  
                  // 2. Posts Area (With Toggle rendering)
                  if (posts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: EmptyContentsWithTextAnimationView(
                          text: Strings.youHaveNoPost,
                        ),
                      ),
                    )
                  else if (isGridView.value)
                    PostSliverGridView(posts: posts)
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts.elementAt(index);
                          return PostCard(post: post);
                        },
                        childCount: posts.length,
                      ),
                    ),
                ],
              );
            },
            error: (error, stackTrace) => const SliverFillRemaining(
              child: Center(child: ErrorAnimationView()),
            ),
            loading: () => const SliverFillRemaining(
              child: Center(child: LoadingAnimationView()),
            ),
          );
        },
        error: (error, stackTrace) => Center(child: ErrorAnimationView()),
        loading: () => const Center(child: LoadingAnimationView()),
      ),
    );
  }

  Widget _buildStatColumn(String label, String count, ThemeData theme) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          count,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 18,
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
            fontSize: 12.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
