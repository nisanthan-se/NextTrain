import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../painters/grid_painter.dart';
import '../services/profile_session.dart';
import 'home_screen.dart';
import 'sign_in_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  double progress = 0.0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startInitialization();
  }

  Future<void> _startInitialization() async {
    await FirebaseAuth.instance.authStateChanges().first;

    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) return;

      setState(() {
        progress += 0.01;
      });

      if (progress >= 1.0) {
        timer.cancel();
        _navigateNext();
      }
    });
  }

  Future<void> _navigateNext() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      final profile = await BackendService.getCurrentUserProfile();
      if (profile != null) {
        ProfileSession.instance.setProfile(profile);
      } else {
        ProfileSession.instance.setProfile(
          AppUserProfile(
            name: user.displayName ?? user.email?.split('@').first ?? 'User',
            email: user.email ?? '',
            location: 'Sri Lanka',
            role: 'NextTrain Premium User',
            predictions: 0,
          ),
        );
      }

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
      return;
    }

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const SignInScreen()),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const cyan = Color(0xFF00F5FF);
    const purple = Color(0xFFFF00FF);
    const bgColor = Color(0xFF050B12);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(painter: const GridPainter(opacity: 0.08, gap: 28)),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: 140,
                  width: 140,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: cyan.withValues(alpha: 0.4),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: cyan.withValues(alpha: 0.3),
                        blurRadius: 30,
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.train,
                    color: cyan,
                    size: 70,
                  ),
                ),
                const SizedBox(height: 40),
                const Text(
                  'NEXTTRAIN',
                  style: TextStyle(
                    color: cyan,
                    fontSize: 46,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                ),
                const SizedBox(height: 15),
                const Text(
                  'AI-POWERED TRAIN DELAY PREDICTION',
                  style: TextStyle(
                    color: purple,
                    fontSize: 14,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(height: 25),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    border: Border.all(
                      color: purple.withValues(alpha: 0.5),
                    ),
                  ),
                  child: const Text(
                    'SRI LANKA RAILWAYS • v1.0.0',
                    style: TextStyle(
                      color: purple,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 120),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 50,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          const Text(
                            'INITIALIZING AI ENGINE',
                            style: TextStyle(
                              color: cyan,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          Text(
                            '${(progress * 100).toInt()}%',
                            style: const TextStyle(
                              color: cyan,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: progress,
                        minHeight: 6,
                        backgroundColor: Colors.white.withValues(alpha: 0.05),
                        valueColor: const AlwaysStoppedAnimation(cyan),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

