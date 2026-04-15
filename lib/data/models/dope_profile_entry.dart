import 'package:milexact/data/models/enums.dart';

class DopeProfileEntry {
  const DopeProfileEntry({
    required this.id,
    required this.profileId,
    required this.distanceValue,
    required this.distanceUnit,
    required this.dropValue,
    required this.notes,
  });

  final String id;
  final String profileId;
  final double distanceValue;
  final UnitType distanceUnit;
  final String dropValue;
  final String notes;

  factory DopeProfileEntry.fromJson(Map<String, dynamic> json) {
    return DopeProfileEntry(
      id: json['id'] as String,
      profileId: json['profileId'] as String,
      distanceValue: (json['distanceValue'] as num?)?.toDouble() ?? 0,
      distanceUnit: UnitType.values.byName(
        (json['distanceUnit'] as String?) ?? UnitType.meter.name,
      ),
      dropValue: json['dropValue'] as String? ?? '',
      notes: json['notes'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'profileId': profileId,
      'distanceValue': distanceValue,
      'distanceUnit': distanceUnit.name,
      'dropValue': dropValue,
      'notes': notes,
    };
  }

  DopeProfileEntry copyWith({
    String? id,
    String? profileId,
    double? distanceValue,
    UnitType? distanceUnit,
    String? dropValue,
    String? notes,
  }) {
    return DopeProfileEntry(
      id: id ?? this.id,
      profileId: profileId ?? this.profileId,
      distanceValue: distanceValue ?? this.distanceValue,
      distanceUnit: distanceUnit ?? this.distanceUnit,
      dropValue: dropValue ?? this.dropValue,
      notes: notes ?? this.notes,
    );
  }
}
