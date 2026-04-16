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
    required this.showResult,
  });

  final DistanceResult? result;
  final String errorMessage;
  final bool showResult;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SectionCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!showResult)
            Text('Distance Solution', style: theme.textTheme.titleLarge),
          const SizedBox(height: AppSpacing.md),
          if (!showResult)
            Text(
              'Use the reticle and target dimensions to solve range instantly.',
              style: theme.textTheme.bodyLarge,
            ),
          if (showResult == true && result != null) ...[
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (result!.showsMeters)
                  _DistancePill(
                    label: 'METERS',
                    value: AppFormatters.distance(
                      result!.distanceMeters,
                      unitLabel: 'm',
                    ),
                  ),
                if (result!.showsYards)
                  _DistancePill(
                    label: 'YARDS',
                    value: AppFormatters.distance(
                      result!.distanceYards,
                      unitLabel: 'yd',
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Text(result!.formulaPreview, style: theme.textTheme.bodySmall),
          ],
          if (errorMessage.isNotEmpty && (!showResult)) ...[
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

class _DistancePill extends StatelessWidget {
  const _DistancePill({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        color: theme.colorScheme.primary.withValues(alpha: 0.13),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.24),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              letterSpacing: 1.0,
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
