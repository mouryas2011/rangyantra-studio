/// Color adjustments and grading parameters for video and image clips.
class ColorGradingProperties {
  final double exposure;    // -2.0 to +2.0 EV
  final double brightness;  // -1.0 to +1.0
  final double contrast;    // 0.0 to 2.0 (1.0 = normal)
  final double saturation;  // 0.0 to 2.0 (1.0 = normal, 0 = black&white)
  final double temperature; // -100 to +100 Kelvin shift (cool to warm)
  final double tint;        // -100 to +100 Green to Magenta shift
  final double highlights;  // -1.0 to +1.0
  final double shadows;     // -1.0 to +1.0
  final double whites;      // -1.0 to +1.0
  final double blacks;      // -1.0 to +1.0
  final String? lutPath;    // Optional 3D LUT (.cube) asset/file path

  const ColorGradingProperties({
    this.exposure = 0.0,
    this.brightness = 0.0,
    this.contrast = 1.0,
    this.saturation = 1.0,
    this.temperature = 0.0,
    this.tint = 0.0,
    this.highlights = 0.0,
    this.shadows = 0.0,
    this.whites = 0.0,
    this.blacks = 0.0,
    this.lutPath,
  });

  static const ColorGradingProperties neutral = ColorGradingProperties();

  bool get isModified =>
      exposure != 0.0 ||
      brightness != 0.0 ||
      contrast != 1.0 ||
      saturation != 1.0 ||
      temperature != 0.0 ||
      tint != 0.0 ||
      highlights != 0.0 ||
      shadows != 0.0 ||
      whites != 0.0 ||
      blacks != 0.0 ||
      lutPath != null;

  ColorGradingProperties copyWith({
    double? exposure,
    double? brightness,
    double? contrast,
    double? saturation,
    double? temperature,
    double? tint,
    double? highlights,
    double? shadows,
    double? whites,
    double? blacks,
    String? lutPath,
    bool clearLut = false,
  }) {
    return ColorGradingProperties(
      exposure: exposure ?? this.exposure,
      brightness: brightness ?? this.brightness,
      contrast: contrast ?? this.contrast,
      saturation: saturation ?? this.saturation,
      temperature: temperature ?? this.temperature,
      tint: tint ?? this.tint,
      highlights: highlights ?? this.highlights,
      shadows: shadows ?? this.shadows,
      whites: whites ?? this.whites,
      blacks: blacks ?? this.blacks,
      lutPath: clearLut ? null : (lutPath ?? this.lutPath),
    );
  }

  Map<String, dynamic> toJson() => {
    'exposure': exposure,
    'brightness': brightness,
    'contrast': contrast,
    'saturation': saturation,
    'temperature': temperature,
    'tint': tint,
    'highlights': highlights,
    'shadows': shadows,
    'whites': whites,
    'blacks': blacks,
    'lutPath': lutPath,
  };

  factory ColorGradingProperties.fromJson(Map<String, dynamic> json) =>
      ColorGradingProperties(
        exposure: (json['exposure'] as num?)?.toDouble() ?? 0.0,
        brightness: (json['brightness'] as num?)?.toDouble() ?? 0.0,
        contrast: (json['contrast'] as num?)?.toDouble() ?? 1.0,
        saturation: (json['saturation'] as num?)?.toDouble() ?? 1.0,
        temperature: (json['temperature'] as num?)?.toDouble() ?? 0.0,
        tint: (json['tint'] as num?)?.toDouble() ?? 0.0,
        highlights: (json['highlights'] as num?)?.toDouble() ?? 0.0,
        shadows: (json['shadows'] as num?)?.toDouble() ?? 0.0,
        whites: (json['whites'] as num?)?.toDouble() ?? 0.0,
        blacks: (json['blacks'] as num?)?.toDouble() ?? 0.0,
        lutPath: json['lutPath'] as String?,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ColorGradingProperties &&
          runtimeType == other.runtimeType &&
          exposure == other.exposure &&
          brightness == other.brightness &&
          contrast == other.contrast &&
          saturation == other.saturation &&
          temperature == other.temperature &&
          tint == other.tint &&
          highlights == other.highlights &&
          shadows == other.shadows &&
          whites == other.whites &&
          blacks == other.blacks &&
          lutPath == other.lutPath;

  @override
  int get hashCode =>
      exposure.hashCode ^
      brightness.hashCode ^
      contrast.hashCode ^
      saturation.hashCode ^
      temperature.hashCode ^
      tint.hashCode ^
      highlights.hashCode ^
      shadows.hashCode ^
      whites.hashCode ^
      blacks.hashCode ^
      lutPath.hashCode;
}
