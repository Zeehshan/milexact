class SocialAuthResult {
  const SocialAuthResult({
    required this.email,
    required this.sessionToken,
  });

  final String email;
  final String sessionToken;

  factory SocialAuthResult.fromJson(Map<String, dynamic> json) {
    return SocialAuthResult(
      email: (json['email'] as String?)?.trim() ?? '',
      sessionToken: (json['sessionToken'] as String?)?.trim() ?? '',
    );
  }
}
