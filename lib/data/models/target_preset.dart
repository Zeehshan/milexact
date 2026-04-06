import 'package:milexact/data/models/enums.dart';

class TargetPreset {
  const TargetPreset({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.sizeValue,
    required this.sizeUnit,
    required this.isCustom,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;
  final String name;
  final double sizeValue;
  final MeasurementUnit sizeUnit;
  final bool isCustom;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TargetPreset.fromJson(Map<String, dynamic> json) {
    return TargetPreset(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      sizeValue: (json['sizeValue'] as num).toDouble(),
      sizeUnit: MeasurementUnit.values.byName(json['sizeUnit'] as String),
      isCustom: json['isCustom'] as bool,
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
      'categoryId': categoryId,
      'name': name,
      'sizeValue': sizeValue,
      'sizeUnit': sizeUnit.name,
      'isCustom': isCustom,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  TargetPreset copyWith({
    String? id,
    String? categoryId,
    String? name,
    double? sizeValue,
    MeasurementUnit? sizeUnit,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TargetPreset(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      sizeValue: sizeValue ?? this.sizeValue,
      sizeUnit: sizeUnit ?? this.sizeUnit,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
