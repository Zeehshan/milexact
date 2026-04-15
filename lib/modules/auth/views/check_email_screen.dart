import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/modules/auth/widgets/auth_card_layout.dart';
import 'package:milexact/shared/constants/app_spacing.dart';

class CheckEmailScreen extends StatelessWidget {
  const CheckEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final email =
        ((Get.arguments as Map<String, dynamic>?)?['email'] as String?) ?? '';
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
      title: 'Check your email',
      subtitle:
          'A reset link would be sent to $email. In local mode, continue below to set a new password.',
      child: Column(
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
              'No email is sent while the app is running in local auth mode. Use the button below to continue the reset flow on this device.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.success,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: () => Get.toNamed(
              AppRoutes.resetPassword,
              arguments: <String, dynamic>{'email': email},
            ),
            child: const Text('Continue to reset password'),
          ),
          const SizedBox(height: AppSpacing.sm),
          TextButton.icon(
            onPressed: () => Get.offAllNamed(AppRoutes.signIn),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }
}
