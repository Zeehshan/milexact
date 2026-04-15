import 'package:get/get.dart';
import 'package:milexact/data/repositories/presets_repository.dart';
import 'package:milexact/data/repositories/settings_repository.dart';
import 'package:milexact/modules/calculator/controllers/calculator_controller.dart';
import 'package:milexact/services/calculation_service.dart';
import 'package:milexact/services/reticle_measurement_service.dart';

class CalculatorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CalculatorController>(
      () => CalculatorController(
        Get.find<PresetsRepository>(),
        Get.find<SettingsRepository>(),
        Get.find<CalculationService>(),
        Get.find<ReticleMeasurementService>(),
      ),
    );
  }
}
