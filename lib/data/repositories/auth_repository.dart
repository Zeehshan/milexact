import 'package:get/get.dart';
import 'package:milexact/data/models/auth_user.dart';
import 'package:milexact/services/storage_service.dart';

class AuthRepository extends GetxService {
  AuthRepository(this._storage);

  static const _sessionKey = 'current_session';

  final StorageService _storage;
  final RxList<AuthUser> users = <AuthUser>[].obs;
  final Rxn<AuthUser> currentUser = Rxn<AuthUser>();

  Future<AuthRepository> init() async {
    users.assignAll(
      _storage.authUsersBox.values
          .map((raw) => AuthUser.fromJson(Map<String, dynamic>.from(raw)))
          .toList(growable: false),
    );

    final rawSession = _storage.authSessionBox.get(_sessionKey);
    if (rawSession != null) {
      final session = Map<String, dynamic>.from(rawSession);
      final userId = session['userId'] as String?;
      if (userId != null) {
        currentUser.value = userById(userId);
      }
    }

    return this;
  }

  AuthUser? userById(String id) {
    for (final user in users) {
      if (user.id == id) {
        return user;
      }
    }
    return null;
  }

  AuthUser? userByEmail(String email) {
    final normalized = email.trim().toLowerCase();
    for (final user in users) {
      if (user.email.toLowerCase() == normalized) {
        return user;
      }
    }
    return null;
  }

  Future<void> upsertUser(AuthUser user) async {
    final index = users.indexWhere((item) => item.id == user.id);
    if (index == -1) {
      users.add(user);
    } else {
      users[index] = user;
      users.refresh();
    }

    await _storage.authUsersBox.put(user.id, user.toJson());

    if (currentUser.value?.id == user.id) {
      currentUser.value = user;
    }
  }

  Future<void> saveSession(AuthUser user) async {
    currentUser.value = user;
    await _storage.authSessionBox.put(_sessionKey, <String, dynamic>{
      'userId': user.id,
      'signedInAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> clearSession() async {
    currentUser.value = null;
    await _storage.authSessionBox.delete(_sessionKey);
  }
}
