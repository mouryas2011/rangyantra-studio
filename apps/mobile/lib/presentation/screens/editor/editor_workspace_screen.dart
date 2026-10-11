import 'dart:async';
import 'package:flutter/material.dart';
import 'package:project_model/project_model.dart';
import 'package:timeline_engine/timeline_engine.dart';
import 'package:editing_commands/editing_commands.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../data/services/media_import_service.dart';

/// Professional multitrack video editor workspace featuring live timeline, reversible operations, preview canvas, and autosave.
class EditorWorkspaceScreen extends StatefulWidget {
  final Project initialProject;
  final ProjectRepository repository;

  const EditorWorkspaceScreen({
    super.key,
    required this.initialProject,
    required this.repository,
  });

  @override
  State<EditorWorkspaceScreen> createState() => _EditorWorkspaceScreenState();
}

class _EditorWorkspaceScreenState extends State<EditorWorkspaceScreen> {
  late final TimelineController _controller;
  final MediaImportService _mediaImportService = MediaImportService();

  Timer? _playbackTimer;
  Timer? _autosaveDebounce;
  bool _isAutosaving = false;
  DateTime? _lastSavedAt;

  @override
  void initState() {
    super.initState();
    _controller = TimelineController(project: widget.initialProject);
    _controller.addListener(_onTimelineChanged);
    _lastSavedAt = widget.initialProject.updatedAt;
  }

  @override
  void dispose() {
    _playbackTimer?.cancel();
    _autosaveDebounce?.cancel();
    _controller.removeListener(_onTimelineChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onTimelineChanged() {
    // Synchronize play timer
    if (_controller.isPlaying && _playbackTimer == null) {
      _startPlaybackTicker();
    } else if (!_controller.isPlaying && _playbackTimer != null) {
      _playbackTimer?.cancel();
      _playbackTimer = null;
    }

    // Trigger debounced autosave
    _triggerAutosave();
    if (mounted) setState(() {});
  }

  void _startPlaybackTicker() {
    // 30 FPS playback ticker (approx 33ms)
    _playbackTimer = Timer.periodic(const Duration(milliseconds: 33), (timer) {
      final currentUs = _controller.playhead.microseconds;
      final maxUs = _controller.project.durationMicroseconds;

      if (maxUs == 0 || currentUs >= maxUs) {
        _controller.pause();
        return;
      }

      final nextUs = currentUs + 33333; // ~1 frame step
      _controller.seekToMicroseconds(nextUs > maxUs ? maxUs : nextUs);
    });
  }

  void _triggerAutosave() {
    _autosaveDebounce?.cancel();
    _autosaveDebounce = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      setState(() => _isAutosaving = true);
      try {
        await widget.repository.saveProject(_controller.project);
        if (mounted) {
          setState(() {
            _isAutosaving = false;
            _lastSavedAt = DateTime.now();
          });
        }
      } catch (_) {
        if (mounted) setState(() => _isAutosaving = false);
      }
    });
  }

  // --- Editing Operations ---

  void _splitSelectedClip() {
    final clip = _controller.selectedClip;
    if (clip == null) return;

    final playheadUs = _controller.playhead.microseconds;
    if (playheadUs <= clip.timelineStartUs || playheadUs >= clip.timelineEndUs) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Position the playhead inside the selected clip to split it.'),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
      return;
    }

