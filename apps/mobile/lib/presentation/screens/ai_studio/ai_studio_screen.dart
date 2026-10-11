import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';

/// AI Studio screen with free-first design, local on-device models, and clear roadmap status.
class AiStudioScreen extends StatelessWidget {
  const AiStudioScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('AI Studio (Local & Free-First)'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // Banner
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.electricCyan.withValues(alpha: 0.15),
                  AppColors.primarySaffron.withValues(alpha: 0.10),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.electricCyan, size: 32),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('On-Device Intelligence', style: AppTypography.h3),
                      const SizedBox(height: 4),
                      Text(
                        'RangYantra Studio prioritizes offline, local AI models. No expensive cloud subscriptions or user video uploads required.',
                        style: AppTypography.bodySecondary.copyWith(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('Smart Editing Modules', style: AppTypography.h2),
          const SizedBox(height: 12),

          _buildFeatureCard(
            title: 'Automatic Captions & Subtitles',
            description: 'Speech recognition engine generating synchronized SRT captions in multiple Indian & international languages.',
            status: 'Roadmap Milestone 6',
            statusColor: AppColors.accentGold,
            icon: Icons.subtitles_rounded,
          ),
          _buildFeatureCard(
            title: 'Silence & Gap Removal',
            description: 'Fast audio threshold detection identifying dead air and pauses for rapid jump-cut assembly.',
            status: 'Roadmap Milestone 6',
            statusColor: AppColors.accentGold,
            icon: Icons.graphic_eq_rounded,
          ),
          _buildFeatureCard(
            title: 'Musical Beat & Rhythm Detection',
            description: 'Analyzes audio transients to suggest marker snaps for beat-synced video transitions.',
            status: 'Roadmap Milestone 6',
            statusColor: AppColors.accentGold,
            icon: Icons.music_note_rounded,
          ),
          _buildFeatureCard(
            title: 'Scene Change Detection',
            description: 'Visual difference analysis detecting shot transitions to automatically split uncut footage.',
            status: 'Roadmap Milestone 6',
            statusColor: AppColors.accentGold,
            icon: Icons.burst_mode_rounded,
          ),
          _buildFeatureCard(
            title: 'Subject Masking & Background Segmentation',
            description: 'On-device vision segmentation isolating human subjects for color isolation and motion effects.',
            status: 'Research Phase',
            statusColor: AppColors.mutedText,
            icon: Icons.person_search_rounded,
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required String description,
    required String status,
    required Color statusColor,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
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
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(title, style: AppTypography.h3),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(color: statusColor.withValues(alpha: 0.4), width: 0.8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(description, style: AppTypography.bodySecondary),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
