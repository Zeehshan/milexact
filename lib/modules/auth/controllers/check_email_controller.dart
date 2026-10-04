import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/modules/auth/models/models.dart';
import 'package:milexact/services/auth_service.dart';

class CheckEmailController extends GetxController {
  CheckEmailController(this._authService, this.mode, this.email);

  final AuthService _authService;
  final CheckEmailMode mode;
  final String email;

  final isLoading = false.obs;
  final errorMessage = ''.obs;

  bool get isVerificationMode => mode == CheckEmailMode.verification;

  Future<void> resend() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      if (isVerificationMode) {
        await _authService.resendEmailVerification();
        Get.snackbar(
          'Verification email sent',
          'Check $email for a new verification email.',
        );
      } else {
        await _authService.requestPasswordReset(email: email);
        Get.snackbar(
          'Reset email sent',
          'Check $email for password reset instructions.',
        );
      }
    } on AuthException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> continuePrimaryAction() async {
    if (!isVerificationMode) {
      Get.offAllNamed(AppRoutes.signIn);
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final verified = await _authService.refreshVerificationStatus();
      if (!verified) {
        errorMessage.value =
            'Email is not verified yet. Complete verification, then try again.';
        return;
      }

      Get.offAllNamed(AppRoutes.home);
    } on AuthException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> backToSignIn() async {
    if (isVerificationMode && _authService.isSignedIn) {
      await _authService.signOut();
      return;
    }
    Get.offAllNamed(AppRoutes.signIn);
  }
}
