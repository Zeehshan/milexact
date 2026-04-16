import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/modules/calculator/controllers/calculator_controller.dart';
import 'package:milexact/modules/calculator/widgets/reticle_profile_picker.dart';
import 'package:milexact/modules/calculator/widgets/result_card.dart';
import 'package:milexact/modules/calculator/widgets/reticle_measurement_panel.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/empty_state_view.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class CalculatorScreen extends GetView<CalculatorController> {
  CalculatorScreen({super.key, this.showBottomNav = true});

  final _decimalFormatter = FilteringTextInputFormatter.allow(
    RegExp(r'^\d*\.?\d*$'),
  );
  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TacticalScaffold(
      title: 'MilExact',
      currentRoute: AppRoutes.calculator,
      showBottomNav: showBottomNav,
      body: Obx(() {
        final categories = controller.categories.toList(growable: false);
        final presets = controller.availablePresets;
        final selectedPresetId = controller.selectedPresetId.value;
        final selectedPreset = controller.selectedPreset;

        return SingleChildScrollView(
          physics:
              controller.isMeasurementModeEnabled.value ||
                  controller.isReticleInteracting.value
              ? const NeverScrollableScrollPhysics()
              : null,
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ResultCard(
                showResult: false,
                result: controller.result.value,
                errorMessage: controller.errorMessage.value,
              ),
              // const SizedBox(height: AppSpacing.md),
              // SectionCard(
              //   child: Wrap(
              //     spacing: AppSpacing.sm,
              //     runSpacing: AppSpacing.sm,
              //     children: [
              //       FilledButton.tonalIcon(
              //         onPressed: controller.openRangeCard,
              //         icon: const Icon(Icons.view_agenda_rounded),
              //         label: const Text('Range Card'),
              //       ),
              //       FilledButton.tonalIcon(
              //         onPressed: controller.openDopeProfiles,
              //         icon: const Icon(Icons.straighten_rounded),
              //         label: const Text('DOPE'),
              //       ),
              //       FilledButton.tonalIcon(
              //         onPressed: controller.openVisualRangeCard,
              //         icon: const Icon(Icons.explore_rounded),
              //         label: const Text('Visual Card'),
              //       ),
              //     ],
              //   ),
              // ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Target Setup', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    SelectorChips<TargetInputMode>(
                      options: TargetInputMode.values,
                      selectedValue: controller.targetInputMode.value,
                      labelBuilder: (mode) => mode.label,
                      onSelected: controller.setTargetInputMode,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (controller.isPresetMode) ...[
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Quick Presets',
                              style: theme.textTheme.titleMedium,
                            ),
                          ),
                          OutlinedButton.icon(
                            onPressed: controller.openQuickPresets,
                            icon: const Icon(Icons.category_rounded),
                            label: const Text('Browse'),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (categories.isEmpty)
                        const EmptyStateView(
                          title: 'No quick presets',
                          description:
                              'Create categories and presets to speed up field ranging.',
                          icon: Icons.category_outlined,
                        )
                      else ...[
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
                        DropdownButtonFormField<String>(
                          key: ValueKey(
                            '${controller.selectedCategoryId.value}-$selectedPresetId',
                          ),
                          isExpanded: true,
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
                                    '${preset.name} • H ${AppFormatters.targetSize(preset.heightValue, preset.heightUnit)} • W ${AppFormatters.targetSize(preset.widthValue, preset.widthUnit)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              )
                              .toList(growable: false),
                          selectedItemBuilder: (context) => presets
                              .map(
                                (preset) => Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    '${preset.name} • H ${AppFormatters.targetSize(preset.heightValue, preset.heightUnit)}',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
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
                        if (selectedPreset != null) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Preset dimensions: H ${AppFormatters.targetSize(selectedPreset.heightValue, selectedPreset.heightUnit)} • W ${AppFormatters.targetSize(selectedPreset.widthValue, selectedPreset.widthUnit)}',
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
                      Row(
                        children: [
                          Expanded(
                            child: LabeledTextField(
                              controller:
                                  controller.manualTargetHeightController,
                              label: 'Height',
                              hint: 'Height',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [_decimalFormatter],
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: LabeledTextField(
                              controller:
                                  controller.manualTargetWidthController,
                              label: 'Width',
                              hint: 'Width',
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                  ),
                              inputFormatters: [_decimalFormatter],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Text('Target Unit', style: theme.textTheme.titleMedium),
                      const SizedBox(height: AppSpacing.xs),
                      SelectorChips<UnitType>(
                        options: UnitType.values,
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
                    Text(
                      'Reticle Measurement',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Reticle Type', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<ReticleType>(
                      options: ReticleType.values,
                      selectedValue: controller.selectedReticleType.value,
                      labelBuilder: (type) => type.label,
                      onSelected: controller.setReticleType,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Reticle Format', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    ReticleProfilePicker(
                      selectedProfile: controller.selectedReticleProfile.value,
                      reticleType: controller.selectedReticleType.value,
                      referenceDimension: controller.referenceDimension.value,
                      onSelected: controller.setReticleProfile,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Measurement Mode',
                                style: theme.textTheme.titleMedium,
                              ),
                              const SizedBox(height: 2),
                              SizedBox(
                                height: 35,
                                child: Text(
                                  controller.isMeasurementModeEnabled.value
                                      ? 'Reticle dragging is active and page scrolling is locked.'
                                      : 'Enable this to drag guides inside the reticle.',
                                  style: theme.textTheme.bodySmall,
                                  maxLines: 2,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: controller.isMeasurementModeEnabled.value,
                          onChanged: controller.setMeasurementModeEnabled,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ReticleMeasurementPanel(
                      referenceDimension: controller.referenceDimension.value,
                      baselineFraction: controller.activeBaselineFraction,
                      measurementFraction: controller.activeMeasurementFraction,
                      reticleType: controller.selectedReticleType.value,
                      reticleProfile: controller.selectedReticleProfile.value,
                      readingLabel: controller.reticleReadingInput.value,
                      interactionEnabled:
                          controller.isMeasurementModeEnabled.value,
                      onInteractionActiveChanged:
                          controller.setReticleInteractionActive,
                      onInteractionStart: (localPosition, size) {
                        controller.beginReticleInteraction(
                          localPosition: localPosition,
                          canvasSize: size,
                        );
                      },
                      onInteractionUpdate: (localPosition, size) {
                        controller.updateReticleFromLocalPosition(
                          localPosition: localPosition,
                          canvasSize: size,
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Reference Dimension',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<TargetDimensionType>(
                      options: TargetDimensionType.values,
                      selectedValue: controller.referenceDimension.value,
                      labelBuilder: (dimension) => dimension.label,
                      onSelected: controller.setReferenceDimension,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      !controller.isMeasurementModeEnabled.value
                          ? 'Enable Measurement Mode to place the dashed baseline and drag the amber measurement line.'
                          : controller.referenceDimension.value ==
                                TargetDimensionType.height
                          ? 'Using ${controller.selectedReticleProfile.value.label}. Tap anywhere to place the dashed baseline, then drag to place the amber measurement line for target height.'
                          : 'Using ${controller.selectedReticleProfile.value.label}. Tap anywhere to place the dashed baseline, then drag to place the amber measurement line for the target ${controller.referenceDimension.value.label.toLowerCase()}.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LabeledTextField(
                      controller: controller.reticleReadingController,
                      label: 'Reticle Reading',
                      hint:
                          'Enter ${controller.selectedReticleType.value.label} reading',
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [_decimalFormatter],
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
                      'Display & Formula',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text('Formula Branch', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<MeasurementSystem>(
                      options: MeasurementSystem.values,
                      selectedValue: controller.measurementSystem.value,
                      labelBuilder: (system) => system.label,
                      onSelected: controller.setMeasurementSystem,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Display Units', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<DistanceDisplayPreference>(
                      options: DistanceDisplayPreference.values,
                      selectedValue: controller.displayPreference.value,
                      labelBuilder: (preference) => preference.label,
                      onSelected: controller.setDisplayPreference,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      controller.liveCalculationEnabled.value
                          ? 'Live calculation is enabled. Drag the reticle or edit fields to refresh instantly.'
                          : 'Live calculation is off. Use the button below to calculate after changing inputs.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              if (controller.result.value != null)
                SizedBox(
                  width: double.infinity,
                  child: ResultCard(
                    showResult: true,
                    result: controller.result.value,
                    errorMessage: controller.errorMessage.value,
                  ),
                ),
              // const SizedBox(height: AppSpacing.md),
              // FilledButton.icon(
              //   onPressed: controller.calculate,
              //   icon: const Icon(Icons.calculate_rounded),
              //   label: Text(
              //     controller.liveCalculationEnabled.value
              //         ? 'Refresh Distance'
              //         : 'Calculate Distance',
              //   ),
              // ),
              // const SizedBox(height: AppSpacing.sm),
              Align(
                alignment: Alignment.bottomRight,
                child: FilledButton.tonalIcon(
                  onPressed: controller.canSaveToRangeCard
                      ? controller.addToRangeCard
                      : null,
                  icon: const Icon(Icons.playlist_add_rounded),
                  label: const Text('Save to Range Card'),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
