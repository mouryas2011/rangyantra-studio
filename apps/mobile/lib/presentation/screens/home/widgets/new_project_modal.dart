import 'package:flutter/material.dart';
import 'package:project_model/project_model.dart';
import 'package:uuid/uuid.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_typography.dart';

/// Modal bottom sheet for creating a new video editing project with aspect ratio & FPS selection.
class NewProjectModal extends StatefulWidget {
  final Future<void> Function(Project newProject) onProjectCreated;

  const NewProjectModal({
    super.key,
    required this.onProjectCreated,
  });

  @override
  State<NewProjectModal> createState() => _NewProjectModalState();
}

class _NewProjectModalState extends State<NewProjectModal> {
  final TextEditingController _nameController = TextEditingController();
  CanvasFormat _selectedCanvas = CanvasFormat.portrait9_16;
  int _selectedFps = 30;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Untitled Project';
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _handleCreate() async {
    final title = _nameController.text.trim();
    if (title.isEmpty) return;

    setState(() {
      _isCreating = true;
    });

    final project = Project.create(
      id: const Uuid().v4(),
      name: title,
      canvas: _selectedCanvas.copyWith(fps: _selectedFps),
    );

    await widget.onProjectCreated(project);

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(top: BorderSide(color: AppColors.border, width: 1.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const Text('New Project', style: AppTypography.h1),
          const SizedBox(height: 4),
          const Text(
            'Configure your canvas dimensions and cinema frame rate.',
            style: AppTypography.bodySecondary,
          ),
          const SizedBox(height: 18),

          // Project Title Input
          TextField(
            controller: _nameController,
            style: const TextStyle(color: AppColors.primaryText, fontSize: 15),
            decoration: const InputDecoration(
              labelText: 'Project Name',
              labelStyle: TextStyle(color: AppColors.secondaryText),
              prefixIcon: Icon(Icons.movie_filter_outlined, color: AppColors.primarySaffron),
            ),
          ),
          const SizedBox(height: 20),

          // Aspect Ratio Grid
          const Text('Canvas Aspect Ratio', style: AppTypography.h3),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildRatioCard(
                CanvasFormat.portrait9_16,
                '9:16',
                'Reels / Shorts',
                Icons.stay_current_portrait_rounded,
              ),
              const SizedBox(width: 8),
              _buildRatioCard(
                CanvasFormat.landscape16_9,
                '16:9',
                'YouTube / Cinema',
                Icons.stay_current_landscape_rounded,
              ),
              const SizedBox(width: 8),
              _buildRatioCard(
                CanvasFormat.square1_1,
                '1:1',
                'Square',
                Icons.crop_square_rounded,
              ),
              const SizedBox(width: 8),
              _buildRatioCard(
                CanvasFormat.portrait4_5,
                '4:5',
                'Vertical Feed',
                Icons.photo_size_select_small_rounded,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Frame Rate Selector
          const Text('Frame Rate (FPS)', style: AppTypography.h3),
          const SizedBox(height: 10),
          Row(
            children: [
              _buildFpsChip(24, '24 FPS (Cinematic)'),
              const SizedBox(width: 8),
              _buildFpsChip(30, '30 FPS (Standard)'),
              const SizedBox(width: 8),
              _buildFpsChip(60, '60 FPS (Ultra Smooth)'),
            ],
          ),
          const SizedBox(height: 26),

          // Action Buttons
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _isCreating ? null : _handleCreate,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primarySaffron,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: _isCreating
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text(
                      'Create & Open Editor',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRatioCard(CanvasFormat format, String ratioText, String subtitle, IconData icon) {
    final isSelected = _selectedCanvas.id == format.id;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedCanvas = format;
          });
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySaffron.withValues(alpha: 0.12) : AppColors.surface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primarySaffron : AppColors.border,
              width: isSelected ? 1.8 : 1.0,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: 24,
                color: isSelected ? AppColors.primarySaffron : AppColors.secondaryText,
              ),
              const SizedBox(height: 6),
              Text(
                ratioText,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: isSelected ? AppColors.primaryText : AppColors.secondaryText,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 9, color: AppColors.mutedText),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFpsChip(int fps, String label) {
    final isSelected = _selectedFps == fps;
    return Expanded(
      child: ChoiceChip(
        label: Center(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? Colors.white : AppColors.secondaryText,
            ),
          ),
        ),
        selected: isSelected,
        selectedColor: AppColors.surfaceCard,
        backgroundColor: AppColors.surface,
        side: BorderSide(
          color: isSelected ? AppColors.electricCyan : AppColors.border,
          width: isSelected ? 1.5 : 1.0,
        ),
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFps = fps;
            });
          }
        },
      ),
    );
  }
}
