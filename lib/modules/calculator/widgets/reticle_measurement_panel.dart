import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:milexact/data/models/enums.dart';

const double _reticleInnerRadiusFactor = 0.40;
const double _reticleOuterRadiusMultiplier = 1.15;
const double _guideGrabThreshold = 18.0;
const double _minReticleZoom = 0.55;
const double _maxReticleZoom = 3.0;
const Color _reticleCanvasColor = Color(0xFF020202);
const Color _reticleBorderColor = Color(0xFF141414);
const Color _reticleLineColor = Color(0xFFF2F2EF);
const Color _reticleMinorLineColor = Color(0xFFD8D8D4);
const Color _reticleLabelColor = Color(0xFFFF4A43);
const Color _reticleMeasurementColor = Color(0xFFF0D21B);
const Color _reticleCenterDotColor = Color(0xFFFF453A);

enum _GuideDragTarget { measurement }

class ReticleMeasurementPanel extends StatefulWidget {
  const ReticleMeasurementPanel({
    super.key,
    required this.referenceDimension,
    required this.baselineFraction,
    required this.measurementFraction,
    required this.reticleType,
    required this.reticleProfile,
    required this.readingLabel,
    required this.lineThickness,
    required this.overlayOpacity,
    required this.zoomFactor,
    required this.interactionEnabled,
    required this.onInteractionActiveChanged,
    required this.onInteractionStart,
    required this.onBaselineUpdate,
    required this.onInteractionUpdate,
    this.motionDuration = const Duration(milliseconds: 72),
    this.motionCurve = Curves.easeOutCubic,
  });

  final TargetDimensionType referenceDimension;
  final double baselineFraction;
  final double measurementFraction;
  final ReticleType reticleType;
  final ReticleProfile reticleProfile;
  final String readingLabel;
  final double lineThickness;
  final double overlayOpacity;
  final double zoomFactor;
  final bool interactionEnabled;
  final ValueChanged<bool> onInteractionActiveChanged;
  final void Function(Offset localPosition, Size size) onInteractionStart;
  final void Function(Offset localPosition, Size size) onBaselineUpdate;
  final void Function(Offset localPosition, Size size) onInteractionUpdate;
  final Duration motionDuration;
  final Curve motionCurve;

  @override
  State<ReticleMeasurementPanel> createState() =>
      _ReticleMeasurementPanelState();
}

