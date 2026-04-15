import 'package:get/get.dart';
import 'package:milexact/data/models/enums.dart';

class UnitConversionService extends GetxService {
  static const Map<UnitType, double> _metersPerUnit = {
    UnitType.millimeter: 0.001,
    UnitType.meter: 1.0,
    UnitType.inch: 0.0254,
    UnitType.foot: 0.3048,
    UnitType.yard: 0.9144,
  };

  double convert({
    required double value,
    required UnitType from,
    required UnitType to,
  }) {
    final meters = toMeters(value, from);
    return meters / _metersPerUnit[to]!;
  }

  double toMeters(double value, UnitType unit) {
    return value * _metersPerUnit[unit]!;
  }

  double toYards(double value, UnitType unit) {
    return convert(value: value, from: unit, to: UnitType.yard);
  }

  double metersToYards(double value) {
    return convert(value: value, from: UnitType.meter, to: UnitType.yard);
  }

  double yardsToMeters(double value) {
    return convert(value: value, from: UnitType.yard, to: UnitType.meter);
  }
}
