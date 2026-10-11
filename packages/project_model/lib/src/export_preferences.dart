/// Render and export configuration for project output.
class ExportPreferences {
  final String resolutionName; // '720p', '1080p', '1440p', '4K'
  final int width;
  final int height;
  final int fps;
  final double bitrateMbps;
  final String videoCodec;     // 'H264', 'HEVC'
  final int audioQualityKbps;  // 128, 192, 320

  const ExportPreferences({
    this.resolutionName = '1080p Full HD',
    this.width = 1080,
    this.height = 1920,
    this.fps = 30,
    this.bitrateMbps = 12.0,
    this.videoCodec = 'H264',
    this.audioQualityKbps = 192,
  });

  static const ExportPreferences defaultMobile = ExportPreferences();

  ExportPreferences copyWith({
    String? resolutionName,
    int? width,
    int? height,
    int? fps,
    double? bitrateMbps,
    String? videoCodec,
    int? audioQualityKbps,
  }) {
    return ExportPreferences(
      resolutionName: resolutionName ?? this.resolutionName,
      width: width ?? this.width,
      height: height ?? this.height,
      fps: fps ?? this.fps,
      bitrateMbps: bitrateMbps ?? this.bitrateMbps,
      videoCodec: videoCodec ?? this.videoCodec,
      audioQualityKbps: audioQualityKbps ?? this.audioQualityKbps,
    );
  }

  Map<String, dynamic> toJson() => {
    'resolutionName': resolutionName,
    'width': width,
    'height': height,
    'fps': fps,
    'bitrateMbps': bitrateMbps,
    'videoCodec': videoCodec,
    'audioQualityKbps': audioQualityKbps,
  };

  factory ExportPreferences.fromJson(Map<String, dynamic> json) =>
      ExportPreferences(
        resolutionName: json['resolutionName'] as String? ?? '1080p',
        width: (json['width'] as num?)?.toInt() ?? 1080,
        height: (json['height'] as num?)?.toInt() ?? 1920,
        fps: (json['fps'] as num?)?.toInt() ?? 30,
        bitrateMbps: (json['bitrateMbps'] as num?)?.toDouble() ?? 12.0,
        videoCodec: json['videoCodec'] as String? ?? 'H264',
        audioQualityKbps: (json['audioQualityKbps'] as num?)?.toInt() ?? 192,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExportPreferences &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          fps == other.fps &&
          bitrateMbps == other.bitrateMbps &&
          videoCodec == other.videoCodec;

  @override
  int get hashCode =>
      width.hashCode ^
      height.hashCode ^
      fps.hashCode ^
      bitrateMbps.hashCode ^
      videoCodec.hashCode;
}
