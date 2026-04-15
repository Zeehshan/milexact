import 'package:get/get.dart';
import 'package:milexact/data/models/app_settings.dart';
import 'package:milexact/data/models/auth_user.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/repositories/settings_repository.dart';
import 'package:milexact/services/auth_service.dart';

class SettingsController extends GetxController {
  SettingsController(this._repository, this._authService);

  final SettingsRepository _repository;
  final AuthService _authService;

  Rx<AppSettings> get settings => _repository.settings;
  Rxn<AuthUser> get currentUser => _authService.currentUser;

  Future<void> updateDisplayPreference(
    DistanceDisplayPreference preference,
  ) async {
    await _repository.updateDefaultDisplayUnit(preference);
  }

  Future<void> updateTargetUnit(UnitType unit) async {
    await _repository.updateDefaultTargetUnit(unit);
  }

  Future<void> updateReticleType(ReticleType reticleType) async {
    await _repository.updateDefaultReticleType(reticleType);
  }

  Future<void> updateLiveCalculationEnabled(bool enabled) async {
    await _repository.updateLiveCalculationEnabled(enabled);
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
