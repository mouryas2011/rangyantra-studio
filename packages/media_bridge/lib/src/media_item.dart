import 'package:project_model/project_model.dart';
import 'media_metadata.dart';

/// Represents an imported asset in the project library.
class MediaItem {
  final String id;
  final String name;
  final String path;
  final MediaType mediaType;
  final int sizeBytes;
  final MediaMetadata metadata;
  final String? thumbnailPath;
  final DateTime importedAt;

  const MediaItem({
    required this.id,
    required this.name,
    required this.path,
    required this.mediaType,
    required this.sizeBytes,
    this.metadata = const MediaMetadata(),
    this.thumbnailPath,
    required this.importedAt,
  });

  String get formattedFileSize {
    if (sizeBytes < 1024) return '$sizeBytes B';
    if (sizeBytes < 1024 * 1024) return '${(sizeBytes / 1024).toStringAsFixed(1)} KB';
    if (sizeBytes < 1024 * 1024 * 1024) return '${(sizeBytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    return '${(sizeBytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }

  MediaItem copyWith({
    String? id,
    String? name,
    String? path,
    MediaType? mediaType,
    int? sizeBytes,
    MediaMetadata? metadata,
    String? thumbnailPath,
    DateTime? importedAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      name: name ?? this.name,
      path: path ?? this.path,
      mediaType: mediaType ?? this.mediaType,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      metadata: metadata ?? this.metadata,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      importedAt: importedAt ?? this.importedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'path': path,
    'mediaType': mediaType.name,
    'sizeBytes': sizeBytes,
    'metadata': metadata.toJson(),
    'thumbnailPath': thumbnailPath,
    'importedAt': importedAt.toIso8601String(),
  };

  factory MediaItem.fromJson(Map<String, dynamic> json) => MediaItem(
    id: json['id'] as String,
    name: json['name'] as String? ?? 'Asset',
    path: json['path'] as String,
    mediaType: MediaType.values.firstWhere(
      (m) => m.name == json['mediaType'],
      orElse: () => MediaType.video,
    ),
    sizeBytes: (json['sizeBytes'] as num?)?.toInt() ?? 0,
    metadata: json['metadata'] != null
        ? MediaMetadata.fromJson(json['metadata'] as Map<String, dynamic>)
        : const MediaMetadata(),
    thumbnailPath: json['thumbnailPath'] as String?,
    importedAt: json['importedAt'] != null
        ? DateTime.tryParse(json['importedAt'] as String) ?? DateTime.now()
        : DateTime.now(),
  );

  @override
  String toString() => 'MediaItem($name, ${mediaType.name}, $formattedFileSize)';
}
