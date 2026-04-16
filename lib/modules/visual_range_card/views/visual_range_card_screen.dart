import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/modules/visual_range_card/controllers/visual_range_card_controller.dart';
import 'package:milexact/modules/visual_range_card/widgets/visual_range_card_canvas.dart';
import 'package:milexact/services/visual_range_card_service.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/empty_state_view.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

class VisualRangeCardScreen extends GetView<VisualRangeCardController> {
  const VisualRangeCardScreen({super.key, this.showBottomNav = true});

  final bool showBottomNav;

  @override
  Widget build(BuildContext context) {
    return TacticalScaffold(
      title: 'Visual Range Card',
      currentRoute: AppRoutes.visualRangeCard,
      showBottomNav: showBottomNav,
      body: Obx(() {
        final card = controller.currentCard.value;
        if (card == null) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          physics: controller.isDrawModeEnabled.value
              ? const NeverScrollableScrollPhysics()
              : null,
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
                    Row(
                      children: [
                        const Icon(
                          Icons.adjust_rounded,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'VISUAL RANGE CARD',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.3,
                                ),
                          ),
                        ),
                        _ArcToggleButton(
                          enabled: card.arcLinesEnabled,
                          onPressed: () =>
                              controller.toggleArcLines(!card.arcLinesEnabled),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DRAW MODE',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.isDrawModeEnabled.value
                                    ? 'Canvas interaction is active and page scrolling is locked.'
                                    : 'Enable to draw on the plot without scrolling the screen.',
                                style: Theme.of(context).textTheme.bodySmall
                                    ?.copyWith(color: AppColors.textMuted),
                              ),
                            ],
                          ),
                        ),
                        Switch.adaptive(
                          value: controller.isDrawModeEnabled.value,
                          onChanged: controller.setDrawModeEnabled,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'DRAW:',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: AppColors.textMuted,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            spacing: AppSpacing.sm,
                            children: VisualEditorMode.values
                                .map(
                                  (mode) => _ModeChip(
                                    mode: mode,
                                    isSelected:
                                        controller.editorMode.value == mode,
                                    onTap: () => controller.setEditorMode(mode),
                                  ),
                                )
                                .toList(growable: false),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Align(
                          child: Row(
                            children: [
                              const Spacer(),
                              _CompactActionButton(
                                icon: Icons.save_rounded,
                                tooltip: 'Save Visual Card',
                                onPressed: controller.save,
                              ),
                              const SizedBox(width: 8),
                              _CompactActionButton(
                                icon: Icons.undo_rounded,
                                tooltip: 'Undo Last Change',
                                onPressed: controller.undo,
                              ),
                              const SizedBox(width: 8),
                              _CompactActionButton(
                                icon: Icons.layers_clear_rounded,
                                tooltip: 'Clear Plot',
                                onPressed: controller.clearAll,
                                isDestructive: true,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      _instructionText(controller),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textMuted,
                      ),
                    ),
                    // if (controller.editorMode.value.isTerrain) ...[
                    //   const SizedBox(height: AppSpacing.sm),
                    //   Align(
                    //     alignment: Alignment.centerLeft,
                    //     child: TextButton.icon(
                    //       onPressed: controller.canCommitTerrain
                    //           ? controller.commitTerrain
                    //           : null,
                    //       icon: const Icon(Icons.check_rounded, size: 18),
                    //       label: const Text('Finish Path'),
                    //     ),
                    //   ),
                    // ],
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      height: 300,
                      child: VisualRangeCardCanvas(
                        card: card,
                        draftTerrainPoints: controller.draftTerrainPoints
                            .toList(growable: false),
                        editorMode: controller.editorMode.value,
                        interactionEnabled: controller.isDrawModeEnabled.value,
                        visualRangeCardService:
                            Get.find<VisualRangeCardService>(),
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
                  ],
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

  String _instructionText(VisualRangeCardController controller) {
    final mode = controller.editorMode.value;
    if (!controller.isDrawModeEnabled.value) {
      return 'Enable draw mode to place markers or paint terrain without scrolling the page.';
    }
    if (mode == VisualEditorMode.marker) {
      return 'Tap the plot to place targets. Drag markers to adjust.';
    }
    return 'Draw on the map — tap for points or drag to paint ${mode.label.toLowerCase()}.';
  }
}

class _ArcToggleButton extends StatelessWidget {
  const _ArcToggleButton({required this.enabled, required this.onPressed});

  final bool enabled;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        backgroundColor: enabled
            ? AppColors.primary.withValues(alpha: 0.12)
            : AppColors.surfaceAlt,
        side: BorderSide(
          color: enabled
              ? AppColors.primary.withValues(alpha: 0.45)
              : AppColors.border,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        enabled ? 'ARC LINES ON' : 'ARC LINES OFF',
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: enabled ? AppColors.primary : AppColors.textMuted,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.mode,
    required this.isSelected,
    required this.onTap,
  });

  final VisualEditorMode mode;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final accent = _modeColor(mode);

    return Material(
      color: isSelected
          ? accent.withValues(alpha: 0.18)
          : AppColors.surfaceAlt.withValues(alpha: 0.92),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 18,
                height: 3,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                mode.label,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: isSelected
                      ? AppColors.textPrimary
                      : AppColors.textMuted,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _modeColor(VisualEditorMode mode) {
    return switch (mode) {
      VisualEditorMode.marker => AppColors.primary,
      VisualEditorMode.river => const Color(0xFF66B7F0),
      VisualEditorMode.treeline => const Color(0xFF5EAF62),
      VisualEditorMode.road => AppColors.accent,
      VisualEditorMode.building => const Color(0xFFE28A7B),
      VisualEditorMode.other => AppColors.textMuted,
    };
  }
}

class _CompactActionButton extends StatelessWidget {
  const _CompactActionButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.isDestructive = false,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final color = isDestructive ? AppColors.danger : AppColors.textMuted;

    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surfaceAlt.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: SizedBox(
            width: 36,
            height: 36,
            child: Icon(icon, size: 18, color: color),
          ),
        ),
      ),
    );
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
