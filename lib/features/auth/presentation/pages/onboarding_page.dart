import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:pockettrack/features/auth/presentation/pages/login_page.dart';
import 'package:pockettrack/l10n/app_localizations.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  List<Map<String, String>> _getOnboardingData(AppLocalizations l10n) => [
    {
      "title": l10n.onboarding1Title,
      "desc": l10n.onboarding1Desc,
      "icon": "wallet"
    },
    {
      "title": l10n.onboarding2Title,
      "desc": l10n.onboarding2Desc,
      "icon": "chart"
    },
    {
      "title": l10n.onboarding3Title,
      "desc": l10n.onboarding3Desc,
      "icon": "report"
    },
  ];

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_onboarding_completed', true);
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginPage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final onboardingData = _getOnboardingData(l10n);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (value) => setState(() => _currentPage = value),
                itemCount: onboardingData.length,
                itemBuilder: (context, index) => _buildPageContent(index, onboardingData),
              ),
            ),
            _buildBottomSection(l10n, onboardingData),
          ],
        ),
      ),
    );
  }

  Widget _buildPageContent(int index, List<Map<String, String>> onboardingData) {
    IconData iconData;
    switch (onboardingData[index]['icon']) {
      case 'wallet': iconData = Icons.account_balance_wallet_outlined; break;
      case 'chart': iconData = Icons.pie_chart_outline_rounded; break;
      case 'report': iconData = Icons.description_outlined; break;
      default: iconData = Icons.help_outline;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 160, height: 160,
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDFA),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, size: 64, color: const Color(0xFF0D9488)),
          ),
          const SizedBox(height: 60),
          Text(
            onboardingData[index]['title']!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1E293B)),
          ),
          const SizedBox(height: 16),
          Text(
            onboardingData[index]['desc']!,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomSection(AppLocalizations l10n, List<Map<String, String>> onboardingData) {
    bool isLastPage = _currentPage == onboardingData.length - 1;
    
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              onboardingData.length,
              (index) => _buildDot(index),
            ),
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              if (isLastPage) {
                _completeOnboarding();
              } else {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0D9488),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 60),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 0,
            ),
            child: Text(
              isLastPage ? l10n.getStarted : l10n.next,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),
          if (!isLastPage)
            TextButton(
              onPressed: _completeOnboarding,
              child: Text(
                l10n.skip,
                style: const TextStyle(color: Color(0xFF94A3B8), fontWeight: FontWeight.w600),
              ),
            )
          else
            const SizedBox(height: 48),
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    bool isActive = _currentPage == index;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.only(right: 8),
      height: 8,
      width: isActive ? 24 : 8,
      decoration: BoxDecoration(
        color: isActive ? const Color(0xFF0D9488) : const Color(0xFFE2E8F0),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
