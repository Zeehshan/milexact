import 'package:get/get.dart';
import 'package:milexact/modules/auth/controllers/reset_password_controller.dart';

class ResetPasswordBinding extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments as Map<String, dynamic>? ?? const {};
    final email = (arguments['email'] as String?) ?? '';

    Get.lazyPut<ResetPasswordController>(() => ResetPasswordController(email));
  }
}
