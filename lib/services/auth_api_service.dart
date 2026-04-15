import 'package:get/get.dart';
import 'package:milexact/data/models/social_auth_result.dart';
import 'package:milexact/services/auth_service.dart';
import 'package:milexact/shared/constants/auth_api_config.dart';

class AuthApiService extends GetConnect {
  AuthApiService() {
    httpClient.timeout = const Duration(seconds: 20);
  }

  bool get isConfigured => AuthApiConfig.baseUrl.trim().isNotEmpty;

  Future<SocialAuthResult> signInWithGoogle({
    required String idToken,
    String? accessToken,
    String? email,
  }) {
    return _exchangeToken(
      path: AuthApiConfig.googleSignInPath,
      body: <String, dynamic>{
        'idToken': idToken,
        if (accessToken != null && accessToken.isNotEmpty)
          'accessToken': accessToken,
        if (email != null && email.isNotEmpty) 'email': email,
      },
    );
  }

  Future<SocialAuthResult> signInWithApple({
    required String identityToken,
    required String authorizationCode,
    String? email,
    String? givenName,
    String? familyName,
  }) {
    return _exchangeToken(
      path: AuthApiConfig.appleSignInPath,
      body: <String, dynamic>{
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        if (email != null && email.isNotEmpty) 'email': email,
        if (givenName != null && givenName.isNotEmpty) 'givenName': givenName,
        if (familyName != null && familyName.isNotEmpty)
          'familyName': familyName,
      },
    );
  }

  Future<SocialAuthResult> _exchangeToken({
    required String path,
    required Map<String, dynamic> body,
  }) async {
    if (!isConfigured) {
      throw const AuthException(
        'Auth API base URL is not configured. Set --dart-define=AUTH_API_BASE_URL=...',
      );
    }

    final response = await post<Map<String, dynamic>>(
      '${AuthApiConfig.baseUrl}$path',
      body,
    );

    if (!response.isOk || response.body == null) {
      throw AuthException(
        response.body?['message'] as String? ??
            'Social sign-in failed. Check your auth API configuration.',
      );
    }

    final result = SocialAuthResult.fromJson(response.body!);
    if (result.email.isEmpty) {
      throw const AuthException('Auth API did not return a valid user email.');
    }

    return result;
  }
}
