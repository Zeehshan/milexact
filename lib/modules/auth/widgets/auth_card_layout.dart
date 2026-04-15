import 'package:flutter/material.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/shared/constants/app_spacing.dart';

class AuthCardLayout extends StatelessWidget {
  const AuthCardLayout({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
    this.header,
    this.backLabel,
    this.onBack,
  });

  final String title;
  final String subtitle;
  final Widget child;
  final Widget? header;
  final String? backLabel;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.28),
                      blurRadius: 32,
                      offset: const Offset(0, 16),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      height: 3,
                      decoration: const BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(28),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                        AppSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (backLabel != null && onBack != null) ...[
                            TextButton.icon(
                              onPressed: onBack,
                              icon: const Icon(Icons.arrow_back_rounded),
                              label: Text(backLabel!),
                            ),
                            const SizedBox(height: AppSpacing.sm),
                          ],
                          if (header != null) ...[
                            Center(child: header!),
                            const SizedBox(height: AppSpacing.lg),
                          ],
                          Center(
                            child: Column(
                              children: [
                                Text(
                                  title,
                                  style: theme.textTheme.headlineMedium,
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Text(
                                  subtitle,
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          child,
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthLogoBadge extends StatelessWidget {
  const AuthLogoBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.primary.withValues(alpha: 0.16),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.34)),
      ),
      child: const Icon(
        Icons.gps_fixed_rounded,
        size: 42,
        color: AppColors.primary,
      ),
    );
  }
}
