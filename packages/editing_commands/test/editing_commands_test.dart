import 'package:flutter_test/flutter_test.dart';
import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';
import 'package:editing_commands/editing_commands.dart';

void main() {
  late Project baseProject;
  late Clip baseClip;

  setUp(() {
    baseClip = Clip(
      id: 'clip_orig',
      trackId: 'track_v1',
      name: 'Main Video',
      mediaType: MediaType.video,
      timelineStartUs: 0,
      timelineDurationUs: 10000000, // 10s
      sourceInUs: 0,
      sourceOutUs: 10000000,
      speed: 1.0,
      volume: 1.0,
    );

    baseProject = Project(
      id: 'p_edit',
      name: 'Editing Test Project',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      canvas: CanvasFormat.portrait9_16,
      tracks: [
        Track(
          id: 'track_v1',
          name: 'Video 1',
          type: TrackType.video,
          orderIndex: 0,
          clips: [baseClip],
        ),
        Track(
          id: 'track_v2',
          name: 'Video 2 (Overlay)',
          type: TrackType.video,
          orderIndex: 1,
          clips: [],
        ),
      ],
    );
  });

  group('Editing Commands Unit Tests', () {
    test('SplitClipCommand divides clip accurately and undoes cleanly', () {
      final controller = TimelineController(project: baseProject);
      expect(controller.project.tracks[0].clips.length, equals(1));

      // Split at 4.0s (4,000,000 us)
      final splitCmd = SplitClipCommand(
        clipId: 'clip_orig',
        splitTimeUs: 4000000,
        newClipId: 'clip_split_part2',
      );

      controller.execute(splitCmd);

      final clipsAfterSplit = controller.project.tracks[0].clips;
      expect(clipsAfterSplit.length, equals(2));

      final clipA = clipsAfterSplit[0];
      final clipB = clipsAfterSplit[1];

      // Clip A checks
      expect(clipA.id, equals('clip_orig'));
      expect(clipA.timelineStartUs, equals(0));
      expect(clipA.timelineDurationUs, equals(4000000));
      expect(clipA.sourceInUs, equals(0));
      expect(clipA.sourceOutUs, equals(4000000));

      // Clip B checks
      expect(clipB.id, equals('clip_split_part2'));
      expect(clipB.timelineStartUs, equals(4000000));
      expect(clipB.timelineDurationUs, equals(6000000));
      expect(clipB.sourceInUs, equals(4000000));
      expect(clipB.sourceOutUs, equals(10000000));

      // Undo verification
      expect(controller.canUndo, isTrue);
      controller.undo();

      final clipsAfterUndo = controller.project.tracks[0].clips;
      expect(clipsAfterUndo.length, equals(1));
      expect(clipsAfterUndo[0].id, equals('clip_orig'));
      expect(clipsAfterUndo[0].timelineDurationUs, equals(10000000));
    });

    test('TrimClipCommand head and tail trims', () {
      final controller = TimelineController(project: baseProject);

      // Trim In to 2s
      final trimIn = TrimClipCommand(
        clipId: 'clip_orig',
        edge: TrimEdge.inPoint,
        newBoundaryTimelineUs: 2000000,
      );
      controller.execute(trimIn);

      var clip = controller.project.tracks[0].clips[0];
      expect(clip.timelineStartUs, equals(2000000));
      expect(clip.timelineDurationUs, equals(8000000));
      expect(clip.sourceInUs, equals(2000000));

      // Trim Out to 7s
      final trimOut = TrimClipCommand(
        clipId: 'clip_orig',
        edge: TrimEdge.outPoint,
        newBoundaryTimelineUs: 7000000,
      );
      controller.execute(trimOut);

      clip = controller.project.tracks[0].clips[0];
      expect(clip.timelineStartUs, equals(2000000));
      expect(clip.timelineDurationUs, equals(5000000));
      expect(clip.timelineEndUs, equals(7000000));

      // Undo both
      controller.undo(); // undo trimOut
      clip = controller.project.tracks[0].clips[0];
      expect(clip.timelineDurationUs, equals(8000000));

      controller.undo(); // undo trimIn
      clip = controller.project.tracks[0].clips[0];
      expect(clip.timelineStartUs, equals(0));
      expect(clip.timelineDurationUs, equals(10000000));
    });

    test('DeleteClipCommand and DuplicateClipCommand', () {
      final controller = TimelineController(project: baseProject);

      // Duplicate
      final dupCmd = DuplicateClipCommand(
        clipId: 'clip_orig',
        newClipId: 'clip_copy_1',
      );
      controller.execute(dupCmd);

      expect(controller.project.tracks[0].clips.length, equals(2));
      final dupClip = controller.project.tracks[0].clips[1];
      expect(dupClip.id, equals('clip_copy_1'));
      expect(dupClip.timelineStartUs, equals(10000000)); // Adjacent placement

      // Delete the copy
      final delCmd = DeleteClipCommand(clipId: 'clip_copy_1');
      controller.execute(delCmd);
      expect(controller.project.tracks[0].clips.length, equals(1));

      // Undo deletion
      controller.undo();
      expect(controller.project.tracks[0].clips.length, equals(2));

      // Undo duplicate
      controller.undo();
      expect(controller.project.tracks[0].clips.length, equals(1));
    });

    test('MoveClipCommand across tracks', () {
      final controller = TimelineController(project: baseProject);

      final moveCmd = MoveClipCommand(
        clipId: 'clip_orig',
        newStartTimelineUs: 1500000,
        targetTrackId: 'track_v2',
      );
      controller.execute(moveCmd);

      expect(controller.project.tracks[0].clips.isEmpty, isTrue);
      expect(controller.project.tracks[1].clips.length, equals(1));
      expect(controller.project.tracks[1].clips[0].timelineStartUs, equals(1500000));
      expect(controller.project.tracks[1].clips[0].trackId, equals('track_v2'));

      // Undo move
      controller.undo();
      expect(controller.project.tracks[0].clips.length, equals(1));
      expect(controller.project.tracks[1].clips.isEmpty, isTrue);
      expect(controller.project.tracks[0].clips[0].timelineStartUs, equals(0));
    });

    test('SpeedClipCommand calculates duration and undoes', () {
      final controller = TimelineController(project: baseProject);

      // Set 2.0x speed: 10s source becomes 5s timeline
      final speedCmd = SpeedClipCommand(clipId: 'clip_orig', newSpeed: 2.0);
      controller.execute(speedCmd);

      var clip = controller.project.tracks[0].clips[0];
      expect(clip.speed, equals(2.0));
      expect(clip.timelineDurationUs, equals(5000000));

      controller.undo();
      clip = controller.project.tracks[0].clips[0];
      expect(clip.speed, equals(1.0));
      expect(clip.timelineDurationUs, equals(10000000));
    });

    test('ColorGradingCommand updates and restores color grading', () {
      final controller = TimelineController(project: baseProject);

      const grading = ColorGradingProperties(
        exposure: 0.5,
        contrast: 1.2,
        temperature: 20.0,
      );
      controller.execute(ColorGradingCommand(clipId: 'clip_orig', newGrading: grading));

      var clip = controller.project.tracks[0].clips[0];
      expect(clip.colorGrading.exposure, equals(0.5));
      expect(clip.colorGrading.contrast, equals(1.2));
      expect(clip.colorGrading.temperature, equals(20.0));

      controller.undo();
      clip = controller.project.tracks[0].clips[0];
      expect(clip.colorGrading.exposure, equals(0.0));
      expect(clip.colorGrading.contrast, equals(1.0));
    });
  });
}
