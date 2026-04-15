import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/services/auth_service.dart';

class ForgotPasswordController extends GetxController {
  ForgotPasswordController(this._authService);

  final AuthService _authService;

  final emailController = TextEditingController();
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetLink() async {
    final email = emailController.text.trim();
    if (email.isEmpty) {
      errorMessage.value = 'Enter the email linked to your account.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      final normalizedEmail = await _authService.requestPasswordReset(
        email: email,
      );
      Get.toNamed(
        AppRoutes.checkEmail,
        arguments: <String, dynamic>{'email': normalizedEmail},
      );
    } on AuthException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }
}
