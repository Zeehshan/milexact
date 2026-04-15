import 'dart:convert';

import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/auth_user.dart';
import 'package:milexact/data/repositories/auth_repository.dart';
import 'package:milexact/services/auth_api_service.dart';
import 'package:milexact/services/social_identity_service.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class AuthService extends GetxService {
  AuthService(
    this._repository,
    this._authApiService,
    this._socialIdentityService,
  );

  static final _emailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  final AuthRepository _repository;
  final AuthApiService _authApiService;
  final SocialIdentityService _socialIdentityService;

  Rxn<AuthUser> get currentUser => _repository.currentUser;
  bool get isSignedIn => currentUser.value != null;

  String normalizeEmail(String email) => email.trim().toLowerCase();

  bool isValidEmail(String email) =>
      _emailPattern.hasMatch(normalizeEmail(email));

  String hashPassword({required String email, required String password}) {
    final base = '${normalizeEmail(email)}::$password::milexact-auth-v1';
    var payload = utf8.encode(base);
    var hash = 0xcbf29ce484222325;
    const prime = 0x100000001b3;

    for (var round = 0; round < 512; round++) {
      for (final byte in payload) {
        hash ^= byte;
        hash = (hash * prime) & 0xFFFFFFFFFFFFFFFF;
      }
      payload = utf8.encode('$base::$round::$hash');
    }

    return hash.toRadixString(16).padLeft(16, '0');
  }

  Future<void> signUp({required String email, required String password}) async {
    final normalizedEmail = normalizeEmail(email);

    if (!isValidEmail(normalizedEmail)) {
      throw const AuthException('Enter a valid email address.');
    }
    if (password.trim().length < 8) {
      throw const AuthException('Password must be at least 8 characters.');
    }
    if (_repository.userByEmail(normalizedEmail) != null) {
      throw const AuthException('An account with this email already exists.');
    }

    final now = DateTime.now();
    final user = AuthUser(
      id: IdGenerator.generate(prefix: 'user'),
      email: normalizedEmail,
      passwordHash: hashPassword(email: normalizedEmail, password: password),
      createdAt: now,
      updatedAt: now,
    );

    await _repository.upsertUser(user);
    await _repository.saveSession(user);
  }

  Future<void> signIn({required String email, required String password}) async {
    final normalizedEmail = normalizeEmail(email);
    final user = _repository.userByEmail(normalizedEmail);

    if (user == null) {
      throw const AuthException('No account found for this email.');
    }

    final passwordHash = hashPassword(
      email: normalizedEmail,
      password: password,
    );
    if (user.passwordHash != passwordHash) {
      throw const AuthException('Incorrect password.');
    }

    await _repository.saveSession(user);
  }

  Future<String> requestPasswordReset({required String email}) async {
    final normalizedEmail = normalizeEmail(email);

    if (!isValidEmail(normalizedEmail)) {
      throw const AuthException('Enter a valid email address.');
    }
    if (_repository.userByEmail(normalizedEmail) == null) {
      throw const AuthException('No account found for this email.');
    }

    return normalizedEmail;
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    final normalizedEmail = normalizeEmail(email);
    final user = _repository.userByEmail(normalizedEmail);

    if (user == null) {
      throw const AuthException('No account found for this email.');
    }
    if (newPassword.trim().length < 8) {
      throw const AuthException('Password must be at least 8 characters.');
    }

    await _repository.upsertUser(
      user.copyWith(
        passwordHash: hashPassword(
          email: normalizedEmail,
          password: newPassword,
        ),
        updatedAt: DateTime.now(),
      ),
    );
    await _repository.clearSession();
  }

  Future<void> signOut() async {
    await _repository.clearSession();
    Get.offAllNamed(AppRoutes.signIn);
  }

  Future<void> signInWithGoogle() async {
    final identity = await _socialIdentityService.requestGoogleIdentity();
    final result = await _authApiService.signInWithGoogle(
      idToken: identity.idToken,
      accessToken: identity.accessToken,
      email: identity.email,
    );
    await _completeSocialSignIn(email: result.email);
  }

  Future<void> signInWithApple() async {
    final identity = await _socialIdentityService.requestAppleIdentity();
    final result = await _authApiService.signInWithApple(
      identityToken: identity.identityToken,
      authorizationCode: identity.authorizationCode,
      email: identity.email,
      givenName: identity.givenName,
      familyName: identity.familyName,
    );
    await _completeSocialSignIn(email: result.email);
  }

  Future<void> _completeSocialSignIn({required String email}) async {
    final normalizedEmail = normalizeEmail(email);
    final existing = _repository.userByEmail(normalizedEmail);
    final now = DateTime.now();
    final user =
        existing ??
        AuthUser(
          id: IdGenerator.generate(prefix: 'user'),
          email: normalizedEmail,
          passwordHash: '',
          createdAt: now,
          updatedAt: now,
        );

    final updatedUser = user.copyWith(email: normalizedEmail, updatedAt: now);
    await _repository.upsertUser(updatedUser);
    await _repository.saveSession(updatedUser);
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
