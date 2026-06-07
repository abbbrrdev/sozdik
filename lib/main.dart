import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_strings.dart';
import 'core/di/injection.dart';
import 'features/home/presentation/home_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await configureDependencies();
  runApp(const SozdiTapApp());
}

class SozdiTapApp extends StatelessWidget {
  const SozdiTapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: _buildTheme(),
      home: const HomePage(),
    );
  }

  ThemeData _buildTheme() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.light(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      textTheme: GoogleFonts.nunitoTextTheme(base.textTheme).copyWith(
        bodyMedium: GoogleFonts.nunito(
          color: AppColors.textPrimary,
          fontSize: 15,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.nunito(
          fontSize: 20,
          fontWeight: FontWeight.w900,
          color: AppColors.textPrimary,
          letterSpacing: 2,
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: AppColors.accent,
        contentTextStyle: GoogleFonts.nunito(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: GoogleFonts.nunito(
            fontWeight: FontWeight.w700,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
