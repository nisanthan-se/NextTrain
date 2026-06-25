import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_fallback.dart';
import '../services/profile_session.dart';
import '../utils/color_utils.dart';
import 'create_account_screen.dart';
import 'home_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  static const Color bgColor = Color(0xFF050B12);
  static const Color cyan = Color(0xFF00F5FF);

  final TextEditingController _emailController = TextEditingController(text: 'user@example.com');
  final TextEditingController _passwordController = TextEditingController(text: '123456');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sign In',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Welcome back to NextTrain',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 30),
                _inputField(controller: _emailController, label: 'Email', icon: Icons.email_outlined),
                const SizedBox(height: 16),
                _inputField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, obscureText: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      final currentContext = context;

                      if (email.isEmpty || password.isEmpty) {
                        _showSnackBar(currentContext, 'Please enter your email and password');
                        return;
                      }

                      try {
                        final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        final user = credential.user;
                        if (user != null) {
                          ProfileSession.instance.setProfile(
                            AppUserProfile(
                              name: user.displayName ?? email.split('@').first,
                              email: user.email ?? email,
                              location: 'Sri Lanka',
                              role: 'NextTrain Premium User',
                              predictions: 0,
                            ),
                          );
                        }

                        if (!mounted) return;
                        Navigator.pushReplacement(
                          currentContext,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                      } on FirebaseAuthException catch (e, st) {
                        // Log full error for debugging and show a clear message to user
                        // so they can act (enable sign-in method, check project config).
                        // Keep fallback behavior for demo flows.
                        // ignore: avoid_print
                        print('FirebaseAuthException during sign-in: ${e.code} ${e.message}');
                        // ignore: avoid_print
                        print(st);

                        if (!mounted) return;
                        if (shouldUseDemoAuthFallback(e.message ?? '')) {
                          Navigator.pushReplacement(
                            currentContext,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        } else {
                          _showSnackBar(currentContext, _mapAuthError(e));
                          _showErrorDialog(currentContext, 'Sign in failed', e.message ?? 'An error occurred');
                        }
                      } catch (e, st) {
                        // Generic error logging
                        // ignore: avoid_print
                        print('Error during sign-in: $e');
                        // ignore: avoid_print
                        print(st);

                        if (!mounted) return;
                        if (shouldUseDemoAuthFallback(e.toString())) {
                          Navigator.pushReplacement(
                            currentContext,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        } else {
                          _showSnackBar(currentContext, 'Sign in failed');
                          _showErrorDialog(currentContext, 'Sign in failed', e.toString());
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cyan,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      'SIGN IN',
                      style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Expanded(child: Divider(color: Colors.white24)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text('or', style: GoogleFonts.poppins(color: Colors.white38)),
                    ),
                    const Expanded(child: Divider(color: Colors.white24)),
                  ],
                ),
                const SizedBox(height: 20),
                Center(
                  child: TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
                      );
                    },
                    child: Text('Create account', style: TextStyle(color: cyan)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _inputField({required TextEditingController controller, required String label, required IconData icon, bool obscureText = false}) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: cyan),
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.04),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: cyan.withValues(alpha: 0.2)),
    );
  }

  void _showErrorDialog(BuildContext context, String title, String details) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(details),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email or password is incorrect. Please try again.';
      case 'too-many-requests':
        return 'Too many sign-in attempts. Please wait a moment and try again.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled in Firebase Console. Please enable it in Authentication > Sign-in method.';
      default:
        return e.message ?? 'Sign in failed';
    }
  }
}
