import 'package:file_picker/file_picker.dart';
import 'package:media_bridge/media_bridge.dart';

/// Service for launching platform file pickers and processing imported media assets.
class MediaImportService {
  final MediaImportHandler _importHandler;

  MediaImportService({MediaImportHandler? importHandler})
      : _importHandler = importHandler ?? const MediaImportHandler();

  /// Prompts the user to select video files.
  Future<List<MediaItem>> pickVideos({bool allowMultiple = true}) async {
    return _pickMedia(
      type: FileType.video,
      allowMultiple: allowMultiple,
    );
  }

  /// Prompts the user to select audio files.
  Future<List<MediaItem>> pickAudio({bool allowMultiple = true}) async {
    return _pickMedia(
      type: FileType.audio,
      allowMultiple: allowMultiple,
    );
  }

  /// Prompts the user to select image files.
  Future<List<MediaItem>> pickImages({bool allowMultiple = true}) async {
    return _pickMedia(
      type: FileType.image,
      allowMultiple: allowMultiple,
    );
  }

  /// Prompts user to pick any supported media (video, audio, image).
  Future<List<MediaItem>> pickAnyMedia({bool allowMultiple = true}) async {
    return _pickMedia(
      type: FileType.media,
      allowMultiple: allowMultiple,
    );
  }

  Future<List<MediaItem>> _pickMedia({
    required FileType type,
    required bool allowMultiple,
  }) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: type,
        allowMultiple: allowMultiple,
      );

      if (result == null || result.files.isEmpty) {
        return [];
      }

      final items = <MediaItem>[];
      for (final file in result.files) {
        if (file.path != null && file.path!.isNotEmpty) {
          try {
            final item = await _importHandler.processFile(file.path!);
            items.add(item);
          } catch (e) {
            // Handle corrupted or inaccessible single file without failing the whole batch
            continue;
          }
        }
      }

      return items;
    } catch (_) {
      return [];
    }
  }
}
