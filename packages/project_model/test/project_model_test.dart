import 'package:flutter_test/flutter_test.dart';
import 'package:project_model/project_model.dart';

void main() {
  group('ProjectModel Tests', () {
    test('Project creation and defaults', () {
      final project = Project.create(
        id: 'proj_123',
        name: 'Test Project',
        canvas: CanvasFormat.portrait9_16,
      );

      expect(project.id, equals('proj_123'));
      expect(project.name, equals('Test Project'));
      expect(project.canvas.width, equals(1080));
      expect(project.canvas.height, equals(1920));
      expect(project.tracks.length, equals(3));
      expect(project.durationMicroseconds, equals(0));
      expect(project.totalClipCount, equals(0));
    });

    test('Clip and Track duration calculation', () {
      final clip1 = Clip(
        id: 'clip_1',
        trackId: 'track_1',
        name: 'Intro Clip',
        mediaType: MediaType.video,
        timelineStartUs: 0,
        timelineDurationUs: 5000000, // 5 seconds
        sourceInUs: 0,
        sourceOutUs: 5000000,
      );

      final clip2 = Clip(
        id: 'clip_2',
        trackId: 'track_1',
        name: 'Main Clip',
        mediaType: MediaType.video,
        timelineStartUs: 5000000,
        timelineDurationUs: 7000000, // 7 seconds (ends at 12s)
        sourceInUs: 1000000,
        sourceOutUs: 8000000,
      );

      final track = Track(
        id: 'track_1',
        name: 'Video 1',
        type: TrackType.video,
        orderIndex: 0,
        clips: [clip1, clip2],
      );

      expect(track.durationUs, equals(12000000));

      final project = Project(
        id: 'proj_456',
        name: 'Cinematic Reel',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        canvas: CanvasFormat.landscape16_9,
        tracks: [track],
      );

      expect(project.durationMicroseconds, equals(12000000));
      expect(project.totalClipCount, equals(2));
    });

    test('Full Project JSON serialization and round-trip deserialization', () {
      final clip = Clip(
        id: 'c1',
        trackId: 't1',
        name: 'Sunset Shot',
        mediaPath: '/media/sunset.mp4',
        mediaType: MediaType.video,
        timelineStartUs: 1000000,
        timelineDurationUs: 4000000,
        sourceInUs: 500000,
        sourceOutUs: 4500000,
        speed: 1.5,
        volume: 0.8,
        transform: const TransformProperties(
          positionX: 10.0,
          positionY: -5.0,
          scaleX: 1.1,
          scaleY: 1.1,
          rotationDegrees: 15.0,
          opacity: 0.95,
        ),
        colorGrading: const ColorGradingProperties(
          exposure: 0.2,
          contrast: 1.1,
          saturation: 1.3,
          temperature: 15.0,
          tint: -5.0,
        ),
        effects: const [
          VisualEffect(
            id: 'fx_1',
            type: EffectType.vignette,
            name: 'Vignette',
            intensity: 0.7,
          ),
        ],
        transitionIn: const Transition(
          id: 'trans_1',
          type: TransitionType.crossDissolve,
          durationMicroseconds: 500000,
        ),
      );

      final textClip = Clip(
        id: 'c2',
        trackId: 't2',
        name: 'Title Overlay',
        mediaType: MediaType.text,
        timelineStartUs: 0,
        timelineDurationUs: 3000000,
        sourceInUs: 0,
        sourceOutUs: 3000000,
        textProperties: const TextProperties(
          text: 'RangYantra Studio',
          fontFamily: 'Inter',
          fontSize: 64.0,
          textColorHex: '#FF7A00',
        ),
      );

      final originalProject = Project(
        id: 'p_roundtrip',
        name: 'Full Serializer Test',
        createdAt: DateTime(2026, 10, 11, 12, 0),
        updatedAt: DateTime(2026, 10, 11, 12, 30),
        canvas: CanvasFormat.portrait9_16,
        tracks: [
          Track(
            id: 't1',
            name: 'Video Track',
            type: TrackType.video,
            orderIndex: 0,
            clips: [clip],
          ),
          Track(
            id: 't2',
            name: 'Text Track',
            type: TrackType.text,
            orderIndex: 1,
            clips: [textClip],
          ),
        ],
        exportPreferences: const ExportPreferences(
          resolutionName: '1080p',
          bitrateMbps: 16.0,
          videoCodec: 'H264',
        ),
      );

      final jsonString = ProjectSerializer.serialize(originalProject);
      expect(jsonString, contains('"p_roundtrip"'));
      expect(jsonString, contains('"RangYantra Studio"'));
      expect(jsonString, contains('"Sunset Shot"'));
      expect(jsonString, contains('"vignette"'));

      final restoredProject = ProjectSerializer.deserialize(jsonString);

      expect(restoredProject.id, equals(originalProject.id));
      expect(restoredProject.name, equals(originalProject.name));
      expect(restoredProject.tracks.length, equals(2));

      final restoredClip = restoredProject.tracks[0].clips[0];
      expect(restoredClip.id, equals('c1'));
      expect(restoredClip.speed, equals(1.5));
      expect(restoredClip.volume, equals(0.8));
      expect(restoredClip.transform.rotationDegrees, equals(15.0));
      expect(restoredClip.colorGrading.saturation, equals(1.3));
      expect(restoredClip.effects.first.type, equals(EffectType.vignette));
      expect(restoredClip.transitionIn?.type, equals(TransitionType.crossDissolve));

      final restoredText = restoredProject.tracks[1].clips[0];
      expect(restoredText.textProperties?.text, equals('RangYantra Studio'));
      expect(restoredText.textProperties?.textColorHex, equals('#FF7A00'));
    });

    test('Schema validation throws on missing ID', () {
      expect(
        () => ProjectSerializer.deserialize('{"name": "No ID"}'),
        throwsA(isA<FormatException>()),
      );
    });
  });
}
