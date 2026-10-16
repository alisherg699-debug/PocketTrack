import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pockettrack/features/auth/presentation/pages/pin_entry_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/features/auth/presentation/pages/login_page.dart';
import 'package:pockettrack/features/expense/presentation/pages/home_page.dart';
import 'package:pockettrack/features/auth/presentation/pages/onboarding_page.dart';
import 'package:pockettrack/features/auth/presentation/pages/language_selection_page.dart';
import 'package:pockettrack/core/l10n/app_localizations.dart';
import 'package:pockettrack/core/utils/secure_storage_helper.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _startNavigation();
  }

  Future<void> _startNavigation() async {
    // 2 soniya logoni ko'rsatib turamiz
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    // Kerakli holatlarni tekshiramiz
    final prefs = await SharedPreferences.getInstance();
    final bool isLanguageSelected = prefs.getBool('is_language_selected') ?? false;
    final bool isOnboardingDone = prefs.getBool('is_onboarding_completed') ?? false;
    
    final fbUser = FirebaseAuth.instance.currentUser;
    final pin = await SecureStorageHelper.read(key: 'user_pin');

    if (!mounted) return;

    if (!isLanguageSelected) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LanguageSelectionPage()),
      );
      return;
    }

    if (fbUser != null) {
      // Foydalanuvchi tizimda bo'lsa
      if (pin != null && pin.isNotEmpty) {
        // PIN-kod o'rnatilgan bo'lsa
        Navigator.pushReplacement(
          context, 
          MaterialPageRoute(builder: (context) => PinEntryPage(onVerified: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
          }))
        );
      } else {
        // PIN-kod yo'q bo'lsa
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomePage()));
      }
    } else {
      // Foydalanuvchi tizimga kirmagan bo'lsa
      if (isOnboardingDone) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginPage()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const OnboardingPage()));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // LOGOTIP
            Container(
              height: 80,
              width: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF0D9488),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Center(
                child: SvgPicture.asset(
                  'assets/iconssvg/cash.svg',
                  height: 32,
                  width: 32,
                  colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // ILOVA NOMI
            Text(
              "PocketTrack",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
                fontFamily: 'Geist',
              ),
            ),
            const SizedBox(height: 8),
            // SHIOR
            Text(
              AppLocalizations.of(context)?.appTagline ?? "Har bir tiyinni hisobga oling",
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white70 : const Color(0xFF64748B),
                fontFamily: 'Geist',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
