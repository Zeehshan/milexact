import 'package:get/get.dart';
import 'package:milexact/data/repositories/dope_profiles_repository.dart';
import 'package:milexact/modules/dope/controllers/dope_profiles_controller.dart';

class DopeProfilesBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<DopeProfilesController>()) {
      return;
    }
    Get.lazyPut<DopeProfilesController>(
      () => DopeProfilesController(Get.find<DopeProfilesRepository>()),
    );
  }
}
