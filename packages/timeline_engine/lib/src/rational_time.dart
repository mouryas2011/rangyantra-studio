/// A frame-accurate rational time representation preventing floating-point timing drift.
class RationalTime implements Comparable<RationalTime> {
  final int frameNumber;
  final int fps;

  const RationalTime({
    required this.frameNumber,
    this.fps = 30,
  });

  const RationalTime.zero({this.fps = 30}) : frameNumber = 0;

  /// Creates a [RationalTime] from microseconds using integer frame quantization.
  factory RationalTime.fromMicroseconds(int microseconds, {int fps = 30}) {
    if (microseconds <= 0) return RationalTime(frameNumber: 0, fps: fps);
    // (us * fps) / 1,000,000 rounded to nearest frame
    final frames = ((microseconds * fps) + 500000) ~/ 1000000;
    return RationalTime(frameNumber: frames, fps: fps);
  }

  /// Creates a [RationalTime] from seconds.
  factory RationalTime.fromSeconds(double seconds, {int fps = 30}) {
    if (seconds <= 0) return RationalTime(frameNumber: 0, fps: fps);
    final frames = (seconds * fps).round();
    return RationalTime(frameNumber: frames, fps: fps);
  }

  /// Exact duration in microseconds.
  int get microseconds => (frameNumber * 1000000) ~/ fps;

  /// Time in seconds.
  double get seconds => frameNumber / fps;

  /// Formatted SMPTE timecode: HH:MM:SS:FF
  String toSMPTETimecode() {
    final totalSeconds = frameNumber ~/ fps;
    final f = frameNumber % fps;
    final s = totalSeconds % 60;
    final m = (totalSeconds ~/ 60) % 60;
    final h = totalSeconds ~/ 3600;

    final hh = h.toString().padLeft(2, '0');
    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    final ff = f.toString().padLeft(2, '0');

    return '$hh:$mm:$ss:$ff';
  }

  /// Concise display timecode: MM:SS.ff
  String toDisplayTime() {
    final totalSeconds = frameNumber ~/ fps;
    final f = frameNumber % fps;
    final s = totalSeconds % 60;
    final m = totalSeconds ~/ 60;

    final mm = m.toString().padLeft(2, '0');
    final ss = s.toString().padLeft(2, '0');
    final ff = f.toString().padLeft(2, '0');

    return '$mm:$ss.$ff';
  }

  RationalTime operator +(RationalTime other) {
    if (fps == other.fps) {
      return RationalTime(frameNumber: frameNumber + other.frameNumber, fps: fps);
    }
    // Resample to this timebase's fps
    final otherFramesInThisFps = ((other.frameNumber * fps) / other.fps).round();
    return RationalTime(frameNumber: frameNumber + otherFramesInThisFps, fps: fps);
  }

  RationalTime operator -(RationalTime other) {
    if (fps == other.fps) {
      final res = frameNumber - other.frameNumber;
      return RationalTime(frameNumber: res < 0 ? 0 : res, fps: fps);
    }
    final otherFramesInThisFps = ((other.frameNumber * fps) / other.fps).round();
    final res = frameNumber - otherFramesInThisFps;
    return RationalTime(frameNumber: res < 0 ? 0 : res, fps: fps);
  }

  bool operator <(RationalTime other) => microseconds < other.microseconds;
  bool operator <=(RationalTime other) => microseconds <= other.microseconds;
  bool operator >(RationalTime other) => microseconds > other.microseconds;
  bool operator >=(RationalTime other) => microseconds >= other.microseconds;

  @override
  int compareTo(RationalTime other) => microseconds.compareTo(other.microseconds);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RationalTime &&
          runtimeType == other.runtimeType &&
          microseconds == other.microseconds;

  @override
  int get hashCode => microseconds.hashCode;

  @override
  String toString() => '${toSMPTETimecode()} ($frameNumber f @ ${fps}fps)';
}
