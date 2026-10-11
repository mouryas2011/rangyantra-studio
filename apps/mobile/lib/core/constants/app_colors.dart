import 'package:flutter/material.dart';

/// Design tokens and brand color palette for RangYantra Studio.
class AppColors {
  // Brand Backgrounds & Surfaces
  static const Color background = Color(0xFF080B10);
  static const Color surface = Color(0xFF111923);
  static const Color surfaceElevated = Color(0xFF172332);
  static const Color surfaceCard = Color(0xFF1A2636);

  // Brand Accents
  static const Color primarySaffron = Color(0xFFFF7A00);
  static const Color saffronLight = Color(0xFFFFA033);
  static const Color electricCyan = Color(0xFF00D9FF);
  static const Color cyanGlow = Color(0xFF70EFFF);
  static const Color accentGold = Color(0xFFFFC857);

  // Typography & Neutrals
  static const Color primaryText = Color(0xFFF5F7FA);
  static const Color secondaryText = Color(0xFFA9B4C2);
  static const Color mutedText = Color(0xFF6B7C92);

  // Structural Borders & Dividers
  static const Color border = Color(0xFF263341);
  static const Color borderLight = Color(0xFF37495D);

  // Semantic Feedback
  static const Color danger = Color(0xFFFF4D4D);
  static const Color success = Color(0xFF00E676);
  static const Color warning = Color(0xFFFFB300);
  static const Color info = Color(0xFF29B6F6);

  // Timeline Track Colors
  static const Color trackVideo = Color(0xFF1E3A5F);
  static const Color trackVideoClip = Color(0xFF0284C7);
  static const Color trackAudio = Color(0xFF1B4332);
  static const Color trackAudioClip = Color(0xFF10B981);
  static const Color trackText = Color(0xFF581C87);
  static const Color trackTextClip = Color(0xFF9333EA);

  // Linear Gradients
  static const LinearGradient saffronGradient = LinearGradient(
    colors: [accentGold, primarySaffron, Color(0xFFD94800)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cyanGradient = LinearGradient(
    colors: [Color(0xFF0088B3), electricCyan, cyanGlow],
    begin: Alignment.bottomLeft,
    end: Alignment.topRight,
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primarySaffron, accentGold, electricCyan],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
