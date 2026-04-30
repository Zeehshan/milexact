import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/modules/auth/models/models.dart';
import 'package:milexact/services/auth_service.dart';

class SignUpController extends GetxController {
  SignUpController(this._authService);

  final AuthService _authService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscurePassword = true.obs;
  final obscureConfirmPassword = true.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  void toggleConfirmPasswordVisibility() {
    obscureConfirmPassword.value = !obscureConfirmPassword.value;
  }

  Future<void> signUp() async {
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      errorMessage.value = 'Complete all fields to create your account.';
      return;
    }
    if (password != confirmPassword) {
      errorMessage.value = 'Passwords do not match.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.signUp(email: email, password: password);
      Get.offAllNamed(
        AppRoutes.checkEmail,
        arguments: <String, dynamic>{
          'email': _authService.currentUser.value?.email ?? email.trim(),
          'mode': CheckEmailMode.verification.routeValue,
        },
      );
    } on AuthException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }
}
