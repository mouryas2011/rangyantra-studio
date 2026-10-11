import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/constants/app_colors.dart';

enum LogoVariant {
  primary,
  compact,
  dark,
  light,
  monochrome,
}

/// Dynamic RangYantra Studio logo widget with vector SVG and custom painter fallback.
class AppLogo extends StatelessWidget {
  final double size;
  final LogoVariant variant;
  final bool showWordmark;

  const AppLogo({
    super.key,
    this.size = 48.0,
    this.variant = LogoVariant.compact,
    this.showWordmark = false,
  });

  @override
  Widget build(BuildContext context) {
    final assetPath = _getAssetPath();

    return SvgPicture.asset(
      assetPath,
      width: showWordmark ? size * 3.125 : size,
      height: size,
      placeholderBuilder: (context) => _buildFallback(context),
    );
  }

  String _getAssetPath() {
    switch (variant) {
      case LogoVariant.primary:
        return 'assets/branding/logo_primary.svg';
      case LogoVariant.compact:
        return 'assets/branding/logo_compact.svg';
      case LogoVariant.dark:
        return 'assets/branding/logo_dark.svg';
      case LogoVariant.light:
        return 'assets/branding/logo_light.svg';
      case LogoVariant.monochrome:
        return 'assets/branding/logo_monochrome.svg';
    }
  }

  Widget _buildFallback(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.surfaceElevated,
        borderRadius: BorderRadius.circular(size * 0.22),
        border: Border.all(color: AppColors.border),
      ),
      child: Center(
        child: Icon(
          Icons.movie_creation_outlined,
          color: AppColors.primarySaffron,
          size: size * 0.5,
        ),
      ),
    );
  }
}
