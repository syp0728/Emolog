// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';
// import 'providers/journal_provider.dart'; // ✅ 이거 꼭 추가
// import 'screens/home_screen.dart';

// void main() {
//   runApp(
//     MultiProvider(
//       providers: [ChangeNotifierProvider(create: (_) => JournalProvider())],
//       child: const EmologApp(), // ✅ 클래스 이름도 맞게
//     ),
//   );
// }

// class EmologApp extends StatelessWidget {
//   const EmologApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Emolog',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
//         useMaterial3: true,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/journal_provider.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_page.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => JournalProvider())],
      child: const EmologApp(),
    ),
  );
}

class EmologApp extends StatelessWidget {
  const EmologApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Emolog',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      // ✅ 항상 OnboardingPage를 시작화면으로 보여줌
      home: const OnboardingPage(),
    );
  }
}
