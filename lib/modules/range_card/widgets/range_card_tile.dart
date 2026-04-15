import 'package:flutter/material.dart';
import 'package:milexact/data/models/range_card_entry.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';

class RangeCardTile extends StatelessWidget {
  const RangeCardTile({
    super.key,
    required this.entry,
    required this.onTap,
    required this.onDelete,
  });

  final RangeCardEntry entry;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          entry.targetName,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          AppFormatters.distanceSummary(
                            preference: entry.displayPreference,
                            meters: entry.distanceMeters,
                            yards: entry.distanceYards,
                          ),
                          style: theme.textTheme.bodyLarge,
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    tooltip: 'Delete',
                    onPressed: onDelete,
                    icon: const Icon(Icons.delete_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _ValueTag(
                    label: 'DOPE',
                    value: entry.dopeValue.isEmpty ? '--' : entry.dopeValue,
                  ),
                  _ValueTag(
                    label: 'Wind',
                    value: AppFormatters.windSummary(
                      entry.windValueType,
                      windDirectionClock: entry.windDirectionClock,
                    ),
                  ),
                  _ValueTag(
                    label: 'Placement',
                    value: entry.targetPlacementLabel.isEmpty
                        ? '${AppFormatters.number(entry.targetPlacementAngle)}°'
                        : entry.targetPlacementLabel,
                  ),
                ],
              ),
              if (entry.terrainNotes.trim().isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(
                  AppFormatters.preview(entry.terrainNotes),
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _ValueTag extends StatelessWidget {
  const _ValueTag({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Text('$label: $value', style: theme.textTheme.bodySmall),
    );
  }
}
