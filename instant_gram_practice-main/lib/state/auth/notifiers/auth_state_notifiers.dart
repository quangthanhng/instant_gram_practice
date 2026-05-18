import 'package:hooks_riverpod/legacy.dart';
import 'package:instagram_clone_qthanh/state/auth/backend/authenticator.dart';
import 'package:instagram_clone_qthanh/state/auth/models/auth_result.dart';
import 'package:instagram_clone_qthanh/state/auth/models/auth_state.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/user_id.dart';
import 'package:instagram_clone_qthanh/state/user_info/backend/user_info_storage.dart';

class AuthStateNotifiers extends StateNotifier<AuthState> {
  final _authenticator = Authenticator();
  final _userInforStorage = const UserInfoStorage();

  AuthStateNotifiers() : super(const AuthState.unknown()) {
    if (_authenticator.isAlreadyLoggedIn) {
      state = AuthState(
        result: AuthResult.success,
        isLoading: false,
        userId: _authenticator.userId,
      );
    }
  }

  Future<void> logOut() async {
    state = state.copiedWithIsLoading(true);
    await _authenticator.logOut();
    state = const AuthState.unknown();
  }

  Future<void> logInWithGoogle() async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.loginWithGoogle();
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(userId: userId);
    }

    state = AuthState(result: result, isLoading: false, userId: userId);
  }

  Future<void> logInWithFacebook() async {
    state = state.copiedWithIsLoading(true);
    final result = await _authenticator.loginWithFacebook();
    final userId = _authenticator.userId;
    if (result == AuthResult.success && userId != null) {
      await saveUserInfo(userId: userId);
    }

    state = AuthState(result: result, isLoading: false, userId: userId);
  }

  Future<void> saveUserInfo({required UserId userId}) =>
      _userInforStorage.saveUserInfo(
        userId: userId,
        displayName: _authenticator.displayName,
        email: _authenticator.email,
      );
}
