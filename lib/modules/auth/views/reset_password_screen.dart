import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/modules/auth/controllers/controllers.dart';
import 'package:milexact/modules/auth/widgets/auth_card_layout.dart';
import 'package:milexact/shared/constants/app_spacing.dart';

class ResetPasswordScreen extends GetView<ResetPasswordController> {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthCardLayout(
      backLabel: 'Back to sign in',
      onBack: controller.backToSignIn,
      title: 'Reset your password',
      subtitle:
          'Password reset now happens from the Firebase email link sent to ${controller.email}.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Open the reset email, complete the password change there, then return and sign in with the new password.',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.md),
          FilledButton(
            onPressed: controller.backToSignIn,
            child: const Text('Back to sign in'),
          ),
        ],
      ),
    );
  }
}
