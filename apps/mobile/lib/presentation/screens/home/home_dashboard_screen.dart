import 'package:flutter/material.dart';
import 'package:project_model/project_model.dart';
import 'package:uuid/uuid.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/database/project_record.dart';
import '../../../data/repositories/project_repository.dart';
import '../../../data/services/media_import_service.dart';
import '../../widgets/app_logo.dart';
import '../editor/editor_workspace_screen.dart';
import '../ai_studio/ai_studio_screen.dart';
import '../templates/templates_screen.dart';
import '../settings/settings_screen.dart';
import 'widgets/empty_projects_view.dart';
import 'widgets/new_project_modal.dart';
import 'widgets/project_card.dart';

/// Primary application dashboard displaying real projects, search, media import, and studio sections.
class HomeDashboardScreen extends StatefulWidget {
  final ProjectRepository? repository;
  final MediaImportService? importService;

  const HomeDashboardScreen({
    super.key,
    this.repository,
    this.importService,
  });

  @override
  State<HomeDashboardScreen> createState() => _HomeDashboardScreenState();
}

class _HomeDashboardScreenState extends State<HomeDashboardScreen> {
  late final ProjectRepository _repository;
  late final MediaImportService _importService;

  int _selectedNavigationIndex = 0;
  final TextEditingController _searchController = TextEditingController();

