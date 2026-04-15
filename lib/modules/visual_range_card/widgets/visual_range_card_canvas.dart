import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/visual_range_card_state.dart';
import 'package:milexact/data/models/visual_point.dart';
import 'package:milexact/services/visual_range_card_service.dart';
import 'package:milexact/shared/constants/app_spacing.dart';

class VisualRangeCardCanvas extends StatelessWidget {
  const VisualRangeCardCanvas({
    super.key,
    required this.card,
    required this.draftTerrainPoints,
    required this.editorMode,
    required this.visualRangeCardService,
    required this.onTapDown,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final VisualRangeCardState card;
  final List<VisualPoint> draftTerrainPoints;
  final VisualEditorMode editorMode;
  final VisualRangeCardService visualRangeCardService;
  final void Function(Offset localPosition, Size size) onTapDown;
  final void Function(Offset localPosition, Size size) onPanStart;
  final void Function(Offset localPosition, Size size) onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => onTapDown(details.localPosition, size),
          onPanStart: (details) => onPanStart(details.localPosition, size),
          onPanUpdate: (details) => onPanUpdate(details.localPosition, size),
          onPanEnd: (_) => onPanEnd(),
          child: Stack(
            children: [
              CustomPaint(
                size: size,
                painter: _VisualRangeCardPainter(
                  card: card,
                  draftTerrainPoints: draftTerrainPoints,
                  editorMode: editorMode,
                  visualRangeCardService: visualRangeCardService,
                ),
              ),
              Positioned(
                left: AppSpacing.md,
                top: AppSpacing.md,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.32),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                      vertical: AppSpacing.xs,
                    ),
                    child: Text(
                      editorMode == VisualEditorMode.marker
                          ? 'Tap to place targets • Drag markers to adjust'
                          : 'Tap to draw ${editorMode.label.toLowerCase()}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _VisualRangeCardPainter extends CustomPainter {
  const _VisualRangeCardPainter({
    required this.card,
    required this.draftTerrainPoints,
    required this.editorMode,
    required this.visualRangeCardService,
  });

  final VisualRangeCardState card;
  final List<VisualPoint> draftTerrainPoints;
  final VisualEditorMode editorMode;
  final VisualRangeCardService visualRangeCardService;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    final borderPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    canvas.drawRRect(rect, borderPaint);
    final center = visualRangeCardService.plotCenter(size);
    final radius = visualRangeCardService.plotRadius(size);
    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.18)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    final spokePaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.12)
      ..strokeWidth = 1.0;

    if (card.arcLinesEnabled) {
      for (var i = 1; i <= 4; i++) {
        final currentRadius = radius * (i / 4);
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: currentRadius),
          math.pi,
          math.pi,
          false,
          arcPaint,
        );
      }

      for (var degrees = 30; degrees <= 150; degrees += 30) {
        final radians = math.pi - (degrees * math.pi / 180);
        canvas.drawLine(
          center,
          Offset(
            center.dx + math.cos(radians) * radius,
            center.dy - math.sin(radians) * radius,
          ),
          spokePaint,
        );
      }
    }

    for (final terrain in card.terrainItems) {
      final points = terrain.points
          .map(
            (point) => visualRangeCardService.offsetFromNormalizedPoint(
              point: point,
              size: size,
            ),
          )
          .toList(growable: false);
      if (points.length < 2) {
        continue;
      }
      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }
      final terrainPaint = Paint()
        ..color = _terrainColor(terrain.styleToken)
        ..style = PaintingStyle.stroke
        ..strokeWidth = terrain.type == TerrainType.building ? 5 : 3
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(path, terrainPaint);
    }

    if (draftTerrainPoints.length >= 2) {
      final draftPath = Path();
      final draftOffsets = draftTerrainPoints
          .map(
            (point) => visualRangeCardService.offsetFromNormalizedPoint(
              point: point,
              size: size,
            ),
          )
          .toList(growable: false);
      draftPath.moveTo(draftOffsets.first.dx, draftOffsets.first.dy);
      for (final point in draftOffsets.skip(1)) {
        draftPath.lineTo(point.dx, point.dy);
      }
      canvas.drawPath(
        draftPath,
        Paint()
          ..color = const Color(0xFFB48A53)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5,
      );
    }

    for (final marker in card.targetMarkers) {
      final offset = visualRangeCardService.offsetFromMarker(
        marker: marker,
        size: size,
      );
      canvas.drawCircle(offset, 8, Paint()..color = const Color(0xFF8EAE72));
      canvas.drawCircle(
        offset,
        14,
        Paint()
          ..color = const Color(0xFF8EAE72).withValues(alpha: 0.18)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
      final textPainter = TextPainter(
        text: TextSpan(
          text: marker.label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: 120);
      textPainter.paint(canvas, offset.translate(10, -18));
    }
  }

  Color _terrainColor(String token) {
    return switch (token) {
      'river' => const Color(0xFF5C87B8),
      'treeline' => const Color(0xFF5F8A5F),
      'road' => const Color(0xFF8B7A61),
      'building' => const Color(0xFF8EAE72),
      _ => const Color(0xFFB48A53),
    };
  }

  @override
  bool shouldRepaint(covariant _VisualRangeCardPainter oldDelegate) {
    return oldDelegate.card != card ||
        oldDelegate.editorMode != editorMode ||
        oldDelegate.draftTerrainPoints != draftTerrainPoints;
  }
}
