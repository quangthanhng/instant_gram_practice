import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/auth/models/auth_state.dart';
import 'package:instagram_clone_qthanh/state/auth/notifiers/auth_state_notifiers.dart';

final authStateProvider = StateNotifierProvider<AuthStateNotifiers, AuthState>(
  (_) => AuthStateNotifiers(),
);
