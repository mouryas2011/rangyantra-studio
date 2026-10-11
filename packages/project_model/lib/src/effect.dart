enum EffectType {
  blur,
  sharpen,
  vignette,
  filmGrain,
  glow,
  chromaticAberration,
  distortion,
}

/// Visual effect model applied to a video or image clip.
class VisualEffect {
  final String id;
  final EffectType type;
  final String name;
  final double intensity; // 0.0 to 1.0
  final bool isEnabled;
  final Map<String, dynamic> parameters;

  const VisualEffect({
    required this.id,
    required this.type,
    required this.name,
    this.intensity = 0.5,
    this.isEnabled = true,
    this.parameters = const {},
  });

  VisualEffect copyWith({
    String? id,
    EffectType? type,
    String? name,
    double? intensity,
    bool? isEnabled,
    Map<String, dynamic>? parameters,
  }) {
    return VisualEffect(
      id: id ?? this.id,
      type: type ?? this.type,
      name: name ?? this.name,
      intensity: intensity ?? this.intensity,
      isEnabled: isEnabled ?? this.isEnabled,
      parameters: parameters ?? this.parameters,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'type': type.name,
    'name': name,
    'intensity': intensity,
    'isEnabled': isEnabled,
    'parameters': parameters,
  };

  factory VisualEffect.fromJson(Map<String, dynamic> json) => VisualEffect(
    id: json['id'] as String,
    type: EffectType.values.firstWhere(
      (e) => e.name == json['type'],
      orElse: () => EffectType.blur,
    ),
    name: json['name'] as String? ?? 'Effect',
    intensity: (json['intensity'] as num?)?.toDouble() ?? 0.5,
    isEnabled: json['isEnabled'] as bool? ?? true,
    parameters: Map<String, dynamic>.from(json['parameters'] as Map? ?? {}),
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VisualEffect &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          type == other.type &&
          name == other.name &&
          intensity == other.intensity &&
          isEnabled == other.isEnabled;

  @override
  int get hashCode =>
      id.hashCode ^
      type.hashCode ^
      name.hashCode ^
      intensity.hashCode ^
      isEnabled.hashCode;
}
