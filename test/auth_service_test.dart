import 'package:flutter_test/flutter_test.dart';
import 'package:milexact/data/models/auth_user.dart';
import 'package:milexact/data/repositories/auth_repository.dart';
import 'package:milexact/services/auth_api_service.dart';
import 'package:milexact/services/auth_service.dart';
import 'package:milexact/services/social_identity_service.dart';
import 'package:milexact/services/storage_service.dart';

void main() {
  group('AuthService', () {
    late _FakeAuthRepository repository;
    late AuthService service;

    setUp(() {
      repository = _FakeAuthRepository();
      service = AuthService(
        repository,
        _FakeAuthApiService(),
        _FakeSocialIdentityService(),
      );
    });

    test('sign up creates a normalized local session', () async {
      await service.signUp(
        email: ' Shooter@Example.com ',
        password: 'secret123',
      );

      expect(service.currentUser.value, isNotNull);
      expect(service.currentUser.value!.email, 'shooter@example.com');
      expect(repository.users, hasLength(1));
    });

    test('sign in rejects an incorrect password', () async {
      await service.signUp(email: 'shooter@example.com', password: 'secret123');
      await repository.clearSession();

      expect(
        () => service.signIn(
          email: 'shooter@example.com',
          password: 'wrong-pass',
        ),
        throwsA(isA<AuthException>()),
      );
    });

    test('reset password updates the stored hash and clears session', () async {
      await service.signUp(email: 'shooter@example.com', password: 'secret123');
      final beforeHash = repository.currentUser.value!.passwordHash;

      await service.resetPassword(
        email: 'shooter@example.com',
        newPassword: 'new-secret123',
      );

      expect(repository.currentUser.value, isNull);
      expect(repository.users.single.passwordHash, isNot(beforeHash));
    });
  });
}

class _FakeAuthApiService extends AuthApiService {}

class _FakeSocialIdentityService extends SocialIdentityService {}

class _FakeAuthRepository extends AuthRepository {
  _FakeAuthRepository() : super(StorageService());

  @override
  AuthUser? userById(String id) {
    for (final user in users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  @override
  AuthUser? userByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final user in users) {
      if (user.email.toLowerCase() == normalized) {
        return user;
      }
    }
    return null;
  }

  @override
  Future<void> upsertUser(AuthUser user) async {
    final index = users.indexWhere((item) => item.id == user.id);
    if (index == -1) {
      users.add(user);
    } else {
      users[index] = user;
      users.refresh();
    }
    if (currentUser.value?.id == user.id) {
      currentUser.value = user;
    }
  }

  @override
  Future<void> saveSession(AuthUser user) async {
    currentUser.value = user;
  }

  @override
  Future<void> clearSession() async {
    currentUser.value = null;
  }
}
