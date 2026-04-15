import 'package:get/get.dart';
import 'package:milexact/data/models/dope_profile.dart';
import 'package:milexact/data/models/dope_profile_entry.dart';
import 'package:milexact/data/repositories/dope_profiles_repository.dart';
import 'package:milexact/shared/utils/id_generator.dart';

class DopeProfilesController extends GetxController {
  DopeProfilesController(this._repository);

  final DopeProfilesRepository _repository;
  final searchQuery = ''.obs;

  RxList<DopeProfile> get profiles => _repository.profiles;

  List<DopeProfile> get filteredProfiles {
    final query = searchQuery.value.trim().toLowerCase();
    if (query.isEmpty) {
      return profiles.toList(growable: false);
    }

    return profiles
        .where((profile) {
          return profile.rifleName.toLowerCase().contains(query) ||
              profile.caliber.toLowerCase().contains(query);
        })
        .toList(growable: false);
  }

  void setSearchQuery(String value) {
    searchQuery.value = value;
  }

  Future<void> saveProfile({
    String? profileId,
    required String rifleName,
    required String caliber,
    required String bulletGrain,
    required String velocityFps,
    required List<DopeProfileEntry> entries,
    required bool isActive,
  }) async {
    final trimmedRifleName = rifleName.trim();
    final trimmedCaliber = caliber.trim();
    final parsedBulletGrain = double.tryParse(bulletGrain.trim());
    final parsedVelocityFps = double.tryParse(velocityFps.trim());

    if (trimmedRifleName.isEmpty) {
      throw ArgumentError('Rifle name is required.');
    }
    if (parsedBulletGrain == null || parsedBulletGrain <= 0) {
      throw ArgumentError('Enter a valid bullet grain.');
    }
    if (parsedVelocityFps == null || parsedVelocityFps <= 0) {
      throw ArgumentError('Enter a valid velocity FPS.');
    }
    if (entries.isEmpty) {
      throw ArgumentError('Add at least one DOPE row.');
    }

    final existing = profileId == null
        ? null
        : _repository.profileById(profileId);
    final now = DateTime.now();
    final resolvedProfileId =
        existing?.id ?? IdGenerator.generate(prefix: 'dope');
    final normalizedEntries = entries
        .map(
          (entry) => entry.copyWith(
            id: entry.id.isEmpty
                ? IdGenerator.generate(prefix: 'dope-row')
                : entry.id,
            profileId: resolvedProfileId,
          ),
        )
        .toList(growable: false);

    final profile =
        existing?.copyWith(
          rifleName: trimmedRifleName,
          caliber: trimmedCaliber,
          bulletGrain: parsedBulletGrain,
          velocityFps: parsedVelocityFps,
          entries: normalizedEntries,
          isActive: isActive,
          updatedAt: now,
        ) ??
        DopeProfile(
          id: resolvedProfileId,
          rifleName: trimmedRifleName,
          caliber: trimmedCaliber,
          bulletGrain: parsedBulletGrain,
          velocityFps: parsedVelocityFps,
          entries: normalizedEntries,
          isActive: isActive,
          createdAt: now,
          updatedAt: now,
        );

    await _repository.upsert(profile);
    if (isActive) {
      await _repository.setActive(profile.id);
    }
  }

  Future<void> deleteProfile(String profileId) async {
    await _repository.delete(profileId);
  }

  Future<void> setActiveProfile(String? profileId) async {
    await _repository.setActive(profileId);
  }
}