class _ReticleMeasurementPanelState extends State<ReticleMeasurementPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motionController;
  late Animation<double> _motionAnimation;
  late double _displayBaselineFraction;
  late double _displayMeasurementFraction;
  Tween<double>? _baselineTween;
  Tween<double>? _measurementTween;
  int? _activePointer;
  _GuideDragTarget? _activeDragTarget;

  @override
  void initState() {
    super.initState();
    _displayBaselineFraction = widget.baselineFraction;
    _displayMeasurementFraction = widget.measurementFraction;
    _motionController = AnimationController(
      vsync: this,
      duration: widget.motionDuration,
    );
    _motionAnimation = CurvedAnimation(
      parent: _motionController,
      curve: widget.motionCurve,
    );
    _motionController.addListener(_handleAnimationTick);
  }

  @override
  void didUpdateWidget(covariant ReticleMeasurementPanel oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.motionDuration != widget.motionDuration) {
      _motionController.duration = widget.motionDuration;
    }

    if (oldWidget.interactionEnabled && !widget.interactionEnabled) {
      _activePointer = null;
      _activeDragTarget = null;
      widget.onInteractionActiveChanged(false);
    }

    if (oldWidget.baselineFraction != widget.baselineFraction ||
        oldWidget.measurementFraction != widget.measurementFraction) {
      _baselineTween = Tween<double>(
        begin: _displayBaselineFraction,
        end: widget.baselineFraction,
      );
      _measurementTween = Tween<double>(
        begin: _displayMeasurementFraction,
        end: widget.measurementFraction,
      );
      _motionAnimation = CurvedAnimation(
        parent: _motionController,
        curve: widget.motionCurve,
      );
      _motionController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    widget.onInteractionActiveChanged(false);
    _motionController
      ..removeListener(_handleAnimationTick)
      ..dispose();
    super.dispose();
  }

  void _handleAnimationTick() {
    setState(() {
      _displayBaselineFraction =
          _baselineTween?.evaluate(_motionAnimation) ?? widget.baselineFraction;
      _displayMeasurementFraction =
          _measurementTween?.evaluate(_motionAnimation) ??
          widget.measurementFraction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 350);

        return SizedBox(
          height: size.height,
          width: double.infinity,
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: widget.interactionEnabled
                ? (event) => _handlePointerDown(event, size)
                : null,
            onPointerMove: widget.interactionEnabled
                ? (event) => _handlePointerMove(event, size)
                : null,
            onPointerUp: widget.interactionEnabled ? _handlePointerUp : null,
            onPointerCancel: widget.interactionEnabled
                ? _handlePointerCancel
                : null,
            child: CustomPaint(
              size: size,
              painter: ReticleMeasurementPainter(
                referenceDimension: widget.referenceDimension,
                baselineFraction: _displayBaselineFraction,
                measurementFraction: _displayMeasurementFraction,
                reticleType: widget.reticleType,
                reticleProfile: widget.reticleProfile,
                readingLabel: widget.readingLabel,
                lineThickness: widget.lineThickness,
                overlayOpacity: widget.overlayOpacity,
                zoomFactor: widget.zoomFactor,
                measurementModeEnabled: widget.interactionEnabled,
              ),
            ),
          ),
        );
      },
    );
  }

  void _handlePointerDown(PointerDownEvent event, Size size) {
    _activePointer = event.pointer;
    widget.onInteractionActiveChanged(true);
    final localPosition = _clampInteractionToScope(
      _logicalCanvasPosition(event.localPosition, size),
      size,
    );
    final dragTarget = _resolveDragTarget(localPosition, size);

    _activeDragTarget = dragTarget;

    switch (dragTarget) {
      case _GuideDragTarget.measurement:
        widget.onInteractionUpdate(localPosition, size);
        break;
      default:
        widget.onInteractionUpdate(localPosition, size);
        _activeDragTarget = _GuideDragTarget.measurement;
        break;
    }
  }

  void _handlePointerMove(PointerMoveEvent event, Size size) {
    if (_activePointer != event.pointer) {
      return;
    }

    final localPosition = _clampInteractionToScope(
      _logicalCanvasPosition(event.localPosition, size),
      size,
    );
    switch (_activeDragTarget) {
      case _GuideDragTarget.measurement:
        widget.onInteractionUpdate(localPosition, size);
        break;
      default:
        widget.onInteractionUpdate(localPosition, size);
        break;
    }
  }

  void _handlePointerUp(PointerUpEvent event) {
    if (_activePointer != event.pointer) {
      return;
    }

    _activePointer = null;
    _activeDragTarget = null;
    widget.onInteractionActiveChanged(false);
  }

  void _handlePointerCancel(PointerCancelEvent event) {
    if (_activePointer != event.pointer) {
      return;
    }

    _activePointer = null;
    _activeDragTarget = null;
    widget.onInteractionActiveChanged(false);
  }

  _GuideDragTarget? _resolveDragTarget(Offset localPosition, Size size) {
    final measurementPosition = _axisPositionPx(
      _displayMeasurementFraction,
      size,
    );
    final touchPosition =
        widget.referenceDimension == TargetDimensionType.height
        ? localPosition.dy
        : localPosition.dx;
    final hasMeasurement =
        (_displayMeasurementFraction - _displayBaselineFraction).abs() >
            0.001 &&
        widget.readingLabel.trim().isNotEmpty;

    if (hasMeasurement &&
        (touchPosition - measurementPosition).abs() <= _guideGrabThreshold) {
      return _GuideDragTarget.measurement;
    }

    return null;
  }

  double _axisPositionPx(double fraction, Size size) {
    return widget.referenceDimension == TargetDimensionType.height
        ? size.height * fraction
        : size.width * fraction;
  }

  Offset _logicalCanvasPosition(Offset localPosition, Size size) {
    final zoomFactor = widget.zoomFactor.clamp(
      _minReticleZoom,
      _maxReticleZoom,
    );
    if ((zoomFactor - 1).abs() < 0.001) {
      return localPosition;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final delta = localPosition - center;
    return center + (delta / zoomFactor);
  }

  Offset _clampInteractionToScope(Offset localPosition, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final scopeRadius =
        size.shortestSide *
        _reticleInnerRadiusFactor *
        _reticleOuterRadiusMultiplier;

    if (widget.referenceDimension == TargetDimensionType.height) {
      return Offset(
        localPosition.dx,
        localPosition.dy.clamp(
          center.dy - scopeRadius,
          center.dy + scopeRadius,
        ),
      );
    }

    return Offset(
      localPosition.dx.clamp(center.dx - scopeRadius, center.dx + scopeRadius),
      localPosition.dy,
    );
  }
}

