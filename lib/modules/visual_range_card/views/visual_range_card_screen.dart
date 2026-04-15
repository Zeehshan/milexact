import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/modules/visual_range_card/controllers/visual_range_card_controller.dart';
import 'package:milexact/modules/visual_range_card/widgets/visual_range_card_canvas.dart';
import 'package:milexact/services/visual_range_card_service.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/app_bar_action_menu.dart';
import 'package:milexact/shared/widgets/empty_state_view.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/selector_chips.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class VisualRangeCardScreen extends GetView<VisualRangeCardController> {
  const VisualRangeCardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return TacticalScaffold(
      title: 'Visual Range Card',
      currentRoute: AppRoutes.visualRangeCard,
      menuActions: [
        AppBarMenuAction(
          id: 'save',
          label: 'Save Visual Card',
          icon: Icons.save_rounded,
          onSelected: controller.save,
        ),
        AppBarMenuAction(
          id: 'undo',
          label: 'Undo Last Change',
          icon: Icons.undo_rounded,
          onSelected: controller.undo,
        ),
        AppBarMenuAction(
          id: 'clear',
          label: 'Clear Plot',
          icon: Icons.layers_clear_rounded,
          onSelected: controller.clearAll,
          isDestructive: true,
        ),
      ],
      body: Obx(() {
        final card = controller.currentCard.value;
        if (card == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: AppSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (controller.linkedEntry != null) ...[
                SectionCard(
                  child: Text(
                    'Linked entry: ${controller.linkedEntry!.targetName} • ${AppFormatters.number(controller.linkedEntry!.distanceMeters)} m',
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
              ],
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plotting Tools',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    SelectorChips<VisualEditorMode>(
                      options: VisualEditorMode.values,
                      selectedValue: controller.editorMode.value,
                      labelBuilder: (mode) => mode.label,
                      onSelected: controller.setEditorMode,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SwitchListTile.adaptive(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Show Arc Lines'),
                      value: card.arcLinesEnabled,
                      onChanged: controller.toggleArcLines,
                    ),
                    if (controller.editorMode.value.isTerrain) ...[
                      const SizedBox(height: AppSpacing.sm),
                      FilledButton.tonalIcon(
                        onPressed: controller.canCommitTerrain
                            ? controller.commitTerrain
                            : null,
                        icon: const Icon(Icons.check_rounded),
                        label: const Text('Finish Terrain Path'),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: SizedBox(
                  height: 360,
                  child: VisualRangeCardCanvas(
                    card: card,
                    draftTerrainPoints: controller.draftTerrainPoints.toList(
                      growable: false,
                    ),
                    editorMode: controller.editorMode.value,
                    visualRangeCardService: Get.find<VisualRangeCardService>(),
                    onTapDown: (localPosition, size) {
                      controller.handleTap(
                        size: size,
                        localPosition: localPosition,
                      );
                    },
                    onPanStart: (localPosition, size) {
                      controller.handlePanStart(
                        size: size,
                        localPosition: localPosition,
                      );
                    },
                    onPanUpdate: (localPosition, size) {
                      controller.handlePanUpdate(
                        size: size,
                        localPosition: localPosition,
                      );
                    },
                    onPanEnd: controller.handlePanEnd,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Target Markers',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (controller.targetMarkers.isEmpty)
                      const EmptyStateView(
                        title: 'No markers',
                        description:
                            'Use Marker mode and tap the plot to place targets.',
                        icon: Icons.track_changes_outlined,
                      )
                    else
                      ...controller.targetMarkers.map(
                        (marker) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _EditableRow(
                            title: marker.label,
                            subtitle:
                                '${controller.distanceLabel(marker)} • ${AppFormatters.number(marker.angle)}°',
                            onEdit: () => _editMarker(
                              marker.id,
                              marker.label,
                              marker.notes,
                            ),
                            onDelete: () => controller.removeMarker(marker.id),
                          ),
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
                    Text(
                      'Terrain Items',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    if (controller.terrainItems.isEmpty)
                      const EmptyStateView(
                        title: 'No terrain items',
                        description:
                            'Choose a terrain mode and tap the plot to draw a path.',
                        icon: Icons.terrain_outlined,
                      )
                    else
                      ...controller.terrainItems.map(
                        (terrain) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: _EditableRow(
                            title: terrain.label,
                            subtitle:
                                '${terrain.type.label} • ${terrain.points.length} points',
                            onEdit: () =>
                                _editTerrain(terrain.id, terrain.label),
                            onDelete: () =>
                                controller.removeTerrain(terrain.id),
                          ),
                        ),
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

  Future<void> _editMarker(
    String markerId,
    String currentLabel,
    String currentNotes,
  ) async {
    final labelController = TextEditingController(text: currentLabel);
    final notesController = TextEditingController(text: currentNotes);

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit Marker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: const InputDecoration(labelText: 'Label'),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      controller.renameMarker(
        markerId: markerId,
        label: labelController.text,
        notes: notesController.text,
      );
    }
  }

  Future<void> _editTerrain(String terrainId, String currentLabel) async {
    final labelController = TextEditingController(text: currentLabel);

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Edit Terrain'),
        content: TextField(
          controller: labelController,
          decoration: const InputDecoration(labelText: 'Label'),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (confirmed ?? false) {
      controller.renameTerrain(
        terrainId: terrainId,
        label: labelController.text,
      );
    }
  }
}

class _EditableRow extends StatelessWidget {
  const _EditableRow({
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
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
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: AppSpacing.xs),
                  Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
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
