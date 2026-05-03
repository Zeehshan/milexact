import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/app/routes/app_routes.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/target_marker.dart';
import 'package:milexact/modules/visual_range_card/controllers/visual_range_card_controller.dart';
import 'package:milexact/modules/visual_range_card/widgets/visual_range_card_canvas.dart';
import 'package:milexact/services/visual_range_card_service.dart';
import 'package:milexact/shared/constants/app_spacing.dart';
import 'package:milexact/shared/utils/formatters.dart';
import 'package:milexact/shared/widgets/empty_state_view.dart';
import 'package:milexact/shared/widgets/section_card.dart';
import 'package:milexact/shared/widgets/tactical_scaffold.dart';

const List<VisualEditorMode> _drawModes = <VisualEditorMode>[
  VisualEditorMode.river,
  VisualEditorMode.treeline,
  VisualEditorMode.road,
  VisualEditorMode.building,
];

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
        final renderCard = card.copyWith(
          targetMarkers: controller.targetMarkers,
        );
        final draftTerrainPoints = controller.draftTerrainPoints.toList(
          growable: false,
        );
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
                                'DRAW',
                                style: Theme.of(context).textTheme.titleSmall
                                    ?.copyWith(
                                      color: AppColors.textMuted,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                controller.isDrawModeEnabled.value
                                    ? 'Drawing is active and page scrolling is locked.'
                                    : 'Enable drawing to paint river, treeline, road, or building.',
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
                            children: _drawModes
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
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final plotHeight = (constraints.maxWidth * (290 / 400))
                            .clamp(260.0, 360.0);
                        return SizedBox(
                          height: plotHeight,
                          child: VisualRangeCardCanvas(
                            card: renderCard,
                            draftTerrainPoints: draftTerrainPoints,
                            editorMode: controller.editorMode.value,
                            interactionEnabled:
                                controller.isDrawModeEnabled.value,
                            maxDistanceMeters: controller.displayMaxDistance,
                            visualRangeCardService:
                                Get.find<VisualRangeCardService>(),
                            onTapDown: (localPosition, size) {
                              controller.handleTap(
                                size: size,
                                localPosition: localPosition,
                              );
                            },
                            onPanDown: (localPosition, size) {
                              controller.handlePanDown(
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
                            onPanEnd: () {
                              controller.handlePanEnd();
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: AppSpacing.md),
                    if (controller.targetMarkers.isEmpty)
                      const _InlineMarkerEmptyState()
                    else
                      _MarkerControlPanel(
                        markers: controller.targetMarkers,
                        controller: controller,
                        onEditMarker: _editMarker,
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
                            'Choose River, Treeline, Road, or Building and drag on the plot.',
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

  Future<void> _editMarker(TargetMarker marker) async {
    final linkedEntry = controller.linkedRangeEntryForMarker(marker);
    final isLinkedMarker = linkedEntry != null;
    final labelController = TextEditingController(
      text: isLinkedMarker ? linkedEntry.targetPlacementLabel : marker.label,
    );
    final notesController = TextEditingController(text: marker.notes);

    final confirmed = await Get.dialog<bool>(
      AlertDialog(
        title: Text(isLinkedMarker ? 'Edit Placement' : 'Edit Marker'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: isLinkedMarker ? 'Placement / Location' : 'Label',
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: notesController,
              decoration: InputDecoration(
                labelText: isLinkedMarker ? 'Terrain Notes' : 'Notes',
              ),
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
        markerId: marker.id,
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
    if (!controller.isDrawModeEnabled.value) {
      return 'Enable drawing to paint terrain without scrolling the page.';
    }
    final mode = controller.editorMode.value;
    return 'Draw anywhere on the visual card — tap for points or drag to paint ${mode.label.toLowerCase()}.';
  }
}

class _InlineMarkerEmptyState extends StatelessWidget {
  const _InlineMarkerEmptyState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.6)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.track_changes_outlined,
            color: AppColors.textMuted,
            size: 18,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              'Save targets to the Range Card first, then they will appear here for quick angle movement.',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: AppColors.textMuted),
            ),
          ),
        ],
      ),
    );
  }
}

class _MarkerControlPanel extends StatelessWidget {
  const _MarkerControlPanel({
    required this.markers,
    required this.controller,
    required this.onEditMarker,
  });

