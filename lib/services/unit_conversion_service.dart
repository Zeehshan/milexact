import 'package:get/get.dart';
import 'package:milexact/data/models/enums.dart';

class UnitConversionService extends GetxService {
  static const Map<MeasurementUnit, double> _metersPerUnit = {
    MeasurementUnit.millimeter: 0.001,
    MeasurementUnit.meter: 1.0,
    MeasurementUnit.inch: 0.0254,
    MeasurementUnit.foot: 0.3048,
    MeasurementUnit.yard: 0.9144,
  };

  double convert({
    required double value,
    required MeasurementUnit from,
    required MeasurementUnit to,
  }) {
    final meters = toMeters(value, from);
    return meters / _metersPerUnit[to]!;
  }

  double toMeters(double value, MeasurementUnit unit) {
    return value * _metersPerUnit[unit]!;
  }

  double toYards(double value, MeasurementUnit unit) {
    return convert(value: value, from: unit, to: MeasurementUnit.yard);
  }

  double metersToYards(double value) {
    return convert(
      value: value,
      from: MeasurementUnit.meter,
      to: MeasurementUnit.yard,
    );
  }

  double yardsToMeters(double value) {
    return convert(
      value: value,
      from: MeasurementUnit.yard,
      to: MeasurementUnit.meter,
    );
  }
}
