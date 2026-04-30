import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/modules/auth/controllers/controllers.dart';
import 'package:milexact/modules/auth/widgets/auth_card_layout.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';

class SignUpScreen extends GetView<SignUpController> {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthCardLayout(
      backLabel: 'Back to sign in',
      onBack: Get.back,
      title: 'Create your account',
      subtitle:
          'Create a Firebase-backed MilExact account and verify your email.',
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledTextField(
              label: 'Email',
              controller: controller.emailController,
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              autofillHints: const [AutofillHints.newUsername],
              autocorrect: false,
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: 'Password',
              controller: controller.passwordController,
              hint: 'Min. 8 characters',
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.next,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
              ),
              autofillHints: const [AutofillHints.newPassword],
              autocorrect: false,
              enableSuggestions: false,
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: 'Confirm Password',
              controller: controller.confirmPasswordController,
              hint: 'Re-enter password',
              obscureText: controller.obscureConfirmPassword.value,
              textInputAction: TextInputAction.done,
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
              onPressed: controller.isLoading.value ? null : controller.signUp,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Create account'),
            ),
          ],
        ),
      ),
    );
  }
}
