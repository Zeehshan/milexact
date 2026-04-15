import 'package:milexact/data/models/enums.dart';

class RangeCardEntry {
  const RangeCardEntry({
    required this.id,
    required this.targetName,
    required this.targetHeightValue,
    required this.targetHeightUnit,
    required this.targetWidthValue,
    required this.targetWidthUnit,
    required this.reticleReading,
    required this.reticleType,
    required this.displayPreference,
    required this.distanceMeters,
    required this.distanceYards,
    required this.dopeValue,
    required this.selectedDopeProfileId,
    required this.windValueType,
    required this.windDirectionClock,
    required this.targetPlacementAngle,
    required this.targetPlacementLabel,
    required this.terrainNotes,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String targetName;
  final double targetHeightValue;
  final UnitType targetHeightUnit;
  final double targetWidthValue;
  final UnitType targetWidthUnit;
  final double reticleReading;
  final ReticleType reticleType;
  final DistanceDisplayPreference displayPreference;
  final double distanceMeters;
  final double distanceYards;
  final String dopeValue;
  final String? selectedDopeProfileId;
  final WindValueType windValueType;
  final String windDirectionClock;
  final double targetPlacementAngle;
  final String targetPlacementLabel;
  final String terrainNotes;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory RangeCardEntry.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
    final legacySizeValue = (json['targetSizeValue'] as num?)?.toDouble() ?? 0;
    final legacyUnitName = json['targetSizeUnit'] as String?;
    final legacyUnit = legacyUnitName == null
        ? UnitType.meter
        : UnitType.values.byName(legacyUnitName);
    final legacyWindFull = (json['windFull'] as String? ?? '').trim();
    final legacyWindHalf = (json['windHalf'] as String? ?? '').trim();
    final legacyWindQuarter = (json['windQuarter'] as String? ?? '').trim();
    final windTypeName = json['windValueType'] as String?;
    final windValueType = windTypeName != null
        ? WindValueType.values.byName(windTypeName)
        : legacyWindFull.isNotEmpty
        ? WindValueType.full
        : legacyWindHalf.isNotEmpty
        ? WindValueType.half
        : legacyWindQuarter.isNotEmpty
        ? WindValueType.quarter
        : WindValueType.none;

    return RangeCardEntry(
      id: json['id'] as String,
      targetName: json['targetName'] as String? ?? 'Unknown Target',
      targetHeightValue:
          (json['targetHeightValue'] as num?)?.toDouble() ?? legacySizeValue,
      targetHeightUnit: UnitType.values.byName(
        (json['targetHeightUnit'] as String?) ?? legacyUnit.name,
      ),
      targetWidthValue:
          (json['targetWidthValue'] as num?)?.toDouble() ?? legacySizeValue,
      targetWidthUnit: UnitType.values.byName(
        (json['targetWidthUnit'] as String?) ?? legacyUnit.name,
      ),
      reticleReading: (json['reticleReading'] as num?)?.toDouble() ?? 0,
      reticleType: ReticleType.values.byName(
        (json['reticleType'] as String?) ?? ReticleType.mil.name,
      ),
      displayPreference: DistanceDisplayPreference.values.byName(
        (json['displayPreference'] as String?) ??
            (json['outputPreference'] as String?) ??
            DistanceDisplayPreference.both.name,
      ),
      distanceMeters:
          (json['distanceMeters'] as num?)?.toDouble() ??
          (json['calculatedDistanceMeters'] as num?)?.toDouble() ??
          0,
      distanceYards:
          (json['distanceYards'] as num?)?.toDouble() ??
          (json['calculatedDistanceYards'] as num?)?.toDouble() ??
          0,
      dopeValue:
          (json['dopeValue'] as String?) ?? (json['dope'] as String?) ?? '',
      selectedDopeProfileId: json['selectedDopeProfileId'] as String?,
      windValueType: windValueType,
      windDirectionClock: json['windDirectionClock'] as String? ?? '12',
      targetPlacementAngle:
          (json['targetPlacementAngle'] as num?)?.toDouble() ?? 90,
      targetPlacementLabel: json['targetPlacementLabel'] as String? ?? '',
      terrainNotes:
          (json['terrainNotes'] as String?) ?? (json['notes'] as String?) ?? '',
      createdAt: createdAt,
      updatedAt: DateTime.fromMillisecondsSinceEpoch(
        (json['updatedAt'] as num?)?.toInt() ??
            createdAt.millisecondsSinceEpoch,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'targetName': targetName,
      'targetHeightValue': targetHeightValue,
      'targetHeightUnit': targetHeightUnit.name,
      'targetWidthValue': targetWidthValue,
      'targetWidthUnit': targetWidthUnit.name,
      'reticleReading': reticleReading,
      'reticleType': reticleType.name,
      'displayPreference': displayPreference.name,
      'distanceMeters': distanceMeters,
      'distanceYards': distanceYards,
      'dopeValue': dopeValue,
      'selectedDopeProfileId': selectedDopeProfileId,
      'windValueType': windValueType.name,
      'windDirectionClock': windDirectionClock,
      'targetPlacementAngle': targetPlacementAngle,
      'targetPlacementLabel': targetPlacementLabel,
      'terrainNotes': terrainNotes,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  RangeCardEntry copyWith({
    String? id,
    String? targetName,
    double? targetHeightValue,
    UnitType? targetHeightUnit,
    double? targetWidthValue,
    UnitType? targetWidthUnit,
    double? reticleReading,
    ReticleType? reticleType,
    DistanceDisplayPreference? displayPreference,
    double? distanceMeters,
    double? distanceYards,
    String? dopeValue,
    String? selectedDopeProfileId,
    WindValueType? windValueType,
    String? windDirectionClock,
    double? targetPlacementAngle,
    String? targetPlacementLabel,
    String? terrainNotes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return RangeCardEntry(
      id: id ?? this.id,
      targetName: targetName ?? this.targetName,
      targetHeightValue: targetHeightValue ?? this.targetHeightValue,
      targetHeightUnit: targetHeightUnit ?? this.targetHeightUnit,
      targetWidthValue: targetWidthValue ?? this.targetWidthValue,
      targetWidthUnit: targetWidthUnit ?? this.targetWidthUnit,
      reticleReading: reticleReading ?? this.reticleReading,
      reticleType: reticleType ?? this.reticleType,
      displayPreference: displayPreference ?? this.displayPreference,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      distanceYards: distanceYards ?? this.distanceYards,
      dopeValue: dopeValue ?? this.dopeValue,
      selectedDopeProfileId:
          selectedDopeProfileId ?? this.selectedDopeProfileId,
      windValueType: windValueType ?? this.windValueType,
      windDirectionClock: windDirectionClock ?? this.windDirectionClock,
      targetPlacementAngle: targetPlacementAngle ?? this.targetPlacementAngle,
      targetPlacementLabel: targetPlacementLabel ?? this.targetPlacementLabel,
      terrainNotes: terrainNotes ?? this.terrainNotes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
