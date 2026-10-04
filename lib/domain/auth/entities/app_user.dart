class AppUser {
  const AppUser({
    required this.id,
    required this.email,
    required this.emailVerified,
    required this.providerIds,
    this.displayName,
    this.photoUrl,
    this.createdAt,
    this.updatedAt,
    this.lastSignInAt,
  });

  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;
  final List<String> providerIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? lastSignInAt;

  bool get usesPasswordProvider => providerIds.contains('password');
  bool get usesGoogleProvider => providerIds.contains('google.com');
  bool get usesAppleProvider => providerIds.contains('apple.com');

  bool get requiresEmailVerification => usesPasswordProvider && !emailVerified;

  AppUser copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    bool? emailVerified,
    List<String>? providerIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSignInAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      providerIds: providerIds ?? this.providerIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSignInAt: lastSignInAt ?? this.lastSignInAt,
    );
  }
}
