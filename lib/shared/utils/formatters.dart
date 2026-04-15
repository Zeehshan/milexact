import 'package:intl/intl.dart';
import 'package:milexact/data/models/enums.dart';

abstract final class AppFormatters {
  static final DateFormat _dateFormat = DateFormat('MMM d, HH:mm');

  static String number(double value) {
    final absolute = value.abs();
    final decimals = absolute >= 1000
        ? 0
        : absolute >= 100
        ? 1
        : 2;
    var formatted = value.toStringAsFixed(decimals);
    if (formatted.contains('.')) {
      formatted = formatted.replaceFirst(RegExp(r'0+$'), '');
      formatted = formatted.replaceFirst(RegExp(r'\.$'), '');
    }
    return formatted;
  }

  static String distance(double value, {required String unitLabel}) {
    return '${number(value)} $unitLabel';
  }

  static String targetSize(double value, UnitType unit) {
    return '${number(value)} ${unit.shortLabel}';
  }

  static String distanceSummary({
    required DistanceDisplayPreference preference,
    required double meters,
    required double yards,
  }) {
    return switch (preference) {
      DistanceDisplayPreference.meters => distance(meters, unitLabel: 'm'),
      DistanceDisplayPreference.yards => distance(yards, unitLabel: 'yd'),
      DistanceDisplayPreference.both =>
        '${distance(meters, unitLabel: 'm')} • ${distance(yards, unitLabel: 'yd')}',
    };
  }

  static String windSummary(
    WindValueType windValueType, {
    required String windDirectionClock,
  }) {
    return switch (windValueType) {
      WindValueType.none => 'No Value',
      _ => '${windValueType.label} • $windDirectionClock o\'clock',
    };
  }

  static String dateTime(DateTime value) => _dateFormat.format(value);

  static String preview(String value, {int maxLength = 80}) {
    final trimmed = value.trim();
    if (trimmed.length <= maxLength) {
      return trimmed;
    }
    return '${trimmed.substring(0, maxLength).trimRight()}...';
  }
}
