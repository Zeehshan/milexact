import 'package:milexact/data/models/enums.dart';

class RangeCardEntry {
  const RangeCardEntry({
    required this.id,
    required this.targetName,
    required this.targetSizeValue,
    required this.targetSizeUnit,
    required this.reticleReading,
    required this.reticleType,
    required this.outputPreference,
    required this.calculatedDistanceMeters,
    required this.calculatedDistanceYards,
    required this.dope,
    required this.windFull,
    required this.windHalf,
    required this.windQuarter,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String targetName;
  final double targetSizeValue;
  final MeasurementUnit targetSizeUnit;
  final double reticleReading;
  final ReticleType reticleType;
  final DistanceOutputPreference outputPreference;
  final double calculatedDistanceMeters;
  final double calculatedDistanceYards;
  final String dope;
  final String windFull;
  final String windHalf;
  final String windQuarter;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RangeCardEntry.fromJson(Map<String, dynamic> json) {
    return RangeCardEntry(
      id: json['id'] as String,
      targetName: json['targetName'] as String,
      targetSizeValue: (json['targetSizeValue'] as num).toDouble(),
      targetSizeUnit: MeasurementUnit.values.byName(
        json['targetSizeUnit'] as String,
      ),
      reticleReading: (json['reticleReading'] as num).toDouble(),
      reticleType: ReticleType.values.byName(json['reticleType'] as String),
      outputPreference: DistanceOutputPreference.values.byName(
        json['outputPreference'] as String,
      ),
      calculatedDistanceMeters: (json['calculatedDistanceMeters'] as num)
          .toDouble(),
      calculatedDistanceYards: (json['calculatedDistanceYards'] as num)
          .toDouble(),
      dope: json['dope'] as String? ?? '',
      windFull: json['windFull'] as String? ?? '',
      windHalf: json['windHalf'] as String? ?? '',
      windQuarter: json['windQuarter'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(
        (json['createdAt'] as num).toInt(),
      ),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt'] as num).toInt(),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetName': targetName,
      'targetSizeValue': targetSizeValue,
      'targetSizeUnit': targetSizeUnit.name,
      'reticleReading': reticleReading,
      'reticleType': reticleType.name,
      'outputPreference': outputPreference.name,
      'calculatedDistanceMeters': calculatedDistanceMeters,
      'calculatedDistanceYards': calculatedDistanceYards,
      'dope': dope,
      'windFull': windFull,
      'windHalf': windHalf,
      'windQuarter': windQuarter,
      'notes': notes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  RangeCardEntry copyWith({
    String? id,
    String? targetName,
    double? targetSizeValue,
    MeasurementUnit? targetSizeUnit,
    double? reticleReading,
    ReticleType? reticleType,
    DistanceOutputPreference? outputPreference,
    double? calculatedDistanceMeters,
    double? calculatedDistanceYards,
    String? dope,
    String? windFull,
    String? windHalf,
    String? windQuarter,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RangeCardEntry(
      id: id ?? this.id,
      targetName: targetName ?? this.targetName,
      targetSizeValue: targetSizeValue ?? this.targetSizeValue,
      targetSizeUnit: targetSizeUnit ?? this.targetSizeUnit,
      reticleReading: reticleReading ?? this.reticleReading,
      reticleType: reticleType ?? this.reticleType,
      outputPreference: outputPreference ?? this.outputPreference,
      calculatedDistanceMeters:
          calculatedDistanceMeters ?? this.calculatedDistanceMeters,
      calculatedDistanceYards:
          calculatedDistanceYards ?? this.calculatedDistanceYards,
      dope: dope ?? this.dope,
      windFull: windFull ?? this.windFull,
      windHalf: windHalf ?? this.windHalf,
      windQuarter: windQuarter ?? this.windQuarter,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
