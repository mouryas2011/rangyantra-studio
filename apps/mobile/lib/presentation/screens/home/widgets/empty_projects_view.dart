import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// Clean empty projects placeholder encouraging the user to create or import media.
class EmptyProjectsView extends StatelessWidget {
  final VoidCallback onNewProject;
  final VoidCallback onImportMedia;

  const EmptyProjectsView({
    super.key,
    required this.onNewProject,
    required this.onImportMedia,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: AppColors.surfaceElevated,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primarySaffron.withValues(alpha: 0.08),
                    blurRadius: 28,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Center(
                child: Icon(
                  Icons.video_library_outlined,
                  size: 46,
                  color: AppColors.primarySaffron,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text('No Projects Yet', style: AppTypography.h1),
            const SizedBox(height: 8),
            const Text(
              'Your creative studio is ready. Create a project from scratch or import videos from your device to begin editing.',
              style: AppTypography.bodySecondary,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: onNewProject,
                  icon: const Icon(Icons.add, size: 20),
                  label: const Text('New Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySaffron,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  onPressed: onImportMedia,
                  icon: const Icon(Icons.file_upload_outlined, size: 20),
                  label: const Text('Import Media'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
