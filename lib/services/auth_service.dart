import 'dart:async';

import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/domain/auth/auth.dart';

export 'package:milexact/domain/auth/auth.dart' show AuthException;

class AuthService extends GetxService {
  AuthService({
    required ObserveAuthStateUseCase observeAuthStateUseCase,
    required RestoreCurrentUserUseCase restoreCurrentUserUseCase,
    required ReloadCurrentUserUseCase reloadCurrentUserUseCase,
    required SignUpWithEmailUseCase signUpWithEmailUseCase,
    required SignInWithEmailUseCase signInWithEmailUseCase,
    required SignInWithGoogleUseCase signInWithGoogleUseCase,
    required SignInWithAppleUseCase signInWithAppleUseCase,
    required SendPasswordResetEmailUseCase sendPasswordResetEmailUseCase,
    required SendEmailVerificationUseCase sendEmailVerificationUseCase,
    required SignOutUseCase signOutUseCase,
  }) : _observeAuthStateUseCase = observeAuthStateUseCase,
       _restoreCurrentUserUseCase = restoreCurrentUserUseCase,
       _reloadCurrentUserUseCase = reloadCurrentUserUseCase,
       _signUpWithEmailUseCase = signUpWithEmailUseCase,
       _signInWithEmailUseCase = signInWithEmailUseCase,
       _signInWithGoogleUseCase = signInWithGoogleUseCase,
       _signInWithAppleUseCase = signInWithAppleUseCase,
       _sendPasswordResetEmailUseCase = sendPasswordResetEmailUseCase,
       _sendEmailVerificationUseCase = sendEmailVerificationUseCase,
       _signOutUseCase = signOutUseCase;

  static final _emailPattern = RegExp(
    r'^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$',
    caseSensitive: false,
  );

  final ObserveAuthStateUseCase _observeAuthStateUseCase;
  final RestoreCurrentUserUseCase _restoreCurrentUserUseCase;
  final ReloadCurrentUserUseCase _reloadCurrentUserUseCase;
  final SignUpWithEmailUseCase _signUpWithEmailUseCase;
  final SignInWithEmailUseCase _signInWithEmailUseCase;
  final SignInWithGoogleUseCase _signInWithGoogleUseCase;
  final SignInWithAppleUseCase _signInWithAppleUseCase;
  final SendPasswordResetEmailUseCase _sendPasswordResetEmailUseCase;
  final SendEmailVerificationUseCase _sendEmailVerificationUseCase;
  final SignOutUseCase _signOutUseCase;

  final Rxn<AppUser> currentUser = Rxn<AppUser>();

  StreamSubscription<AppUser?>? _authSubscription;

  bool get isSignedIn => currentUser.value != null;
  bool get supportsAppleSignIn => GetPlatform.isIOS;

  bool get needsEmailVerification =>
      currentUser.value?.requiresEmailVerification ?? false;

  bool get canAccessApp => isSignedIn && !needsEmailVerification;

  Future<AuthService> init() async {
    currentUser.value = await _restoreCurrentUserUseCase();
    _authSubscription = _observeAuthStateUseCase().listen((user) {
      currentUser.value = user;
    });
    return this;
  }

  String normalizeEmail(String email) => email.trim().toLowerCase();

  bool isValidEmail(String email) =>
      _emailPattern.hasMatch(normalizeEmail(email));

  Future<void> signUp({required String email, required String password}) async {
    final normalizedEmail = normalizeEmail(email);

    if (!isValidEmail(normalizedEmail)) {
      throw const AuthException('Enter a valid email address.');
    }
    if (password.trim().length < 8) {
      throw const AuthException('Password must be at least 8 characters.');
    }

    final user = await _signUpWithEmailUseCase(
      email: normalizedEmail,
      password: password,
    );
    currentUser.value = user;
    await _sendEmailVerificationUseCase();
    await refreshCurrentUser();
  }

  Future<void> signIn({required String email, required String password}) async {
    final normalizedEmail = normalizeEmail(email);

    if (!isValidEmail(normalizedEmail)) {
      throw const AuthException('Enter a valid email address.');
    }
    if (password.isEmpty) {
      throw const AuthException('Enter your password.');
    }

    final user = await _signInWithEmailUseCase(
      email: normalizedEmail,
      password: password,
    );
    currentUser.value = user;
    await refreshCurrentUser();
  }

  Future<String> requestPasswordReset({required String email}) async {
    final normalizedEmail = normalizeEmail(email);

    if (!isValidEmail(normalizedEmail)) {
      throw const AuthException('Enter a valid email address.');
    }

    await _sendPasswordResetEmailUseCase(email: normalizedEmail);
    return normalizedEmail;
  }

  Future<void> resetPassword({
    required String email,
    required String newPassword,
  }) async {
    throw const AuthException(
      'Password reset is handled from the Firebase email link.',
    );
  }

  Future<void> signOut() async {
    await _signOutUseCase();
    currentUser.value = null;
    Get.offAllNamed(AppRoutes.signIn);
  }

  Future<void> signInWithGoogle() async {
    final user = await _signInWithGoogleUseCase();
    currentUser.value = user;
    await refreshCurrentUser();
  }

  Future<void> signInWithApple() async {
    if (!supportsAppleSignIn) {
      throw const AuthException('Apple sign-in is available on iOS only.');
    }

    final user = await _signInWithAppleUseCase();
    currentUser.value = user;
    await refreshCurrentUser();
  }

  Future<void> resendEmailVerification() => _sendEmailVerificationUseCase();

  Future<AppUser?> refreshCurrentUser() async {
    currentUser.value = await _reloadCurrentUserUseCase();
    return currentUser.value;
  }

  Future<bool> refreshVerificationStatus() async {
    final user = await refreshCurrentUser();
    return user?.emailVerified ?? false;
  }

  @override
  void onClose() {
    _authSubscription?.cancel();
    super.onClose();
  }
}
