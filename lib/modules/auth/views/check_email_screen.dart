import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/modules/auth/controllers/controllers.dart';
import 'package:milexact/modules/auth/widgets/auth_card_layout.dart';
import 'package:milexact/shared/constants/app_spacing.dart';

class CheckEmailScreen extends GetView<CheckEmailController> {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthCardLayout(
      header: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary.withValues(alpha: 0.1),
        ),
        child: const Icon(
          Icons.mark_email_read_outlined,
          size: 38,
          color: AppColors.primary,
        ),
      ),
      title: controller.isVerificationMode
          ? 'Verify your email'
          : 'Check your email',
      subtitle: controller.isVerificationMode
          ? 'We sent a verification email to ${controller.email}. Verify your address before entering the app.'
          : 'We sent password reset instructions to ${controller.email}. Follow the email link to update your password.',
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                ),
              ),
              child: Text(
                controller.isVerificationMode
                    ? 'Open the verification email, confirm the address, then return here and continue.'
                    : 'Open the reset email, complete the password change, then sign back in.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            if (controller.errorMessage.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                controller.errorMessage.value,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.continuePrimaryAction,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      controller.isVerificationMode
                          ? 'I verified my email'
                          : 'Back to sign in',
                    ),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton(
              onPressed: controller.isLoading.value ? null : controller.resend,
              child: Text(
                controller.isVerificationMode
                    ? 'Resend verification email'
                    : 'Resend reset email',
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            TextButton.icon(
              onPressed: controller.isLoading.value
                  ? null
                  : controller.backToSignIn,
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Back to sign in'),
            ),
          ],
        ),
      ),
    );
  }
}
