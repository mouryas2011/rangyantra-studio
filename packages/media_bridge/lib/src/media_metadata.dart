/// Detailed media track and stream metadata.
class MediaMetadata {
  final int? width;
  final int? height;
  final int? durationMicroseconds;
  final double? fps;
  final String? videoCodec;
  final String? audioCodec;
  final int? audioChannels;
  final int? bitrate;
  final int? rotationDegrees;

  const MediaMetadata({
    this.width,
    this.height,
    this.durationMicroseconds,
    this.fps,
    this.videoCodec,
    this.audioCodec,
    this.audioChannels,
    this.bitrate,
    this.rotationDegrees,
  });

  bool get hasVideo => (width != null && height != null) || videoCodec != null;
  bool get hasAudio => audioChannels != null || audioCodec != null;

  double get aspectRatio {
    if (width != null && height != null && height! > 0) {
      return width! / height!;
    }
    return 16.0 / 9.0;
  }

  Map<String, dynamic> toJson() => {
    'width': width,
    'height': height,
    'durationMicroseconds': durationMicroseconds,
    'fps': fps,
    'videoCodec': videoCodec,
    'audioCodec': audioCodec,
    'audioChannels': audioChannels,
    'bitrate': bitrate,
    'rotationDegrees': rotationDegrees,
  };

  factory MediaMetadata.fromJson(Map<String, dynamic> json) => MediaMetadata(
    width: (json['width'] as num?)?.toInt(),
    height: (json['height'] as num?)?.toInt(),
    durationMicroseconds: (json['durationMicroseconds'] as num?)?.toInt(),
    fps: (json['fps'] as num?)?.toDouble(),
    videoCodec: json['videoCodec'] as String?,
    audioCodec: json['audioCodec'] as String?,
    audioChannels: (json['audioChannels'] as num?)?.toInt(),
    bitrate: (json['bitrate'] as num?)?.toInt(),
    rotationDegrees: (json['rotationDegrees'] as num?)?.toInt(),
  );

  @override
  String toString() =>
      'MediaMetadata(${width}x$height, ${fps ?? 0}fps, dur: ${(durationMicroseconds ?? 0) / 1000000}s, codec: $videoCodec/$audioCodec)';
}
