import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:instagram_clone_qthanh/state/posts/typedefs/user_id.dart';
import 'package:instagram_clone_qthanh/state/auth/constants/constants.dart';
import 'package:instagram_clone_qthanh/state/auth/models/auth_result.dart';

class Authenticator {
  //  Dùng singleton instance, khai báo ở class level
  final _googleSignIn = GoogleSignIn.instance;
  bool _isGoogleSignInInitialized = false;

  UserId? get userId => FirebaseAuth.instance.currentUser?.uid;
  // Hàm lấy uid của userId với UserId là đã được typedef từ String
  bool get isAlreadyLoggedIn => userId != null;
  // Hàm check rằng đã login thành công chưa, nếu đã login rồi thì sẽ trả về một uid của User
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

  // Khi logOut phải logOut cả 3 tài khoản giúp thoát hoàn toàn trạng thái, có thể nó đang ở trong trạng thái đăng nhập bị chồng chéo khi cả facebook lẫn google đều login vào cùng 1 tài khoản
  Future<void> logOut() async {
    await FirebaseAuth.instance.signOut();
    await GoogleSignIn.instance.signOut();
    await FacebookAuth.instance.logOut();
  }

  Future<AuthResult> loginWithFacebook() async {
    // Tạo nonce ngẫu nhiên cho Limited Login (iOS)
    final rawNonce = _generateNonce();
    final hashedNonce = _sha256ofString(rawNonce);

    final loginResult = await FacebookAuth.instance.login(
      permissions: ['public_profile'],
      loginTracking: LoginTracking.limited,
      nonce: hashedNonce, // Truyền SHA256 hash cho Facebook SDK
    );
    print('Facebook Login Status: ${loginResult.status}');
    print('Facebook Login Message: ${loginResult.message}');

    final accessToken = loginResult.accessToken;
    if (accessToken == null) {
      print('Facebook Login: Access token is null');
      return AuthResult.aborted;
    }

    // Debug: kiểm tra loại token trả về
    print('Facebook Token Type: ${accessToken.runtimeType}');

    final OAuthCredential oauthCredentials;

    if (accessToken is LimitedToken) {
      // iOS Limited Login: Facebook trả về OIDC token
      // Truyền rawNonce (chưa hash) → Firebase sẽ tự hash SHA256 để so khớp
      print('Facebook Login: Using Limited Token (OIDC) flow');
      oauthCredentials = OAuthCredential(
        providerId: 'facebook.com',
        signInMethod: 'oauth',
        idToken: accessToken.tokenString,
        rawNonce: rawNonce, // Raw nonce (chưa hash)
      );
    } else {
      // Classic access token (user cho phép tracking hoặc Android)
      print('Facebook Login: Using Classic Token flow');
      oauthCredentials = FacebookAuthProvider.credential(
        accessToken.tokenString,
      );
    }

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
      print(
        'FirebaseAuthException in Facebook Login: ${e.code} - ${e.message}',
      );
      return AuthResult.failure;
    } catch (e, stackTrace) {
      print('Unknown Exception in Facebook Login: $e\n$stackTrace');
      return AuthResult.failure;
    }
  }

  Future<AuthResult> loginWithGoogle() async {
    try {
      await _ensureGoogleSignInInitialized();

      // Sử dụng authenticate() cho google_sign_in v7.0.0+
      // Bỏ qua việc gọi authorizeScopes() vì nó sẽ làm hiện popup xin quyền lần 2.
      // Firebase chỉ cần idToken là đủ để đăng nhập.
      final googleUser = await _googleSignIn.authenticate();

      final googleAuth = await googleUser.authentication;
      final idToken = googleAuth.idToken;

      if (idToken == null) {
        return AuthResult.failure;
      }

      final oauthCredentials = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: null, // Không bắt buộc đối với Firebase Auth
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

  /// Tạo nonce ngẫu nhiên (cryptographically secure)
  String _generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(
      length,
      (_) => charset[random.nextInt(charset.length)],
    ).join();
  }

  /// Hash SHA256 một chuỗi
  String _sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }
}
