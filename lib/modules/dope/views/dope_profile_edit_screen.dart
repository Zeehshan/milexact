import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/modules/dope/controllers/dope_profile_edit_controller.dart';
import 'package:milexact/modules/dope/widgets/dope_profile_entry_form_card.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class DopeProfileEditScreen extends GetView<DopeProfileEditController> {
  const DopeProfileEditScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TacticalScaffold(
      title: controller.screenTitle,
      showBottomNav: false,
      showSettingsAction: false,
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 520;

                        if (stacked) {
                          return Column(
                            children: [
                              LabeledTextField(
                                controller: controller.rifleNameController,
                                label: 'Rifle Name',
                                hint: 'Primary rifle',
                              ),
                              const SizedBox(height: AppSpacing.md),
                              LabeledTextField(
                                controller: controller.caliberController,
                                label: 'Caliber',
                                hint: '.308 Win',
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: LabeledTextField(
                                controller: controller.rifleNameController,
                                label: 'Rifle Name',
                                hint: 'Primary rifle',
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: LabeledTextField(
                                controller: controller.caliberController,
                                label: 'Caliber',
                                hint: '.308 Win',
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final stacked = constraints.maxWidth < 520;

                        if (stacked) {
                          return Column(
                            children: [
                              LabeledTextField(
                                controller: controller.bulletGrainController,
                                label: 'Bullet Grain',
                                hint: '168',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                              const SizedBox(height: AppSpacing.md),
                              LabeledTextField(
                                controller: controller.velocityFpsController,
                                label: 'Velocity FPS',
                                hint: '2650',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ],
                          );
                        }

                        return Row(
                          children: [
                            Expanded(
                              child: LabeledTextField(
                                controller: controller.bulletGrainController,
                                label: 'Bullet Grain',
                                hint: '168',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            Expanded(
                              child: LabeledTextField(
                                controller: controller.velocityFpsController,
                                label: 'Velocity FPS',
                                hint: '2650',
                                keyboardType:
                                    const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Set As Active Profile'),
                      subtitle: const Text(
                        'Mark this rifle as the default manual DOPE reference.',
                      ),
                      value: controller.isActive.value,
                      onChanged: controller.updateActive,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Profile Rows',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        OutlinedButton.icon(
                          onPressed: controller.addRow,
                          icon: const Icon(Icons.add_rounded),
                          label: const Text('Add Row'),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Add distance and drop references manually. No ballistic calculation is generated here.',
                      style: theme.textTheme.bodySmall,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    ...controller.entryForms.asMap().entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: DopeProfileEntryFormCard(
                          index: entry.key,
                          item: entry.value,
                          onDelete: () => controller.removeRow(entry.value),
                          onUnitChanged: (unit) =>
                              controller.updateRowUnit(entry.value, unit),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (controller.errorMessage.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  controller.errorMessage.value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.isSaving.value ? null : Get.back,
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton(
                      onPressed: controller.isSaving.value
                          ? null
                          : controller.saveProfile,
                      child: controller.isSaving.value
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Text(controller.submitLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
