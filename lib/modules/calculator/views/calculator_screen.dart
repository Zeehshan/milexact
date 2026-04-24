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
                    ReticleMeasurementPanel(
                      referenceDimension: controller.referenceDimension.value,
                      baselineFraction: controller.activeBaselineFraction,
                      measurementFraction: controller.activeMeasurementFraction,
                      reticleType: controller.selectedReticleType.value,
                      reticleProfile: controller.selectedReticleProfile.value,
                      readingLabel: controller.reticleReadingInput.value,
                      lineThickness: controller.reticleLineThickness.value,
                      overlayOpacity: controller.reticleOverlayOpacity.value,
                      zoomFactor: controller.reticleZoom.value,
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
                      onBaselineUpdate: (localPosition, size) {
                        controller.updateReticleBaselineFromLocalPosition(
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
                    const SizedBox(height: AppSpacing.sm),
                    _ReticleOptionsPanel(
                      isMeasuring: controller.isMeasurementModeEnabled.value,
                      thickness: controller.reticleLineThickness.value,
                      opacity: controller.reticleOverlayOpacity.value,
                      onMeasurementModeChanged:
                          controller.setMeasurementModeEnabled,
                      onReset: controller.resetReticleMeasurement,
                      onThicknessChanged: controller.setReticleLineThickness,
                      onOpacityChanged: controller.setReticleOverlayOpacity,
                      onZoomStep: controller.adjustReticleZoom,
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

class _ReticleOptionsPanel extends StatelessWidget {
  const _ReticleOptionsPanel({
    required this.isMeasuring,
    required this.thickness,
    required this.opacity,
    required this.onMeasurementModeChanged,
    required this.onReset,
    required this.onThicknessChanged,
    required this.onOpacityChanged,
    required this.onZoomStep,
  });

  final bool isMeasuring;
  final double thickness;
  final double opacity;
  final ValueChanged<bool> onMeasurementModeChanged;
  final VoidCallback onReset;
  final ValueChanged<double> onThicknessChanged;
  final ValueChanged<double> onOpacityChanged;
  final ValueChanged<double> onZoomStep;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final opacityPercent = (opacity.clamp(0.35, 1.0) * 100).round();

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: FilledButton.icon(
                  onPressed: () => onMeasurementModeChanged(!isMeasuring),
                  icon: const Icon(Icons.straighten_rounded),
                  label: Text(
                    isMeasuring ? 'Measuring' : 'Measure',
                    overflow: TextOverflow.ellipsis,
                  ),
                  style: FilledButton.styleFrom(
                    minimumSize: const Size(0, 50),
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    backgroundColor: isMeasuring
                        ? const Color(0xFFF4B12B)
                        : colorScheme.surfaceContainerHighest.withValues(
                            alpha: 0.9,
                          ),
                    foregroundColor: isMeasuring
                        ? const Color(0xFF111510)
                        : colorScheme.onSurfaceVariant,
                    iconColor: isMeasuring
                        ? const Color(0xFF111510)
                        : colorScheme.onSurfaceVariant,
                    textStyle: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.3,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ReticleRoundIconButton(
                tooltip: 'Reset measurement',
                icon: Icons.refresh_rounded,
                onPressed: onReset,
              ),
              const SizedBox(width: AppSpacing.sm),
              _ReticleRoundIconButton(
                tooltip: 'Zoom out reticle',
                icon: Icons.zoom_out_rounded,
                onPressed: () => onZoomStep(-0.1),
              ),
              const SizedBox(width: AppSpacing.sm),
              _ReticleRoundIconButton(
                tooltip: 'Zoom in reticle',
                icon: Icons.zoom_in_rounded,
                onPressed: () => onZoomStep(0.1),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ReticleSliderPill(
                  label: 'Thickness',
                  valueText: '${thickness.toStringAsFixed(1)}x',
                  value: thickness,
                  min: 0.8,
                  max: 3.0,
                  onChanged: onThicknessChanged,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _ReticleSliderPill(
                  label: 'Opacity',
                  valueText: '$opacityPercent%',
                  value: opacity,
                  min: 0.35,
                  max: 1,
                  onChanged: onOpacityChanged,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ReticleSliderPill extends StatelessWidget {
  const _ReticleSliderPill({
    required this.label,
    required this.valueText,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String label;
  final String valueText;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      height: 74,
      padding: const EdgeInsets.fromLTRB(14, 10, 10, 6),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.42),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
              Text(
                valueText,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w800,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
              ),
              child: Slider(
                padding: EdgeInsets.zero,
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReticleRoundIconButton extends StatelessWidget {
  const _ReticleRoundIconButton({
    required this.tooltip,
    required this.icon,
    required this.onPressed,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return IconButton.filledTonal(
      tooltip: tooltip,
      onPressed: onPressed,
      icon: Icon(icon),
      style: IconButton.styleFrom(
        fixedSize: const Size.square(50),
        padding: EdgeInsets.zero,
        backgroundColor: colorScheme.surfaceContainerHighest.withValues(
          alpha: 0.45,
        ),
        foregroundColor: colorScheme.onSurfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      ),
    );
  }
}
