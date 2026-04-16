import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/data/models/enums.dart';
import 'package:milexact/data/models/visual_point.dart';
import 'package:milexact/data/models/visual_range_card_state.dart';
import 'package:milexact/services/visual_range_card_service.dart';

const double _kViewWidth = 400;
const double _kViewHeight = 290;
const double _kCx = 200;
const double _kCy = 270;
const double _kMaxR = 230;
const double _kFanDeg = 160;

const List<Color> _kMarkerColors = [
  Color(0xFF4ADE80),
  Color(0xFFF59E0B),
  Color(0xFF60A8FB),
  Color(0xFFF87171),
  Color(0xFFA78BFA),
  Color(0xFF34D399),
  Color(0xFFFB923C),
  Color(0xFFE879F9),
];

typedef VisualCanvasPositionCallback =
    void Function(Offset localPosition, Size size);

class VisualRangeCardCanvas extends StatelessWidget {
  const VisualRangeCardCanvas({
    super.key,
    required this.card,
    required this.draftTerrainPoints,
    required this.editorMode,
    required this.interactionEnabled,
    required this.maxDistanceMeters,
    required this.visualRangeCardService,
    required this.onTapDown,
    required this.onPanStart,
    required this.onPanUpdate,
    required this.onPanEnd,
  });