    try {
      final cmd = SplitClipCommand(
        clipId: clip.id,
        splitTimeUs: playheadUs,
      );
      _controller.execute(cmd);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Split failed: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _trimClipIn() {
    final clip = _controller.selectedClip;
    if (clip == null) return;
    final playheadUs = _controller.playhead.microseconds;
    if (playheadUs <= clip.timelineStartUs || playheadUs >= clip.timelineEndUs - 100000) {
      return;
    }

    try {
      final cmd = TrimClipCommand(
        clipId: clip.id,
        edge: TrimEdge.inPoint,
        newBoundaryTimelineUs: playheadUs,
      );
      _controller.execute(cmd);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trim failed: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _trimClipOut() {
    final clip = _controller.selectedClip;
    if (clip == null) return;
    final playheadUs = _controller.playhead.microseconds;
    if (playheadUs <= clip.timelineStartUs + 100000 || playheadUs >= clip.timelineEndUs) {
      return;
    }

    try {
      final cmd = TrimClipCommand(
        clipId: clip.id,
        edge: TrimEdge.outPoint,
        newBoundaryTimelineUs: playheadUs,
      );
      _controller.execute(cmd);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Trim failed: $e'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _duplicateSelectedClip() {
    final clip = _controller.selectedClip;
    if (clip == null) return;
    _controller.execute(DuplicateClipCommand(clipId: clip.id));
  }

  void _deleteSelectedClip() {
    final clip = _controller.selectedClip;
    if (clip == null) return;
    _controller.execute(DeleteClipCommand(clipId: clip.id));
    _controller.selectClip(null, null);
  }

  void _showSpeedDialog() {
    final clip = _controller.selectedClip;
    if (clip == null) return;

    double tempSpeed = clip.speed;
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Clip Playback Speed', style: AppTypography.h2),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '${tempSpeed.toStringAsFixed(2)}x',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primarySaffron),
              ),
              const SizedBox(height: 12),
              Slider(
                value: tempSpeed,
                min: 0.25,
                max: 4.0,
                divisions: 15,
                activeColor: AppColors.primarySaffron,
                onChanged: (val) {
                  setDialogState(() {
                    tempSpeed = val;
                  });
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [0.5, 1.0, 1.5, 2.0].map((s) {
                  return TextButton(
                    onPressed: () => setDialogState(() => tempSpeed = s),
                    child: Text('${s}x'),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                _controller.execute(SpeedClipCommand(clipId: clip.id, newSpeed: tempSpeed));
                Navigator.of(context).pop();
              },
              child: const Text('Apply Speed'),
            ),
          ],
        ),
      ),
    );
  }

  void _showColorGradingSheet() {
    final clip = _controller.selectedClip;
    if (clip == null) return;

    var grading = clip.colorGrading;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.surfaceElevated,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Color Grading & Corrections', style: AppTypography.h2),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        grading = ColorGradingProperties.neutral;
                      });
                    },
                    child: const Text('Reset', style: TextStyle(color: AppColors.secondaryText)),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildSliderRow(
                'Exposure',
                grading.exposure,
                -2.0,
                2.0,
                (v) => setSheetState(() => grading = grading.copyWith(exposure: v)),
              ),
              _buildSliderRow(
                'Contrast',
                grading.contrast,
                0.0,
                2.0,
                (v) => setSheetState(() => grading = grading.copyWith(contrast: v)),
              ),
              _buildSliderRow(
                'Saturation',
                grading.saturation,
                0.0,
                2.0,
                (v) => setSheetState(() => grading = grading.copyWith(saturation: v)),
              ),
              _buildSliderRow(
                'Temperature',
                grading.temperature,
                -50.0,
                50.0,
                (v) => setSheetState(() => grading = grading.copyWith(temperature: v)),
              ),
              _buildSliderRow(
                'Tint',
                grading.tint,
                -50.0,
                50.0,
                (v) => setSheetState(() => grading = grading.copyWith(tint: v)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    _controller.execute(
                      ColorGradingCommand(clipId: clip.id, newGrading: grading),
                    );
                    Navigator.of(context).pop();
                  },
                  child: const Text('Apply Color Grade'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliderRow(String label, double val, double min, double max, ValueChanged<double> onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 86,
          child: Text(label, style: AppTypography.bodySecondary),
        ),
        Expanded(
          child: Slider(
            value: val,
            min: min,
            max: max,
            activeColor: AppColors.primarySaffron,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 44,
          child: Text(
            val.toStringAsFixed(2),
            style: AppTypography.caption.copyWith(color: AppColors.electricCyan),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }

  Future<void> _addMediaClip() async {
    final items = await _mediaImportService.pickAnyMedia(allowMultiple: false);
    if (items.isEmpty) return;

    final item = items.first;
    final durUs = item.metadata.durationMicroseconds ?? 5000000;
    final targetTrack = _controller.project.tracks.firstWhere(
      (t) => t.type == TrackType.video,
      orElse: () => _controller.project.tracks.first,
    );

    final newClip = Clip(
      id: const Uuid().v4(),
      trackId: targetTrack.id,
      name: item.name,
      mediaPath: item.path,
      mediaType: item.mediaType,
      timelineStartUs: targetTrack.durationUs,
      timelineDurationUs: durUs,
      sourceInUs: 0,
      sourceOutUs: durUs,
    );

    _controller.execute(AddClipCommand(trackId: targetTrack.id, clip: newClip));
  }

  void _addTitleClip() {
    final textTrack = _controller.project.tracks.firstWhere(
      (t) => t.type == TrackType.text,
      orElse: () => _controller.project.tracks[1],
    );

    final newClip = Clip(
      id: const Uuid().v4(),
      trackId: textTrack.id,
      name: 'Title Overlay',
      mediaType: MediaType.text,
      timelineStartUs: _controller.playhead.microseconds,
      timelineDurationUs: 3000000, // 3s
      sourceInUs: 0,
      sourceOutUs: 3000000,
      textProperties: const TextProperties(
        text: 'Cinema Title',
        fontFamily: 'Inter',
        fontSize: 54,
        textColorHex: '#FFFFFF',
        shadowColorHex: '#80000000',
      ),
    );

    _controller.execute(AddClipCommand(trackId: textTrack.id, clip: newClip));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Top App Bar
            _buildTopBar(),

            // Video Preview Canvas
            _buildPreviewArea(),

            // Timeline Transport Bar (Timecode & Playback Controls)
            _buildTransportControls(),

            // Multitrack Timeline Area
            Expanded(
              child: _buildTimelineArea(),
            ),

            // Bottom Editing Toolbar
            _buildEditingToolbar(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, size: 20),
            onPressed: () => Navigator.of(context).pop(),
            tooltip: 'Back to Projects',
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _controller.project.name,
                  style: AppTypography.h3,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    if (_isAutosaving)
                      const Row(
                        children: [
                          SizedBox(
                            width: 8,
                            height: 8,
                            child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.electricCyan),
                          ),
                          SizedBox(width: 4),
                          Text('Autosaving...', style: TextStyle(fontSize: 10, color: AppColors.electricCyan)),
                        ],
                      )
                    else if (_lastSavedAt != null)
                      Text(
                        'Autosaved • ${_controller.project.canvas.displayName.split(' ').first}',
                        style: const TextStyle(fontSize: 10, color: AppColors.mutedText),
                      ),
                  ],
                ),
              ],
            ),
          ),

          // Undo / Redo
          IconButton(
            icon: const Icon(Icons.undo_rounded, size: 20),
            color: _controller.canUndo ? AppColors.primaryText : AppColors.mutedText,
            onPressed: _controller.canUndo ? () => _controller.undo() : null,
            tooltip: _controller.undoDescription ?? 'Undo',
          ),
          IconButton(
            icon: const Icon(Icons.redo_rounded, size: 20),
            color: _controller.canRedo ? AppColors.primaryText : AppColors.mutedText,
            onPressed: _controller.canRedo ? () => _controller.redo() : null,
            tooltip: _controller.redoDescription ?? 'Redo',
          ),

          const SizedBox(width: 6),

          // Export Button CTA
          ElevatedButton.icon(
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Export Engine (${_controller.project.exportPreferences.resolutionName} @ ${_controller.project.canvas.fps}fps) configured for native pipeline render in Milestone 2.',
                  ),
                  backgroundColor: AppColors.surfaceElevated,
                ),
              );
            },
            icon: const Icon(Icons.file_download_outlined, size: 16),
            label: const Text('Export', style: TextStyle(fontSize: 12)),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primarySaffron,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewArea() {
    final canvas = _controller.project.canvas;
    final activeClip = _controller.selectedClip;

    return Container(
      height: 220,
      width: double.infinity,
      color: Colors.black,
      child: Center(
        child: AspectRatio(
          aspectRatio: canvas.aspectRatio,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              border: Border.all(color: AppColors.border),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Live Viewport Content
                if (activeClip != null)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          activeClip.mediaType == MediaType.text
                              ? Icons.title
                              : (activeClip.mediaType == MediaType.audio ? Icons.audiotrack : Icons.movie_creation_outlined),
                          size: 36,
                          color: AppColors.electricCyan,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          activeClip.textProperties?.text ?? activeClip.name,
                          style: TextStyle(
                            fontSize: activeClip.mediaType == MediaType.text ? 18 : 13,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (activeClip.colorGrading.isModified)
                          Container(
                            margin: const EdgeInsets.only(top: 6),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppColors.primarySaffron.withValues(alpha: 0.18),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text('Graded', style: TextStyle(fontSize: 9, color: AppColors.primarySaffron)),
                          ),
                      ],
                    ),
                  )
                else
                  const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.video_collection_outlined, size: 36, color: AppColors.mutedText),
                      SizedBox(height: 6),
                      Text('RangYantra Cinema Viewport', style: TextStyle(color: AppColors.mutedText, fontSize: 12)),
                    ],
                  ),

                // Aspect Ratio Watermark / Info
                Positioned(
                  top: 6,
                  left: 6,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(
                      '${canvas.id.replaceAll('_', ':')} • ${canvas.fps}fps',
                      style: const TextStyle(fontSize: 9, color: AppColors.secondaryText),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTransportControls() {
    final playheadCode = _controller.playhead.toSMPTETimecode();
    final totalTime = RationalTime.fromMicroseconds(
      _controller.project.durationMicroseconds,
      fps: _controller.project.canvas.fps,
    ).toSMPTETimecode();

    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 14.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border),
          bottom: BorderSide(color: AppColors.border),
        ),
      ),
      child: Row(
        children: [
          // SMPTE Timecode Readout
          Text(
            playheadCode,
            style: AppTypography.mono,
          ),
          Text(
            ' / $totalTime',
            style: const TextStyle(fontFamily: 'monospace', fontSize: 11, color: AppColors.secondaryText),
          ),

          const Spacer(),

          // Transport Buttons
          IconButton(
            icon: const Icon(Icons.skip_previous_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _controller.seekToMicroseconds(0),
            tooltip: 'Jump to Start',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_left_rounded, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              final prev = _controller.playhead.microseconds - 33333;
              _controller.seekToMicroseconds(prev < 0 ? 0 : prev);
            },
            tooltip: 'Previous Frame',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: Icon(
              _controller.isPlaying ? Icons.pause_circle_filled_rounded : Icons.play_circle_fill_rounded,
              size: 32,
              color: AppColors.primarySaffron,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: _controller.togglePlay,
            tooltip: _controller.isPlaying ? 'Pause' : 'Play',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.chevron_right_rounded, size: 22),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () {
              final next = _controller.playhead.microseconds + 33333;
              _controller.seekToMicroseconds(next);
            },
            tooltip: 'Next Frame',
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.skip_next_rounded, size: 20),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _controller.seekToMicroseconds(_controller.project.durationMicroseconds),
            tooltip: 'Jump to End',
          ),

          const Spacer(),

          // Zoom Controls
          IconButton(
            icon: const Icon(Icons.zoom_out, size: 18, color: AppColors.secondaryText),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _controller.setZoom(_controller.zoomPixelsPerSecond - 20),
          ),
          IconButton(
            icon: const Icon(Icons.zoom_in, size: 18, color: AppColors.secondaryText),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _controller.setZoom(_controller.zoomPixelsPerSecond + 20),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineArea() {
    final zoom = _controller.zoomPixelsPerSecond;
    final totalDurSec = (_controller.project.durationMicroseconds / 1000000).clamp(10.0, 3600.0);
    final timelineWidth = (totalDurSec * zoom).clamp(600.0, 10000.0);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SizedBox(
        width: timelineWidth,
        child: Stack(
          children: [
            // Track Lanes
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _controller.project.tracks.map((track) {
                return _buildTrackLane(track, zoom);
              }).toList(),
            ),

            // Red Playhead Scrubber Line
            Positioned(
              left: (_controller.playhead.seconds * zoom) - 7,
              top: 0,
              bottom: 0,
              width: 16,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onHorizontalDragUpdate: (details) {
                  final newPosSec = (_controller.playhead.seconds + (details.delta.dx / zoom));
                  _controller.seekToMicroseconds((newPosSec * 1000000).round());
                },
                child: Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    // Vertical Scrubber Line
                    Positioned(
                      top: 0,
                      bottom: 0,
                      left: 7,
                      width: 2,
                      child: Container(color: AppColors.primarySaffron),
                    ),
                    // Scrubber Knob
                    Positioned(
                      top: 0,
                      width: 14,
                      height: 14,
                      child: Container(
                        decoration: const BoxDecoration(
                          color: AppColors.primarySaffron,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackLane(Track track, double zoom) {
    Color trackColor;
    IconData trackIcon;

    switch (track.type) {
      case TrackType.video:
        trackColor = AppColors.trackVideoClip;
        trackIcon = Icons.video_collection;
        break;
      case TrackType.text:
        trackColor = AppColors.trackTextClip;
        trackIcon = Icons.title;
        break;
      case TrackType.audio:
        trackColor = AppColors.trackAudioClip;
        trackIcon = Icons.audiotrack;
        break;
      default:
        trackColor = AppColors.primarySaffron;
        trackIcon = Icons.layers;
    }

    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(vertical: 2.0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border.withValues(alpha: 0.5))),
      ),
      child: Stack(
        children: [
          // Track Name watermark
          Positioned(
            left: 8,
            top: 6,
            child: Row(
              children: [
                Icon(trackIcon, size: 12, color: AppColors.mutedText),
                const SizedBox(width: 4),
                Text(
                  track.name,
                  style: const TextStyle(fontSize: 10, color: AppColors.mutedText, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Render Clips in this track
          ...track.clips.map((clip) {
            final left = (clip.timelineStartUs / 1000000) * zoom;
            final width = ((clip.timelineDurationUs / 1000000) * zoom).clamp(16.0, 10000.0);
            final isSelected = clip.id == _controller.selectedClipId;

            return Positioned(
              left: left,
              top: 14,
              bottom: 4,
              width: width,
              child: GestureDetector(
                onTap: () {
                  _controller.selectClip(clip.id, track.id);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: trackColor.withValues(alpha: isSelected ? 0.95 : 0.65),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isSelected ? AppColors.electricCyan : AppColors.border,
                      width: isSelected ? 2.0 : 1.0,
                    ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.electricCyan.withValues(alpha: 0.3),
                              blurRadius: 6,
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(trackIcon, size: 14, color: Colors.white70),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          clip.name,
                          style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildEditingToolbar() {
    final hasSelection = _controller.selectedClip != null;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // Split Tool
            _buildToolButton(
              Icons.call_split_rounded,
              'Split',
              hasSelection ? _splitSelectedClip : null,
              accent: AppColors.primarySaffron,
            ),
            // Trim In
            _buildToolButton(
              Icons.chevron_right,
              'Trim In',
              hasSelection ? _trimClipIn : null,
            ),
            // Trim Out
            _buildToolButton(
              Icons.chevron_left,
              'Trim Out',
              hasSelection ? _trimClipOut : null,
            ),
            // Duplicate
            _buildToolButton(
              Icons.copy_rounded,
              'Duplicate',
              hasSelection ? _duplicateSelectedClip : null,
            ),
            // Speed
            _buildToolButton(
              Icons.speed_rounded,
              'Speed',
              hasSelection ? _showSpeedDialog : null,
            ),
            // Color Grading
            _buildToolButton(
              Icons.palette_outlined,
              'Color',
              hasSelection ? _showColorGradingSheet : null,
              accent: AppColors.electricCyan,
            ),
            // Delete
            _buildToolButton(
              Icons.delete_outline_rounded,
              'Delete',
              hasSelection ? _deleteSelectedClip : null,
              accent: AppColors.danger,
            ),

            const VerticalDivider(width: 16, indent: 12, endIndent: 12, color: AppColors.border),

            // Add Media
            _buildToolButton(
              Icons.add_photo_alternate_outlined,
              '+ Media',
              _addMediaClip,
              accent: AppColors.accentGold,
            ),
            // Add Title
            _buildToolButton(
              Icons.text_fields_rounded,
              '+ Title',
              _addTitleClip,
              accent: AppColors.accentGold,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolButton(IconData icon, String label, VoidCallback? onTap, {Color? accent}) {
    final isEnabled = onTap != null;
    final color = accent ?? (isEnabled ? AppColors.primaryText : AppColors.mutedText);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isEnabled ? AppColors.secondaryText : AppColors.mutedText,
                fontWeight: isEnabled ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
