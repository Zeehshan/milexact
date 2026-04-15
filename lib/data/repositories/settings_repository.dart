import 'package:get/get.dart';
import 'package:milexact/data/local/seed_data.dart';
import 'package:milexact/data/models/app_settings.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/services/storage_service.dart';

class SettingsRepository extends GetxService {
  SettingsRepository(this._storage);

  static const _settingsKey = 'settings';

  final StorageService _storage;
  final Rx<AppSettings> settings = SeedData.defaultSettings().obs;

  Future<SettingsRepository> init() async {
    final raw = _storage.settingsBox.get(_settingsKey);
    if (raw == null) {
      await _storage.settingsBox.put(_settingsKey, settings.value.toJson());
    } else {
      settings.value = AppSettings.fromJson(Map<String, dynamic>.from(raw));
    }

    return this;
  }

  Future<void> save(AppSettings nextSettings) async {
    settings.value = nextSettings;
    await _storage.settingsBox.put(_settingsKey, nextSettings.toJson());
  }

  Future<void> updateDefaultDisplayUnit(DistanceDisplayPreference preference) {
    return save(settings.value.copyWith(defaultDisplayUnit: preference));
  }

  Future<void> updateDefaultTargetUnit(UnitType unit) {
    return save(settings.value.copyWith(defaultTargetUnit: unit));
  }

  Future<void> updateDefaultReticleType(ReticleType reticleType) {
    return save(settings.value.copyWith(defaultReticleType: reticleType));
  }

  Future<void> updateLiveCalculationEnabled(bool enabled) {
    return save(settings.value.copyWith(liveCalculationEnabled: enabled));
  }
}
