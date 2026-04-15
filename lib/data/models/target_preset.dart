import 'package:milexact/data/models/enums.dart';

class TargetPreset {
  const TargetPreset({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.heightValue,
    required this.heightUnit,
    required this.widthValue,
    required this.widthUnit,
    required this.supportsMetric,
    required this.supportsImperial,
    required this.isCustom,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String categoryId;
  final String name;
  final double heightValue;
  final UnitType heightUnit;
  final double widthValue;
  final UnitType widthUnit;
  final bool supportsMetric;
  final bool supportsImperial;
  final bool isCustom;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory TargetPreset.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );
    final legacyValue = (json['sizeValue'] as num?)?.toDouble();
    final legacyUnitName = json['sizeUnit'] as String?;
    final legacyUnit = legacyUnitName == null
        ? UnitType.meter
        : UnitType.values.byName(legacyUnitName);
    final heightValue =
        (json['heightValue'] as num?)?.toDouble() ?? legacyValue ?? 0;
    final heightUnitName = json['heightUnit'] as String?;
    final heightUnit = heightUnitName == null
        ? legacyUnit
        : UnitType.values.byName(heightUnitName);
    final widthValue = (json['widthValue'] as num?)?.toDouble() ?? heightValue;
    final widthUnitName = json['widthUnit'] as String?;
    final widthUnit = widthUnitName == null
        ? heightUnit
        : UnitType.values.byName(widthUnitName);

    return TargetPreset(
      id: json['id'] as String,
      categoryId: json['categoryId'] as String,
      name: json['name'] as String,
      heightValue: heightValue,
      heightUnit: heightUnit,
      widthValue: widthValue,
      widthUnit: widthUnit,
      supportsMetric: json['supportsMetric'] as bool? ?? true,
      supportsImperial: json['supportsImperial'] as bool? ?? true,
      isCustom: json['isCustom'] as bool? ?? false,
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
      'categoryId': categoryId,
      'name': name,
      'heightValue': heightValue,
      'heightUnit': heightUnit.name,
      'widthValue': widthValue,
      'widthUnit': widthUnit.name,
      'supportsMetric': supportsMetric,
      'supportsImperial': supportsImperial,
      'isCustom': isCustom,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  double dimensionValue(TargetDimensionType dimension) {
    return switch (dimension) {
      TargetDimensionType.height => heightValue,
      TargetDimensionType.width => widthValue,
    };
  }

  UnitType dimensionUnit(TargetDimensionType dimension) {
    return switch (dimension) {
      TargetDimensionType.height => heightUnit,
      TargetDimensionType.width => widthUnit,
    };
  }

  TargetPreset copyWith({
    String? id,
    String? categoryId,
    String? name,
    double? heightValue,
    UnitType? heightUnit,
    double? widthValue,
    UnitType? widthUnit,
    bool? supportsMetric,
    bool? supportsImperial,
    bool? isCustom,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TargetPreset(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      heightValue: heightValue ?? this.heightValue,
      heightUnit: heightUnit ?? this.heightUnit,
      widthValue: widthValue ?? this.widthValue,
      widthUnit: widthUnit ?? this.widthUnit,
      supportsMetric: supportsMetric ?? this.supportsMetric,
      supportsImperial: supportsImperial ?? this.supportsImperial,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
