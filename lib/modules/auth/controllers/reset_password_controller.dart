import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';

class ResetPasswordController extends GetxController {
  ResetPasswordController(this.email);

  final String email;

  void backToSignIn() {
    Get.offAllNamed(AppRoutes.signIn);
  }
}
