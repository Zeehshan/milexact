import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/modules/settings/controllers/settings_controller.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class SettingsScreen extends GetView<SettingsController> {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TacticalScaffold(
      title: 'Settings',
      currentRoute: AppRoutes.settings,
      body: Obx(() {
        final settings = controller.settings.value;

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Defaults', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Default Output Preference',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<DistanceOutputPreference>(
                      options: DistanceOutputPreference.values,
                      selectedValue: settings.defaultOutputPreference,
                      labelBuilder: (preference) => preference.label,
                      onSelected: controller.updateOutputPreference,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Default Target Unit',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<MeasurementUnit>(
                      options: MeasurementUnit.values,
                      selectedValue: settings.defaultTargetUnit,
                      labelBuilder: (unit) => unit.shortLabel.toUpperCase(),
                      onSelected: controller.updateTargetUnit,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Default Reticle Type',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<ReticleType>(
                      options: ReticleType.values,
                      selectedValue: settings.defaultReticleType,
                      labelBuilder: (reticle) => reticle.label,
                      onSelected: controller.updateReticleType,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Enable Auto-Calculate'),
                      subtitle: const Text(
                        'Recalculate distance as inputs change on the calculator screen.',
                      ),
                      value: settings.autoCalculateEnabled,
                      onChanged: controller.updateAutoCalculateEnabled,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('About', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'MilExact is a fully offline scope-based distance calculator built for fast mobile field use. Formula handling, unit conversion, settings, presets, and range card data all stay local on device.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Help', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '1. Pick a preset target or enter a manual target.\n'
                      '2. Enter the reticle reading and choose the workflow.\n'
                      '3. Save the result to the range card and add manual DOPE and wind holds.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
