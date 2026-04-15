import 'package:get/get.dart';
import 'package:milexact/data/local/seed_data.dart';
import 'package:milexact/data/models/dope_profile.dart';
import 'package:milexact/services/storage_service.dart';

class DopeProfilesRepository extends GetxService {
  DopeProfilesRepository(this._storage);

  final StorageService _storage;
  final RxList<DopeProfile> profiles = <DopeProfile>[].obs;

  Future<DopeProfilesRepository> init() async {
    if (_storage.dopeProfilesBox.isEmpty) {
      await _storage.dopeProfilesBox.putAll({
        for (final profile in SeedData.defaultDopeProfiles())
          profile.id: profile.toJson(),
      });
    }

    _reload();
    return this;
  }

  DopeProfile? profileById(String id) {
    return profiles.firstWhereOrNull((profile) => profile.id == id);
  }

  Future<void> upsert(DopeProfile profile) async {
    await _storage.dopeProfilesBox.put(profile.id, profile.toJson());
    _reload();
  }

  Future<void> delete(String profileId) async {
    await _storage.dopeProfilesBox.delete(profileId);
    _reload();
  }

  Future<void> setActive(String? profileId) async {
    for (final profile in profiles) {
      final next = profile.copyWith(
        isActive: profile.id == profileId,
        updatedAt: DateTime.now(),
      );
      await _storage.dopeProfilesBox.put(next.id, next.toJson());
    }
    _reload();
  }

  void _reload() {
    profiles.assignAll(
      _storage.dopeProfilesBox.values
          .map((raw) => DopeProfile.fromJson(Map<String, dynamic>.from(raw)))
          .toList()
        ..sort((left, right) {
          if (left.isActive != right.isActive) {
            return left.isActive ? -1 : 1;
          }
          return left.rifleName.toLowerCase().compareTo(
            right.rifleName.toLowerCase(),
          );
        }),
    );
  }
}
