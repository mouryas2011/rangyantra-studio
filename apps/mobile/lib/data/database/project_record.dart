import 'package:project_model/project_model.dart';

/// Lightweight summary model for high-performance project listing and search.
class ProjectRecord {
  final String id;
  final String name;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String aspectRatioId;
  final int width;
  final int height;
  final int fps;
  final int durationUs;
  final int clipCount;
  final String? thumbnailPath;

  const ProjectRecord({
    required this.id,
    required this.name,
    required this.schemaVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.aspectRatioId,
    required this.width,
    required this.height,
    required this.fps,
    required this.durationUs,
    required this.clipCount,
    this.thumbnailPath,
  });

  String get formattedDuration {
    final totalSeconds = durationUs ~/ 1000000;
    final s = totalSeconds % 60;
    final m = totalSeconds ~/ 60;
    final ms = (durationUs % 1000000) ~/ 10000;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}.${ms.toString().padLeft(2, '0')}';
  }

  String get resolutionLabel => '${width}x$height';

  factory ProjectRecord.fromMap(Map<String, dynamic> map) => ProjectRecord(
    id: map['id'] as String,
    name: map['name'] as String,
    schemaVersion: (map['schema_version'] as num).toInt(),
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
    aspectRatioId: map['aspect_ratio_id'] as String,
    width: (map['width'] as num).toInt(),
    height: (map['height'] as num).toInt(),
    fps: (map['fps'] as num).toInt(),
    durationUs: (map['duration_us'] as num).toInt(),
    clipCount: (map['clip_count'] as num).toInt(),
    thumbnailPath: map['thumbnail_path'] as String?,
  );

  factory ProjectRecord.fromProject(Project project, {String? thumbnailPath}) => ProjectRecord(
    id: project.id,
    name: project.name,
    schemaVersion: project.schemaVersion,
    createdAt: project.createdAt,
    updatedAt: project.updatedAt,
    aspectRatioId: project.canvas.id,
    width: project.canvas.width,
    height: project.canvas.height,
    fps: project.canvas.fps,
    durationUs: project.durationMicroseconds,
    clipCount: project.totalClipCount,
    thumbnailPath: thumbnailPath,
  );
}
