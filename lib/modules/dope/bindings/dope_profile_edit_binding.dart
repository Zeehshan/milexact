import 'package:get/get.dart';
import 'package:milexact/data/models/dope_profile.dart';
import 'package:milexact/data/repositories/dope_profiles_repository.dart';
import 'package:milexact/modules/dope/controllers/dope_profile_edit_controller.dart';

class DopeProfileEditBinding extends Bindings {
  @override
  void dependencies() {
    final profile = Get.arguments is DopeProfile
        ? Get.arguments as DopeProfile
        : null;

    Get.lazyPut<DopeProfileEditController>(
      () => DopeProfileEditController(
        Get.find<DopeProfilesRepository>(),
        initialProfile: profile,
      ),
    );
  }
}
