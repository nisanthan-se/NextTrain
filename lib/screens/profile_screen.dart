import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/profile_session.dart';
import 'prediction_screen.dart';
import 'settings_screen.dart';
import 'sign_in_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static const Color bgColor = Color(0xFF050B12);
  static const Color cyan = Color(0xFF00F5FF);
  static const Color purple = Color(0xFFFF00FF);

  String name = 'Guest';
  String email = '';
  String location = 'Sri Lanka';
  String role = 'NextTrain User';
  int predictions = 0;
  bool isSignedIn = false;

  StreamSubscription<AppUserProfile?>? _profileSub;

  @override
  void initState() {
    super.initState();
    _listenToProfile();
  }

  void _listenToProfile() {
    final user = FirebaseAuth.instance.currentUser;
    isSignedIn = user != null;

    final cachedProfile = ProfileSession.instance.currentProfile;
    if (cachedProfile != null) {
      _applyProfile(cachedProfile);
    } else if (user != null) {
      name = user.displayName ?? user.email?.split('@').first ?? 'User';
      email = user.email ?? '';
    }

    if (user == null) return;

    _profileSub = BackendService.watchCurrentUserProfile().listen((profile) {
      if (!mounted) return;
      if (profile != null) {
        ProfileSession.instance.setProfile(profile);
        _applyProfile(profile);
      }
    });
  }

  void _applyProfile(AppUserProfile profile) {
    setState(() {
      name = profile.name;
      email = profile.email;
      location = profile.location;
      role = profile.role;
      predictions = profile.predictions;
      isSignedIn = true;
    });
  }

  @override
  void dispose() {
    _profileSub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!isSignedIn) {
      return Scaffold(
        backgroundColor: bgColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.person_outline, color: cyan, size: 72),
                  const SizedBox(height: 20),
                  Text(
                    'Sign in to view your profile',
                    style: GoogleFonts.poppins(color: Colors.white70, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: cyan),
                    onPressed: () {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(builder: (_) => const SignInScreen()),
                        (_) => false,
                      );
                    },
                    child: const Text('Sign In', style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Container(
                height: 132,
                width: 132,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: cyan, width: 2),
                  boxShadow: [BoxShadow(color: cyan.withValues(alpha: 0.25), blurRadius: 24)],
                ),
                child: const Icon(Icons.person, size: 70, color: cyan),
              ),
              const SizedBox(height: 20),
              Text(
                name,
                style: GoogleFonts.orbitron(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(role, style: GoogleFonts.poppins(color: Colors.white60, fontSize: 15)),
              const SizedBox(height: 24),
              ValueListenableBuilder<List<PredictionRecord>>(
                valueListenable: predictionHistoryNotifier,
                builder: (context, records, _) {
                  final stats = DashboardStats.fromRecords(records, profilePredictions: predictions);
                  return Row(
                    children: [
                      Expanded(child: _statCard(label: 'Accuracy', value: stats.accuracyLabel, color: cyan)),
                      const SizedBox(width: 12),
                      Expanded(child: _statCard(label: 'Predictions', value: stats.predictionsLabel, color: purple)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 24),
              _infoCard(icon: Icons.email_outlined, title: 'Email', value: email),
              const SizedBox(height: 12),
              _infoCard(icon: Icons.location_on_outlined, title: 'Location', value: location),
              const SizedBox(height: 12),
              _infoCard(icon: Icons.history, title: 'Total saved', value: '$predictions predictions'),
              const SizedBox(height: 24),
              _actionButton(
                icon: Icons.edit,
                title: 'Edit Profile',
                color: cyan,
                onTap: () => _showEditDialog(context),
              ),
              const SizedBox(height: 12),
              _actionButton(
                icon: Icons.settings,
                title: 'Settings',
                color: purple,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
              ),
              const SizedBox(height: 12),
              _actionButton(
                icon: Icons.logout,
                title: 'Logout',
                color: Colors.redAccent,
                onTap: () => _logout(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _statCard({required String label, required String value, required Color color}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Column(
        children: [
          Text(value, style: GoogleFonts.orbitron(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(color: Colors.white60, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _infoCard({required IconData icon, required String title, required String value}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: cyan.withValues(alpha: 0.2)),
        color: Colors.white.withValues(alpha: 0.03),
      ),
      child: Row(
        children: [
          Icon(icon, color: cyan),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(color: Colors.white54, fontSize: 13)),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: color.withValues(alpha: 0.3)),
          color: Colors.white.withValues(alpha: 0.03),
        ),
        child: Row(
          children: [
            const SizedBox(width: 20),
            Icon(icon, color: color),
            const SizedBox(width: 15),
            Text(title, style: GoogleFonts.poppins(color: Colors.white, fontSize: 16)),
            const Spacer(),
            Icon(Icons.arrow_forward_ios, color: color, size: 18),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final nameController = TextEditingController(text: name);
    final emailController = TextEditingController(text: email);
    final locationController = TextEditingController(text: location);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: bgColor,
        title: const Text('Edit Profile', style: TextStyle(color: Colors.white)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _dialogField(controller: nameController, label: 'Name'),
            const SizedBox(height: 10),
            _dialogField(controller: emailController, label: 'Email'),
            const SizedBox(height: 10),
            _dialogField(controller: locationController, label: 'Location'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: cyan),
            onPressed: () async {
              final currentContext = context;
              try {
                await BackendService.updateProfile(
                  name: nameController.text.trim().isNotEmpty ? nameController.text.trim() : name,
                  email: emailController.text.trim().isNotEmpty ? emailController.text.trim() : email,
                  location: locationController.text.trim().isNotEmpty ? locationController.text.trim() : location,
                );

                if (!mounted) return;
                setState(() {
                  name = nameController.text.trim().isNotEmpty ? nameController.text.trim() : name;
                  email = emailController.text.trim().isNotEmpty ? emailController.text.trim() : email;
                  location = locationController.text.trim().isNotEmpty ? locationController.text.trim() : location;
                });
                ProfileSession.instance.setProfile(
                  AppUserProfile(
                    name: name,
                    email: email,
                    location: location,
                    role: role,
                    predictions: predictions,
                  ),
                );
                Navigator.pop(currentContext);
                _showSnackBar(currentContext, 'Profile updated');
              } catch (e) {
                _showSnackBar(currentContext, 'Could not update profile: $e');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Widget _dialogField({required TextEditingController controller, required String label}) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: const UnderlineInputBorder(borderSide: BorderSide(color: Colors.white24)),
        focusedBorder: const UnderlineInputBorder(borderSide: BorderSide(color: cyan)),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    ProfileSession.instance.clear();
    predictionHistoryNotifier.value = [];

    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: cyan.withValues(alpha: 0.2)),
    );
  }
}
