import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/modules/auth/controllers/controllers.dart';
import 'package:milexact/modules/auth/widgets/auth_card_layout.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';

class ForgotPasswordScreen extends GetView<ForgotPasswordController> {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthCardLayout(
      backLabel: 'Back to sign in',
      onBack: Get.back,
      title: 'Reset your password',
      subtitle:
          'Enter your email and we will send a Firebase password reset link.',
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            LabeledTextField(
              label: 'Email',
              controller: controller.emailController,
              hint: 'you@example.com',
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
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
                  : controller.sendResetLink,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Send reset link'),
            ),
          ],
        ),
      ),
    );
  }
}
