import 'package:flutter/material.dart';
import 'package:milexact/data/models/distance_result.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/section_card.dart';

class ResultCard extends StatelessWidget {
  const ResultCard({
    super.key,
    required this.result,
    required this.errorMessage,
  });

  final DistanceResult? result;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasResult = result != null;

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Distance Solution', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (hasResult) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (result!.showsMeters)
                  _DistanceStat(
                    label: 'METERS',
                    value: AppFormatters.distance(
                      result!.distanceMeters,
                      unitLabel: 'm',
                    ),
                  ),
                if (result!.showsYards)
                  _DistanceStat(
                    label: 'YARDS',
                    value: AppFormatters.distance(
                      result!.distanceYards,
                      unitLabel: 'yd',
                    ),
                  ),
              ],
            ),
          ] else ...[
            Text(
              'Enter a target size and reticle reading to calculate distance.',
              style: theme.textTheme.bodyLarge,
            ),
          ],
          if (errorMessage.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Text(
              errorMessage,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DistanceStat extends StatelessWidget {
  const _DistanceStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.28),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.headlineMedium),
        ],
      ),
    );
  }
}
