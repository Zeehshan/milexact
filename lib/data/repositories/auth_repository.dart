import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:milexact/data/remote/firebase/firebase_auth_data_source.dart';
import 'package:milexact/data/remote/firebase/firestore_user_profile_data_source.dart';
import 'package:milexact/domain/auth/entities/app_user.dart';
import 'package:milexact/domain/auth/exceptions/auth_exception.dart';
import 'package:milexact/domain/auth/repositories/auth_repository_contract.dart';

class AuthRepository extends GetxService implements AuthRepositoryContract {
  AuthRepository(this._authDataSource, this._profileDataSource);

  final FirebaseAuthDataSource _authDataSource;
  final FirestoreUserProfileDataSource _profileDataSource;

  AppUser? _currentUser;

  @override
  AppUser? get currentUser => _currentUser;

  Future<AuthRepository> init() async {
    _currentUser = await restoreCurrentUser();
    return this;
  }

  @override
  Stream<AppUser?> authStateChanges() {
    return _authDataSource.userChanges().map((user) {
      final mapped = _mapFirebaseUser(user);
      _currentUser = mapped;

      if (mapped != null) {
        unawaited(_syncUserProfile(mapped));
      }

      return mapped;
    });
  }

  @override
  Future<AppUser?> restoreCurrentUser() async {
    final user = _mapFirebaseUser(_authDataSource.currentUser);
    _currentUser = user;
    if (user != null) {
      unawaited(_syncUserProfile(user));
    }
    return user;
  }

  @override
  Future<AppUser?> reloadCurrentUser() async {
    final user = _mapFirebaseUser(await _authDataSource.reloadCurrentUser());
    _currentUser = user;
    if (user != null) {
      await _syncUserProfile(user);
    }
    return user;
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authDataSource.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _completeAuthenticatedFlow(credential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _authDataSource.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return await _completeAuthenticatedFlow(credential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      final credential = await _authDataSource.signInWithGoogle();
      return await _completeAuthenticatedFlow(credential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<AppUser> signInWithApple() async {
    try {
      final credential = await _authDataSource.signInWithApple();
      return await _completeAuthenticatedFlow(credential.user);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await _authDataSource.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> sendEmailVerification() async {
    try {
      await _authDataSource.sendEmailVerification();
    } on FirebaseAuthException catch (error) {
      throw _mapFirebaseAuthException(error);
    }
  }

  @override
  Future<void> signOut() async {
    await _authDataSource.signOut();
    _currentUser = null;
  }

  Future<AppUser> _completeAuthenticatedFlow(User? user) async {
    final mapped = _mapFirebaseUser(user);
    if (mapped == null) {
      throw const AuthException(
        'Authentication completed without a valid user.',
      );
    }

    try {
      await _syncUserProfile(mapped);
    } catch (error) {
      await _authDataSource.signOut();
      _currentUser = null;

      if (error is AuthException) {
        rethrow;
      }

      throw const AuthException(
        'Authenticated successfully, but failed to sync your user profile.',
      );
    }

    _currentUser = mapped;
    return mapped;
  }

  Future<void> _syncUserProfile(AppUser user) async {
    await _profileDataSource.upsertUser(user);
  }

  AppUser? _mapFirebaseUser(User? user) {
    if (user == null) {
      return null;
    }

    final providerIds =
        user.providerData
            .map((provider) => provider.providerId)
            .where((providerId) => providerId.isNotEmpty)
            .toSet()
            .toList(growable: false)
          ..sort();

    return AppUser(
      id: user.uid,
      email: user.email?.trim().toLowerCase() ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      emailVerified: user.emailVerified,
      providerIds: providerIds,
      createdAt: user.metadata.creationTime,
      updatedAt: user.metadata.lastSignInTime,
      lastSignInAt: user.metadata.lastSignInTime,
    );
  }

  AuthException _mapFirebaseAuthException(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return const AuthException(
          'An account with this email already exists.',
        );
      case 'invalid-email':
        return const AuthException('Enter a valid email address.');
      case 'weak-password':
        return const AuthException('Password must be at least 8 characters.');
      case 'user-not-found':
        return const AuthException('No account found for this email.');
      case 'wrong-password':
      case 'invalid-credential':
        return const AuthException('Invalid email or password.');
      case 'user-disabled':
        return const AuthException('This account has been disabled.');
      case 'network-request-failed':
        return const AuthException(
          'Network connection is required for authentication.',
        );
      case 'too-many-requests':
        return const AuthException('Too many attempts. Try again later.');
      case 'operation-not-allowed':
        return const AuthException(
          'This sign-in method is not enabled for the project.',
        );
      case 'account-exists-with-different-credential':
        return const AuthException(
          'This email is already linked to a different sign-in method.',
        );
      default:
        return AuthException(
          error.message ?? 'Authentication failed. Please try again.',
        );
    }
  }
}
