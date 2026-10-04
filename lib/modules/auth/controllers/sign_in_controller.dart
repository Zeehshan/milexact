import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/modules/auth/models/models.dart';
import 'package:milexact/services/auth_service.dart';

class SignInController extends GetxController {
  SignInController(this._authService);

  final AuthService _authService;

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final obscurePassword = true.obs;
  final isLoading = false.obs;
  final socialLoadingProvider = RxnString();
  final errorMessage = ''.obs;

  bool get supportsAppleSignIn => _authService.supportsAppleSignIn;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  Future<void> signIn() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      errorMessage.value = 'Enter your email and password.';
      return;
    }

    isLoading.value = true;
    errorMessage.value = '';

    try {
      await _authService.signIn(email: email, password: password);
      if (_authService.needsEmailVerification) {
        Get.offAllNamed(
          AppRoutes.checkEmail,
          arguments: <String, dynamic>{
            'email': _authService.currentUser.value?.email ?? email.trim(),
            'mode': CheckEmailMode.verification.routeValue,
          },
        );
        return;
      }

      Get.offAllNamed(AppRoutes.home);
    } on AuthException catch (error) {
      errorMessage.value = error.message;
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> signInWithGoogle() async {
    await _runSocialSignIn(
      provider: 'google',
      action: _authService.signInWithGoogle,
    );
  }

  Future<void> signInWithApple() async {
    await _runSocialSignIn(
      provider: 'apple',
      action: _authService.signInWithApple,
    );
  }

  Future<void> _runSocialSignIn({
    required String provider,
    required Future<void> Function() action,
  }) async {
    socialLoadingProvider.value = provider;
    errorMessage.value = '';

    try {
      await action();
      if (_authService.needsEmailVerification) {
        Get.offAllNamed(
          AppRoutes.checkEmail,
          arguments: <String, dynamic>{
            'email':
                _authService.currentUser.value?.email ??
                emailController.text.trim(),
            'mode': CheckEmailMode.verification.routeValue,
          },
        );
        return;
      }
      Get.offAllNamed(AppRoutes.home);
    } on AuthException catch (error) {
      errorMessage.value = error.message;
    } finally {
      socialLoadingProvider.value = null;
    }
  }
}
