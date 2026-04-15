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
      showBottomNav: false,
      showSettingsAction: false,
      body: Obx(() {
        final settings = controller.settings.value;
        final currentUser = controller.currentUser.value;

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Account', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      currentUser?.email ?? 'No local account session',
                      style: theme.textTheme.bodyLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Email/password sessions are stored locally. Google and Apple sign-in are wired for custom API exchange when your backend URL is configured.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    OutlinedButton.icon(
                      onPressed: currentUser == null
                          ? null
                          : () async {
                              final confirmed = await Get.dialog<bool>(
                                AlertDialog(
                                  title: const Text('Sign Out'),
                                  content: const Text(
                                    'Sign out from the current local session?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Get.back(result: false),
                                      child: const Text('Cancel'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Get.back(result: true),
                                      child: const Text('Sign out'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed ?? false) {
                                await controller.signOut();
                              }
                            },
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Sign Out'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Defaults', style: theme.textTheme.titleLarge),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Default Display Unit',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<DistanceDisplayPreference>(
                      options: DistanceDisplayPreference.values,
                      selectedValue: settings.defaultDisplayUnit,
                      labelBuilder: (preference) => preference.label,
                      onSelected: controller.updateDisplayPreference,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Default Target Unit',
                      style: theme.textTheme.titleMedium,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    SelectorChips<UnitType>(
                      options: UnitType.values,
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
                      title: const Text('Live Calculation'),
                      subtitle: const Text(
                        'Calculate immediately when inputs or reticle measurement change.',
                      ),
                      value: settings.liveCalculationEnabled,
                      onChanged: controller.updateLiveCalculationEnabled,
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
                      'MilExact Rev.2 is a fully offline ranging, range-card, DOPE-library, and visual plotting tool for fast field use. All presets, settings, profiles, and cards stay on device.',
                      style: theme.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Text('Help', style: theme.textTheme.titleMedium),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      '1. Measure a target with the reticle or enter the reading manually.\n'
                      '2. Use a quick preset or enter target dimensions.\n'
                      '3. Save the result to the range card and optionally link it to a visual card.\n'
                      '4. Manage DOPE profiles as a manual reference library only.',
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
