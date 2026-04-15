abstract final class AuthApiConfig {
  static const baseUrl = String.fromEnvironment(
    'AUTH_API_BASE_URL',
    defaultValue: '',
  );

  static const googleSignInPath = '/auth/social/google';
  static const appleSignInPath = '/auth/social/apple';
}
