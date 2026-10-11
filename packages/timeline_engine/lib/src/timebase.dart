import 'rational_time.dart';
import 'package:project_model/project_model.dart';

/// Utilities for snapping, spatial-to-temporal mapping, and boundary checking.
class Timebase {
  final int fps;

  const Timebase({this.fps = 30});

  /// Snaps a candidate [time] to nearest anchor point if within [thresholdMicroseconds].
  RationalTime snapToNearest(
    RationalTime time,
    List<RationalTime> anchorPoints, {
    int thresholdMicroseconds = 150000, // 150ms snap radius
  }) {
    if (anchorPoints.isEmpty) return time;

    RationalTime bestMatch = time;
    int minDiff = thresholdMicroseconds + 1;

    for (final anchor in anchorPoints) {
      final diff = (time.microseconds - anchor.microseconds).abs();
      if (diff <= thresholdMicroseconds && diff < minDiff) {
        minDiff = diff;
        bestMatch = anchor;
      }
    }

    return bestMatch;
  }

  /// Extracts all active snapping points in a project: clip starts, clip ends, and 0.
  List<RationalTime> getSnapPoints(Project project) {
    final points = <RationalTime>{
      RationalTime.zero(fps: fps),
    };

    for (final track in project.tracks) {
      for (final clip in track.clips) {
        points.add(RationalTime.fromMicroseconds(clip.timelineStartUs, fps: fps));
        points.add(RationalTime.fromMicroseconds(clip.timelineEndUs, fps: fps));
      }
    }

    final sorted = points.toList()..sort();
    return sorted;
  }

  /// Converts horizontal pixel offset on the timeline canvas to [RationalTime].
  RationalTime pixelsToTime(double pixels, double pixelsPerSecond) {
    if (pixels <= 0 || pixelsPerSecond <= 0) {
      return RationalTime.zero(fps: fps);
    }
    final seconds = pixels / pixelsPerSecond;
    return RationalTime.fromSeconds(seconds, fps: fps);
  }

  /// Converts [RationalTime] to horizontal pixel offset on the timeline canvas.
  double timeToPixels(RationalTime time, double pixelsPerSecond) {
    return time.seconds * pixelsPerSecond;
  }
}
