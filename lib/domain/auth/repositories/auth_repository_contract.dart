import 'package:milexact/domain/auth/entities/app_user.dart';

abstract class AuthRepositoryContract {
  AppUser? get currentUser;

  Stream<AppUser?> authStateChanges();

  Future<AppUser?> restoreCurrentUser();

  Future<AppUser?> reloadCurrentUser();

  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> signInWithGoogle();

  Future<AppUser> signInWithApple();

  Future<void> sendPasswordResetEmail({required String email});

  Future<void> sendEmailVerification();

  Future<void> signOut();
}