  final VisualRangeCardState card;
  final List<VisualPoint> draftTerrainPoints;
  final VisualEditorMode editorMode;
  final bool interactionEnabled;
  final double maxDistanceMeters;
  final VisualRangeCardService visualRangeCardService;
  final VisualCanvasPositionCallback onTapDown;
  final VisualCanvasPositionCallback onPanStart;
  final VisualCanvasPositionCallback onPanUpdate;
  final VoidCallback onPanEnd;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        return DecoratedBox(
          decoration: BoxDecoration(
            color: const Color(0xFF0D1110),
            borderRadius: BorderRadius.circular(18),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(18),
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: interactionEnabled
                  ? (details) => onTapDown(details.localPosition, size)
                  : null,
              onPanStart: interactionEnabled
                  ? (details) => onPanStart(details.localPosition, size)
                  : null,
              onPanUpdate: interactionEnabled
                  ? (details) => onPanUpdate(details.localPosition, size)
                  : null,
              onPanEnd: interactionEnabled ? (_) => onPanEnd() : null,
              child: CustomPaint(
                painter: _VisualRangePainter(
                  card: card,
                  draftTerrainPoints: draftTerrainPoints,
                  editorMode: editorMode,
                  maxRange: maxDistanceMeters,
                  visualRangeCardService: visualRangeCardService,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _VisualRangePainter extends CustomPainter {
  const _VisualRangePainter({
    required this.card,
    required this.draftTerrainPoints,
    required this.editorMode,
    required this.maxRange,
    required this.visualRangeCardService,
  });

  final VisualRangeCardState card;
  final List<VisualPoint> draftTerrainPoints;
  final VisualEditorMode editorMode;
  final double maxRange;
  final VisualRangeCardService visualRangeCardService;

  @override
  void paint(Canvas canvas, Size size) {
    final chartRect = Offset.zero & size;
    final framePaint = Paint()
      ..color = const Color(0xFF0F1412)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(
      RRect.fromRectAndRadius(chartRect, const Radius.circular(18)),
      framePaint,
    );

    canvas.save();
    canvas.scale(size.width / _kViewWidth, size.height / _kViewHeight);

    final halfFan = _kFanDeg / 2;
    _drawFanWedge(canvas, AppColors.primary.withValues(alpha: 0.04), halfFan);
    _drawBoundaryLines(canvas, Colors.white.withValues(alpha: 0.18), halfFan);
    _drawGuideRings(canvas, Colors.white.withValues(alpha: 0.14), halfFan);
    if (card.arcLinesEnabled) {
      _drawArcLines(canvas, Colors.white, halfFan);
    }
    _drawSpokes(
      canvas,
      Colors.white.withValues(alpha: 0.03),
      AppColors.textMuted.withValues(alpha: 0.34),
    );
    _drawNorthLine(canvas, AppColors.success.withValues(alpha: 0.55));
    _drawTerrainItems(canvas);
    _drawPivot(canvas, AppColors.success);
    _drawEntries(canvas);

    canvas.restore();
  }

  void _drawFanWedge(Canvas canvas, Color fillColor, double halfFan) {
    final path = Path()
      ..moveTo(_kCx, _kCy)
      ..lineTo(_toXY(-halfFan, 1).dx, _toXY(-halfFan, 1).dy)
      ..arcTo(
        Rect.fromCircle(center: const Offset(_kCx, _kCy), radius: _kMaxR),
        _degToRad(-90 - halfFan),
        _degToRad(_kFanDeg),
        false,
      )
      ..close();

    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.fill
        ..color = fillColor,
    );
  }

  void _drawBoundaryLines(Canvas canvas, Color color, double halfFan) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8
      ..color = color;

    canvas.drawLine(const Offset(_kCx, _kCy), _toXY(-halfFan, 1), paint);
    canvas.drawLine(const Offset(_kCx, _kCy), _toXY(halfFan, 1), paint);
  }

  void _drawGuideRings(Canvas canvas, Color color, double halfFan) {
    for (final ring in _rings) {
      final norm = ring / maxRange;
      final svgRadius = norm * _kMaxR;
      if (svgRadius > _kMaxR + 2) {
        continue;
      }
      final path = _arcPath(svgRadius, -halfFan, halfFan);
      _drawDashedPath(
        canvas,
        path,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.4
          ..color = color,
        const <double>[3, 4],
      );
    }
  }

  void _drawArcLines(Canvas canvas, Color color, double halfFan) {
    for (var index = 0; index < _rings.length; index++) {
      final ring = _rings[index];
      final norm = ring / maxRange;
      final svgRadius = norm * _kMaxR;
      if (svgRadius > _kMaxR + 2) {
        continue;
      }
      final isMax = index == _rings.length - 1;
      final path = _arcPath(svgRadius, -halfFan, halfFan);
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = isMax ? 1.8 : 1.2
        ..color = color.withValues(alpha: isMax ? 0.65 : 0.45);
      canvas.drawPath(path, paint);

      for (final degree in <double>[-halfFan, halfFan]) {
        final inner = _toXY(degree, math.max(0, norm - 0.03));
        final outer = _toXY(degree, math.min(1, norm + 0.03));
        canvas.drawLine(
          inner,
          outer,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1
            ..color = color.withValues(alpha: 0.45),
        );
      }

      final left = _toXY(-halfFan + 3, norm);
      final right = _toXY(halfFan - 3, norm);
      final label = _formatDistance(ring.toDouble());
      _drawText(
        canvas,
        label,
        Offset(left.dx - 3, left.dy + 2),
        color.withValues(alpha: 0.8),
        9.5,
        TextAlign.right,
        fontWeight: FontWeight.w700,
      );
      _drawText(
        canvas,
        label,
        Offset(right.dx + 3, right.dy + 2),
        color.withValues(alpha: 0.8),
        9.5,
        TextAlign.left,
        fontWeight: FontWeight.w700,
      );
    }
  }

  void _drawSpokes(Canvas canvas, Color lineColor, Color textColor) {
    for (final degree in const <int>[-60, -40, -20, 0, 20, 40, 60]) {
      canvas.drawLine(
        const Offset(_kCx, _kCy),
        _toXY(degree.toDouble(), 0.97),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.4
          ..color = lineColor,
      );

      if (degree == 0) {
        continue;
      }
      final labelPoint = _toXY(degree.toDouble(), 0.82);
      _drawText(
        canvas,
        degree > 0 ? 'R$degree°' : 'L${degree.abs()}°',
        labelPoint,
        textColor,
        8,
        TextAlign.center,
      );
    }
  }

  void _drawNorthLine(Canvas canvas, Color color) {
    _drawDashedPath(
      canvas,
      Path()
        ..moveTo(_kCx, _kCy)
        ..lineTo(_kCx, _kCy - (_kMaxR * 1.02)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.9
        ..color = color,
      const <double>[5, 3],
    );

    _drawText(
      canvas,
      'N',
      Offset(_kCx, _kCy - (_kMaxR * 1.05)),
      AppColors.success.withValues(alpha: 0.85),
      10,
      TextAlign.center,
      fontWeight: FontWeight.w700,
    );
  }

  void _drawTerrainItems(Canvas canvas) {
    for (final terrain in card.terrainItems) {
      _drawStroke(canvas, terrain.points, terrain.type, isDraft: false);
    }

    if (draftTerrainPoints.length >= 2 && editorMode.isTerrain) {
      _drawStroke(
        canvas,
        draftTerrainPoints,
        editorMode.terrainType ?? TerrainType.other,
        isDraft: true,
      );
    }
  }

  void _drawStroke(
    Canvas canvas,
    List<VisualPoint> points,
    TerrainType terrainType, {
    required bool isDraft,
  }) {
    if (points.length < 2) {
      return;
    }
    final style = _styleForTerrain(terrainType, isDraft: isDraft);
    final path = Path()
      ..moveTo(
        _fromNormalizedPoint(points.first).dx,
        _fromNormalizedPoint(points.first).dy,
      );
    for (var index = 1; index < points.length; index++) {
      final offset = _fromNormalizedPoint(points[index]);
      path.lineTo(offset.dx, offset.dy);
    }

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = style.strokeWidth
      ..strokeCap = style.strokeCap
      ..strokeJoin = style.strokeJoin
      ..color = style.color.withValues(alpha: style.opacity);

    if (style.dashArray == null) {
      canvas.drawPath(path, paint);
    } else {
      _drawDashedPath(canvas, path, paint, style.dashArray!);
    }
  }

  void _drawPivot(Canvas canvas, Color color) {
    canvas.drawCircle(
      const Offset(_kCx, _kCy),
      4,
      Paint()..color = color.withValues(alpha: 0.8),
    );
    canvas.drawCircle(
      const Offset(_kCx, _kCy),
      8,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1
        ..color = color.withValues(alpha: 0.3),
    );
  }

  void _drawEntries(Canvas canvas) {
    for (var index = 0; index < card.targetMarkers.length; index++) {
      final marker = card.targetMarkers[index];
      final visualAngle = visualRangeCardService.visualAngleFromStored(
        marker.angle,
      );
      final normalizedRange = math.min(marker.distance / maxRange, 0.97);
      final point = _toXY(visualAngle, normalizedRange);
      final color = _kMarkerColors[index % _kMarkerColors.length];
      final labelRight = visualAngle >= 0;

      _drawDashedPath(
        canvas,
        Path()
          ..moveTo(_kCx, _kCy)
          ..lineTo(point.dx, point.dy),
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..color = color.withValues(alpha: 0.4),
        const <double>[3, 2],
      );

      canvas.drawCircle(
        point,
        7,
        Paint()..color = color.withValues(alpha: 0.18),
      );
      canvas.drawCircle(
        point,
        4,
        Paint()..color = color.withValues(alpha: 0.85),
      );

      final labelX = labelRight ? point.dx + 5 : point.dx - 5;
      _drawText(
        canvas,
        marker.label,
        Offset(labelX, point.dy - 10),
        color.withValues(alpha: 0.95),
        9,
        labelRight ? TextAlign.left : TextAlign.right,
        fontWeight: FontWeight.w700,
      );
      _drawText(
        canvas,
        _formatDistance(marker.distance),
        Offset(labelX, point.dy - 3.5),
        color.withValues(alpha: 0.72),
        7.5,
        labelRight ? TextAlign.left : TextAlign.right,
      );
    }
  }

  _BrushStyle _styleForTerrain(
    TerrainType terrainType, {
    required bool isDraft,
  }) {
    final opacity = isDraft ? 0.75 : 0.92;
    return switch (terrainType) {
      TerrainType.river => _BrushStyle(
        color: const Color(0xFF38BDF8),
        strokeWidth: 2.5,
        dashArray: null,
        opacity: opacity,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ),
      TerrainType.treeline => _BrushStyle(
        color: const Color(0xFF16A34A),
        strokeWidth: 3.5,
        dashArray: const <double>[2, 4],
        opacity: opacity,
        strokeCap: StrokeCap.square,
        strokeJoin: StrokeJoin.miter,
      ),
      TerrainType.road => _BrushStyle(
        color: const Color(0xFFD4A017),
        strokeWidth: 2,
        dashArray: const <double>[6, 2],
        opacity: opacity,
        strokeCap: StrokeCap.butt,
        strokeJoin: StrokeJoin.round,
      ),
      TerrainType.building => _BrushStyle(
        color: const Color(0xFFF87171),
        strokeWidth: 4,
        dashArray: null,
        opacity: isDraft ? 0.65 : 0.75,
        strokeCap: StrokeCap.square,
        strokeJoin: StrokeJoin.miter,
      ),
      TerrainType.other => _BrushStyle(
        color: AppColors.textMuted,
        strokeWidth: 2.5,
        dashArray: null,
        opacity: opacity,
        strokeCap: StrokeCap.round,
        strokeJoin: StrokeJoin.round,
      ),
    };
  }

  Offset _toXY(double angleDegrees, double rangeNorm) {
    final radians = _degToRad(angleDegrees);
    final radius = rangeNorm * _kMaxR;
    return Offset(
      _kCx + (radius * math.sin(radians)),
      _kCy - (radius * math.cos(radians)),
    );
  }

  Path _arcPath(double radius, double fromDeg, double toDeg) {
    return Path()..addArc(
      Rect.fromCircle(center: const Offset(_kCx, _kCy), radius: radius),
      _degToRad(-90 + fromDeg),
      _degToRad(toDeg - fromDeg),
    );
  }

  Offset _fromNormalizedPoint(VisualPoint point) {
    return Offset(point.x * _kViewWidth, point.y * _kViewHeight);
  }

  double _degToRad(double degrees) => degrees * math.pi / 180;

  int get _ringStep {
    if (maxRange <= 300) {
      return 50;
    }
    if (maxRange <= 1000) {
      return 100;
    }
    if (maxRange <= 3000) {
      return 500;
    }
    return 1000;
  }

  List<int> get _rings {
    final rings = <int>[];
    for (
      var ring = _ringStep;
      ring <= maxRange + _ringStep;
      ring += _ringStep
    ) {
      if (ring > maxRange * 1.15) {
        break;
      }
      rings.add(ring);
    }
    return rings;
  }

  String _formatDistance(double meters) {
    if (meters >= 1000) {
      final kilometers = meters / 1000;
      return (meters % 1000).abs() < 1
          ? '${kilometers.round()}km'
          : '${kilometers.toStringAsFixed(1)}km';
    }
    return '${meters.round()}m';
  }

  void _drawText(
    Canvas canvas,
    String text,
    Offset anchor,
    Color color,
    double fontSize,
    TextAlign textAlign, {
    FontWeight fontWeight = FontWeight.w600,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: fontWeight,
          height: 1,
        ),
      ),
      textAlign: textAlign,
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = switch (textAlign) {
      TextAlign.right || TextAlign.end => Offset(
        anchor.dx - painter.width,
        anchor.dy - (painter.height / 2),
      ),
      TextAlign.center => Offset(
        anchor.dx - (painter.width / 2),
        anchor.dy - (painter.height / 2),
      ),
      _ => Offset(anchor.dx, anchor.dy - (painter.height / 2)),
    };
    painter.paint(canvas, offset);
  }

  void _drawDashedPath(
    Canvas canvas,
    Path source,
    Paint paint,
    List<double> intervals,
  ) {
    for (final metric in source.computeMetrics()) {
      var distance = 0.0;
      var index = 0;
      while (distance < metric.length) {
        final length = intervals[index % intervals.length];
        if (index.isEven) {
          final extracted = metric.extractPath(
            distance,
            math.min(distance + length, metric.length),
          );
          canvas.drawPath(extracted, paint);
        }
        distance += length;
        index++;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _VisualRangePainter oldDelegate) {
    return oldDelegate.card != card ||
        oldDelegate.editorMode != editorMode ||
        oldDelegate.maxRange != maxRange ||
        oldDelegate.visualRangeCardService != visualRangeCardService ||
        oldDelegate.draftTerrainPoints.length != draftTerrainPoints.length ||
        !_samePoints(oldDelegate.draftTerrainPoints, draftTerrainPoints);
  }

  bool _samePoints(List<VisualPoint> left, List<VisualPoint> right) {
    if (identical(left, right)) {
      return true;
    }
    if (left.length != right.length) {
      return false;
    }
    for (var index = 0; index < left.length; index++) {
      if (left[index].x != right[index].x || left[index].y != right[index].y) {
        return false;
      }
    }
    return true;
  }
}

class _BrushStyle {
  const _BrushStyle({
    required this.color,
    required this.strokeWidth,
    required this.dashArray,
    required this.opacity,
    required this.strokeCap,
    required this.strokeJoin,
  });

  final Color color;
  final double strokeWidth;
  final List<double>? dashArray;
  final double opacity;
  final StrokeCap strokeCap;
  final StrokeJoin strokeJoin;
}
