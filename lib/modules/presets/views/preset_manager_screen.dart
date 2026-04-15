import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/target_category.dart';
import 'package:milexact/data/models/target_preset.dart';
import 'package:milexact/modules/presets/controllers/preset_manager_controller.dart';
import 'package:milexact/modules/presets/widgets/category_editor_dialog.dart';
import 'package:milexact/modules/presets/widgets/preset_editor_dialog.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/empty_state_view.dart';
import 'package:milexact/shared/widgets/labeled_text_field.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class QuickPresetScreen extends GetView<QuickPresetController> {
  const QuickPresetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TacticalScaffold(
      title: 'Quick Presets',
      currentRoute: AppRoutes.quickPresets,
      body: Obx(() {
        final categories = controller.categories.toList(growable: false);
        final selectedCategory = controller.selectedCategory;
        final presets = controller.filteredPresets;

        return Padding(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.selectionMode.value) ...[
                SectionCard(
                  child: Text(
                    'Tap a preset to send it back to the calculator.',
                    style: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              LabeledTextField(
                label: 'Search Presets',
                hint: 'Search by name',
                onChanged: controller.setSearchQuery,
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
                            'Categories',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Add category',
                          onPressed: _showCategoryDialog,
                          icon: const Icon(Icons.add_circle_outline_rounded),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (categories.isEmpty)
                      const EmptyStateView(
                        title: 'No categories',
                        description:
                            'Create a category to begin organizing presets.',
                        icon: Icons.category_outlined,
                      )
                    else ...[
                      SelectorChips<String>(
                        options: categories
                            .map((category) => category.id)
                            .toList(growable: false),
                        selectedValue: controller.selectedCategoryId.value,
                        labelBuilder: (categoryId) => categories
                            .firstWhere((category) => category.id == categoryId)
                            .name,
                        onSelected: controller.selectCategory,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: selectedCategory == null
                                  ? null
                                  : () => _showCategoryDialog(
                                      category: selectedCategory,
                                    ),
                              icon: const Icon(Icons.edit_outlined),
                              label: const Text('Edit'),
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: OutlinedButton.icon(
                              onPressed: selectedCategory == null
                                  ? null
                                  : () => _confirmDeleteCategory(
                                      selectedCategory,
                                    ),
                              icon: const Icon(Icons.delete_outline_rounded),
                              label: const Text('Delete'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Expanded(
                child: SectionCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              selectedCategory == null
                                  ? 'Preset Library'
                                  : '${selectedCategory.name} Presets',
                              style: theme.textTheme.titleLarge,
                            ),
                          ),
                          IconButton(
                            tooltip: 'Add preset',
                            onPressed: selectedCategory == null
                                ? null
                                : _showPresetDialog,
                            icon: const Icon(Icons.add_circle_outline_rounded),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      if (presets.isEmpty)
                        const Expanded(
                          child: EmptyStateView(
                            title: 'No presets',
                            description:
                                'Add a custom preset or switch categories.',
                            icon: Icons.track_changes_outlined,
                          ),
                        )
                      else
                        Expanded(
                          child: ListView.separated(
                            itemCount: presets.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: AppSpacing.sm),
                            itemBuilder: (context, index) {
                              final preset = presets[index];
                              return _PresetTile(
                                preset: preset,
                                selectionMode: controller.selectionMode.value,
                                onUse: () => controller.usePreset(preset),
                                onEdit: () => _showPresetDialog(preset: preset),
                                onDelete: () => _confirmDeletePreset(preset),
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Future<void> _showCategoryDialog({TargetCategory? category}) async {
    await Get.dialog<void>(
      CategoryEditorDialog(
        initialName: category?.name,
        onSave: (name) =>
            controller.saveCategory(categoryId: category?.id, name: name),
      ),
    );
  }

  Future<void> _showPresetDialog({TargetPreset? preset}) async {
    final category = controller.selectedCategory;
    if (category == null) {
      return;
    }

    await Get.dialog<void>(
      PresetEditorDialog(
        initialName: preset?.name,
        initialHeightValue: preset?.heightValue,
        initialHeightUnit: preset?.heightUnit,
        initialWidthValue: preset?.widthValue,
        initialWidthUnit: preset?.widthUnit,
        initialSupportsMetric: preset?.supportsMetric,
        initialSupportsImperial: preset?.supportsImperial,
        onSave:
            ({
              required String name,
              required String heightValue,
              required UnitType heightUnit,
              required String widthValue,
              required UnitType widthUnit,
              required bool supportsMetric,
              required bool supportsImperial,
            }) => controller.savePreset(
              presetId: preset?.id,
              categoryId: category.id,
              name: name,
              heightValue: heightValue,
              heightUnit: heightUnit,
              widthValue: widthValue,
              widthUnit: widthUnit,
              supportsMetric: supportsMetric,
              supportsImperial: supportsImperial,
            ),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(TargetCategory category) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}" and every preset inside it?'),
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
      await controller.deleteCategory(category);
      Get.snackbar('Deleted', 'Category and linked presets removed.');
    }
  }

  Future<void> _confirmDeletePreset(TargetPreset preset) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Preset'),
        content: Text('Delete "${preset.name}" from quick presets?'),
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
      await controller.deletePreset(preset);
      Get.snackbar('Deleted', 'Preset removed.');
    }
  }
}

class _PresetTile extends StatelessWidget {
  const _PresetTile({
    required this.preset,
    required this.selectionMode,
    required this.onUse,
    required this.onEdit,
    required this.onDelete,
  });

  final TargetPreset preset;
  final bool selectionMode;
  final VoidCallback onUse;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: selectionMode ? onUse : null,
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
                        Text(preset.name, style: theme.textTheme.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'Height ${AppFormatters.targetSize(preset.heightValue, preset.heightUnit)} • Width ${AppFormatters.targetSize(preset.widthValue, preset.widthUnit)}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  if (selectionMode)
                    FilledButton.tonal(
                      onPressed: onUse,
                      child: const Text('Use'),
                    ),
                  if (!selectionMode) ...[
                    IconButton(
                      tooltip: 'Edit',
                      onPressed: onEdit,
                      icon: const Icon(Icons.edit_outlined),
                    ),
                    IconButton(
                      tooltip: 'Delete',
                      onPressed: onDelete,
                      icon: const Icon(Icons.delete_outline_rounded),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: [
                  _SupportChip(
                    label: preset.supportsMetric ? 'Metric' : 'Metric Off',
                  ),
                  _SupportChip(
                    label: preset.supportsImperial
                        ? 'Imperial'
                        : 'Imperial Off',
                  ),
                  _SupportChip(label: preset.isCustom ? 'Custom' : 'Seed'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SupportChip extends StatelessWidget {
  const _SupportChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.12),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.22),
        ),
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall),
    );
  }
}
