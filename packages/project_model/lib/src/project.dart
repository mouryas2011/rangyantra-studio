import 'canvas_format.dart';
import 'track.dart';
import 'export_preferences.dart';

/// The root document model for a RangYantra Studio editing project.
/// Versioned for forward/backward compatibility.
class Project {
  static const int currentSchemaVersion = 1;

  final String id;
  final String name;
  final int schemaVersion;
  final DateTime createdAt;
  final DateTime updatedAt;
  final CanvasFormat canvas;
  final List<Track> tracks;
  final ExportPreferences exportPreferences;

  const Project({
    required this.id,
    required this.name,
    this.schemaVersion = currentSchemaVersion,
    required this.createdAt,
    required this.updatedAt,
    required this.canvas,
    this.tracks = const [],
    this.exportPreferences = ExportPreferences.defaultMobile,
  });

  /// The total project duration in microseconds (the maximum duration of all tracks).
  int get durationMicroseconds {
    if (tracks.isEmpty) return 0;
    int maxDur = 0;
    for (final track in tracks) {
      final d = track.durationUs;
      if (d > maxDur) {
        maxDur = d;
      }
    }
    return maxDur;
  }

  /// Total count of clips across all tracks.
  int get totalClipCount {
    int count = 0;
    for (final track in tracks) {
      count += track.clips.length;
    }
    return count;
  }

  /// Create an empty project with default video and audio tracks.
  factory Project.create({
    required String id,
    required String name,
    CanvasFormat canvas = CanvasFormat.portrait9_16,
  }) {
    final now = DateTime.now();
    return Project(
      id: id,
      name: name,
      schemaVersion: currentSchemaVersion,
      createdAt: now,
      updatedAt: now,
      canvas: canvas,
      tracks: [
        Track(
          id: '${id}_t_video1',
          name: 'Main Video',
          type: TrackType.video,
          orderIndex: 0,
        ),
        Track(
          id: '${id}_t_overlay1',
          name: 'Overlay & Titles',
          type: TrackType.text,
          orderIndex: 1,
        ),
        Track(
          id: '${id}_t_audio1',
          name: 'Background Audio',
          type: TrackType.audio,
          orderIndex: 2,
        ),
      ],
      exportPreferences: ExportPreferences(
        width: canvas.width,
        height: canvas.height,
        fps: canvas.fps,
      ),
    );
  }

  Project copyWith({
    String? id,
    String? name,
    int? schemaVersion,
    DateTime? createdAt,
    DateTime? updatedAt,
    CanvasFormat? canvas,
    List<Track>? tracks,
    ExportPreferences? exportPreferences,
  }) {
    return Project(
      id: id ?? this.id,
      name: name ?? this.name,
      schemaVersion: schemaVersion ?? this.schemaVersion,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      canvas: canvas ?? this.canvas,
      tracks: tracks ?? this.tracks,
      exportPreferences: exportPreferences ?? this.exportPreferences,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'schemaVersion': schemaVersion,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'canvas': canvas.toJson(),
    'tracks': tracks.map((t) => t.toJson()).toList(),
    'exportPreferences': exportPreferences.toJson(),
  };

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Untitled Project',
      schemaVersion: (json['schemaVersion'] as num?)?.toInt() ?? 1,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      canvas: json['canvas'] != null
          ? CanvasFormat.fromJson(json['canvas'] as Map<String, dynamic>)
          : CanvasFormat.portrait9_16,
      tracks: (json['tracks'] as List?)
              ?.map((t) => Track.fromJson(t as Map<String, dynamic>))
              .toList() ??
          const [],
      exportPreferences: json['exportPreferences'] != null
          ? ExportPreferences.fromJson(json['exportPreferences'] as Map<String, dynamic>)
          : ExportPreferences.defaultMobile,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Project &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          schemaVersion == other.schemaVersion &&
          canvas == other.canvas;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ schemaVersion.hashCode ^ canvas.hashCode;

  @override
  String toString() =>
      'Project(id: $id, name: "$name", tracks: ${tracks.length}, clips: $totalClipCount, duration: ${durationMicroseconds}us)';
}
