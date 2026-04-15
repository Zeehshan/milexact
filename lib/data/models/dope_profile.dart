import 'package:milexact/data/models/dope_profile_entry.dart';

class DopeProfile {
  const DopeProfile({
    required this.id,
    required this.rifleName,
    required this.caliber,
    required this.bulletGrain,
    required this.velocityFps,
    required this.entries,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String rifleName;
  final String caliber;
  final double bulletGrain;
  final double velocityFps;
  final List<DopeProfileEntry> entries;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  factory DopeProfile.fromJson(Map<String, dynamic> json) {
    final createdAt = DateTime.fromMillisecondsSinceEpoch(
      (json['createdAt'] as num?)?.toInt() ??
          DateTime.now().millisecondsSinceEpoch,
    );

    return DopeProfile(
      id: json['id'] as String,
      rifleName: json['rifleName'] as String? ?? '',
      caliber: json['caliber'] as String? ?? '',
      bulletGrain: (json['bulletGrain'] as num?)?.toDouble() ?? 0,
      velocityFps: (json['velocityFps'] as num?)?.toDouble() ?? 0,
      entries: ((json['entries'] as List?) ?? const <dynamic>[])
          .map(
            (raw) => DopeProfileEntry.fromJson(
              Map<String, dynamic>.from(raw as Map),
            ),
          )
          .toList(growable: false),
      isActive: json['isActive'] as bool? ?? false,
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
      'rifleName': rifleName,
      'caliber': caliber,
      'bulletGrain': bulletGrain,
      'velocityFps': velocityFps,
      'entries': entries.map((entry) => entry.toJson()).toList(growable: false),
      'isActive': isActive,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'updatedAt': updatedAt.millisecondsSinceEpoch,
    };
  }

  DopeProfile copyWith({
    String? id,
    String? rifleName,
    String? caliber,
    double? bulletGrain,
    double? velocityFps,
    List<DopeProfileEntry>? entries,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DopeProfile(
      id: id ?? this.id,
      rifleName: rifleName ?? this.rifleName,
      caliber: caliber ?? this.caliber,
      bulletGrain: bulletGrain ?? this.bulletGrain,
      velocityFps: velocityFps ?? this.velocityFps,
      entries: entries ?? this.entries,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
