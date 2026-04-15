import 'package:get/get.dart';
import 'package:milexact/modules/auth/controllers/sign_up_controller.dart';
import 'package:milexact/services/auth_service.dart';

class SignUpBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignUpController>(
      () => SignUpController(Get.find<AuthService>()),
    );
  }
}
