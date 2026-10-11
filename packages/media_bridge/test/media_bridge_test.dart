import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_bridge/media_bridge.dart';
import 'package:project_model/project_model.dart';

void main() {
  group('MediaBridge Tests', () {
    test('MediaMetadata calculations and JSON serialization', () {
      const meta = MediaMetadata(
        width: 1080,
        height: 1920,
        durationMicroseconds: 15000000,
        fps: 60.0,
        videoCodec: 'H264',
        audioCodec: 'AAC',
        audioChannels: 2,
      );

      expect(meta.hasVideo, isTrue);
      expect(meta.hasAudio, isTrue);
      expect(meta.aspectRatio, closeTo(1080 / 1920, 0.001));

      final json = meta.toJson();
      final restored = MediaMetadata.fromJson(json);

      expect(restored.width, equals(1080));
      expect(restored.height, equals(1920));
      expect(restored.fps, equals(60.0));
      expect(restored.videoCodec, equals('H264'));
    });

    test('MediaItem formatting and JSON roundtrip', () {
      final item = MediaItem(
        id: 'asset_1',
        name: 'sunset_4k.mp4',
        path: '/storage/movies/sunset_4k.mp4',
        mediaType: MediaType.video,
        sizeBytes: 15728640, // 15 MB
        metadata: const MediaMetadata(
          width: 3840,
          height: 2160,
          durationMicroseconds: 8000000,
        ),
        importedAt: DateTime(2026, 10, 11, 10, 0),
      );

      expect(item.formattedFileSize, equals('15.0 MB'));

      final json = item.toJson();
      final restored = MediaItem.fromJson(json);

      expect(restored.id, equals('asset_1'));
      expect(restored.name, equals('sunset_4k.mp4'));
      expect(restored.mediaType, equals(MediaType.video));
      expect(restored.metadata.width, equals(3840));
    });

    test('MediaImportHandler throws on missing file', () async {
      const handler = MediaImportHandler();
      expect(
        () => handler.processFile('/non_existent_directory/fake_video.mp4'),
        throwsA(isA<FileNotFoundException>()),
      );
    });

    test('MediaImportHandler processes temporary valid file', () async {
      final tempDir = await Directory.systemTemp.createTemp('rangyantra_test');
      final testFile = File('${tempDir.path}/test_clip.mp4');
      await testFile.writeAsBytes(List.filled(1024, 0)); // 1KB non-empty file

      const handler = MediaImportHandler();
      final item = await handler.processFile(testFile.path);

      expect(item.name, equals('test_clip.mp4'));
      expect(item.mediaType, equals(MediaType.video));
      expect(item.sizeBytes, equals(1024));

      // Cleanup
      await tempDir.delete(recursive: true);
    });
  });
}
