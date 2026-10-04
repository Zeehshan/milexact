import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:milexact/domain/auth/entities/app_user.dart';
import 'package:milexact/domain/auth/repositories/auth_repository_contract.dart';
import 'package:milexact/domain/auth/use_cases/observe_auth_state_use_case.dart';
import 'package:milexact/domain/auth/use_cases/reload_current_user_use_case.dart';
import 'package:milexact/domain/auth/use_cases/restore_current_user_use_case.dart';
import 'package:milexact/domain/auth/use_cases/send_email_verification_use_case.dart';
import 'package:milexact/domain/auth/use_cases/send_password_reset_email_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_in_with_apple_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_in_with_email_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_in_with_google_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_out_use_case.dart';
import 'package:milexact/domain/auth/use_cases/sign_up_with_email_use_case.dart';
import 'package:milexact/services/auth_service.dart';

void main() {
  group('AuthService', () {
    late _FakeAuthRepository repository;
    late AuthService service;

    setUp(() async {
      repository = _FakeAuthRepository();
      service = AuthService(
        observeAuthStateUseCase: ObserveAuthStateUseCase(repository),
        restoreCurrentUserUseCase: RestoreCurrentUserUseCase(repository),
        reloadCurrentUserUseCase: ReloadCurrentUserUseCase(repository),
        signUpWithEmailUseCase: SignUpWithEmailUseCase(repository),
        signInWithEmailUseCase: SignInWithEmailUseCase(repository),
        signInWithGoogleUseCase: SignInWithGoogleUseCase(repository),
        signInWithAppleUseCase: SignInWithAppleUseCase(repository),
        sendPasswordResetEmailUseCase: SendPasswordResetEmailUseCase(
          repository,
        ),
        sendEmailVerificationUseCase: SendEmailVerificationUseCase(repository),
        signOutUseCase: SignOutUseCase(repository),
      );
      await service.init();
    });

    test('sign up normalizes email and sends verification', () async {
      await service.signUp(
        email: ' Shooter@Example.com ',
        password: 'secret123',
      );

      expect(service.currentUser.value, isNotNull);
      expect(service.currentUser.value?.email, 'shooter@example.com');
      expect(repository.lastSignedUpEmail, 'shooter@example.com');
      expect(repository.sentVerificationEmail, isTrue);
    });

    test(
      'sign in rejects invalid email format before repository call',
      () async {
        expect(
          () => service.signIn(email: 'not-an-email', password: 'secret123'),
          throwsA(isA<AuthException>()),
        );
        expect(repository.lastSignedInEmail, isNull);
      },
    );

    test(
      'password reset normalizes email and delegates to repository',
      () async {
        final normalized = await service.requestPasswordReset(
          email: ' Shooter@Example.com ',
        );

        expect(normalized, 'shooter@example.com');
        expect(repository.lastResetEmail, 'shooter@example.com');
      },
    );
  });
}

class _FakeAuthRepository implements AuthRepositoryContract {
  final _streamController = StreamController<AppUser?>.broadcast();

  AppUser? _currentUser;
  String? lastSignedUpEmail;
  String? lastSignedInEmail;
  String? lastResetEmail;
  bool sentVerificationEmail = false;

  @override
  AppUser? get currentUser => _currentUser;

  @override
  Stream<AppUser?> authStateChanges() => _streamController.stream;

  @override
  Future<AppUser?> reloadCurrentUser() async => _currentUser;

  @override
  Future<AppUser?> restoreCurrentUser() async => _currentUser;

  @override
  Future<void> sendEmailVerification() async {
    sentVerificationEmail = true;
  }

  @override
  Future<void> sendPasswordResetEmail({required String email}) async {
    lastResetEmail = email;
  }

  @override
  Future<AppUser> signInWithApple() async {
    return _setCurrentUser(
      const AppUser(
        id: 'apple-user',
        email: 'apple@example.com',
        emailVerified: true,
        providerIds: ['apple.com'],
      ),
    );
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    lastSignedInEmail = email;
    return _setCurrentUser(
      AppUser(
        id: 'email-user',
        email: email,
        emailVerified: true,
        providerIds: const ['password'],
      ),
    );
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    return _setCurrentUser(
      const AppUser(
        id: 'google-user',
        email: 'google@example.com',
        emailVerified: true,
        providerIds: ['google.com'],
      ),
    );
  }

  @override
  Future<void> signOut() async {
    _currentUser = null;
    _streamController.add(null);
  }

  @override
  Future<AppUser> signUpWithEmail({
    required String email,
    required String password,
  }) async {
    lastSignedUpEmail = email;
    return _setCurrentUser(
      AppUser(
        id: 'signup-user',
        email: email,
        emailVerified: false,
        providerIds: const ['password'],
      ),
    );
  }

  Future<AppUser> _setCurrentUser(AppUser user) async {
    _currentUser = user;
    _streamController.add(user);
    return user;
  }
}
