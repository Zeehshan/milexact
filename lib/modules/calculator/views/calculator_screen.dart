import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/modules/calculator/controllers/calculator_controller.dart';
import 'package:milexact/modules/calculator/widgets/result_card.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/empty_state_view.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class CalculatorScreen extends GetView<CalculatorController> {
  CalculatorScreen({super.key});

  final _decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*$'),
  );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TacticalScaffold(
      title: 'MilExact',
      currentRoute: AppRoutes.calculator,
      body: Obx(() {
        final categories = controller.categories.toList(growable: false);
        final presets = controller.availablePresets;
        final selectedPresetId = controller.selectedPresetId.value;

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResultCard(
                result: controller.result.value,
                errorMessage: controller.errorMessage.value,
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.openRangeCard,
                        icon: const Icon(Icons.view_agenda_rounded),
                        label: const Text('Open Range Card'),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: controller.openPresetManager,
                        icon: const Icon(Icons.category_rounded),
                        label: const Text('Manage Presets'),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Input', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    SelectorChips<TargetInputMode>(
                      options: TargetInputMode.values,
                      selectedValue: controller.targetInputMode.value,
                      labelBuilder: (mode) => mode.label,
                      onSelected: controller.setTargetInputMode,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (controller.isPresetMode) ...[
                      if (categories.isEmpty)
                        const EmptyStateView(
                          title: 'No target categories',
                          description:
                              'Add categories and presets in the manager to use saved target references.',
                          icon: Icons.category_outlined,
                        )
                      else ...[
                        Text('Category', style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        SelectorChips<String>(
                          options: categories
                              .map((category) => category.id)
                              .toList(growable: false),
                          selectedValue: controller.selectedCategoryId.value,
                          labelBuilder: (categoryId) => categories
                              .firstWhere(
                                (category) => category.id == categoryId,
                              )
                              .name,
                          onSelected: controller.setCategory,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'Preset Target',
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            '${controller.selectedCategoryId.value}-$selectedPresetId',
                          ),
                          initialValue:
                              presets.any(
                                (preset) => preset.id == selectedPresetId,
                              )
                              ? selectedPresetId
                              : null,
                          items: presets
                              .map(
                                (preset) => DropdownMenuItem<String>(
                                  value: preset.id,
                                  child: Text(
                                    '${preset.name} • ${AppFormatters.targetSize(preset.sizeValue, preset.sizeUnit)}',
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          onChanged: presets.isEmpty
                              ? null
                              : (value) {
                                  if (value != null) {
                                    controller.setPreset(value);
                                  }
                                },
                          decoration: const InputDecoration(
                            hintText: 'Select a preset',
                          ),
                        ),
                        if (controller.selectedPreset != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Preset size: ${AppFormatters.targetSize(controller.selectedPreset!.sizeValue, controller.selectedPreset!.sizeUnit)}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ],
                      ],
                    ] else ...[
                      LabeledTextField(
                        controller: controller.manualTargetNameController,
                        label: 'Target Name',
                        hint: 'Custom target label',
                      ),
                      const SizedBox(height: AppSpacing.md),
                      LabeledTextField(
                        controller: controller.manualTargetSizeController,
                        label: 'Target Size',
                        hint: 'Enter target size',
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [_decimalFormatter],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Target Unit', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      SelectorChips<MeasurementUnit>(
                        options: MeasurementUnit.values,
                        selectedValue: controller.selectedTargetUnit.value,
                        labelBuilder: (unit) => unit.shortLabel.toUpperCase(),
                        onSelected: controller.setTargetUnit,
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ranging Setup', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Measurement System',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<MeasurementSystem>(
                      options: MeasurementSystem.values,
                      selectedValue: controller.measurementSystem.value,
                      labelBuilder: (system) => system.label,
                      onSelected: controller.setMeasurementSystem,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.reticleReadingController,
                      label: 'Reticle Reading',
                      hint: 'Enter MIL or MRAD reading',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [_decimalFormatter],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Reticle Type', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<ReticleType>(
                      options: ReticleType.values,
                      selectedValue: controller.selectedReticleType.value,
                      labelBuilder: (type) => type.label,
                      onSelected: controller.setReticleType,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Distance Output', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<DistanceOutputPreference>(
                      options: DistanceOutputPreference.values,
                      selectedValue: controller.outputPreference.value,
                      labelBuilder: (preference) => preference.label,
                      onSelected: controller.setOutputPreference,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      controller.autoCalculateEnabled.value
                          ? 'Live calculation is enabled in settings. Use the button to force a refresh anytime.'
                          : 'Auto-calculate is disabled. Use the button below to solve distance.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              FilledButton.icon(
                onPressed: controller.calculate,
                icon: const Icon(Icons.calculate_rounded),
                label: Text(
                  controller.autoCalculateEnabled.value
                      ? 'Refresh Distance'
                      : 'Calculate Distance',
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              FilledButton.tonalIcon(
                onPressed: controller.result.value == null
                    ? null
                    : controller.addToRangeCard,
                icon: const Icon(Icons.playlist_add_rounded),
                label: const Text('Add to Range Card'),
              ),
            ],
          ),
        );
      }),
    );
  }
}
