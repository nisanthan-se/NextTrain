import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../screens/home_screen.dart';

Future<void> goToMainApp(BuildContext context) async {
  final user = FirebaseAuth.instance.currentUser;
  if (user != null) {
    try {
      await user.reload();
    } catch (_) {}
  }

  if (!context.mounted) return;

  Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (route) => false,
  );
}
