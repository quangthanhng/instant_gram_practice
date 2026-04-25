import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram_clone_qthanh/posts/typedefs/user_id.dart';
import 'package:instagram_clone_qthanh/stat/auth/constants/constants.dart';
import 'package:instagram_clone_qthanh/stat/auth/models/auth_result.dart';

class Authenticator {
  //  Dùng singleton instance, khai báo ở class level
  final _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  UserId? get userId => FirebaseAuth.instance.currentUser?.uid;
  bool get isAlreadyLoggedIn => userId != null;
  String get displayName =>
      FirebaseAuth.instance.currentUser?.displayName ?? '';
  String? get email => FirebaseAuth.instance.currentUser?.email;

  //  Đảm bảo initialize() được gọi trước khi dùng
  Future<void> _ensureGoogleSignInInitialized() async {
    if (!_isGoogleSignInInitialized) {
      await _googleSignIn.initialize();
      _isGoogleSignInInitialized = true;
    }
  }

  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
    await FacebookAuth.instance.logOut();
  }

  Future<AuthResult> loginWithFacebook() async {
    final loginResult = await FacebookAuth.instance.login();
    final token = loginResult.accessToken?.tokenString;
    if (token == null) {
      return AuthResult.aborted;
    }
    final oauthCredentials = FacebookAuthProvider.credential(token);
    try {
      await FirebaseAuth.instance.signInWithCredential(oauthCredentials);
      return AuthResult.success;
    } on FirebaseAuthException catch (e) {
      final email = e.email;
      final credential = e.credential;
      if (e.code == Constants.accountExistWithDifferentCredential &&
          email != null &&
          credential != null) {
        try {
          final googleResult = await loginWithGoogle();
          if (googleResult == AuthResult.success) {
            await FirebaseAuth.instance.currentUser?.linkWithCredential(
              credential,
            );
          }
        } catch (_) {}
        return AuthResult.success;
      }
      return AuthResult.failure;
    }
  }

  Future<AuthResult> loginWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      final googleUser = await _googleSignIn.authenticate(
        scopeHint: [Constants.emailScope],
      );

      // ✅ idToken lấy từ authentication (sync)
      final idToken = googleUser.authentication.idToken;

      // ✅ accessToken lấy riêng qua authorizationClient
      final clientAuth = await googleUser.authorizationClient.authorizeScopes([
        Constants.emailScope,
      ]);
      final accessToken = clientAuth.accessToken;

      if (idToken == null) {
        return AuthResult.failure;
      }

      final oauthCredentials = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken, // có thể null, Firebase vẫn chấp nhận
      );

      await FirebaseAuth.instance.signInWithCredential(oauthCredentials);
      return AuthResult.success;
    } on GoogleSignInException catch (e) {
      print('GoogleSignInException: ${e.code} - ${e.description}');
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return AuthResult.aborted;
      }
      return AuthResult.failure;
    } on FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      return AuthResult.failure;
    } catch (e, stackTrace) {
      print('Unknown Exception in loginWithGoogle: $e\n$stackTrace');
      return AuthResult.failure;
    }
  }
}
