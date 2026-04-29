import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/modules/auth/controllers/sign_in_controller.dart';
import 'package:milexact/modules/auth/widgets/auth_card_layout.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';

class SignInScreen extends GetView<SignInController> {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthCardLayout(
      header: const AuthLogoBadge(),
      title: 'Welcome to MilExact',
      subtitle: 'Sign in to continue',
      child: Obx(
        () => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            OutlinedButton.icon(
              onPressed: controller.socialLoadingProvider.value == null
                  ? controller.signInWithGoogle
                  : null,
              icon: controller.socialLoadingProvider.value == 'google'
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const _GoogleBadge(),
              label: const Text('Continue with Google'),
            ),
            if (controller.supportsAppleSignIn) ...[
              const SizedBox(height: AppSpacing.sm),
              OutlinedButton.icon(
                onPressed: controller.socialLoadingProvider.value == null
                    ? controller.signInWithApple
                    : null,
                icon: controller.socialLoadingProvider.value == 'apple'
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.apple_rounded),
                label: const Text('Continue with Apple'),
              ),
            ],
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                const Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Text('OR', style: theme.textTheme.bodySmall),
                ),
                const Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: 'Email',
              controller: controller.emailController,
              hint: 'you@example.com',
              textInputAction: TextInputAction.next,
              keyboardType: TextInputType.emailAddress,
              prefixIcon: const Icon(Icons.mail_outline_rounded),
              autofillHints: const [AutofillHints.email],
              autocorrect: false,
            ),
            const SizedBox(height: AppSpacing.md),
            LabeledTextField(
              label: 'Password',
              controller: controller.passwordController,
              hint: 'Min. 8 characters',
              obscureText: controller.obscurePassword.value,
              textInputAction: TextInputAction.done,
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                onPressed: controller.togglePasswordVisibility,
                icon: Icon(
                  controller.obscurePassword.value
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                ),
              ),
              autofillHints: const [AutofillHints.password],
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
              onPressed: controller.isLoading.value ? null : controller.signIn,
              child: controller.isLoading.value
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Sign in'),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.forgotPassword),
                    child: const Text('Forgot password?'),
                  ),
                ),
                Expanded(
                  child: TextButton(
                    onPressed: () => Get.toNamed(AppRoutes.signUp),
                    child: const Text('Need an account? Sign up'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
      ),
      child: Text(
        'G',
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
