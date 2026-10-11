import 'package:flutter/services.dart';
import 'media_metadata.dart';

/// Contract interface connecting Flutter to native platform engines:
/// - Android: AndroidX Media3 Transformer & MediaMetadataRetriever
/// - iOS: AVFoundation & AVAssetTrack
abstract class NativeMediaBridge {
  static const MethodChannel channel = MethodChannel('com.rangyantra.studio/media_engine');

  /// Extracts duration, dimensions, framerate, and codecs from a media file.
  Future<MediaMetadata> extractMetadata(String filePath);

  /// Generates a video/image thumbnail frame asynchronously.
  Future<String?> generateThumbnail(
    String filePath, {
    int timestampUs = 0,
    int width = 256,
    int height = 256,
  });

  /// Verifies hardware codec decode/encode capability.
  Future<bool> isCodecSupported(String codec);
}

/// Default implementation communicating via MethodChannel with mock/fallback support.
class DefaultNativeMediaBridge implements NativeMediaBridge {
  const DefaultNativeMediaBridge();

  @override
  Future<MediaMetadata> extractMetadata(String filePath) async {
    try {
      final res = await NativeMediaBridge.channel.invokeMethod<Map>('extractMetadata', {
        'filePath': filePath,
      });
      if (res != null) {
        return MediaMetadata.fromJson(Map<String, dynamic>.from(res));
      }
    } on MissingPluginException {
      // Graceful fallback when running in testing or desktop without native runner
      return _fallbackMetadata(filePath);
    } catch (_) {
      return _fallbackMetadata(filePath);
    }
    return _fallbackMetadata(filePath);
  }

  @override
  Future<String?> generateThumbnail(
    String filePath, {
    int timestampUs = 0,
    int width = 256,
    int height = 256,
  }) async {
    try {
      return await NativeMediaBridge.channel.invokeMethod<String>('generateThumbnail', {
        'filePath': filePath,
        'timestampUs': timestampUs,
        'width': width,
        'height': height,
      });
    } catch (_) {
      return null;
    }
  }

  @override
  Future<bool> isCodecSupported(String codec) async {
    try {
      final res = await NativeMediaBridge.channel.invokeMethod<bool>('isCodecSupported', {
        'codec': codec,
      });
      return res ?? true;
    } catch (_) {
      return true;
    }
  }

  MediaMetadata _fallbackMetadata(String filePath) {
    final lower = filePath.toLowerCase();
    if (lower.endsWith('.mp4') || lower.endsWith('.mov') || lower.endsWith('.mkv')) {
      return const MediaMetadata(
        width: 1920,
        height: 1080,
        durationMicroseconds: 10000000, // 10s default estimate
        fps: 30.0,
        videoCodec: 'H264',
        audioCodec: 'AAC',
        audioChannels: 2,
      );
    } else if (lower.endsWith('.mp3') || lower.endsWith('.wav') || lower.endsWith('.aac') || lower.endsWith('.m4a')) {
      return const MediaMetadata(
        durationMicroseconds: 30000000, // 30s default estimate
        audioCodec: 'AAC',
        audioChannels: 2,
      );
    } else if (lower.endsWith('.png') || lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.webp')) {
      return const MediaMetadata(
        width: 1080,
        height: 1080,
        durationMicroseconds: 5000000, // Standard 5s still duration
        videoCodec: 'IMAGE',
      );
    }
    return const MediaMetadata();
  }
}
