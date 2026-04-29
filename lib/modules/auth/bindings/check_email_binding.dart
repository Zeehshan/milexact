import 'package:get/get.dart';
import 'package:milexact/modules/auth/controllers/check_email_controller.dart';
import 'package:milexact/modules/auth/models/check_email_mode.dart';
import 'package:milexact/services/auth_service.dart';

class CheckEmailBinding extends Bindings {
  @override
  void dependencies() {
    final arguments = Get.arguments as Map<String, dynamic>? ?? const {};
    final email = (arguments['email'] as String?) ?? '';
    final mode = CheckEmailModeX.fromRouteValue(arguments['mode'] as String?);

    Get.lazyPut<CheckEmailController>(
      () => CheckEmailController(Get.find<AuthService>(), mode, email),
    );
  }
}
