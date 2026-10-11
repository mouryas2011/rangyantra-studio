import 'package:flutter/material.dart';
import 'package:project_model/project_model.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// Screen offering original editable templates composed of real tracks and animation layers.
class TemplatesScreen extends StatelessWidget {
  final ValueChanged<Project> onTemplateSelected;

  const TemplatesScreen({
    super.key,
    required this.onTemplateSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Creative Templates'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          const Text(
            'Instant Editable Starters',
            style: AppTypography.h1,
          ),
          const SizedBox(height: 4),
          const Text(
            'Every template is built from real tracks, text clips, and keyframe timings ready for immediate customization.',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 16),

          _buildTemplateCard(
            context,
            title: '9:16 Kinetic Reels / Shorts Intro',
            format: CanvasFormat.portrait9_16,
            duration: '00:08.00',
            description: 'Fast-paced vertical sequence with kinetic title card, overlay track, and punchy transitions.',
            icon: Icons.flash_on_rounded,
            onApply: () => onTemplateSelected(_createKineticReelTemplate()),
          ),

          _buildTemplateCard(
            context,
            title: '16:9 Cinematic Vlog Opener',
            format: CanvasFormat.landscape16_9,
            duration: '00:15.00',
            description: 'Widescreen 24 FPS cinema project with letterbox overlay, warm color grade preset, and title credits.',
            icon: Icons.movie_filter_rounded,
            onApply: () => onTemplateSelected(_createCinematicVlogTemplate()),
          ),

          _buildTemplateCard(
            context,
            title: '1:1 Square Product Highlight',
            format: CanvasFormat.square1_1,
            duration: '00:10.00',
            description: 'Balanced square format suitable for social posts, promo showcases, and feature bullets.',
            icon: Icons.crop_square_rounded,
            onApply: () => onTemplateSelected(_createSquareProductTemplate()),
          ),

          _buildTemplateCard(
            context,
            title: '9:16 Festival & Celebration Greeting',
            format: CanvasFormat.portrait9_16,
            duration: '00:12.00',
            description: 'Golden-saffron festive greeting template with dual language Hindi-English typography and celebratory motion.',
            icon: Icons.celebration_rounded,
            onApply: () => onTemplateSelected(_createFestivalGreetingTemplate()),
          ),
        ],
      ),
    );
  }

  Widget _buildTemplateCard(
    BuildContext context, {
    required String title,
    required CanvasFormat format,
    required String duration,
    required String description,
    required IconData icon,
    required VoidCallback onApply,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Icon(icon, color: AppColors.primarySaffron, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTypography.h3),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                          decoration: BoxDecoration(
                            color: AppColors.electricCyan.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: Text(
                            format.id.replaceAll('_', ':'),
                            style: const TextStyle(fontSize: 10, color: AppColors.electricCyan, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${format.fps} FPS • $duration',
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description, style: AppTypography.bodySecondary),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onApply,
              icon: const Icon(Icons.file_copy_outlined, size: 16),
              label: const Text('Use This Template'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.surfaceCard,
                side: const BorderSide(color: AppColors.borderLight),
                foregroundColor: AppColors.primaryText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Project _createKineticReelTemplate() {
    final id = const Uuid().v4();
    final now = DateTime.now();

    final textTrack = Track(
      id: '${id}_track_text',
      name: 'Kinetic Titles',
      type: TrackType.text,
      orderIndex: 0,
      clips: [
        Clip(
          id: const Uuid().v4(),
          trackId: '${id}_track_text',
          name: 'Intro Hook',
          mediaType: MediaType.text,
          timelineStartUs: 0,
          timelineDurationUs: 2500000,
          sourceOutUs: 2500000,
          textProperties: const TextProperties(
            text: 'WATCH THIS NEXT',
            fontFamily: 'Inter',
            fontSize: 58,
            textColorHex: '#FF7A00',
            strokeColorHex: '#000000',
            strokeWidth: 2,
          ),
        ),
        Clip(
          id: const Uuid().v4(),
          trackId: '${id}_track_text',
          name: 'Main Headline',
          mediaType: MediaType.text,
          timelineStartUs: 2500000,
          timelineDurationUs: 5500000,
          sourceOutUs: 5500000,
          textProperties: const TextProperties(
            text: 'Cinematic Creation',
            fontFamily: 'Inter',
            fontSize: 48,
            textColorHex: '#00D9FF',
          ),
        ),
      ],
    );

    final videoTrack = Track(
      id: '${id}_track_video',
      name: 'Video Background',
      type: TrackType.video,
      orderIndex: 1,
      clips: [
        Clip(
          id: const Uuid().v4(),
          trackId: '${id}_track_video',
          name: 'Reel Canvas Background',
          mediaType: MediaType.colorSolid,
          timelineStartUs: 0,
          timelineDurationUs: 8000000,
          sourceOutUs: 8000000,
        ),
      ],
    );

    final audioTrack = Track(
      id: '${id}_track_audio',
      name: 'Audio Track',
      type: TrackType.audio,
      orderIndex: 2,
      clips: [],
    );

    return Project(
      id: id,
      name: 'Kinetic Reels Template',
      createdAt: now,
      updatedAt: now,
      canvas: CanvasFormat.portrait9_16,
      tracks: [videoTrack, textTrack, audioTrack],
    );
  }

  Project _createCinematicVlogTemplate() {
    final id = const Uuid().v4();
    final now = DateTime.now();

    final videoTrack = Track(
      id: '${id}_v1',
      name: 'Cinematic Footage',
      type: TrackType.video,
      orderIndex: 0,
      clips: [
        Clip(
          id: const Uuid().v4(),
          trackId: '${id}_v1',
          name: 'Opening Shot',
          mediaType: MediaType.colorSolid,
          timelineStartUs: 0,
          timelineDurationUs: 15000000,
          sourceOutUs: 15000000,
          colorGrading: const ColorGradingProperties(
            temperature: 15,
            contrast: 1.15,
            saturation: 1.1,
          ),
        ),
      ],
    );

    final titleTrack = Track(
      id: '${id}_title',
      name: 'Cinematic Credits',
      type: TrackType.text,
      orderIndex: 1,
      clips: [
        Clip(
          id: const Uuid().v4(),
          trackId: '${id}_title',
          name: 'Episode Title',
          mediaType: MediaType.text,
          timelineStartUs: 1000000,
          timelineDurationUs: 6000000,
          sourceOutUs: 6000000,
          textProperties: const TextProperties(
            text: 'A CINEMATIC JOURNEY',
            fontFamily: 'Inter',
            fontSize: 42,
            letterSpacing: 4.0,
          ),
        ),
      ],
    );

    return Project(
      id: id,
      name: 'Cinematic Vlog Template',
      createdAt: now,
      updatedAt: now,
      canvas: CanvasFormat.landscape16_9.copyWith(fps: 24),
      tracks: [videoTrack, titleTrack],
    );
  }

  Project _createSquareProductTemplate() {
    final id = const Uuid().v4();
    final now = DateTime.now();

    return Project(
      id: id,
      name: 'Square Product Showcase',
      createdAt: now,
      updatedAt: now,
      canvas: CanvasFormat.square1_1,
      tracks: [
        Track(
          id: '${id}_v',
          name: 'Product Video',
          type: TrackType.video,
          orderIndex: 0,
          clips: [
            Clip(
              id: const Uuid().v4(),
              trackId: '${id}_v',
              name: 'Product Hero',
              mediaType: MediaType.colorSolid,
              timelineStartUs: 0,
              timelineDurationUs: 10000000,
              sourceOutUs: 10000000,
            ),
          ],
        ),
        Track(
          id: '${id}_t',
          name: 'Features & CTA',
          type: TrackType.text,
          orderIndex: 1,
          clips: [
            Clip(
              id: const Uuid().v4(),
              trackId: '${id}_t',
              name: 'Feature Callout',
              mediaType: MediaType.text,
              timelineStartUs: 500000,
              timelineDurationUs: 5000000,
              sourceOutUs: 5000000,
              textProperties: const TextProperties(
                text: 'PREMIUM QUALITY',
                textColorHex: '#FFC857',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Project _createFestivalGreetingTemplate() {
    final id = const Uuid().v4();
    final now = DateTime.now();

    return Project(
      id: id,
      name: 'Festive Greeting Template',
      createdAt: now,
      updatedAt: now,
      canvas: CanvasFormat.portrait9_16,
      tracks: [
        Track(
          id: '${id}_v',
          name: 'Festive Background',
          type: TrackType.video,
          orderIndex: 0,
          clips: [
            Clip(
              id: const Uuid().v4(),
              trackId: '${id}_v',
              name: 'Golden Glow Ambient',
              mediaType: MediaType.colorSolid,
              timelineStartUs: 0,
              timelineDurationUs: 12000000,
              sourceOutUs: 12000000,
              colorGrading: const ColorGradingProperties(
                temperature: 25,
                exposure: 0.2,
                saturation: 1.25,
              ),
            ),
          ],
        ),
        Track(
          id: '${id}_t',
          name: 'Devanagari & English Typography',
          type: TrackType.text,
          orderIndex: 1,
          clips: [
            Clip(
              id: const Uuid().v4(),
              trackId: '${id}_t',
              name: 'Hindi Greetings',
              mediaType: MediaType.text,
              timelineStartUs: 0,
              timelineDurationUs: 6000000,
              sourceOutUs: 6000000,
              textProperties: const TextProperties(
                text: 'हार्दिक शुभकामनाएं',
                textColorHex: '#FF7A00',
                fontSize: 52,
              ),
            ),
            Clip(
              id: const Uuid().v4(),
              trackId: '${id}_t',
              name: 'English Greetings',
              mediaType: MediaType.text,
              timelineStartUs: 6000000,
              timelineDurationUs: 6000000,
              sourceOutUs: 6000000,
              textProperties: const TextProperties(
                text: 'Warm Wishes & Blessings',
                textColorHex: '#FFC857',
                fontSize: 42,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
