import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/data/models/enums.dart';

const double _reticleInnerRadiusFactor = 0.40;
const double _reticleOuterRadiusMultiplier = 1.15;
const double _guideGrabThreshold = 18.0;

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
  bool _isBaselineLocked = false;
  double _lockedBaselineFraction = 0.0;

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
      _isBaselineLocked = false;
      widget.onInteractionActiveChanged(false);
    }

    if (oldWidget.baselineFraction != widget.baselineFraction ||
        oldWidget.measurementFraction != widget.measurementFraction) {
      // Don't update baseline animation if it's locked
      if (!_isBaselineLocked) {
        _baselineTween = Tween<double>(
          begin: _displayBaselineFraction,
          end: widget.baselineFraction,
        );
      }
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
      // If baseline is locked, keep it at the locked value
      if (_isBaselineLocked) {
        _displayBaselineFraction = _lockedBaselineFraction;
      } else {
        _displayBaselineFraction =
            _baselineTween?.evaluate(_motionAnimation) ??
            widget.baselineFraction;
      }
      _displayMeasurementFraction =
          _measurementTween?.evaluate(_motionAnimation) ??
          widget.measurementFraction;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 280);

        return SizedBox(
          height: size.height,
          width: double.infinity,
          child: Stack(
            children: [
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
                    isBaselineLocked: _isBaselineLocked,
                  ),
                ),
              ),
              // Lock/Unlock baseline button
              Positioned(
                right: 12,
                bottom: 12,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    setState(() {
                      if (!_isBaselineLocked) {
                        // When locking, save the current baseline position
                        _lockedBaselineFraction = _displayBaselineFraction;
                      }
                      _isBaselineLocked = !_isBaselineLocked;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _isBaselineLocked
                          ? AppColors.accent.withValues(alpha: 0.2)
                          : AppColors.primary.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _isBaselineLocked
                            ? AppColors.accent.withValues(alpha: 0.6)
                            : AppColors.primary.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Icon(
                      _isBaselineLocked
                          ? Icons.lock_rounded
                          : Icons.lock_open_rounded,
                      size: 20,
                      color: _isBaselineLocked
                          ? AppColors.accent
                          : AppColors.primary.withValues(alpha: 0.7),
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

  void _handlePointerDown(PointerDownEvent event, Size size) {
    _activePointer = event.pointer;
    widget.onInteractionActiveChanged(true);
    final localPosition = _clampInteractionToScope(event.localPosition, size);
    final dragTarget = _resolveDragTarget(localPosition, size);

    // If baseline is locked, ignore baseline drag target and use measurement instead
    if (_isBaselineLocked && dragTarget == _GuideDragTarget.baseline) {
      _activeDragTarget = _GuideDragTarget.measurement;
      widget.onInteractionUpdate(localPosition, size);
      return;
    }

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

    final localPosition = _clampInteractionToScope(event.localPosition, size);
    switch (_activeDragTarget) {
      case _GuideDragTarget.baseline:
        // Don't update baseline if it's locked
        if (!_isBaselineLocked) {
          widget.onBaselineUpdate(localPosition, size);
        }
        break;
      case _GuideDragTarget.measurement:
        if (!_isBaselineLocked) {
          widget.onBaselineUpdate(localPosition, size);
          break;
        } else {
          widget.onInteractionUpdate(localPosition, size);
          break;
        }
      default:
        if (!_isBaselineLocked) {
          widget.onBaselineUpdate(localPosition, size);
          break;
        } else {
          widget.onInteractionUpdate(localPosition, size);
          break;
        }
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
    final baselinePosition = _axisPositionPx(widget.baselineFraction, size);
    final measurementPosition = _axisPositionPx(
      widget.measurementFraction,
      size,
    );
    final touchPosition =
        widget.referenceDimension == TargetDimensionType.height
        ? localPosition.dy
        : localPosition.dx;
    final hasMeasurement =
        (widget.measurementFraction - widget.baselineFraction).abs() > 0.001 &&
        widget.readingLabel.trim().isNotEmpty;

    if (hasMeasurement &&
        (touchPosition - measurementPosition).abs() <= _guideGrabThreshold) {
      return _GuideDragTarget.measurement;
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
    this.isBaselineLocked = false,
  });

  final TargetDimensionType referenceDimension;
  final double baselineFraction;
  final double measurementFraction;
  final ReticleType reticleType;
  final ReticleProfile reticleProfile;
  final String readingLabel;
  final double lineThickness;
  final double overlayOpacity;
  final bool isBaselineLocked;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide * _reticleInnerRadiusFactor;
    final scopeRadius = radius * _reticleOuterRadiusMultiplier;
    final normalizedThickness = lineThickness.clamp(0.8, 3.0);
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
      ..strokeWidth = (normalizedThickness * 1.7).clamp(1.8, 4.0);
    final tickPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.52)
      ..strokeWidth = 1;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    canvas.drawRRect(rect, borderPaint);

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
        _drawStandardTicks(canvas, center, tickPaint);
        _drawMilDots(canvas, center, reticlePaint);
      case ReticleProfile.christmasTree:
        _drawStandardTicks(canvas, center, tickPaint);
        _drawChristmasTree(canvas, size, center, tickPaint);
      case ReticleProfile.duplex:
        _drawDuplex(canvas, size, center, reticlePaint);
      case ReticleProfile.simpleCrosshair:
        _drawStandardTicks(canvas, center, tickPaint);
    }

    _drawAxisLabels(canvas, size, center, radius);

    if (referenceDimension == TargetDimensionType.height) {
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
    } else {
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

    _drawLegend(canvas, size, center, scopeRadius);
    _drawFooter(canvas, size);
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
    final normalizedOpacity = overlayOpacity.clamp(0.35, 1.0);
    final connectorThickness = (lineThickness * 4.8).clamp(3.0, 12.0);
    final dashedPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final measurementGuidePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final connectorPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: normalizedOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = connectorThickness
      ..strokeCap = StrokeCap.square;
    final zeroFillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final zeroBorderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final hasMeasurement = deltaFraction > 0.001 && readingLabel.isNotEmpty;
    final zeroHandlePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;
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

    final zeroRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(center.dx - baselineHalfSpan + 9, baselineY - 2),
        width: 8,
        height: 16,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(zeroRect, zeroFillPaint);
    canvas.drawRRect(zeroRect, zeroBorderPaint);

    // Enhanced baseline handle with glow effect and arrows
    final baselineHandleGlowPaint = Paint()
      ..color = isBaselineLocked
          ? AppColors.accent.withValues(alpha: 0.2)
          : AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Add lock border when locked
    if (isBaselineLocked) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, baselineY),
            width: 30,
            height: 12,
          ),
          const Radius.circular(4),
        ),
        Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.accent.withValues(alpha: 0.6),
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, baselineY),
          width: 28,
          height: 10,
        ),
        const Radius.circular(3),
      ),
      baselineHandleGlowPaint,
    );

    final handlePaint = Paint()
      ..color = isBaselineLocked
          ? AppColors.accent.withValues(alpha: 0.8)
          : AppColors.primary.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, baselineY),
          width: 24,
          height: 8,
        ),
        const Radius.circular(2),
      ),
      handlePaint,
    );

    // Draw lock icon if baseline is locked
    if (isBaselineLocked) {
      _drawTextIcon(
        canvas,
        icon: Icons.lock_rounded,
        center: Offset(center.dx - 2, baselineY),
        size: 8,
        color: AppColors.accent,
      );
    }

    // Draw arrow indicators on baseline handle
    final arrowPaint = Paint()
      ..color = isBaselineLocked
          ? Colors.transparent
          : AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Left arrow (hidden when locked)
    if (!isBaselineLocked) {
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
    }

    // Right arrow
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

    _paintText(
      canvas,
      text: '0',
      offset: Offset(zeroRect.left + 2.1, zeroRect.top + 2.2),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    );

    // Label for baseline
    _paintText(
      canvas,
      text: 'START',
      offset: Offset(center.dx - 15, baselineY - 12),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 8,
        fontWeight: FontWeight.w600,
      ),
    );

    if (hasMeasurement && isBaselineLocked) {
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
        ..color = AppColors.accent.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, measurementY),
            width: 28,
            height: 10,
          ),
          const Radius.circular(4),
        ),
        measurementHandleGlowPaint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(center.dx, measurementY),
            width: 24,
            height: 8,
          ),
          const Radius.circular(3),
        ),
        measurementHandlePaint,
      );

      // Draw arrow indicators on measurement handle
      final targetArrowPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.7)
        ..strokeWidth = 1.3
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
      _paintText(
        canvas,
        text: 'TARGET',
        offset: Offset(center.dx - 18, measurementY - 12),
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      );

      _paintText(
        canvas,
        text: '$readingLabel ${reticleType.label}',
        offset: Offset(center.dx + 38, center.dy - 8),
        style: const TextStyle(
          color: AppColors.accent,
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
    final normalizedOpacity = overlayOpacity.clamp(0.35, 1.0);
    final connectorThickness = (lineThickness * 4.8).clamp(3.0, 12.0);
    final dashedPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final measurementGuidePaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.2;
    final connectorPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: normalizedOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = connectorThickness
      ..strokeCap = StrokeCap.square;
    final zeroFillPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.14)
      ..style = PaintingStyle.fill;
    final zeroBorderPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.95)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final hasMeasurement = deltaFraction > 0.001 && readingLabel.isNotEmpty;
    final zeroHandlePaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;
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

    final zeroRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(baselineX, center.dy - baselineHalfSpan + 8),
        width: 16,
        height: 8,
      ),
      const Radius.circular(2),
    );
    canvas.drawRRect(zeroRect, zeroFillPaint);
    canvas.drawRRect(zeroRect, zeroBorderPaint);

    // Enhanced baseline handle with glow effect and arrows
    final baselineHandleGlowPaint = Paint()
      ..color = isBaselineLocked
          ? AppColors.accent.withValues(alpha: 0.2)
          : AppColors.primary.withValues(alpha: 0.12)
      ..style = PaintingStyle.fill;

    // Add lock border when locked
    if (isBaselineLocked) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(baselineX, center.dy),
            width: 12,
            height: 30,
          ),
          const Radius.circular(4),
        ),
        Paint()
          ..color = Colors.transparent
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..color = AppColors.accent.withValues(alpha: 0.6),
      );
    }

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(baselineX, center.dy),
          width: 10,
          height: 28,
        ),
        const Radius.circular(3),
      ),
      baselineHandleGlowPaint,
    );

    final handlePaint = Paint()
      ..color = isBaselineLocked
          ? AppColors.accent.withValues(alpha: 0.8)
          : AppColors.primary.withValues(alpha: 0.96)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(baselineX, center.dy),
          width: 8,
          height: 24,
        ),
        const Radius.circular(2),
      ),
      handlePaint,
    );

    // Draw lock icon if baseline is locked
    if (isBaselineLocked) {
      _drawTextIcon(
        canvas,
        icon: Icons.lock_rounded,
        center: Offset(baselineX, center.dy - 2),
        size: 8,
        color: AppColors.accent,
      );
    }

    // Draw arrow indicators on baseline handle
    final arrowPaint = Paint()
      ..color = isBaselineLocked
          ? Colors.transparent
          : AppColors.primary.withValues(alpha: 0.6)
      ..strokeWidth = 1.2
      ..style = PaintingStyle.stroke;

    // Up arrow (hidden when locked)
    if (!isBaselineLocked) {
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
    }

    // Down arrow (hidden when locked)
    if (!isBaselineLocked) {
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
    }

    _paintText(
      canvas,
      text: '0',
      offset: Offset(zeroRect.left + 5.2, zeroRect.top - 0.3),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 9,
        fontWeight: FontWeight.w800,
      ),
    );

    // Label for baseline
    _paintText(
      canvas,
      text: 'START',
      offset: Offset(baselineX - 14, center.dy - 18),
      style: const TextStyle(
        color: AppColors.primary,
        fontSize: 8,
        fontWeight: FontWeight.w600,
      ),
    );

    if (hasMeasurement && isBaselineLocked) {
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
        ..color = AppColors.accent.withValues(alpha: 0.16)
        ..style = PaintingStyle.fill;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(measurementX, center.dy),
            width: 10,
            height: 28,
          ),
          const Radius.circular(4),
        ),
        measurementHandleGlowPaint,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(measurementX, center.dy),
            width: 8,
            height: 24,
          ),
          const Radius.circular(3),
        ),
        measurementHandlePaint,
      );

      // Draw arrow indicators on measurement handle
      final targetArrowPaint = Paint()
        ..color = AppColors.accent.withValues(alpha: 0.7)
        ..strokeWidth = 1.3
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
      _paintText(
        canvas,
        text: 'TARGET',
        offset: Offset(measurementX - 16, center.dy - 18),
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 8,
          fontWeight: FontWeight.w600,
        ),
      );

      _paintText(
        canvas,
        text: '$readingLabel ${reticleType.label}',
        offset: Offset(center.dx - 8, center.dy - 4),
        style: const TextStyle(
          color: AppColors.accent,
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
    for (var i = -4; i <= 4; i++) {
      if (i == 0) {
        continue;
      }

      final tickOffset = i * 20.0;
      canvas.drawLine(
        Offset(center.dx - 6, center.dy + tickOffset),
        Offset(center.dx + 6, center.dy + tickOffset),
        tickPaint,
      );
      canvas.drawLine(
        Offset(center.dx + tickOffset, center.dy - 6),
        Offset(center.dx + tickOffset, center.dy + 6),
        tickPaint,
      );
    }
  }

  void _drawMilDots(Canvas canvas, Offset center, Paint reticlePaint) {
    final dotPaint = Paint()
      ..color = reticlePaint.color
      ..style = PaintingStyle.fill;

    for (var i = 1; i <= 5; i++) {
      final offset = i * 18.5;
      canvas.drawCircle(Offset(center.dx + offset, center.dy), 2.6, dotPaint);
      canvas.drawCircle(Offset(center.dx - offset, center.dy), 2.6, dotPaint);
      canvas.drawCircle(Offset(center.dx, center.dy + offset), 2.6, dotPaint);
      canvas.drawCircle(Offset(center.dx, center.dy - offset), 2.6, dotPaint);
    }
  }

  void _drawChristmasTree(
    Canvas canvas,
    Size size,
    Offset center,
    Paint tickPaint,
  ) {
    final branchPaint = Paint()
      ..color = tickPaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = tickPaint.strokeWidth;

    for (var row = 1; row <= 5; row++) {
      final y = center.dy + (row * 20.0);
      if (y > size.height - 16) {
        continue;
      }

      final halfWidth = row * 18.0;
      canvas.drawLine(
        Offset(center.dx - halfWidth, y),
        Offset(center.dx + halfWidth, y),
        branchPaint,
      );
      canvas.drawCircle(Offset(center.dx - halfWidth, y), 1.8, branchPaint);
      canvas.drawCircle(Offset(center.dx + halfWidth, y), 1.8, branchPaint);
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

  void _drawDuplex(
    Canvas canvas,
    Size size,
    Offset center,
    Paint reticlePaint,
  ) {
    final scopeRadius =
        size.shortestSide *
        _reticleInnerRadiusFactor *
        _reticleOuterRadiusMultiplier;
    final thickPaint = Paint()
      ..color = reticlePaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(center.dx - scopeRadius, center.dy),
      Offset(center.dx - 44, center.dy),
      thickPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 44, center.dy),
      Offset(center.dx + scopeRadius, center.dy),
      thickPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy - scopeRadius),
      Offset(center.dx, center.dy - 44),
      thickPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 44),
      Offset(center.dx, center.dy + scopeRadius),
      thickPaint,
    );
  }

  void _drawLegend(
    Canvas canvas,
    Size size,
    Offset center,
    double scopeRadius,
  ) {
    final activeStyle = const TextStyle(
      color: AppColors.accent,
      fontSize: 11,
      fontWeight: FontWeight.w700,
    );
    final inactiveStyle = const TextStyle(
      color: AppColors.textMuted,
      fontSize: 11,
      fontWeight: FontWeight.w600,
    );
    final topLine = '↕ • ${reticleProfile.heightGuide} ${reticleType.label}';
    final bottomLine = '↔ • ${reticleProfile.widthGuide} ${reticleType.label}';
    final topPainter = _textPainter(
      topLine,
      referenceDimension == TargetDimensionType.height
          ? activeStyle
          : inactiveStyle,
    );
    final bottomPainter = _textPainter(
      bottomLine,
      referenceDimension == TargetDimensionType.width
          ? activeStyle
          : inactiveStyle,
    );
    const rightPadding = 8.0;
    const topInset = 10.0;
    const lineGap = 4.0;
    final circleTop = center.dy - scopeRadius;
    final circleRight = center.dx + scopeRadius;
    final topY = (circleTop + topInset).clamp(
      18.0,
      size.height - topPainter.height - bottomPainter.height - lineGap - 18,
    );
    final bottomY = topY + topPainter.height + lineGap;
    final blockWidth = topPainter.width > bottomPainter.width
        ? topPainter.width
        : bottomPainter.width;
    final blockLeft = (circleRight - rightPadding - blockWidth).clamp(
      center.dx - scopeRadius + 18,
      size.width - blockWidth - 18,
    );

    topPainter.paint(canvas, Offset(blockLeft, topY));
    bottomPainter.paint(canvas, Offset(blockLeft, bottomY));
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
        oldDelegate.overlayOpacity != overlayOpacity;
  }
}
