import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/modules/range_card/controllers/range_card_edit_controller.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class RangeCardEditScreen extends GetView<RangeCardEditController> {
  const RangeCardEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TacticalScaffold(
      title: controller.isExistingEntry ? 'Edit Entry' : 'Add Entry',
      showBottomNav: false,
      currentRoute: AppRoutes.rangeCardEdit,
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
                            controller.entry.distanceMeters,
                            unitLabel: 'm',
                          ),
                        ),
                        _SummaryStat(
                          label: 'YARDS',
                          value: AppFormatters.distance(
                            controller.entry.distanceYards,
                            unitLabel: 'yd',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Height ${AppFormatters.targetSize(controller.entry.targetHeightValue, controller.entry.targetHeightUnit)} • Width ${AppFormatters.targetSize(controller.entry.targetWidthValue, controller.entry.targetWidthUnit)}',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Reticle reading ${AppFormatters.number(controller.entry.reticleReading)} ${controller.entry.reticleType.label}',
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
                    Text('Manual Fields', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.targetLabelController,
                      label: 'Target Label',
                      hint: 'Target label',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    DropdownButtonFormField<String?>(
                      initialValue: controller.selectedDopeProfileId.value,
                      items: [
                        const DropdownMenuItem<String?>(
                          value: null,
                          child: Text('No DOPE profile'),
                        ),
                        ...controller.profiles.map(
                          (profile) => DropdownMenuItem<String?>(
                            value: profile.id,
                            child: Text(profile.rifleName),
                          ),
                        ),
                      ],
                      onChanged: controller.setDopeProfile,
                      decoration: const InputDecoration(
                        labelText: 'Saved DOPE Profile',
                      ),
                    ),
                    if (controller.selectedProfileEntries.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      DropdownButtonFormField<String>(
                        key: ValueKey(
                          controller.selectedDopeProfileId.value ??
                              'no-profile-selected',
                        ),
                        initialValue: controller.selectedDopeEntryId.value,
                        items: controller.selectedProfileEntries
                            .map(
                              (row) => DropdownMenuItem<String>(
                                value: row.id,
                                child: Text(
                                  '${AppFormatters.number(row.distanceValue)} ${row.distanceUnit.shortLabel} • ${row.dropValue}',
                                ),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: controller.setDopeEntry,
                        decoration: const InputDecoration(
                          labelText: 'Saved DOPE Row',
                        ),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.dopeValueController,
                      label: 'DOPE Value',
                      hint: 'Manual DOPE or selected profile row',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Wind Value', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<WindValueType>(
                      options: WindValueType.values,
                      selectedValue: controller.selectedWindValueType.value,
                      labelBuilder: (type) => type.label,
                      onSelected: controller.setWindValueType,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.windDirectionClockController,
                      label: 'Wind Direction Clock',
                      hint: '12, 3, 9...',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Target Placement Angle',
                      style: theme.textTheme.titleMedium,
                    ),
                    Slider(
                      value: controller.targetPlacementAngle.value,
                      min: 0,
                      max: 180,
                      divisions: 36,
                      label:
                          '${AppFormatters.number(controller.targetPlacementAngle.value)}°',
                      onChanged: controller.setTargetPlacementAngle,
                    ),
                    Text(
                      '${AppFormatters.number(controller.targetPlacementAngle.value)}°',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.targetPlacementLabelController,
                      label: 'Target Placement Label',
                      hint: 'Tree line left, berm center...',
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.terrainNotesController,
                      label: 'Terrain Notes',
                      hint: 'Road crossing, creek bed, low wall...',
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
              const SizedBox(height: AppSpacing.sm),
              FilledButton.tonalIcon(
                onPressed: controller.openVisualRangeCard,
                icon: const Icon(Icons.explore_rounded),
                label: const Text('Open Visual Range Card'),
              ),
              if (controller.isExistingEntry) ...[
                const SizedBox(height: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: _confirmDelete,
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