class ReticleMeasurementPainter extends CustomPainter {
  const ReticleMeasurementPainter({
    required this.referenceDimension,
    required this.baselineFraction,
    required this.measurementFraction,
    required this.reticleType,
    required this.reticleProfile,
    required this.readingLabel,
    required this.lineThickness,
    required this.overlayOpacity,
    required this.zoomFactor,
    this.measurementModeEnabled = false,
  });

  final TargetDimensionType referenceDimension;
  final double baselineFraction;
  final double measurementFraction;
  final ReticleType reticleType;
  final ReticleProfile reticleProfile;
  final String readingLabel;
  final double lineThickness;
  final double overlayOpacity;
  final double zoomFactor;
  final bool measurementModeEnabled;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * _reticleInnerRadiusFactor;
    final scopeRadius = radius * _reticleOuterRadiusMultiplier;
    final reticleVisibility = overlayOpacity.clamp(0.2, 1.0);
    const measurementOpacity = 0.96;
    final horizontalExtent = (size.width / 2) - 22;
    final verticalExtent = (size.height / 2) - 18;
    final borderPaint = Paint()
      ..color = _reticleBorderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final fillPaint = Paint()
      ..color = _reticleCanvasColor
      ..style = PaintingStyle.fill;
    final reticlePaint = Paint()
      ..color = _reticleLineColor.withValues(alpha: reticleVisibility * 0.96)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final accentPaint = Paint()
      ..color = _reticleMeasurementColor.withValues(alpha: measurementOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    canvas.drawRRect(rect, fillPaint);
    canvas.drawRRect(rect, borderPaint);

    canvas.save();
    canvas.clipRRect(rect);
    canvas.translate(center.dx, center.dy);
    final normalizedZoom = zoomFactor.clamp(_minReticleZoom, _maxReticleZoom);
    canvas.scale(normalizedZoom, normalizedZoom);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawLine(
      Offset(center.dx, center.dy - verticalExtent),
      Offset(center.dx, center.dy + verticalExtent),
      reticlePaint,
    );
    canvas.drawLine(
      Offset(center.dx - horizontalExtent, center.dy),
      Offset(center.dx + horizontalExtent, center.dy),
      reticlePaint,
    );

    switch (reticleProfile) {
      case ReticleProfile.milDot:
        _drawMilDots(canvas, center, radius, reticlePaint);
      case ReticleProfile.milHash05:
        _drawMilHashCrosshair(
          canvas,
          center,
          radius,
          minorTicksPerMil: 2,
          majorHalfLength: 14,
          minorHalfLength: 5,
          majorStrokeWidth: 1.6,
          minorStrokeWidth: 1.0,
          centerDotRadius: 3.0,
        );
      case ReticleProfile.milHash02:
        _drawMilHashCrosshair(
          canvas,
          center,
          radius,
          minorTicksPerMil: 5,
          majorHalfLength: 14,
          minorHalfLength: 4,
          majorStrokeWidth: 1.6,
          minorStrokeWidth: 1.05,
          centerDotRadius: 3.0,
        );
      case ReticleProfile.christmasTree:
        _drawMilHashCrosshair(
          canvas,
          center,
          radius,
          minorTicksPerMil: 5,
          majorHalfLength: 14,
          minorHalfLength: 4,
          majorStrokeWidth: 1.6,
          minorStrokeWidth: 1.05,
          centerDotRadius: 3.0,
        );
        _drawChristmasTree(canvas, size, center);
      case ReticleProfile.duplex:
        _drawDuplex(canvas, size, center, reticlePaint);
    }

    if (reticleProfile == ReticleProfile.christmasTree) {
      _drawChristmasTreeLabels(canvas, center, radius);
    } else if (reticleProfile == ReticleProfile.milHash05 ||
        reticleProfile == ReticleProfile.milHash02) {
      _drawMilHashLabels(canvas, center, radius);
    } else if (reticleProfile != ReticleProfile.duplex) {
      _drawAxisLabels(canvas, size, center, radius);
    }

    final showMeasurementOverlay =
        measurementModeEnabled || readingLabel.trim().isNotEmpty;

    if (showMeasurementOverlay &&
        referenceDimension == TargetDimensionType.height) {
      final baselineY = size.height * baselineFraction;
      final measurementY = size.height * measurementFraction;
      _drawHeightMeasurementOverlay(
        canvas: canvas,
        size: size,
        center: center,
        scopeRadius: scopeRadius,
        baselineY: baselineY,
        measurementY: measurementY,
        accentPaint: accentPaint,
      );
    } else if (showMeasurementOverlay) {
      final baselineX = size.width * baselineFraction;
      final measurementX = size.width * measurementFraction;
      _drawWidthMeasurementOverlay(
        canvas: canvas,
        size: size,
        center: center,
        scopeRadius: scopeRadius,
        baselineX: baselineX,
        measurementX: measurementX,
        accentPaint: accentPaint,
      );
    }

    _drawFooter(canvas, size);
    canvas.restore();
  }

