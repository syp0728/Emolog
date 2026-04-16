import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'home_screen.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  Future<void> _completeOnboarding(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasSeenOnboarding', true);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      globalBackgroundColor: const Color(0xFFF5F5F5),
      // pages: [
      //   PageViewModel(
      //     title: "Record Your Emotions by Voice",
      //     body:
      //         "Speak about your day — AI will summarize and analyze your emotion.",
      //     image: Image.asset('lib/src/Emo.png', height: 250),
      //     decoration: _getPageDecoration(),
      //   ),
      //   PageViewModel(
      //     title: "See Your Emotions on the Calendar",
      //     body:
      //         "Track how your feelings change over time through a visual diary.",
      //     image: Image.asset('lib/src/Emo.png', height: 250),
      //     decoration: _getPageDecoration(),
      //   ),
      //   PageViewModel(
      //     title: "Set Emotion Goals and Stick to Them",
      //     body: "Set small weekly goals and mark your progress each day.",
      //     image: Image.asset('lib/src/Emo.png', height: 250),
      //     decoration: _getPageDecoration(),
      //   ),
      // ],
      pages: [
        PageViewModel(
          title: "Talk, and Emolog Listens",
          body:
              "Your voice isn't just heard — it's understood. Speak freely, and Emolog will summarize your thoughts and reflect your emotions.",
          image: Image.asset('lib/src/Emo.png', height: 250),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "See How You Feel Over Time",
          body:
              "Emolog turns your emotional patterns into visual stories — letting you better understand yourself, day by day.",
          image: Image.asset('lib/src/Emo.png', height: 250),
          decoration: _getPageDecoration(),
        ),
        PageViewModel(
          title: "Set Goals. Stay Aware.",
          body:
              "Shape your emotional habits through small, intentional goals. Interact daily, reflect weekly.",
          image: Image.asset('lib/src/Emo.png', height: 250),
          decoration: _getPageDecoration(),
        ),
      ],
      done: const Text(
        "Get Started",
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      onDone: () => _completeOnboarding(context),
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Icon(Icons.arrow_forward),
      dotsDecorator: DotsDecorator(
        activeColor: const Color(0xFFA783E1),
        color: Colors.grey.shade400,
        size: const Size(8, 8),
        activeSize: const Size(16, 8),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  PageDecoration _getPageDecoration() {
    return const PageDecoration(
      titleTextStyle: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyTextStyle: TextStyle(fontSize: 16, color: Colors.black54),
      imagePadding: EdgeInsets.only(top: 20),
      contentMargin: EdgeInsets.symmetric(horizontal: 24),
    );
  }
}
