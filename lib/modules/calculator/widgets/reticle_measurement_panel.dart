import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/data/models/enums.dart';

const double _reticleInnerRadiusFactor = 0.40;
const double _reticleOuterRadiusMultiplier = 1.15;
const double _guideGrabThreshold = 18.0;
const double _minReticleZoom = 0.55;
const double _maxReticleZoom = 3.0;

enum _GuideDragTarget { baseline, measurement }

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
          child: Stack(
            children: [
              Positioned(
                top: 6,
                right: 8,
                child: _ReticleGuideLegend(
                  referenceDimension: widget.referenceDimension,
                  reticleProfile: widget.reticleProfile,
                  reticleType: widget.reticleType,
                ),
              ),
              Listener(
                behavior: HitTestBehavior.opaque,
                onPointerDown: widget.interactionEnabled
                    ? (event) => _handlePointerDown(event, size)
                    : null,
                onPointerMove: widget.interactionEnabled
                    ? (event) => _handlePointerMove(event, size)
                    : null,
                onPointerUp: widget.interactionEnabled
                    ? _handlePointerUp
                    : null,
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
            ],
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
      case _GuideDragTarget.baseline:
        widget.onBaselineUpdate(localPosition, size);
        break;
      default:
        widget.onInteractionStart(localPosition, size);
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
      case _GuideDragTarget.baseline:
        widget.onBaselineUpdate(localPosition, size);
        break;
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
    final center = Offset(size.width / 2, size.height / 2);
    final scopeRadius =
        size.shortestSide *
        _reticleInnerRadiusFactor *
        _reticleOuterRadiusMultiplier;
    final baselinePosition = _axisPositionPx(_displayBaselineFraction, size);
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

    final startIcon = _baselineActionIconPosition(
      size: size,
      center: center,
      scopeRadius: scopeRadius,
      useTargetSide: false,
    );
    final targetIcon = _baselineActionIconPosition(
      size: size,
      center: center,
      scopeRadius: scopeRadius,
      useTargetSide: true,
    );

    if ((localPosition - targetIcon).distance <= 28) {
      return _GuideDragTarget.measurement;
    }

    if ((localPosition - startIcon).distance <= 28) {
      return _GuideDragTarget.baseline;
    }

    if ((touchPosition - baselinePosition).abs() <= _guideGrabThreshold) {
      return _GuideDragTarget.baseline;
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

  Offset _baselineActionIconPosition({
    required Size size,
    required Offset center,
    required double scopeRadius,
    required bool useTargetSide,
  }) {
    if (widget.referenceDimension == TargetDimensionType.height) {
      final baselineY = size.height * _displayBaselineFraction;
      final span = _horizontalHalfSpanForCircle(
        center: center,
        radius: scopeRadius,
        y: baselineY,
      );
      return Offset(
        useTargetSide ? center.dx + span - 28 : center.dx - span + 28,
        baselineY,
      );
    }

    final baselineX = size.width * _displayBaselineFraction;
    final span = _verticalHalfSpanForCircle(
      center: center,
      radius: scopeRadius,
      x: baselineX,
    );
    return Offset(
      baselineX,
      useTargetSide ? center.dy + span - 28 : center.dy - span + 28,
    );
  }

  double _horizontalHalfSpanForCircle({
    required Offset center,
    required double radius,
    required double y,
  }) {
    final dy = (y - center.dy).abs();
    if (dy >= radius) {
      return 0;
    }
    return math.sqrt((radius * radius) - (dy * dy));
  }

  double _verticalHalfSpanForCircle({
    required Offset center,
    required double radius,
    required double x,
  }) {
    final dx = (x - center.dx).abs();
    if (dx >= radius) {
      return 0;
    }
    return math.sqrt((radius * radius) - (dx * dx));
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

class _ReticleGuideLegend extends StatelessWidget {
  const _ReticleGuideLegend({
    required this.referenceDimension,
    required this.reticleProfile,
    required this.reticleType,
  });

  final TargetDimensionType referenceDimension;
  final ReticleProfile reticleProfile;
  final ReticleType reticleType;

  @override
  Widget build(BuildContext context) {
    final heightActive = referenceDimension == TargetDimensionType.height;
    final widthActive = referenceDimension == TargetDimensionType.width;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _LegendLine(
          text: '↕ • ${reticleProfile.heightGuide} ${reticleType.label}',
          active: heightActive,
        ),
        const SizedBox(height: 3),
        _LegendLine(
          text: '↔ • ${reticleProfile.widthGuide} ${reticleType.label}',
          active: widthActive,
        ),
      ],
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        color: active ? AppColors.accent : AppColors.textMuted,
        fontSize: 11,
        fontWeight: active ? FontWeight.w700 : FontWeight.w600,
      ),
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
    final normalizedOpacity = overlayOpacity.clamp(0.35, 1.0);
    final borderPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final ringPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.16)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final reticlePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.82)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;
    final accentPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: normalizedOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final tickPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.52)
      ..strokeWidth = 1;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    canvas.drawRRect(rect, borderPaint);

    canvas.save();
    canvas.clipRRect(rect);
    canvas.translate(center.dx, center.dy);
    final normalizedZoom = zoomFactor.clamp(_minReticleZoom, _maxReticleZoom);
    canvas.scale(normalizedZoom, normalizedZoom);
    canvas.translate(-center.dx, -center.dy);

    canvas.drawCircle(center, scopeRadius, ringPaint);
    canvas.drawCircle(center, radius, ringPaint);

    canvas.drawLine(
      Offset(center.dx, center.dy - scopeRadius),
      Offset(center.dx, center.dy + scopeRadius),
      reticlePaint,
    );
    canvas.drawLine(
      Offset(center.dx - scopeRadius, center.dy),
      Offset(center.dx + scopeRadius, center.dy),
      reticlePaint,
    );

    switch (reticleProfile) {
      case ReticleProfile.milDot:
        _drawMilDots(canvas, center, radius, reticlePaint);
      case ReticleProfile.christmasTree:
        _drawStandardTicks(canvas, center, tickPaint);
        _drawChristmasTree(canvas, size, center, tickPaint);
      case ReticleProfile.duplex:
        _drawDuplex(canvas, size, center, reticlePaint);
      case ReticleProfile.simpleCrosshair:
        _drawSimpleCrosshair(canvas, center, radius, tickPaint, reticlePaint);
    }

    if (reticleProfile == ReticleProfile.simpleCrosshair) {
      _drawSimpleCrosshairLabels(canvas, center, radius);
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
    final normalizedThickness = lineThickness.clamp(0.8, 3.0);
    final normalizedOpacity = overlayOpacity.clamp(0.35, 1.0);
    final guideAlpha = (0.4 + (normalizedOpacity * 0.6)).clamp(0.0, 1.0);
    final guideThickness = 0.8;
    final connectorThickness = (lineThickness * 4.8).clamp(3.0, 12.0);
    final handleWidth = (16 + (normalizedThickness * 4)).clamp(20.0, 30.0);
    final handleHeight = (5 + (normalizedThickness * 1.6)).clamp(7.0, 12.0);
    final glowWidth = handleWidth + 4;
    final glowHeight = handleHeight + 4;
    final targetLabelColor = AppColors.accent.withValues(alpha: guideAlpha);
    final dashedPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: guideAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideThickness;
    final measurementGuidePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: guideAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideThickness;
    final connectorPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: normalizedOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = connectorThickness
      ..strokeCap = StrokeCap.square;
    final hasMeasurement = deltaFraction > 0.001 && readingLabel.isNotEmpty;
    final measurementHandlePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final baselineHalfSpan = _horizontalHalfSpanForCircle(
      center: center,
      radius: scopeRadius,
      y: baselineY,
    );
    final measurementHalfSpan = _horizontalHalfSpanForCircle(
      center: center,
      radius: scopeRadius,
      y: measurementY,
    );

    _drawDashedLine(
      canvas: canvas,
      start: Offset(center.dx - baselineHalfSpan, baselineY),
      end: Offset(center.dx + baselineHalfSpan, baselineY),
      paint: dashedPaint,
      dashLength: 10,
      gapLength: 6,
    );

    _drawBaselineActionIcon(
      canvas,
      center: Offset(center.dx - baselineHalfSpan + 28, baselineY),
      icon: Icons.touch_app_rounded,
      color: AppColors.primary,
      tooltipBackground: AppColors.background,
    );
    _drawBaselineActionIcon(
      canvas,
      center: Offset(center.dx + baselineHalfSpan - 28, baselineY),
      icon: Icons.my_location_rounded,
      color: AppColors.accent,
      tooltipBackground: AppColors.background,
    );

    if (hasMeasurement) {
      final baselineHandleGlowPaint = Paint()
        ..color = AppColors.primary.withValues(
          alpha: 0.06 + (normalizedOpacity * 0.14),
        )
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, baselineY),
            width: glowWidth,
            height: glowHeight,
          ),
          const Radius.circular(3),
        ),
        baselineHandleGlowPaint,
      );

      final handlePaint = Paint()
        ..color = AppColors.primary.withValues(alpha: guideAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, baselineY),
            width: handleWidth,
            height: handleHeight,
          ),
          const Radius.circular(2),
        ),
        handlePaint,
      );

      final arrowPaint = Paint()
        ..color = AppColors.primary.withValues(
          alpha: 0.35 + (normalizedOpacity * 0.45),
        )
        ..strokeWidth = (normalizedThickness * 0.9).clamp(1.0, 2.2)
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(center.dx - 6, baselineY - 1),
        Offset(center.dx - 10, baselineY),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(center.dx - 6, baselineY + 1),
        Offset(center.dx - 10, baselineY),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(center.dx + 6, baselineY - 1),
        Offset(center.dx + 10, baselineY),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(center.dx + 6, baselineY + 1),
        Offset(center.dx + 10, baselineY),
        arrowPaint,
      );

      canvas.drawLine(
        Offset(center.dx - measurementHalfSpan, measurementY),
        Offset(center.dx + measurementHalfSpan, measurementY),
        measurementGuidePaint,
      );
      canvas.drawLine(
        Offset(center.dx, measurementY),
        Offset(center.dx, baselineY),
        connectorPaint,
      );

      // Enhanced measurement handle with glow effect
      final measurementHandleGlowPaint = Paint()
        ..color = AppColors.accent.withValues(
          alpha: 0.08 + (normalizedOpacity * 0.12),
        )
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, measurementY),
            width: glowWidth,
            height: glowHeight,
          ),
          const Radius.circular(4),
        ),
        measurementHandleGlowPaint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, measurementY),
            width: handleWidth,
            height: handleHeight,
          ),
          const Radius.circular(3),
        ),
        measurementHandlePaint,
      );

      // Draw arrow indicators on measurement handle
      final targetArrowPaint = Paint()
        ..color = AppColors.accent.withValues(
          alpha: 0.4 + (normalizedOpacity * 0.4),
        )
        ..strokeWidth = (normalizedThickness * 0.95).clamp(1.0, 2.3)
        ..style = PaintingStyle.stroke;

      // Up/Down arrows to indicate dragging
      canvas.drawLine(
        Offset(center.dx - 1, measurementY - 4),
        Offset(center.dx - 1, measurementY + 4),
        targetArrowPaint,
      );
      canvas.drawLine(
        Offset(center.dx + 1, measurementY - 4),
        Offset(center.dx + 1, measurementY + 4),
        targetArrowPaint,
      );

      // decorative dots
      canvas.drawCircle(
        Offset(center.dx - 1, measurementY - 5),
        1.2,
        targetArrowPaint,
      );
      canvas.drawCircle(
        Offset(center.dx + 1, measurementY - 5),
        1.2,
        targetArrowPaint,
      );
      canvas.drawCircle(
        Offset(center.dx - 1, measurementY + 5),
        1.2,
        targetArrowPaint,
      );
      canvas.drawCircle(
        Offset(center.dx + 1, measurementY + 5),
        1.2,
        targetArrowPaint,
      );

      canvas.drawLine(
        Offset(center.dx - 32, center.dy - 14),
        Offset(center.dx + 10, center.dy - 14),
        measurementGuidePaint,
      );
      canvas.drawLine(
        Offset(center.dx - 32, center.dy + 14),
        Offset(center.dx + 10, center.dy + 14),
        measurementGuidePaint,
      );

      // Label for measurement target
      // _paintText(
      //   canvas,
      //   text: 'TARGET',
      //   offset: Offset(center.dx - 18, measurementY - 12),
      //   style: TextStyle(
      //     color: targetLabelColor,
      //     fontSize: 8,
      //     fontWeight: FontWeight.w600,
      //   ),
      // );

      _paintText(
        canvas,
        text: '$readingLabel ${reticleType.label}',
        offset: Offset(center.dx + 38, center.dy - 8),
        style: TextStyle(
          color: targetLabelColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      );

      final badgeText = '$readingLabel ${reticleType.label}';
      final badgePainter = _textPainter(
        badgeText,
        const TextStyle(
          color: AppColors.accent,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      );
      final padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          center.dx + 26,
          measurementY - 24,
          badgePainter.width + padding.horizontal,
          badgePainter.height + padding.vertical,
        ),
        const Radius.circular(12),
      );
      final badgeFillPaint = Paint()
        ..color = AppColors.background.withValues(alpha: 0.88)
        ..style = PaintingStyle.fill;
      final badgeBorderPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(badgeRect, badgeFillPaint);
      canvas.drawRRect(badgeRect, badgeBorderPaint);
      badgePainter.paint(
        canvas,
        Offset(badgeRect.left + padding.left, badgeRect.top + padding.top),
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
    final normalizedThickness = lineThickness.clamp(0.8, 3.0);
    final normalizedOpacity = overlayOpacity.clamp(0.35, 1.0);
    final guideAlpha = (0.4 + (normalizedOpacity * 0.6)).clamp(0.0, 1.0);
    final guideThickness = 0.8;
    final connectorThickness = (lineThickness * 4.8).clamp(3.0, 12.0);
    final handleWidth = (5 + (normalizedThickness * 1.6)).clamp(7.0, 12.0);
    final handleHeight = (16 + (normalizedThickness * 4)).clamp(20.0, 30.0);
    final glowWidth = handleWidth + 4;
    final glowHeight = handleHeight + 4;
    final targetLabelColor = AppColors.accent.withValues(alpha: guideAlpha);
    final dashedPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: guideAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideThickness;
    final measurementGuidePaint = Paint()
      ..color = AppColors.accent.withValues(alpha: guideAlpha)
      ..style = PaintingStyle.stroke
      ..strokeWidth = guideThickness;
    final connectorPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: normalizedOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = connectorThickness
      ..strokeCap = StrokeCap.square;
    final hasMeasurement = deltaFraction > 0.001 && readingLabel.isNotEmpty;
    final measurementHandlePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final baselineHalfSpan = _verticalHalfSpanForCircle(
      center: center,
      radius: scopeRadius,
      x: baselineX,
    );
    final measurementHalfSpan = _verticalHalfSpanForCircle(
      center: center,
      radius: scopeRadius,
      x: measurementX,
    );

    _drawDashedLine(
      canvas: canvas,
      start: Offset(baselineX, center.dy - baselineHalfSpan),
      end: Offset(baselineX, center.dy + baselineHalfSpan),
      paint: dashedPaint,
      dashLength: 10,
      gapLength: 6,
    );

    _drawBaselineActionIcon(
      canvas,
      center: Offset(baselineX, center.dy - baselineHalfSpan + 28),
      icon: Icons.touch_app_rounded,
      color: AppColors.primary,
      tooltipBackground: AppColors.background,
    );
    _drawBaselineActionIcon(
      canvas,
      center: Offset(baselineX, center.dy + baselineHalfSpan - 28),
      icon: Icons.my_location_rounded,
      color: AppColors.accent,
      tooltipBackground: AppColors.background,
    );

    if (hasMeasurement) {
      final baselineHandleGlowPaint = Paint()
        ..color = AppColors.primary.withValues(
          alpha: 0.06 + (normalizedOpacity * 0.14),
        )
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(baselineX, center.dy),
            width: glowWidth,
            height: glowHeight,
          ),
          const Radius.circular(3),
        ),
        baselineHandleGlowPaint,
      );

      final handlePaint = Paint()
        ..color = AppColors.primary.withValues(alpha: guideAlpha)
        ..style = PaintingStyle.fill;

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(baselineX, center.dy),
            width: handleWidth,
            height: handleHeight,
          ),
          const Radius.circular(2),
        ),
        handlePaint,
      );

      final arrowPaint = Paint()
        ..color = AppColors.primary.withValues(
          alpha: 0.35 + (normalizedOpacity * 0.45),
        )
        ..strokeWidth = (normalizedThickness * 0.9).clamp(1.0, 2.2)
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(baselineX - 1, center.dy - 6),
        Offset(baselineX, center.dy - 10),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(baselineX + 1, center.dy - 6),
        Offset(baselineX, center.dy - 10),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(baselineX - 1, center.dy + 6),
        Offset(baselineX, center.dy + 10),
        arrowPaint,
      );
      canvas.drawLine(
        Offset(baselineX + 1, center.dy + 6),
        Offset(baselineX, center.dy + 10),
        arrowPaint,
      );

      canvas.drawLine(
        Offset(measurementX, center.dy - measurementHalfSpan),
        Offset(measurementX, center.dy + measurementHalfSpan),
        measurementGuidePaint,
      );
      canvas.drawLine(
        Offset(baselineX, center.dy),
        Offset(measurementX, center.dy),
        connectorPaint,
      );

      // Enhanced measurement handle with glow effect
      final measurementHandleGlowPaint = Paint()
        ..color = AppColors.accent.withValues(
          alpha: 0.08 + (normalizedOpacity * 0.12),
        )
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(measurementX, center.dy),
            width: glowWidth,
            height: glowHeight,
          ),
          const Radius.circular(4),
        ),
        measurementHandleGlowPaint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(measurementX, center.dy),
            width: handleWidth,
            height: handleHeight,
          ),
          const Radius.circular(3),
        ),
        measurementHandlePaint,
      );

      // Draw arrow indicators on measurement handle
      final targetArrowPaint = Paint()
        ..color = AppColors.accent.withValues(
          alpha: 0.4 + (normalizedOpacity * 0.4),
        )
        ..strokeWidth = (normalizedThickness * 0.95).clamp(1.0, 2.3)
        ..style = PaintingStyle.stroke;

      // Left/Right arrows to indicate dragging
      canvas.drawLine(
        Offset(measurementX - 4, center.dy - 1),
        Offset(measurementX + 4, center.dy - 1),
        targetArrowPaint,
      );
      canvas.drawLine(
        Offset(measurementX - 4, center.dy + 1),
        Offset(measurementX + 4, center.dy + 1),
        targetArrowPaint,
      );

      // decorative dots
      canvas.drawCircle(
        Offset(measurementX - 5, center.dy - 1),
        1.2,
        targetArrowPaint,
      );
      canvas.drawCircle(
        Offset(measurementX + 5, center.dy - 1),
        1.2,
        targetArrowPaint,
      );
      canvas.drawCircle(
        Offset(measurementX - 5, center.dy + 1),
        1.2,
        targetArrowPaint,
      );
      canvas.drawCircle(
        Offset(measurementX + 5, center.dy + 1),
        1.2,
        targetArrowPaint,
      );

      canvas.drawLine(
        Offset(center.dx - 14, center.dy - 32),
        Offset(center.dx - 14, center.dy + 10),
        measurementGuidePaint,
      );
      canvas.drawLine(
        Offset(center.dx + 14, center.dy - 32),
        Offset(center.dx + 14, center.dy + 10),
        measurementGuidePaint,
      );

      // Label for measurement target
      // _paintText(
      //   canvas,
      //   text: 'TARGET',
      //   offset: Offset(measurementX - 16, center.dy - 18),
      //   style: TextStyle(
      //     color: targetLabelColor,
      //     fontSize: 8,
      //     fontWeight: FontWeight.w600,
      //   ),
      // );

      _paintText(
        canvas,
        text: '$readingLabel ${reticleType.label}',
        offset: Offset(center.dx - 8, center.dy - 4),
        style: TextStyle(
          color: targetLabelColor,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      );

      final badgeText = '$readingLabel ${reticleType.label}';
      final badgePainter = _textPainter(
        badgeText,
        const TextStyle(
          color: AppColors.accent,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      );
      final padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
      final midpointX = (baselineX + measurementX) / 2;
      final badgeLeft =
          (midpointX - ((badgePainter.width + padding.horizontal) / 2)).clamp(
            18.0,
            size.width - badgePainter.width - padding.horizontal - 18,
          );
      final badgeRect = RRect.fromRectAndRadius(
        Rect.fromLTWH(
          badgeLeft,
          center.dy - 18,
          badgePainter.width + padding.horizontal,
          badgePainter.height + padding.vertical,
        ),
        const Radius.circular(12),
      );
      final badgeFillPaint = Paint()
        ..color = AppColors.background.withValues(alpha: 0.88)
        ..style = PaintingStyle.fill;
      final badgeBorderPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.24)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawRRect(badgeRect, badgeFillPaint);
      canvas.drawRRect(badgeRect, badgeBorderPaint);
      badgePainter.paint(
        canvas,
        Offset(badgeRect.left + padding.left, badgeRect.top + padding.top),
      );
    }
  }

  void _drawStandardTicks(Canvas canvas, Offset center, Paint tickPaint) {
    for (var step = -10; step <= 10; step++) {
      if (step == 0) {
        continue;
      }

      final tickOffset = step * 10.0;
      final isMajor = step.isEven;
      final halfLength = isMajor ? 8.0 : 4.0;
      final paint = Paint()
        ..color = tickPaint.color
        ..strokeWidth = isMajor ? 1.2 : 0.85
        ..style = PaintingStyle.stroke;

      canvas.drawLine(
        Offset(center.dx - halfLength, center.dy + tickOffset),
        Offset(center.dx + halfLength, center.dy + tickOffset),
        paint,
      );
      canvas.drawLine(
        Offset(center.dx + tickOffset, center.dy - halfLength),
        Offset(center.dx + tickOffset, center.dy + halfLength),
        paint,
      );
    }
  }

  void _drawMilDots(
    Canvas canvas,
    Offset center,
    double radius,
    Paint reticlePaint,
  ) {
    final dotPaint = Paint()
      ..color = reticlePaint.color
      ..style = PaintingStyle.fill;
    final step = radius / 5;

    canvas.drawCircle(center, 3.2, dotPaint);

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

  void _drawSimpleCrosshair(
    Canvas canvas,
    Offset center,
    double radius,
    Paint tickPaint,
    Paint reticlePaint,
  ) {
    final majorStep = radius / 5;
    final minorStep = majorStep / 2;
    final majorPaint = Paint()
      ..color = tickPaint.color.withValues(alpha: 0.72)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05;
    final minorPaint = Paint()
      ..color = tickPaint.color.withValues(alpha: 0.52)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    final centerDotPaint = Paint()
      ..color = reticlePaint.color
      ..style = PaintingStyle.fill;

    for (var i = 1; i <= 5; i++) {
      final offset = majorStep * i;
      final majorHalfLength = i == 5 ? 7.0 : 8.0;
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
        final minorOffset = offset + minorStep;
        const minorHalfLength = 4.0;
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

    canvas.drawCircle(center, 3.4, centerDotPaint);
  }

  void _drawChristmasTree(
    Canvas canvas,
    Size size,
    Offset center,
    Paint tickPaint,
  ) {
    final radius = size.shortestSide * _reticleInnerRadiusFactor;
    final scopeRadius = radius * _reticleOuterRadiusMultiplier;
    const milStep = 20.0;
    final branchPaint = Paint()
      ..color = tickPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.15;
    final branchMinorPaint = Paint()
      ..color = tickPaint.color.withValues(alpha: 0.7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.85;
    final windDotPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.65)
      ..style = PaintingStyle.fill;
    final treeLabelStyle = const TextStyle(
      color: AppColors.textMuted,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );

    for (final rowValue in [2, 4, 6, 8]) {
      final y = center.dy + (rowValue * milStep);
      if (y > size.height - 18) {
        continue;
      }

      final maxHalfSpan = _horizontalHalfSpanForCircle(
        center: center,
        radius: scopeRadius,
        y: y,
      );
      final halfWidth = math.min(rowValue * milStep, maxHalfSpan - 12);
      if (halfWidth <= 0) {
        continue;
      }

      canvas.drawLine(
        Offset(center.dx - halfWidth, y),
        Offset(center.dx + halfWidth, y),
        branchPaint,
      );

      final fullSteps = rowValue;
      for (var i = 1; i < fullSteps; i++) {
        final x = center.dx - halfWidth + (i * milStep);
        canvas.drawLine(
          Offset(x, y - 5),
          Offset(x, y + 5),
          i.isEven ? branchPaint : branchMinorPaint,
        );
      }

      canvas.drawLine(
        Offset(center.dx - halfWidth, y - 8),
        Offset(center.dx - halfWidth, y + 8),
        branchPaint,
      );
      canvas.drawLine(
        Offset(center.dx + halfWidth, y - 8),
        Offset(center.dx + halfWidth, y + 8),
        branchPaint,
      );

      _paintText(
        canvas,
        text: '$rowValue',
        offset: Offset(center.dx - halfWidth - 10, y - 7),
        style: treeLabelStyle,
      );
      _paintText(
        canvas,
        text: '$rowValue',
        offset: Offset(center.dx + halfWidth + 5, y - 7),
        style: treeLabelStyle,
      );
    }

    for (final rowValue in [1, 3, 5, 7]) {
      final y = center.dy + (rowValue * milStep);
      final maxHalfSpan = _horizontalHalfSpanForCircle(
        center: center,
        radius: scopeRadius,
        y: y,
      );
      if (maxHalfSpan <= 10) {
        continue;
      }

      final leftDot = Offset(center.dx - maxHalfSpan + 8, y);
      final rightDot = Offset(center.dx + maxHalfSpan - 8, y);
      canvas.drawCircle(leftDot, 2.4, windDotPaint);
      canvas.drawCircle(rightDot, 2.4, windDotPaint);
    }
  }

  void _drawAxisLabels(Canvas canvas, Size size, Offset center, double radius) {
    final labelStyle = const TextStyle(
      color: AppColors.textMuted,
      fontSize: 11,
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

  void _drawSimpleCrosshairLabels(Canvas canvas, Offset center, double radius) {
    final labelStyle = const TextStyle(
      color: AppColors.textMuted,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
    final step = radius / 5;

    for (var i = 1; i <= 5; i++) {
      final offset = step * i;
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx + 10, center.dy - offset - 7),
        style: labelStyle,
      );
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx + 10, center.dy + offset - 7),
        style: labelStyle,
      );
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx + offset - 4, center.dy - 21),
        style: labelStyle,
      );
      _paintText(
        canvas,
        text: '$i',
        offset: Offset(center.dx - offset - 4, center.dy - 21),
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
    final radius = size.shortestSide * _reticleInnerRadiusFactor;
    final scopeRadius = radius * _reticleOuterRadiusMultiplier;
    final innerGap = radius * 0.5;
    final outerInset = 8.0;
    final postLengthEnd = scopeRadius - outerInset;
    final thinPaint = Paint()
      ..color = reticlePaint.color.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.square;
    final thickPaint = Paint()
      ..color = reticlePaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.square;
    final centerDotPaint = Paint()
      ..color = reticlePaint.color
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

    _paintText(
      canvas,
      text: 'gap ≈ 2.5 ${reticleType.label}',
      offset: Offset(center.dx + innerGap + 10, center.dy - 16),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  void _drawFooter(Canvas canvas, Size size) {
    _paintText(
      canvas,
      text: referenceDimension == TargetDimensionType.height ? '' : '',
      // ? '${reticleProfile.label} • tap to set dashed base, drag to place amber height line'
      // : '${reticleProfile.label} • tap to set dashed base, drag to place amber width line',
      offset: Offset(18, size.height - 24),
      style: const TextStyle(
        color: AppColors.textMuted,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }

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

  void _drawTextIcon(
    Canvas canvas, {
    required IconData icon,
    required Offset center,
    required double size,
    required Color color,
  }) {
    final iconPainter = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size,
          fontFamily: icon.fontFamily,
          color: color,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final offset = Offset(
      center.dx - iconPainter.width / 2,
      center.dy - iconPainter.height / 2,
    );
    iconPainter.paint(canvas, offset);
  }

  void _drawBaselineActionIcon(
    Canvas canvas, {
    required Offset center,
    required IconData icon,
    required Color color,
    required Color tooltipBackground,
  }) {
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(center: center, width: 22, height: 22),
      const Radius.circular(6),
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = tooltipBackground.withValues(alpha: 0.82)
        ..style = PaintingStyle.fill,
    );
    canvas.drawRRect(
      rect,
      Paint()
        ..color = color.withValues(alpha: 0.58)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
    _drawTextIcon(canvas, icon: icon, center: center, size: 12, color: color);
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

  double _horizontalHalfSpanForCircle({
    required Offset center,
    required double radius,
    required double y,
  }) {
    final dy = (y - center.dy).abs();
    if (dy >= radius) {
      return 0;
    }
    return math.sqrt((radius * radius) - (dy * dy));
  }

  double _verticalHalfSpanForCircle({
    required Offset center,
    required double radius,
    required double x,
  }) {
    final dx = (x - center.dx).abs();
    if (dx >= radius) {
      return 0;
    }
    return math.sqrt((radius * radius) - (dx * dx));
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
