import 'package:get/get.dart';
import 'package:milexact/data/models/app_settings.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/repositories/settings_repository.dart';

class SettingsController extends GetxController {
  SettingsController(this._repository);

  final SettingsRepository _repository;

  Rx<AppSettings> get settings => _repository.settings;

  Future<void> updateOutputPreference(
    DistanceOutputPreference preference,
  ) async {
    await _repository.updateDefaultOutputPreference(preference);
  }

  Future<void> updateTargetUnit(MeasurementUnit unit) async {
    await _repository.updateDefaultTargetUnit(unit);
  }

  Future<void> updateReticleType(ReticleType reticleType) async {
    await _repository.updateDefaultReticleType(reticleType);
  }

  Future<void> updateAutoCalculateEnabled(bool enabled) async {
    await _repository.updateAutoCalculateEnabled(enabled);
  }
}
