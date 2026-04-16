import 'package:get/get.dart';
import 'package:milexact/data/repositories/presets_repository.dart';
import 'package:milexact/modules/presets/controllers/preset_manager_controller.dart';

class QuickPresetBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<QuickPresetController>()) {
      return;
    }
    Get.lazyPut<QuickPresetController>(
      () => QuickPresetController(Get.find<PresetsRepository>()),
    );
  }
}
