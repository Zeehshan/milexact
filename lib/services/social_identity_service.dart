import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:milexact/services/auth_service.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class SocialIdentityService extends GetxService {
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance;
  bool _googleInitialized = false;

  Future<void> _ensureGoogleInitialized() async {
    if (_googleInitialized) {
      return;
    }

    await _googleSignIn.initialize();
    _googleInitialized = true;
  }

  Future<GoogleIdentityPayload> requestGoogleIdentity() async {
    try {
      await _ensureGoogleInitialized();
      await _googleSignIn.signOut();
      final account = await _googleSignIn.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw const AuthException('Google sign-in did not return an ID token.');
      }

      return GoogleIdentityPayload(email: account.email, idToken: idToken);
    } catch (error) {
      if (error is AuthException) {
        rethrow;
      }
      throw AuthException('Google sign-in failed: $error');
    }
  }

  Future<AppleIdentityPayload> requestAppleIdentity() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      if (credential.identityToken == null ||
          credential.identityToken!.isEmpty ||
          credential.authorizationCode.isEmpty) {
        throw const AuthException('Apple sign-in did not return valid tokens.');
      }

      return AppleIdentityPayload(
        email: credential.email,
        identityToken: credential.identityToken!,
        authorizationCode: credential.authorizationCode,
        givenName: credential.givenName,
        familyName: credential.familyName,
      );
    } catch (error) {
      if (error is AuthException) {
        rethrow;
      }
      throw AuthException('Apple sign-in failed: $error');
    }
  }
}

class GoogleIdentityPayload {
  const GoogleIdentityPayload({
    required this.email,
    required this.idToken,
    this.accessToken,
  });

  final String email;
  final String idToken;
  final String? accessToken;
}

class AppleIdentityPayload {
  const AppleIdentityPayload({
    required this.identityToken,
    required this.authorizationCode,
    this.email,
    this.givenName,
    this.familyName,
  });

  final String identityToken;
  final String authorizationCode;
  final String? email;
  final String? givenName;
  final String? familyName;
}
