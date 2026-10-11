import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/splash/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure status and navigation bar styling for immersive cinema editing
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF080B10),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const RangYantraApp());
}

/// Root widget for RangYantra Studio (रंगयंत्र स्टूडियो).
class RangYantraApp extends StatelessWidget {
  const RangYantraApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RangYantra Studio',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      home: const SplashScreen(),
    );
  }
}
