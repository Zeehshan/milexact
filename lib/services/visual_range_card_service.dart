import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/data/models/target_marker.dart';
import 'package:milexact/data/models/visual_point.dart';

class VisualRangeCardService extends GetxService {
  static const double maxDistance = 1000;

  Offset plotCenter(Size size) => Offset(size.width / 2, size.height - 20);

  double plotRadius(Size size) =>
      math.min(size.width / 2 - 20, size.height - 32);

  bool isInsidePlot({required Offset localPosition, required Size size}) {
    final center = plotCenter(size);
    final radius = plotRadius(size);
    if (localPosition.dy > center.dy) {
      return false;
    }
    return (localPosition - center).distance <= radius;
  }

  VisualPoint normalizedPointFromOffset({
    required Offset localPosition,
    required Size size,
  }) {
    return VisualPoint(
      x: (localPosition.dx / size.width).clamp(0.0, 1.0),
      y: (localPosition.dy / size.height).clamp(0.0, 1.0),
    );
  }

  Offset offsetFromNormalizedPoint({
    required VisualPoint point,
    required Size size,
  }) {
    return Offset(point.x * size.width, point.y * size.height);
  }

  TargetMarker markerFromOffset({
    required String id,
    required String label,
    required Offset localPosition,
    required Size size,
    String? linkedRangeCardEntryId,
    String iconType = 'target',
    String notes = '',
  }) {
    final center = plotCenter(size);
    final radius = plotRadius(size);
    final vector = localPosition - center;
    final clampedDistance = vector.distance.clamp(0.0, radius);
    final normalizedDistance = (clampedDistance / radius) * maxDistance;
    final upwardY = center.dy - localPosition.dy;
    final angleFromRight = math.atan2(upwardY, vector.dx);
    final degrees = 180 - (angleFromRight * 180 / math.pi);
    final clampedAngle = degrees.clamp(0.0, 180.0);

    return TargetMarker(
      id: id,
      label: label,
      angle: clampedAngle,
      distance: normalizedDistance,
      linkedRangeCardEntryId: linkedRangeCardEntryId,
      iconType: iconType,
      notes: notes,
    );
  }

  Offset offsetFromMarker({required TargetMarker marker, required Size size}) {
    final center = plotCenter(size);
    final radius = plotRadius(size);
    final distanceRatio = (marker.distance / maxDistance).clamp(0.0, 1.0);
    final distance = distanceRatio * radius;
    final radians = math.pi - (marker.angle * math.pi / 180);
    return Offset(
      center.dx + math.cos(radians) * distance,
      center.dy - math.sin(radians) * distance,
    );
  }
}
