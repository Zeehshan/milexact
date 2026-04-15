import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/modules/auth/controllers/reset_password_controller.dart';
import 'package:milexact/modules/auth/widgets/auth_card_layout.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthCardLayout(
      backLabel: 'Back to sign in',
      onBack: () => Get.offAllNamed(AppRoutes.signIn),
      title: 'Set new password',
      subtitle: 'Enter a new password for ${controller.email}.',
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledTextField(
              label: 'New Password',
              controller: controller.passwordController,
              hint: 'Must be at least 8 characters',
              obscureText: controller.obscurePassword.value,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
              ),
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: 'Confirm New Password',
              controller: controller.confirmPasswordController,
              hint: 'Re-enter password',
              obscureText: controller.obscureConfirmPassword.value,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: controller.toggleConfirmPasswordVisibility,
                icon: Icon(
                  controller.obscureConfirmPassword.value
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
              ),
              autocorrect: false,
              enableSuggestions: false,
            ),
            if (controller.errorMessage.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                controller.errorMessage.value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.resetPassword,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Reset password'),
            ),
          ],
        ),
      ),
    );
  }
}
