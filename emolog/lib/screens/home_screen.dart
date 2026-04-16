import 'package:flutter/material.dart';
import '../widgets/common_drawer.dart';
import 'conversation_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      drawer: const CommonDrawer(),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        toolbarHeight: 48,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 10),
          ShaderMask(
            shaderCallback: (bounds) => const LinearGradient(
              colors: [Color(0xFFF8B862), Color(0xFFF59092), Color(0xFFA783E1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ).createShader(bounds),
            child: const Text(
              'Emolog',
              style: TextStyle(
                fontSize: 40,
                fontFamily: 'Rubik Spray Paint',
                color: Colors.white, // required for ShaderMask
              ),
            ),
          ),
          //const SizedBox(height: 20),
          Center(
            child: Hero(
              tag: 'emo-image',
              child: Image.asset(
                'lib/src/Emo.png',
                width: 400,
                height: 400,
                fit: BoxFit.contain,
              ),
            ),
          ),
          //const SizedBox(height: 10),
          const Text(
            'Hello, how was your day?',
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 60),
          Hero(
            tag: 'conversation-button',
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) => const ConversationScreen(),
                    transitionDuration: Duration.zero,
                    reverseTransitionDuration: Duration.zero,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFA783E1),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                textStyle: const TextStyle(fontSize: 18),
              ),
              child: const Text(
                'Start Conversation',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 100)
        ],
      ),
    );
  }
}