import 'dart:io';
import 'package:project_model/project_model.dart';
import 'package:uuid/uuid.dart';
import 'media_item.dart';
import 'native_bridge_contract.dart';

/// Handles validation, file integrity, metadata inspection, and asset creation.
class MediaImportHandler {
  final NativeMediaBridge nativeBridge;

  const MediaImportHandler({
    this.nativeBridge = const DefaultNativeMediaBridge(),
  });

  /// Processes an imported file path and returns a validated [MediaItem].
  Future<MediaItem> processFile(String filePath) async {
    final file = File(filePath);
    final exists = await file.exists();
    if (!exists) {
      throw FileNotFoundException('File not found at path: $filePath');
    }

    final sizeBytes = await file.length();
    if (sizeBytes == 0) {
      throw CorruptedMediaException('File is empty (0 bytes): $filePath');
    }

    final name = file.uri.pathSegments.isNotEmpty
        ? file.uri.pathSegments.last
        : 'Media Asset';

    final mediaType = _detectMediaType(filePath);
    final metadata = await nativeBridge.extractMetadata(filePath);
    final thumbnail = await nativeBridge.generateThumbnail(filePath);

    return MediaItem(
      id: const Uuid().v4(),
      name: name,
      path: filePath,
      mediaType: mediaType,
      sizeBytes: sizeBytes,
      metadata: metadata,
      thumbnailPath: thumbnail,
      importedAt: DateTime.now(),
    );
  }

  MediaType _detectMediaType(String path) {
    final ext = path.toLowerCase().split('.').last;
    switch (ext) {
      case 'mp4':
      case 'mov':
      case 'm4v':
      case 'mkv':
      case 'webm':
        return MediaType.video;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'm4a':
      case 'flac':
      case 'ogg':
        return MediaType.audio;
      case 'png':
      case 'jpg':
      case 'jpeg':
      case 'webp':
      case 'gif':
        return MediaType.image;
      default:
        return MediaType.video;
    }
  }
}

class FileNotFoundException implements Exception {
  final String message;
  FileNotFoundException(this.message);
  @override
  String toString() => 'FileNotFoundException: $message';
}

class CorruptedMediaException implements Exception {
  final String message;
  CorruptedMediaException(this.message);
  @override
  String toString() => 'CorruptedMediaException: $message';
}
