import 'package:get/get.dart';
import 'package:milexact/modules/auth/controllers/controllers.dart';
import 'package:milexact/services/auth_service.dart';

class SignInBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SignInController>(
      () => SignInController(Get.find<AuthService>()),
    );
  }
}
