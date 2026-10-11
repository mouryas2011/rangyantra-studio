/// Typography, styling, and layout properties for title and text overlay clips.
class TextProperties {
  final String text;
  final String fontFamily;
  final double fontSize;
  final String textColorHex;
  final String? strokeColorHex;
  final double strokeWidth;
  final String? shadowColorHex;
  final double shadowBlurRadius;
  final double shadowOffsetX;
  final double shadowOffsetY;
  final String? backgroundColorHex;
  final String alignment; // 'left', 'center', 'right'
  final double letterSpacing;
  final double lineSpacing;

  const TextProperties({
    required this.text,
    this.fontFamily = 'Inter',
    this.fontSize = 48.0,
    this.textColorHex = '#FFFFFF',
    this.strokeColorHex,
    this.strokeWidth = 0.0,
    this.shadowColorHex = '#80000000',
    this.shadowBlurRadius = 8.0,
    this.shadowOffsetX = 2.0,
    this.shadowOffsetY = 2.0,
    this.backgroundColorHex,
    this.alignment = 'center',
    this.letterSpacing = 1.0,
    this.lineSpacing = 1.2,
  });

  TextProperties copyWith({
    String? text,
    String? fontFamily,
    double? fontSize,
    String? textColorHex,
    String? strokeColorHex,
    double? strokeWidth,
    String? shadowColorHex,
    double? shadowBlurRadius,
    double? shadowOffsetX,
    double? shadowOffsetY,
    String? backgroundColorHex,
    String? alignment,
    double? letterSpacing,
    double? lineSpacing,
  }) {
    return TextProperties(
      text: text ?? this.text,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      textColorHex: textColorHex ?? this.textColorHex,
      strokeColorHex: strokeColorHex ?? this.strokeColorHex,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      shadowColorHex: shadowColorHex ?? this.shadowColorHex,
      shadowBlurRadius: shadowBlurRadius ?? this.shadowBlurRadius,
      shadowOffsetX: shadowOffsetX ?? this.shadowOffsetX,
      shadowOffsetY: shadowOffsetY ?? this.shadowOffsetY,
      backgroundColorHex: backgroundColorHex ?? this.backgroundColorHex,
      alignment: alignment ?? this.alignment,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      lineSpacing: lineSpacing ?? this.lineSpacing,
    );
  }

  Map<String, dynamic> toJson() => {
    'text': text,
    'fontFamily': fontFamily,
    'fontSize': fontSize,
    'textColorHex': textColorHex,
    'strokeColorHex': strokeColorHex,
    'strokeWidth': strokeWidth,
    'shadowColorHex': shadowColorHex,
    'shadowBlurRadius': shadowBlurRadius,
    'shadowOffsetX': shadowOffsetX,
    'shadowOffsetY': shadowOffsetY,
    'backgroundColorHex': backgroundColorHex,
    'alignment': alignment,
    'letterSpacing': letterSpacing,
    'lineSpacing': lineSpacing,
  };

  factory TextProperties.fromJson(Map<String, dynamic> json) => TextProperties(
    text: json['text'] as String? ?? 'Sample Title',
    fontFamily: json['fontFamily'] as String? ?? 'Inter',
    fontSize: (json['fontSize'] as num?)?.toDouble() ?? 48.0,
    textColorHex: json['textColorHex'] as String? ?? '#FFFFFF',
    strokeColorHex: json['strokeColorHex'] as String?,
    strokeWidth: (json['strokeWidth'] as num?)?.toDouble() ?? 0.0,
    shadowColorHex: json['shadowColorHex'] as String?,
    shadowBlurRadius: (json['shadowBlurRadius'] as num?)?.toDouble() ?? 8.0,
    shadowOffsetX: (json['shadowOffsetX'] as num?)?.toDouble() ?? 2.0,
    shadowOffsetY: (json['shadowOffsetY'] as num?)?.toDouble() ?? 2.0,
    backgroundColorHex: json['backgroundColorHex'] as String?,
    alignment: json['alignment'] as String? ?? 'center',
    letterSpacing: (json['letterSpacing'] as num?)?.toDouble() ?? 1.0,
    lineSpacing: (json['lineSpacing'] as num?)?.toDouble() ?? 1.2,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TextProperties &&
          runtimeType == other.runtimeType &&
          text == other.text &&
          fontFamily == other.fontFamily &&
          fontSize == other.fontSize &&
          textColorHex == other.textColorHex &&
          strokeColorHex == other.strokeColorHex &&
          strokeWidth == other.strokeWidth &&
          alignment == other.alignment;

  @override
  int get hashCode =>
      text.hashCode ^
      fontFamily.hashCode ^
      fontSize.hashCode ^
      textColorHex.hashCode ^
      strokeColorHex.hashCode ^
      strokeWidth.hashCode ^
      alignment.hashCode;
}
