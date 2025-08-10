import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart'; // Impor Google Fonts
import 'package:hive_flutter/hive_flutter.dart';
import 'features/wallpaper/ui/home_page.dart';

const Color primaryColor = Color(0xFF8A8AFF);
const Color scaffoldBackgroundColor = Color(0xFFF8F7FF);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('wallpaper_settings');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Auto Wallpaper',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: scaffoldBackgroundColor,
        colorScheme: ColorScheme.fromSeed(seedColor: primaryColor),

        textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme),

        appBarTheme: const AppBarTheme(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 2.0,
          centerTitle: true,
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}