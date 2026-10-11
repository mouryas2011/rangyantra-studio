import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../data/database/project_record.dart';

/// Card displaying project preview, duration, resolution, and action menu.
class ProjectCard extends StatelessWidget {
  final ProjectRecord project;
  final VoidCallback onTap;
  final VoidCallback onRename;
  final VoidCallback onDuplicate;
  final VoidCallback onDelete;

  const ProjectCard({
    super.key,
    required this.project,
    required this.onTap,
    required this.onRename,
    required this.onDuplicate,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                // Aspect Ratio Thumbnail Box
                _buildThumbnailBox(),

                const SizedBox(width: 14),

                // Project Details
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        project.name,
                        style: AppTypography.h3,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          _buildBadge(
                            project.aspectRatioId.replaceAll('_', ':'),
                            AppColors.electricCyan,
                          ),
                          const SizedBox(width: 6),
                          _buildBadge(
                            '${project.fps} FPS',
                            AppColors.accentGold,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            project.formattedDuration,
                            style: AppTypography.caption,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${project.clipCount} clips • ${_formatRelativeTime(project.updatedAt)}',
                        style: AppTypography.caption.copyWith(color: AppColors.mutedText),
                      ),
                    ],
                  ),
                ),

                // Context Menu
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert, color: AppColors.secondaryText),
                  color: AppColors.surfaceCard,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: const BorderSide(color: AppColors.border),
                  ),
                  onSelected: (val) {
                    if (val == 'rename') onRename();
                    if (val == 'duplicate') onDuplicate();
                    if (val == 'delete') onDelete();
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'rename',
                      child: Row(
                        children: [
                          Icon(Icons.edit_outlined, size: 18, color: AppColors.primaryText),
                          SizedBox(width: 10),
                          Text('Rename', style: AppTypography.body),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'duplicate',
                      child: Row(
                        children: [
                          Icon(Icons.copy_outlined, size: 18, color: AppColors.primaryText),
                          SizedBox(width: 10),
                          Text('Duplicate', style: AppTypography.body),
                        ],
                      ),
                    ),
                    const PopupMenuDivider(),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline, size: 18, color: AppColors.danger),
                          SizedBox(width: 10),
                          Text('Delete', style: TextStyle(color: AppColors.danger, fontSize: 14)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnailBox() {
    final isPortrait = project.height > project.width;
    final isSquare = project.height == project.width;

    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Container(
          width: isSquare ? 42 : (isPortrait ? 28 : 50),
          height: isSquare ? 42 : (isPortrait ? 50 : 28),
          decoration: BoxDecoration(
            color: AppColors.surfaceElevated,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: AppColors.primarySaffron.withValues(alpha: 0.5)),
          ),
          child: const Center(
            child: Icon(
              Icons.play_arrow_rounded,
              size: 20,
              color: AppColors.primarySaffron,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 0.8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  String _formatRelativeTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
