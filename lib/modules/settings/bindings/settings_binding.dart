import 'package:get/get.dart';
import 'package:milexact/data/repositories/settings_repository.dart';
import 'package:milexact/modules/settings/controllers/settings_controller.dart';

class SettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SettingsController>(
      () => SettingsController(Get.find<SettingsRepository>()),
    );
  }
}
