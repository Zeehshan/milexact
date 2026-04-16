import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:milexact/data/models/target_marker.dart';
import 'package:milexact/data/models/visual_point.dart';

class VisualRangeCardService extends GetxService {
  static const double maxDistance = 3000;
  static const double fanDegrees = 160;
  static const double halfFanDegrees = fanDegrees / 2;
  static const double minimumDisplayDistance = 100;

  Offset plotCenter(Size size) => Offset(size.width / 2, size.height - 18);

  double plotRadius(Size size) =>
      math.min(size.width / 2 - 18, size.height - 26);

  bool isInsidePlot({required Offset localPosition, required Size size}) {
    final center = plotCenter(size);
    final radius = plotRadius(size);
    final vector = localPosition - center;
    if (vector.dy > 0) {
      return false;
    }
    final angleFromNorth = math.atan2(vector.dx, -vector.dy) * 180 / math.pi;
    return vector.distance <= radius &&
        angleFromNorth.abs() <= halfFanDegrees + 0.5;
  }

  double effectiveMaxDistance(Iterable<TargetMarker> markers) {
    return markers.fold<double>(
      minimumDisplayDistance,
      (current, marker) => math.max(current, marker.distance),
    );
  }

  double ringStepForDistance(double maxDistanceMeters) {
    if (maxDistanceMeters <= 300) {
      return 50;
    }
    if (maxDistanceMeters <= 1000) {
      return 100;
    }
    if (maxDistanceMeters <= 3000) {
      return 500;
    }
    return 1000;
  }

  List<double> ringValues(double maxDistanceMeters) {
    final values = <double>[];
    final step = ringStepForDistance(maxDistanceMeters);
    for (var value = step; value <= maxDistanceMeters + step; value += step) {
      if (value > maxDistanceMeters * 1.15) {
        break;
      }
      values.add(value);
    }
    return values;
  }

  double visualAngleFromStored(double storedAngle) {
    return ((storedAngle / 180) * fanDegrees) - halfFanDegrees;
  }

  double storedAngleFromVisual(double visualAngle) {
    return ((visualAngle + halfFanDegrees) / fanDegrees) * 180;
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
    required double maxDistanceMeters,
    String? linkedRangeCardEntryId,
    String iconType = 'target',
    String notes = '',
  }) {
    final center = plotCenter(size);
    final radius = plotRadius(size);
    final vector = localPosition - center;
    final clampedDistance = vector.distance.clamp(0.0, radius);
    final normalizedDistance = (clampedDistance / radius) * maxDistanceMeters;
    final rawVisualAngle = math.atan2(vector.dx, -vector.dy) * 180 / math.pi;
    final visualAngle = rawVisualAngle.clamp(-halfFanDegrees, halfFanDegrees);
    final clampedAngle = storedAngleFromVisual(visualAngle);

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

  Offset offsetFromMarker({
    required TargetMarker marker,
    required Size size,
    required double maxDistanceMeters,
  }) {
    final center = plotCenter(size);
    final radius = plotRadius(size);
    final distanceRatio = (marker.distance / maxDistanceMeters).clamp(
      0.0,
      0.97,
    );
    final distance = distanceRatio * radius;
    final radians = visualAngleFromStored(marker.angle) * math.pi / 180;
    return Offset(
      center.dx + math.sin(radians) * distance,
      center.dy - math.cos(radians) * distance,
    );
  }
}
