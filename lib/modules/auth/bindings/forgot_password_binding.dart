import 'package:get/get.dart';
import 'package:milexact/modules/auth/controllers/controllers.dart';
import 'package:milexact/services/auth_service.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ForgotPasswordController>(
      () => ForgotPasswordController(Get.find<AuthService>()),
    );
  }
}
