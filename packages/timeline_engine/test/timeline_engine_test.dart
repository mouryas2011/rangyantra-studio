import 'package:flutter_test/flutter_test.dart';
import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';

// Test command implementation for verifying undo/redo
class MockRenameProjectCommand implements Command {
  final String oldName;
  final String newName;

  MockRenameProjectCommand({required this.oldName, required this.newName});

  @override
  String get description => 'Rename Project to $newName';

  @override
  Project execute(Project project) {
    return project.copyWith(name: newName);
  }

  @override
  Project undo(Project project) {
    return project.copyWith(name: oldName);
  }
}

void main() {
  group('Timeline Engine Tests', () {
    test('RationalTime frame conversion and SMPTE formatting', () {
      final t1 = RationalTime(frameNumber: 30, fps: 30);
      expect(t1.seconds, equals(1.0));
      expect(t1.microseconds, equals(1000000));
      expect(t1.toSMPTETimecode(), equals('00:00:01:00'));

      final t2 = RationalTime.fromMicroseconds(2500000, fps: 30); // 2.5s = 75 frames
      expect(t2.frameNumber, equals(75));
      expect(t2.toSMPTETimecode(), equals('00:00:02:15'));

      final t3 = t1 + t2; // 30 + 75 = 105 frames = 3.5s
      expect(t3.frameNumber, equals(105));
      expect(t3.seconds, equals(3.5));
      expect(t3.toSMPTETimecode(), equals('00:00:03:15'));

      final t4 = t2 - t1; // 75 - 30 = 45 frames
      expect(t4.frameNumber, equals(45));
    });

    test('Timebase snapping to anchor points', () {
      const tb = Timebase(fps: 30);
      final anchors = [
        RationalTime.fromMicroseconds(0),
        RationalTime.fromMicroseconds(3000000), // 3s
        RationalTime.fromMicroseconds(6000000), // 6s
      ];

      // Time close to 3s (2.95s, within 150ms)
      final near = RationalTime.fromMicroseconds(2950000);
      final snapped = tb.snapToNearest(near, anchors, thresholdMicroseconds: 150000);
      expect(snapped.microseconds, equals(3000000));

      // Time far from any anchor (1.5s, >150ms from 0 and 3s)
      final far = RationalTime.fromMicroseconds(1500000);
      final unsnapped = tb.snapToNearest(far, anchors, thresholdMicroseconds: 150000);
      expect(unsnapped.microseconds, equals(1500000));
    });

    test('CommandHistory executes, undos, and redoes', () {
      final project = Project.create(id: 'test_p', name: 'Original Title');
      final history = CommandHistory();

      expect(history.canUndo, isFalse);
      expect(history.canRedo, isFalse);

      final cmd1 = MockRenameProjectCommand(
        oldName: 'Original Title',
        newName: 'Edited Title 1',
      );

      final p1 = history.execute(cmd1, project);
      expect(p1.name, equals('Edited Title 1'));
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);

      final pReverted = history.undo(p1);
      expect(pReverted.name, equals('Original Title'));
      expect(history.canUndo, isFalse);
      expect(history.canRedo, isTrue);

      final pRedone = history.redo(pReverted);
      expect(pRedone.name, equals('Edited Title 1'));
      expect(history.canUndo, isTrue);
      expect(history.canRedo, isFalse);
    });

    test('TimelineController seeking and state updates', () {
      final project = Project(
        id: 'p_ctrl',
        name: 'Controller Project',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        canvas: CanvasFormat.portrait9_16,
        tracks: [
          Track(
            id: 't1',
            name: 'Video',
            type: TrackType.video,
            orderIndex: 0,
            clips: [
              Clip(
                id: 'c1',
                trackId: 't1',
                name: 'Clip',
                mediaType: MediaType.video,
                timelineStartUs: 0,
                timelineDurationUs: 10000000, // 10s
                sourceOutUs: 10000000,
              )
            ],
          )
        ],
      );

      final controller = TimelineController(project: project);
      expect(controller.project.durationMicroseconds, equals(10000000));
      expect(controller.playhead.microseconds, equals(0));

      controller.seekToMicroseconds(4000000); // 4s
      expect(controller.playhead.seconds, equals(4.0));

      // Clamp past end
      controller.seekToMicroseconds(15000000);
      expect(controller.playhead.microseconds, equals(10000000));

      controller.selectClip('c1', 't1');
      expect(controller.selectedClip?.name, equals('Clip'));
    });
  });
}