  void _drawHeightMeasurementOverlay({
    required Canvas canvas,
    required Size size,
    required Offset center,
    required double scopeRadius,
    required double baselineY,
    required double measurementY,
    required Paint accentPaint,
  }) {
    final deltaFraction = (measurementFraction - baselineFraction).abs();
    const normalizedOpacity = 0.96;
    const guideAlpha = 0.92;
    final dashedPaint = Paint()
      ..color = _reticleMeasurementColor.withValues(alpha: guideAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final measurementGuidePaint = Paint()
      ..color = _reticleMeasurementColor.withValues(alpha: guideAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final connectorPaint = Paint()
      ..color = _reticleMeasurementColor.withValues(alpha: normalizedOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (lineThickness * 1.25).clamp(1.4, 3.2)
      ..strokeCap = StrokeCap.butt;
    final hasMeasurement = deltaFraction > 0.001 && readingLabel.isNotEmpty;
    final endpointPaint = Paint()
      ..color = _reticleMeasurementColor.withValues(alpha: normalizedOpacity)
      ..style = PaintingStyle.fill;
    final connectorX = size.width - 18;
    final baselineStart = Offset(14, baselineY);
    final baselineEnd = Offset(size.width - 14, baselineY);
    final measurementStart = Offset(14, measurementY);
    final measurementEnd = Offset(size.width - 14, measurementY);

    _drawDashedLine(
      canvas: canvas,
      start: baselineStart,
      end: baselineEnd,
      paint: dashedPaint,
      dashLength: 10,
      gapLength: 6,
    );

    _paintText(
      canvas,
      text: '0',
      offset: Offset(8, baselineY - 18),
      style: TextStyle(
        color: _reticleMeasurementColor.withValues(alpha: guideAlpha),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );

    if (hasMeasurement) {
      canvas.drawLine(measurementStart, measurementEnd, measurementGuidePaint);
      canvas.drawLine(
        Offset(connectorX, measurementY),
        Offset(connectorX, baselineY),
        connectorPaint,
      );
      canvas.drawCircle(Offset(connectorX, baselineY), 4, endpointPaint);
      canvas.drawCircle(Offset(connectorX, measurementY), 4, endpointPaint);
      _paintText(
        canvas,
        text: '$readingLabel ${reticleType.label}',
        offset: Offset(connectorX - 96, measurementY + 8),
        style: TextStyle(
          color: _reticleMeasurementColor.withValues(alpha: normalizedOpacity),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );
    }
  }

  void _drawWidthMeasurementOverlay({
    required Canvas canvas,
    required Size size,
    required Offset center,
    required double scopeRadius,
    required double baselineX,
    required double measurementX,
    required Paint accentPaint,
  }) {
    final deltaFraction = (measurementFraction - baselineFraction).abs();
    const normalizedOpacity = 0.96;
    const guideAlpha = 0.92;
    final dashedPaint = Paint()
      ..color = _reticleMeasurementColor.withValues(alpha: guideAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final measurementGuidePaint = Paint()
      ..color = _reticleMeasurementColor.withValues(alpha: guideAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final connectorPaint = Paint()
      ..color = _reticleMeasurementColor.withValues(alpha: normalizedOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = (lineThickness * 1.25).clamp(1.4, 3.2)
      ..strokeCap = StrokeCap.butt;
    final hasMeasurement = deltaFraction > 0.001 && readingLabel.isNotEmpty;
    final endpointPaint = Paint()
      ..color = _reticleMeasurementColor.withValues(alpha: normalizedOpacity)
      ..style = PaintingStyle.fill;
    final baselineStart = Offset(baselineX, 14);
    final baselineEnd = Offset(baselineX, size.height - 14);
    final measurementStart = Offset(measurementX, 14);
    final measurementEnd = Offset(measurementX, size.height - 14);

    _drawDashedLine(
      canvas: canvas,
      start: baselineStart,
      end: baselineEnd,
      paint: dashedPaint,
      dashLength: 10,
      gapLength: 6,
    );

    _paintText(
      canvas,
      text: '0',
      offset: Offset(baselineX - 18, 8),
      style: TextStyle(
        color: _reticleMeasurementColor.withValues(alpha: guideAlpha),
        fontSize: 12,
        fontWeight: FontWeight.w700,
      ),
    );

    if (hasMeasurement) {
      canvas.drawLine(measurementStart, measurementEnd, measurementGuidePaint);
      canvas.drawLine(
        Offset(baselineX, center.dy),
        Offset(measurementX, center.dy),
        connectorPaint,
      );
      canvas.drawCircle(Offset(baselineX, center.dy), 4, endpointPaint);
      canvas.drawCircle(Offset(measurementX, center.dy), 4, endpointPaint);
      _paintText(
        canvas,
        text: '$readingLabel ${reticleType.label}',
        offset: Offset(measurementX - 48, center.dy - 28),
        style: TextStyle(
          color: _reticleMeasurementColor.withValues(alpha: normalizedOpacity),
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      );
    }
  }

  void _drawMilDots(
    Canvas canvas,
    Offset center,
    double radius,
    Paint reticlePaint,
  ) {
    final visibility = overlayOpacity.clamp(0.2, 1.0);
    final dotPaint = Paint()
      ..color = _reticleLineColor.withValues(alpha: visibility * 0.96)
      ..style = PaintingStyle.fill;
    final centerDotPaint = Paint()
      ..color = _reticleCenterDotColor
      ..style = PaintingStyle.fill;
    final step = radius / 5;

    canvas.drawCircle(center, 3.2, centerDotPaint);

    for (var i = 1; i <= 5; i++) {
      final offset = i * step;
      final dotRadius = i == 5 ? 3.1 : 2.9;
      canvas.drawCircle(
        Offset(center.dx + offset, center.dy),
        dotRadius,
        dotPaint,
      );
      canvas.drawCircle(
        Offset(center.dx - offset, center.dy),
        dotRadius,
        dotPaint,
      );
      canvas.drawCircle(
        Offset(center.dx, center.dy + offset),
        dotRadius,
        dotPaint,
      );
      canvas.drawCircle(
        Offset(center.dx, center.dy - offset),
        dotRadius,
        dotPaint,
      );
    }
  }

  void _drawMilHashCrosshair(
    Canvas canvas,
    Offset center,
    double radius, {
    required int minorTicksPerMil,
    required double majorHalfLength,
    required double minorHalfLength,
    required double majorStrokeWidth,
    required double minorStrokeWidth,
    required double centerDotRadius,
  }) {
    final visibility = overlayOpacity.clamp(0.2, 1.0);
    final majorStep = radius / 5;
    final minorStep = majorStep / minorTicksPerMil;
    final majorPaint = Paint()
      ..color = _reticleLineColor.withValues(alpha: visibility * 0.96)
      ..style = PaintingStyle.stroke
      ..strokeWidth = majorStrokeWidth;
    final minorPaint = Paint()
      ..color = _reticleMinorLineColor.withValues(alpha: visibility * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = minorStrokeWidth;
    final centerDotPaint = Paint()
      ..color = _reticleCenterDotColor
      ..style = PaintingStyle.fill;

    for (var i = 1; i <= 5; i++) {
      final offset = majorStep * i;
      canvas.drawLine(
        Offset(center.dx - majorHalfLength, center.dy - offset),
        Offset(center.dx + majorHalfLength, center.dy - offset),
        majorPaint,
      );
      canvas.drawLine(
        Offset(center.dx - majorHalfLength, center.dy + offset),
        Offset(center.dx + majorHalfLength, center.dy + offset),
        majorPaint,
      );
      canvas.drawLine(
        Offset(center.dx - offset, center.dy - majorHalfLength),
        Offset(center.dx - offset, center.dy + majorHalfLength),
        majorPaint,
      );
      canvas.drawLine(
        Offset(center.dx + offset, center.dy - majorHalfLength),
        Offset(center.dx + offset, center.dy + majorHalfLength),
        majorPaint,
      );

      if (i < 5) {
        for (
          var subdivision = 1;
          subdivision < minorTicksPerMil;
          subdivision++
        ) {
          final minorOffset = offset + (minorStep * subdivision);
          if (minorOffset >= radius + 0.001) {
            continue;
          }
          canvas.drawLine(
            Offset(center.dx - minorHalfLength, center.dy - minorOffset),
            Offset(center.dx + minorHalfLength, center.dy - minorOffset),
            minorPaint,
          );
          canvas.drawLine(
            Offset(center.dx - minorHalfLength, center.dy + minorOffset),
            Offset(center.dx + minorHalfLength, center.dy + minorOffset),
            minorPaint,
          );
          canvas.drawLine(
            Offset(center.dx - minorOffset, center.dy - minorHalfLength),
            Offset(center.dx - minorOffset, center.dy + minorHalfLength),
            minorPaint,
          );
          canvas.drawLine(
            Offset(center.dx + minorOffset, center.dy - minorHalfLength),
            Offset(center.dx + minorOffset, center.dy + minorHalfLength),
            minorPaint,
          );
        }
      }
    }

    canvas.drawCircle(center, centerDotRadius, centerDotPaint);
  }

  void _drawChristmasTree(Canvas canvas, Size size, Offset center) {
    final visibility = overlayOpacity.clamp(0.2, 1.0);
    final radius = size.shortestSide * _reticleInnerRadiusFactor;
    final scopeRadius = radius * _reticleOuterRadiusMultiplier;
    final milStep = radius / 5;
    final minorStep = milStep / 5;
    final maxTreeHalfWidth = math.min(scopeRadius - 18, (size.width / 2) - 24);
    final rowPaint = Paint()
      ..color = _reticleLineColor.withValues(alpha: visibility * 0.96)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.25;
    final majorTickPaint = Paint()
      ..color = _reticleLineColor.withValues(alpha: visibility * 0.96)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.35;
    final minorTickPaint = Paint()
      ..color = _reticleMinorLineColor.withValues(alpha: visibility * 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.95;
    final treeLabelStyle = TextStyle(
      color: _reticleLabelColor.withValues(alpha: visibility * 0.9),
      fontSize: 15,
      fontWeight: FontWeight.w700,
    );

    for (var row = 1; row <= 10; row++) {
      final y = center.dy + (row * milStep);
      if (y >= center.dy + scopeRadius - 4 || y > size.height - 16) {
        break;
      }

      final halfWidth = math.min(row * milStep, maxTreeHalfWidth);
      if (halfWidth <= minorStep * 2) {
        continue;
      }

      canvas.drawLine(
        Offset(center.dx - halfWidth, y),
        Offset(center.dx + halfWidth, y),
        rowPaint,
      );

      final minorTickCount = (halfWidth / minorStep).floor();
      for (var tick = 1; tick < minorTickCount; tick++) {
        final xOffset = tick * minorStep;
        if (xOffset >= halfWidth - 0.5) {
          continue;
        }

        final isMajor = tick % 5 == 0;
        final tickHalfHeight = isMajor ? 13.0 : 6.0;
        final paint = isMajor ? majorTickPaint : minorTickPaint;

        canvas.drawLine(
          Offset(center.dx - xOffset, y - tickHalfHeight),
          Offset(center.dx - xOffset, y + tickHalfHeight),
          paint,
        );
        canvas.drawLine(
          Offset(center.dx + xOffset, y - tickHalfHeight),
          Offset(center.dx + xOffset, y + tickHalfHeight),
          paint,
        );
      }

      canvas.drawLine(
        Offset(center.dx - halfWidth, y - 15),
        Offset(center.dx - halfWidth, y + 15),
        majorTickPaint,
      );
      canvas.drawLine(
        Offset(center.dx + halfWidth, y - 15),
        Offset(center.dx + halfWidth, y + 15),
        majorTickPaint,
      );

      if (row <= 3) {
        _paintText(
          canvas,
          text: '$row',
          offset: Offset(center.dx - halfWidth - 28, y - 13),
          style: treeLabelStyle,
        );
        _paintText(
          canvas,
          text: '$row',
          offset: Offset(center.dx + halfWidth + 12, y - 13),
          style: treeLabelStyle,
        );
      }
    }
  }

  void _drawAxisLabels(Canvas canvas, Size size, Offset center, double radius) {
    final visibility = overlayOpacity.clamp(0.2, 1.0);
    final labelStyle = TextStyle(
      color: _reticleLabelColor.withValues(alpha: visibility * 0.96),
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final step = radius / 5;

    for (var i = 1; i <= 5; i++) {
      final offset = step * i;
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx + 9, center.dy - offset - 7),
        style: labelStyle,
      );
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx + 9, center.dy + offset - 7),
        style: labelStyle,
      );
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx + offset - 4, center.dy - 22),
        style: labelStyle,
      );
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx - offset - 4, center.dy - 22),
        style: labelStyle,
      );
    }

    _paintText(
      canvas,
      text: '0',
      offset: Offset(center.dx + 9, center.dy - 7),
      style: labelStyle,
    );
    _paintText(
      canvas,
      text: '0',
      offset: Offset(center.dx - 10, center.dy - 22),
      style: labelStyle,
    );
  }

  void _drawMilHashLabels(Canvas canvas, Offset center, double radius) {
    final visibility = overlayOpacity.clamp(0.2, 1.0);
    final labelStyle = TextStyle(
      color: _reticleLabelColor.withValues(alpha: visibility * 0.96),
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final step = radius / 5;

    for (var i = 1; i <= 5; i++) {
      final offset = step * i;
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx - 58, center.dy + offset - 15),
        style: labelStyle,
      );
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx + offset - 4, center.dy - 22),
        style: labelStyle,
      );
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx - offset - 10, center.dy - 22),
        style: labelStyle,
      );
    }
  }

  void _drawChristmasTreeLabels(Canvas canvas, Offset center, double radius) {
    final visibility = overlayOpacity.clamp(0.2, 1.0);
    final labelStyle = TextStyle(
      color: _reticleLabelColor.withValues(alpha: visibility * 0.96),
      fontSize: 16,
      fontWeight: FontWeight.w700,
    );
    final step = radius / 5;

    for (var i = 1; i <= 3; i++) {
      final offset = step * i;
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx + offset - 4, center.dy - 22),
        style: labelStyle,
      );
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx - offset - 10, center.dy - 22),
        style: labelStyle,
      );
    }

    for (var i = 1; i <= 5; i++) {
      final offset = step * i;
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx - 50, center.dy + offset - 15),
        style: labelStyle,
      );
    }
  }

  void _drawDuplex(
    Canvas canvas,
    Size size,
    Offset center,
    Paint reticlePaint,
  ) {
    final visibility = overlayOpacity.clamp(0.2, 1.0);
    final radius = size.shortestSide * _reticleInnerRadiusFactor;
    final scopeRadius = radius * _reticleOuterRadiusMultiplier;
    final innerGap = radius * 0.5;
    final outerInset = 8.0;
    final postLengthEnd = scopeRadius - outerInset;
    final thinPaint = Paint()
      ..color = _reticleLineColor.withValues(alpha: visibility * 0.96)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.square;
    final thickPaint = Paint()
      ..color = _reticleLineColor.withValues(alpha: visibility * 0.96)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.square;
    final centerDotPaint = Paint()
      ..color = _reticleCenterDotColor
      ..style = PaintingStyle.fill;

    canvas.drawLine(
      Offset(center.dx - scopeRadius, center.dy),
      Offset(center.dx + scopeRadius, center.dy),
      thinPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - scopeRadius),
      Offset(center.dx, center.dy + scopeRadius),
      thinPaint,
    );

    canvas.drawLine(
      Offset(center.dx - postLengthEnd, center.dy),
      Offset(center.dx - innerGap, center.dy),
      thickPaint,
    );
    canvas.drawLine(
      Offset(center.dx + innerGap, center.dy),
      Offset(center.dx + postLengthEnd, center.dy),
      thickPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - postLengthEnd),
      Offset(center.dx, center.dy - innerGap),
      thickPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + innerGap),
      Offset(center.dx, center.dy + postLengthEnd),
      thickPaint,
    );

    canvas.drawCircle(center, 3.2, centerDotPaint);
  }

  void _drawFooter(Canvas canvas, Size size) {}

  TextPainter _textPainter(String text, TextStyle style) {
    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
      maxLines: 1,
    )..layout();
    return painter;
  }

  void _paintText(
    Canvas canvas, {
    required String text,
    required Offset offset,
    required TextStyle style,
  }) {
    _textPainter(text, style).paint(canvas, offset);
  }

  void _drawDashedLine({
    required Canvas canvas,
    required Offset start,
    required Offset end,
    required Paint paint,
    required double dashLength,
    required double gapLength,
  }) {
    final vector = end - start;
    final distance = vector.distance;
    if (distance == 0) {
      return;
    }

    final direction = vector / distance;
    var progress = 0.0;
    while (progress < distance) {
      final segmentEnd = (progress + dashLength).clamp(0.0, distance);
      canvas.drawLine(
        start + (direction * progress),
        start + (direction * segmentEnd),
        paint,
      );
      progress += dashLength + gapLength;
    }
  }

  @override
  bool shouldRepaint(covariant ReticleMeasurementPainter oldDelegate) {
    return oldDelegate.referenceDimension != referenceDimension ||
        oldDelegate.baselineFraction != baselineFraction ||
        oldDelegate.measurementFraction != measurementFraction ||
        oldDelegate.reticleProfile != reticleProfile ||
        oldDelegate.reticleType != reticleType ||
        oldDelegate.readingLabel != readingLabel ||
        oldDelegate.lineThickness != lineThickness ||
        oldDelegate.overlayOpacity != overlayOpacity ||
        oldDelegate.zoomFactor != zoomFactor ||
        oldDelegate.measurementModeEnabled != measurementModeEnabled;
  }
}