  final List<TargetMarker> markers;
  final VisualRangeCardController controller;
  final Future<void> Function(TargetMarker) onEditMarker;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt.withValues(alpha: 0.34),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: List.generate(markers.length, (index) {
          final marker = markers[index];
          return _MarkerControlRow(
            marker: marker,
            index: index,
            controller: controller,
            onEditMarker: onEditMarker,
            showDivider: index < markers.length - 1,
          );
        }),
      ),
    );
  }
}

class _MarkerControlRow extends StatelessWidget {
  const _MarkerControlRow({
    required this.marker,
    required this.index,
    required this.controller,
    required this.onEditMarker,
    required this.showDivider,
  });

  final TargetMarker marker;
  final int index;
  final VisualRangeCardController controller;
  final Future<void> Function(TargetMarker) onEditMarker;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final entry = controller.linkedRangeEntryForMarker(marker);
    final placementText = entry?.targetPlacementLabel.trim() ?? '';
    final terrainNotes = entry?.terrainNotes.trim() ?? marker.notes.trim();
    final summary = entry == null
        ? '${controller.distanceLabel(marker)} • ${controller.markerAngleLabel(marker)}'
        : '${entry.distanceMeters.round()}m • ${entry.distanceYards.round()}yd • ${AppFormatters.number(entry.reticleReading)} ${entry.reticleType.label}';

    final content = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isCompact = constraints.maxWidth < 620;
          final info = InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => onEditMarker(marker),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _markerColor(index),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          marker.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          summary,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: AppColors.textMuted),
                        ),
                        if (placementText.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Location: $placementText',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                        if (terrainNotes.isNotEmpty) ...[
                          const SizedBox(height: 2),
                          Text(
                            'Notes: ${AppFormatters.preview(terrainNotes, maxLength: 80)}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );

          final actions = Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.end,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _MarkerPillLabel(label: controller.markerAngleLabel(marker)),
              _MarkerIconAction(
                tooltip: 'Rotate Left',
                icon: Icons.rotate_left_rounded,
                onTap: () => controller.adjustMarkerAngle(marker.id, -5),
              ),
              _MarkerIconAction(
                tooltip: 'Rotate Right',
                icon: Icons.rotate_right_rounded,
                onTap: () => controller.adjustMarkerAngle(marker.id, 5),
              ),
              _MarkerPillAction(
                label: 'CTR',
                onTap: () => controller.centerMarkerAngle(marker.id),
              ),
              if (marker.linkedRangeCardEntryId == null)
                _MarkerIconAction(
                  tooltip: 'Delete',
                  icon: Icons.delete_outline_rounded,
                  onTap: () => controller.removeMarker(marker.id),
                  isDestructive: true,
                ),
            ],
          );

          if (isCompact) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                info,
                const SizedBox(height: 10),
                Align(alignment: Alignment.centerRight, child: actions),
              ],
            );
          }

          return Row(
            children: [
              Expanded(child: info),
              const SizedBox(width: 12),
              actions,
            ],
          );
        },
      ),
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        border: showDivider
            ? Border(
                bottom: BorderSide(
                  color: AppColors.border.withValues(alpha: 0.42),
                ),
              )
            : null,
      ),
      child: content,
    );
  }

  Color _markerColor(int index) {
    const colors = <Color>[
      Color(0xFF4ADE80),
      Color(0xFFF59E0B),
      Color(0xFF60A8FB),
      Color(0xFFF87171),
      Color(0xFFA78BFA),
      Color(0xFF34D399),
      Color(0xFFFB923C),
      Color(0xFFE879F9),
    ];
    return colors[index % colors.length];
  }
}

class _MarkerPillLabel extends StatelessWidget {
  const _MarkerPillLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: AppColors.textMuted,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }
}

class _MarkerPillAction extends StatelessWidget {
  const _MarkerPillAction({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface.withValues(alpha: 0.72),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Text(
            label,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: AppColors.textMuted,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}

class _MarkerIconAction extends StatelessWidget {
  const _MarkerIconAction({
    required this.tooltip,
    required this.icon,
    required this.onTap,
    this.isDestructive = false,
  });

  final String tooltip;
  final IconData icon;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.surface.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(
              icon,
              size: 22,
              color: isDestructive ? AppColors.danger : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
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
    this.onDelete,
  });

  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final VoidCallback? onDelete;

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
            if (onDelete != null)
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
