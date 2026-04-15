import 'package:flutter/material.dart';
import 'package:milexact/app/theme/app_colors.dart';
import 'package:milexact/data/models/enums.dart';

class ReticleMeasurementPanel extends StatelessWidget {
  const ReticleMeasurementPanel({
    super.key,
    required this.referenceDimension,
    required this.handleFraction,
    required this.reticleType,
    required this.reticleProfile,
    required this.readingLabel,
    required this.onInteraction,
  });

  final TargetDimensionType referenceDimension;
  final double handleFraction;
  final ReticleType reticleType;
  final ReticleProfile reticleProfile;
  final String readingLabel;
  final void Function(Offset localPosition, Size size) onInteraction;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, 280);

        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: (details) => onInteraction(details.localPosition, size),
          onPanDown: (details) => onInteraction(details.localPosition, size),
          onPanUpdate: (details) => onInteraction(details.localPosition, size),
          child: SizedBox(
            height: size.height,
            width: double.infinity,
            child: Stack(
              children: [
                CustomPaint(
                  size: size,
                  painter: _ReticlePainter(
                    referenceDimension: referenceDimension,
                    handleFraction: handleFraction,
                    reticleType: reticleType,
                    reticleProfile: reticleProfile,
                    readingLabel: readingLabel,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReticlePainter extends CustomPainter {
  const _ReticlePainter({
    required this.referenceDimension,
    required this.handleFraction,
    required this.reticleType,
    required this.reticleProfile,
    required this.readingLabel,
  });

  final TargetDimensionType referenceDimension;
  final double handleFraction;
  final ReticleType reticleType;
  final ReticleProfile reticleProfile;
  final String readingLabel;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    const edgePadding = 18.0;
    final radius = size.shortestSide * 0.38;
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
      ..color = AppColors.accent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    final tickPaint = Paint()
      ..color = AppColors.primary.withValues(alpha: 0.52)
      ..strokeWidth = 1;
    final accentFillPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final rect = RRect.fromRectAndRadius(
      Offset.zero & size,
      const Radius.circular(18),
    );
    canvas.drawRRect(rect, borderPaint);

    canvas.drawCircle(center, radius * 1.14, ringPaint);
    canvas.drawCircle(center, radius, ringPaint);

    canvas.drawLine(
      Offset(center.dx, edgePadding),
      Offset(center.dx, size.height - edgePadding),
      reticlePaint,
    );
    canvas.drawLine(
      Offset(edgePadding, center.dy),
      Offset(size.width - edgePadding, center.dy),
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
      final offset = size.height * handleFraction;
      final topY = center.dy - offset;
      final bottomY = center.dy + offset;
      canvas.drawLine(
        Offset(center.dx - 58, topY),
        Offset(center.dx + 58, topY),
        accentPaint,
      );
      canvas.drawLine(
        Offset(center.dx - 58, bottomY),
        Offset(center.dx + 58, bottomY),
        accentPaint,
      );
      canvas.drawLine(
        Offset(center.dx + 64, topY),
        Offset(center.dx + 64, bottomY),
        accentPaint,
      );
      canvas.drawCircle(Offset(center.dx + 64, topY), 4.5, accentFillPaint);
      canvas.drawCircle(Offset(center.dx + 64, bottomY), 4.5, accentFillPaint);
    } else {
      final offset = size.width * handleFraction;
      final leftX = center.dx - offset;
      final rightX = center.dx + offset;
      canvas.drawLine(
        Offset(leftX, center.dy - 58),
        Offset(leftX, center.dy + 58),
        accentPaint,
      );
      canvas.drawLine(
        Offset(rightX, center.dy - 58),
        Offset(rightX, center.dy + 58),
        accentPaint,
      );
      canvas.drawLine(
        Offset(leftX, center.dy + 64),
        Offset(rightX, center.dy + 64),
        accentPaint,
      );
      canvas.drawCircle(Offset(leftX, center.dy + 64), 4.5, accentFillPaint);
      canvas.drawCircle(Offset(rightX, center.dy + 64), 4.5, accentFillPaint);
    }

    _drawReadout(canvas, size, center);
    _drawLegend(canvas, size);
    _drawFooter(canvas, size);
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
      ..strokeWidth = 1;

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
    final thickPaint = Paint()
      ..color = reticlePaint.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    canvas.drawLine(
      Offset(16, center.dy),
      Offset(center.dx - 44, center.dy),
      thickPaint,
    );
    canvas.drawLine(
      Offset(center.dx + 44, center.dy),
      Offset(size.width - 16, center.dy),
      thickPaint,
    );
    canvas.drawLine(
      Offset(center.dx, 16),
      Offset(center.dx, center.dy - 44),
      thickPaint,
    );
    canvas.drawLine(
      Offset(center.dx, center.dy + 44),
      Offset(center.dx, size.height - 16),
      thickPaint,
    );
  }

  void _drawReadout(Canvas canvas, Size size, Offset center) {
    final displayText =
        '${readingLabel.isEmpty ? '--' : readingLabel} ${reticleType.label}';
    final textStyle = const TextStyle(
      color: AppColors.accent,
      fontSize: 18,
      fontWeight: FontWeight.w700,
    );
    final textPainter = _textPainter(displayText, textStyle);
    final padding = const EdgeInsets.symmetric(horizontal: 12, vertical: 8);
    final badgeWidth = textPainter.width + padding.horizontal;
    final badgeHeight = textPainter.height + padding.vertical;
    final badgeCenter = referenceDimension == TargetDimensionType.height
        ? Offset(center.dx - 78, center.dy)
        : Offset(center.dx, center.dy - 44);
    final badgeRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: badgeCenter,
        width: badgeWidth,
        height: badgeHeight,
      ),
      const Radius.circular(14),
    );
    final badgePaint = Paint()
      ..color = AppColors.background.withValues(alpha: 0.82)
      ..style = PaintingStyle.fill;
    final badgeBorderPaint = Paint()
      ..color = AppColors.accent.withValues(alpha: 0.34)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    canvas.drawRRect(badgeRect, badgePaint);
    canvas.drawRRect(badgeRect, badgeBorderPaint);
    textPainter.paint(
      canvas,
      Offset(badgeRect.left + padding.left, badgeRect.top + padding.top),
    );
  }

  void _drawLegend(Canvas canvas, Size size) {
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
    final topLine = referenceDimension == TargetDimensionType.height
        ? '↕ Active height scale • ${reticleProfile.heightGuide} ${reticleType.label}'
        : '↕ Height scale • ${reticleProfile.heightGuide} ${reticleType.label}';
    final bottomLine = referenceDimension == TargetDimensionType.width
        ? '↔ Active width scale • ${reticleProfile.widthGuide} ${reticleType.label}'
        : '↔ Width scale • ${reticleProfile.widthGuide} ${reticleType.label}';

    _paintText(
      canvas,
      text: topLine,
      offset: Offset(size.width - 210, 18),
      style: referenceDimension == TargetDimensionType.height
          ? activeStyle
          : inactiveStyle,
    );
    _paintText(
      canvas,
      text: bottomLine,
      offset: Offset(size.width - 210, 34),
      style: referenceDimension == TargetDimensionType.width
          ? activeStyle
          : inactiveStyle,
    );
  }

  void _drawFooter(Canvas canvas, Size size) {
    _paintText(
      canvas,
      text:
          '${reticleProfile.label} • drag to set ${referenceDimension.label.toLowerCase()}',
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

  @override
  bool shouldRepaint(covariant _ReticlePainter oldDelegate) {
    return oldDelegate.referenceDimension != referenceDimension ||
        oldDelegate.handleFraction != handleFraction ||
        oldDelegate.reticleProfile != reticleProfile ||
        oldDelegate.reticleType != reticleType ||
        oldDelegate.readingLabel != readingLabel;
  }
}
