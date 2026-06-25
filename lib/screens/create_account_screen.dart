import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../utils/color_utils.dart';
import 'package:google_fonts/google_fonts.dart';
import '../services/auth_fallback.dart';
import '../services/profile_session.dart';
import 'home_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  static const Color bgColor = Color(0xFF050B12);
  static const Color cyan = Color(0xFF00F5FF);

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Account',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Join NextTrain and start predicting delays',
                  style: GoogleFonts.poppins(
                    color: Colors.white60,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 28),
                _inputField(controller: _nameController, label: 'Name', icon: Icons.person_outline),
                const SizedBox(height: 14),
                _inputField(controller: _emailController, label: 'Email', icon: Icons.email_outlined),
                const SizedBox(height: 14),
                _inputField(controller: _passwordController, label: 'Password', icon: Icons.lock_outline, obscureText: true),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      final name = _nameController.text.trim();
                      final email = _emailController.text.trim();
                      final password = _passwordController.text.trim();
                      final currentContext = context;

                      if (name.isEmpty || email.isEmpty || password.isEmpty) {
                        _showSnackBar(currentContext, 'Please fill all fields');
                        return;
                      }

                      try {
                        final userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                          email: email,
                          password: password,
                        );

                        await BackendService.createUserProfile(
                          uid: userCredential.user!.uid,
                          name: name,
                          email: email,
                        );

                        ProfileSession.instance.setProfile(
                          AppUserProfile(
                            name: name,
                            email: email,
                            location: 'Sri Lanka',
                            role: 'NextTrain Premium User',
                            predictions: 0,
                          ),
                        );

                        if (!mounted) return;
                        Navigator.pushReplacement(
                          currentContext,
                          MaterialPageRoute(builder: (_) => const HomeScreen()),
                        );
                        if (!mounted) return;
                        _showSnackBar(currentContext, 'Account created successfully');
                      } on FirebaseAuthException catch (e) {
                        if (!mounted) return;
                        if (shouldUseDemoAuthFallback(e.message ?? '')) {
                          Navigator.pushReplacement(
                            currentContext,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        } else {
                          _showSnackBar(currentContext, _mapAuthError(e));
                        }
                      } catch (e) {
                        if (!mounted) return;
                        if (shouldUseDemoAuthFallback(e.toString())) {
                          Navigator.pushReplacement(
                            currentContext,
                            MaterialPageRoute(builder: (_) => const HomeScreen()),
                          );
                        } else {
                          _showSnackBar(currentContext, 'Account creation failed');
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: cyan,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    ),
                    child: Text(
                      'CREATE ACCOUNT',
                      style: GoogleFonts.orbitron(fontWeight: FontWeight.bold, color: Colors.black),
                    ),
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

  String _mapAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'email-already-in-use':
        return 'An account already exists for this email.';
      case 'weak-password':
        return 'Please choose a stronger password with at least 6 characters.';
      case 'operation-not-allowed':
        return 'Email/password sign-up is not enabled in Firebase Console. Please enable it in Authentication > Sign-in method.';
      default:
        return e.message ?? 'Account creation failed';
    }
  }
}
