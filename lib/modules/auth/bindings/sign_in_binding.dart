import 'package:get/get.dart';
import 'package:milexact/modules/auth/controllers/sign_in_controller.dart';
import 'package:milexact/services/auth_service.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(
      () => SignInController(Get.find<AuthService>()),
    );
  }
}
