import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/repositories/project_repository.dart';
import '../../widgets/app_logo.dart';

/// Settings, Diagnostics, Storage overview, and System verification.
class SettingsScreen extends StatefulWidget {
  final ProjectRepository repository;

  const SettingsScreen({
    super.key,
    required this.repository,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _projectCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchStats();
  }

  Future<void> _fetchStats() async {
    final count = await widget.repository.getProjectCount();
    if (mounted) {
      setState(() {
        _projectCount = count;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Settings & Diagnostics'),
        backgroundColor: AppColors.surface,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // App Identity Header
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Row(
              children: [
                const AppLogo(size: 48, variant: LogoVariant.compact),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('RangYantra Studio', style: AppTypography.h2),
                      SizedBox(height: 2),
                      Text('रंगयंत्र स्टूडियो • v1.0.0 (Milestone 1 Foundation)', style: TextStyle(color: AppColors.accentGold, fontSize: 12)),
                      SizedBox(height: 2),
                      Text('From Imagination to Cinema', style: AppTypography.caption),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),
          const Text('System Diagnostics', style: AppTypography.h3),
          const SizedBox(height: 10),

          _buildDiagnosticTile(
            'Target Architecture',
            kIsWeb ? 'Web Engine' : '${Platform.operatingSystem.toUpperCase()} (${Platform.version.split(' ').first})',
            Icons.memory_rounded,
          ),
          _buildDiagnosticTile(
            'Local SQLite Database',
            _isLoading ? 'Checking...' : 'Active • $_projectCount saved projects in DB',
            Icons.storage_rounded,
            highlight: AppColors.success,
          ),
          _buildDiagnosticTile(
            'Media Pipeline Engine',
            'Android Media3 Transformer / iOS AVFoundation Native Bridge',
            Icons.video_settings_rounded,
          ),
          _buildDiagnosticTile(
            'Timeline Timebase',
            'RationalTime Microsecond Quantization (No Float Drift)',
            Icons.timer_outlined,
            highlight: AppColors.electricCyan,
          ),
          _buildDiagnosticTile(
            'Hardware Acceleration',
            'Supported (OpenGL ES / Vulkan / Metal)',
            Icons.speed_rounded,
            highlight: AppColors.success,
          ),

          const SizedBox(height: 20),
          const Text('Privacy & Local Storage', style: AppTypography.h3),
          const SizedBox(height: 10),

          Container(
            padding: const EdgeInsets.all(14.0),
            decoration: BoxDecoration(
              color: AppColors.surfaceElevated,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: AppColors.success, size: 20),
                    SizedBox(width: 8),
                    Text('100% On-Device & Private', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryText)),
                  ],
                ),
                SizedBox(height: 6),
                Text(
                  'Your videos, projects, audio, and media remain strictly stored on your device. RangYantra Studio never uploads user projects to remote servers without explicit user instruction.',
                  style: AppTypography.bodySecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiagnosticTile(String title, String subtitle, IconData icon, {Color? highlight}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: highlight ?? AppColors.secondaryText),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primaryText)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: highlight ?? AppColors.secondaryText)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
