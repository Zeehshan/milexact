import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/target_category.dart';
import 'package:milexact/data/models/target_preset.dart';
import 'package:milexact/modules/presets/controllers/preset_manager_controller.dart';
import 'package:milexact/modules/presets/widgets/category_editor_dialog.dart';
import 'package:milexact/modules/presets/widgets/preset_editor_dialog.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/empty_state_view.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class PresetManagerScreen extends GetView<PresetManagerController> {
  const PresetManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TacticalScaffold(
      title: 'Preset Manager',
      currentRoute: AppRoutes.presetManager,
      body: Obx(() {
        final categories = controller.categories.toList(growable: false);
        final selectedCategory = controller.selectedCategory;
        final presets = controller.categoryPresets;

        if (categories.isEmpty) {
          return EmptyStateView(
            title: 'No preset categories',
            description:
                'Create a category first, then add preset targets for fast field use.',
            icon: Icons.category_outlined,
            actionLabel: 'Add Category',
            onAction: _showCategoryDialog,
          );
        }

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
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
                            label: const Text('Edit Category'),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: selectedCategory == null
                                ? null
                                : () =>
                                      _confirmDeleteCategory(selectedCategory),
                            icon: const Icon(Icons.delete_outline_rounded),
                            label: const Text('Delete Category'),
                          ),
                        ),
                      ],
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
                            selectedCategory == null
                                ? 'Preset Targets'
                                : '${selectedCategory.name} Presets',
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        IconButton(
                          tooltip: 'Add preset',
                          onPressed: selectedCategory == null
                              ? null
                              : () => _showPresetDialog(),
                          icon: const Icon(Icons.add_circle_outline_rounded),
                        ),
                      ],
                    ),
                    if (presets.isEmpty) ...[
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'No presets in this category yet.',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ] else ...[
                      const SizedBox(height: AppSpacing.sm),
                      ...presets.map(
                        (preset) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _PresetTile(
                            preset: preset,
                            onEdit: () => _showPresetDialog(preset: preset),
                            onDelete: () => _confirmDeletePreset(preset),
                          ),
                        ),
                      ),
                    ],
                  ],
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
    final selectedCategory = controller.selectedCategory;
    if (selectedCategory == null) {
      return;
    }

    await Get.dialog<void>(
      PresetEditorDialog(
        initialName: preset?.name,
        initialSizeValue: preset?.sizeValue,
        initialUnit: preset?.sizeUnit,
        onSave: (name, sizeValue, unit) => controller.savePreset(
          presetId: preset?.id,
          categoryId: selectedCategory.id,
          name: name,
          sizeValue: sizeValue,
          sizeUnit: unit,
        ),
      ),
    );
  }

  Future<void> _confirmDeleteCategory(TargetCategory category) async {
    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Delete "${category.name}" and all presets inside it?'),
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
        content: Text('Delete "${preset.name}" from presets?'),
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
    required this.onEdit,
    required this.onDelete,
  });

  final TargetPreset preset;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(preset.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    AppFormatters.targetSize(preset.sizeValue, preset.sizeUnit),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
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
        ),
      ),
    );
  }
}
