import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:instagram_clone_qthanh/state/auth/providers/auth_state_provider.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/user_id.dart';

final useridProvider = Provider<UserId?>(
  (ref) => ref.watch(authStateProvider).userId,
);