  List<ProjectRecord> _projects = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _repository = widget.repository ?? ProjectRepository();
    _importService = widget.importService ?? MediaImportService();
    _loadProjects();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadProjects({String? query}) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final records = await _repository.getRecentProjects(query: query);
      if (mounted) {
        setState(() {
          _projects = records;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Failed to load projects: $e';
          _isLoading = false;
        });
      }
    }
  }

  void _onSearchChanged(String query) {
    _loadProjects(query: query);
  }

  void _openNewProjectModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => NewProjectModal(
        onProjectCreated: (newProj) async {
          await _repository.saveProject(newProj);
          await _loadProjects();
          if (mounted) {
            _navigateToEditor(newProj);
          }
        },
      ),
    );
  }

  Future<void> _handleImportMedia() async {
    final mediaItems = await _importService.pickAnyMedia();
    if (mediaItems.isEmpty) return;

    // Create a new project containing these imported media items
    final newId = const Uuid().v4();
    final firstItem = mediaItems.first;
    final projectName = 'Imported: ${firstItem.name}';

    // Auto-detect aspect ratio from first video if available
    CanvasFormat canvas = CanvasFormat.portrait9_16;
    if (firstItem.metadata.width != null && firstItem.metadata.height != null) {
      final w = firstItem.metadata.width!;
      final h = firstItem.metadata.height!;
      if (w > h) {
        canvas = CanvasFormat.landscape16_9;
      } else if (w == h) {
        canvas = CanvasFormat.square1_1;
      }
    }

    final newProject = Project.create(
      id: newId,
      name: projectName,
      canvas: canvas,
    );

    // Place media items on video track
    final trackId = newProject.tracks.first.id;
    int currentTimelineStartUs = 0;
    final clips = <Clip>[];

    for (final item in mediaItems) {
      final durUs = item.metadata.durationMicroseconds ?? 5000000;
      clips.add(
        Clip(
          id: const Uuid().v4(),
          trackId: trackId,
          name: item.name,
          mediaPath: item.path,
          mediaType: item.mediaType,
          timelineStartUs: currentTimelineStartUs,
          timelineDurationUs: durUs,
          sourceInUs: 0,
          sourceOutUs: durUs,
        ),
      );
      currentTimelineStartUs += durUs;
    }

    final updatedTracks = List<Track>.from(newProject.tracks);
    updatedTracks[0] = updatedTracks[0].copyWith(clips: clips);

    final projectWithClips = newProject.copyWith(tracks: updatedTracks);
    await _repository.saveProject(projectWithClips);
    await _loadProjects();

    if (mounted) {
      _navigateToEditor(projectWithClips);
    }
  }

  Future<void> _navigateToEditor(Project project) async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EditorWorkspaceScreen(
          initialProject: project,
          repository: _repository,
        ),
      ),
    );
    // Reload projects when returning from editor
    _loadProjects();
  }

  Future<void> _openExistingProject(String id) async {
    try {
      final project = await _repository.loadProject(id);
      if (mounted) {
        _navigateToEditor(project);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open project: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  Future<void> _showRenameDialog(ProjectRecord record) async {
    final controller = TextEditingController(text: record.name);
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename Project', style: AppTypography.h2),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: AppColors.primaryText),
          decoration: const InputDecoration(labelText: 'New Project Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Rename'),
          ),
        ],
      ),
    );

    if (confirmed == true && controller.text.trim().isNotEmpty) {
      await _repository.renameProject(record.id, controller.text.trim());
      _loadProjects();
    }
  }

  Future<void> _handleDuplicate(ProjectRecord record) async {
    await _repository.duplicateProject(record.id, '${record.name} (Copy)');
    _loadProjects();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Duplicated "${record.name}"'),
          backgroundColor: AppColors.surfaceElevated,
        ),
      );
    }
  }

  Future<void> _showDeleteDialog(ProjectRecord record) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Project?', style: AppTypography.h2),
        content: Text(
          'Are you sure you want to delete "${record.name}"? This action cannot be undone.',
          style: AppTypography.bodySecondary,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger),
            child: const Text('Delete Project'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _repository.deleteProject(record.id);
      _loadProjects();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Deleted "${record.name}"'),
            backgroundColor: AppColors.surfaceElevated,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _buildCurrentScreenContent(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedNavigationIndex,
        onTap: (index) {
          setState(() {
            _selectedNavigationIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_outlined),
            activeIcon: Icon(Icons.folder),
            label: 'Projects',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome_outlined),
            activeIcon: Icon(Icons.auto_awesome),
            label: 'AI Studio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.view_quilt_outlined),
            activeIcon: Icon(Icons.view_quilt),
            label: 'Templates',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings_outlined),
            activeIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildCurrentScreenContent() {
    switch (_selectedNavigationIndex) {
      case 0: // Home
      case 1: // Projects
        return _buildProjectsDashboard();
      case 2: // AI Studio
        return const AiStudioScreen();
      case 3: // Templates
        return TemplatesScreen(
          onTemplateSelected: (templateProject) async {
            await _repository.saveProject(templateProject);
            _navigateToEditor(templateProject);
          },
        );
      case 4: // Settings
        return SettingsScreen(repository: _repository);
      default:
        return _buildProjectsDashboard();
    }
  }

  Widget _buildProjectsDashboard() {
    return Column(
      children: [
        // Top App Header
        _buildAppHeader(),

        // Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search projects by name...',
              prefixIcon: const Icon(Icons.search, color: AppColors.secondaryText),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, size: 18),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
            ),
          ),
        ),

        // Quick Action Row
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _openNewProjectModal,
                  icon: const Icon(Icons.add_rounded, size: 20),
                  label: const Text('New Project'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primarySaffron,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _handleImportMedia,
                  icon: const Icon(Icons.file_upload_outlined, size: 18),
                  label: const Text('Import Media'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 8),

        // Section Title
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Projects (${_projects.length})',
                style: AppTypography.h3,
              ),
              if (_isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primarySaffron),
                ),
            ],
          ),
        ),

        // Projects List / Empty State
        Expanded(
          child: _buildProjectsList(),
        ),
      ],
    );
  }

  Widget _buildAppHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          const AppLogo(size: 38, variant: LogoVariant.compact),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'RANG',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: AppColors.primaryText,
                      ),
                    ),
                    const Text(
                      'YANTRA',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                        color: AppColors.primarySaffron,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: AppColors.electricCyan.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(3),
                        border: Border.all(
                          color: AppColors.electricCyan.withValues(alpha: 0.4),
                          width: 0.8,
                        ),
                      ),
                      child: const Text(
                        'STUDIO',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.2,
                          color: AppColors.electricCyan,
                        ),
                      ),
                    ),
                  ],
                ),
                const Text(
                  'रंगयंत्र स्टूडियो • From Imagination to Cinema',
                  style: TextStyle(fontSize: 11, color: AppColors.secondaryText),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppColors.secondaryText),
            tooltip: 'Refresh',
            onPressed: () => _loadProjects(query: _searchController.text),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectsList() {
    if (_isLoading && _projects.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primarySaffron),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AppColors.danger, size: 40),
            const SizedBox(height: 8),
            Text(_errorMessage!, style: AppTypography.bodySecondary),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => _loadProjects(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_projects.isEmpty) {
      return EmptyProjectsView(
        onNewProject: _openNewProjectModal,
        onImportMedia: _handleImportMedia,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      itemCount: _projects.length,
      itemBuilder: (context, index) {
        final record = _projects[index];
        return ProjectCard(
          project: record,
          onTap: () => _openExistingProject(record.id),
          onRename: () => _showRenameDialog(record),
          onDuplicate: () => _handleDuplicate(record),
          onDelete: () => _showDeleteDialog(record),
        );
      },
    );
  }
}
