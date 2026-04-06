import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/modules/range_card/controllers/range_card_edit_controller.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class RangeCardEditScreen extends GetView<RangeCardEditController> {
  const RangeCardEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TacticalScaffold(
      title: controller.isExistingEntry ? 'Edit Entry' : 'Add Entry',
      showBottomNav: false,
      body: Obx(
        () => SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Distance Summary', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    Wrap(
                      spacing: AppSpacing.sm,
                      runSpacing: AppSpacing.sm,
                      children: [
                        _SummaryStat(
                          label: 'METERS',
                          value: AppFormatters.distance(
                            controller.entry.calculatedDistanceMeters,
                            unitLabel: 'm',
                          ),
                        ),
                        _SummaryStat(
                          label: 'YARDS',
                          value: AppFormatters.distance(
                            controller.entry.calculatedDistanceYards,
                            unitLabel: 'yd',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Target size: ${AppFormatters.targetSize(controller.entry.targetSizeValue, controller.entry.targetSizeUnit)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Reticle reading: ${AppFormatters.number(controller.entry.reticleReading)} ${controller.entry.reticleType.label}',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Range Card Details',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.targetLabelController,
                      label: 'Target Label',
                      hint: 'Target label',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.dopeController,
                      label: 'DOPE',
                      hint: 'Manual DOPE value',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.windFullController,
                      label: 'Wind Full',
                      hint: 'Manual full-value wind hold',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.windHalfController,
                      label: 'Wind Half',
                      hint: 'Manual half-value wind hold',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.windQuarterController,
                      label: 'Wind Quarter',
                      hint: 'Manual quarter-value wind hold',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.notesController,
                      label: 'Notes',
                      hint: 'Optional notes',
                      maxLines: 4,
                      minLines: 3,
                    ),
                    if (controller.errorMessage.value.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        controller.errorMessage.value,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: controller.save,
                icon: const Icon(Icons.save_rounded),
                label: Text(
                  controller.isExistingEntry ? 'Update Entry' : 'Save Entry',
                ),
              ),
              if (controller.isExistingEntry) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _confirmDelete,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                  ),
                  icon: const Icon(Icons.delete_outline_rounded),
                  label: const Text('Delete Entry'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete() async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Entry'),
        content: Text(
          'Delete "${controller.entry.targetName}" from the range card?',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      await controller.deleteEntry();
    }
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: 150,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.xs),
          Text(value, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}
