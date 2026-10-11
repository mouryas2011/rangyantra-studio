import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_typography.dart';
import '../../../data/database/app_database.dart';
import '../../widgets/app_logo.dart';
import '../home/home_dashboard_screen.dart';

/// Premium animated splash screen meeting Section 4 brand requirements.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _sweepPosition;
  late Animation<double> _wordmarkOpacity;
  late Animation<double> _taglineOpacity;

  String? _initError;
  bool _initialized = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    // Sequence animations
    _logoScale = Tween<double>(begin: 0.82, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _sweepPosition = Tween<double>(begin: -1.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.25, 0.70, curve: Curves.easeInOut),
      ),
    );

    _wordmarkOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.50, 0.80, curve: Curves.easeIn),
      ),
    );

    _taglineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.72, 1.0, curve: Curves.easeIn),
      ),
    );

    _startAppInitialization();
  }

  Future<void> _startAppInitialization() async {
    _controller.forward();

    try {
      // Real database initialization and integrity check
      await AppDatabase.getInstance();
      _initialized = true;

      // When animation finishes and DB is ready, navigate
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted && _initialized) {
          _navigateToHome();
        }
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = 'Database initialization failed: $e';
        });
      }
    }
  }

  void _navigateToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (context, anim1, anim2) => const HomeDashboardScreen(),
        transitionsBuilder: (context, anim1, anim2, child) {
          return FadeTransition(opacity: anim1, child: child);
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_initError != null) {
      return _buildErrorRecoveryScreen();
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: GestureDetector(
        onTap: () {
          // Allow tap-to-skip for power users when initialized
          if (_initialized) _navigateToHome();
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Stack(
              children: [
                // Subtle radial background atmosphere
                Positioned.fill(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0, -0.1),
                        radius: 0.85,
                        colors: [
                          AppColors.surfaceElevated.withValues(alpha: 0.4),
                          AppColors.background,
                        ],
                      ),
                    ),
                  ),
                ),

                // Center Content Stack
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo Symbol with Light Sweep Mask
                      Opacity(
                        opacity: _logoOpacity.value,
                        child: Transform.scale(
                          scale: _logoScale.value,
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              const AppLogo(
                                size: 104,
                                variant: LogoVariant.compact,
                              ),

                              // Cyan light sweep sheen
                              ClipRRect(
                                borderRadius: BorderRadius.circular(24),
                                child: ShaderMask(
                                  shaderCallback: (bounds) {
                                    return LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      stops: [
                                        (_sweepPosition.value - 0.25).clamp(0.0, 1.0),
                                        _sweepPosition.value.clamp(0.0, 1.0),
                                        (_sweepPosition.value + 0.25).clamp(0.0, 1.0),
                                      ],
                                      colors: [
                                        Colors.transparent,
                                        AppColors.electricCyan.withValues(alpha: 0.35),
                                        Colors.transparent,
                                      ],
                                    ).createShader(bounds);
                                  },
                                  blendMode: BlendMode.srcATop,
                                  child: const SizedBox(
                                    width: 104,
                                    height: 104,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 28),

                      // Wordmark: RANGYANTRA STUDIO
                      Opacity(
                        opacity: _wordmarkOpacity.value,
                        child: Column(
                          children: [
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                const Text(
                                  'RANG',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3.5,
                                    color: AppColors.primaryText,
                                  ),
                                ),
                                const Text(
                                  'YANTRA',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 3.5,
                                    color: AppColors.primarySaffron,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.electricCyan.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: AppColors.electricCyan.withValues(alpha: 0.4),
                                    ),
                                  ),
                                  child: const Text(
                                    'STUDIO',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.5,
                                      color: AppColors.electricCyan,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 6),

                            // Hindi Brand Wordmark
                            const Text(
                              'रंगयंत्र स्टूडियो',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1.2,
                                color: AppColors.accentGold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Tagline: From Imagination to Cinema
                      Opacity(
                        opacity: _taglineOpacity.value,
                        child: Column(
                          children: [
                            Container(
                              width: 36,
                              height: 2,
                              decoration: BoxDecoration(
                                gradient: AppColors.saffronGradient,
                                borderRadius: BorderRadius.circular(1),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'FROM IMAGINATION TO CINEMA',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 2.2,
                                color: AppColors.secondaryText,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'कल्पना से सिनेमा तक',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w400,
                                letterSpacing: 1.5,
                                color: AppColors.mutedText,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildErrorRecoveryScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: AppColors.danger,
                size: 56,
              ),
              const SizedBox(height: 16),
              const Text(
                'Initialization Issue',
                style: AppTypography.h1,
              ),
              const SizedBox(height: 8),
              Text(
                _initError ?? 'An unknown error occurred during app startup.',
                style: AppTypography.bodySecondary,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _initError = null;
                  });
                  _startAppInitialization();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry Initialization'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
