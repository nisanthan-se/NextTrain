import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../services/profile_session.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  static const Color bgColor = Color(0xFF050B12);
  static const Color cyan = Color(0xFF00F5FF);
  static const Color purple = Color(0xFFFF00FF);

  bool notificationsEnabled = true;
  bool isSaving = false;

  @override
  void initState() {
    super.initState();
    notificationsEnabled =
        ProfileSession.instance.currentProfile?.notificationsEnabled ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        title: Text(
          'Settings',
          style: GoogleFonts.orbitron(color: cyan, fontWeight: FontWeight.bold),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          _sectionTitle('Preferences'),
          SwitchListTile(
            title: const Text('Delay notifications', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              'Get notified about significant delay estimates',
              style: TextStyle(color: Colors.white54),
            ),
            value: notificationsEnabled,
            activeThumbColor: cyan,
            onChanged: isSaving
                ? null
                : (value) async {
                    setState(() {
                      notificationsEnabled = value;
                      isSaving = true;
                    });
                    try {
                      await BackendService.updateNotificationPreference(value);
                      final profile = ProfileSession.instance.currentProfile;
                      if (profile != null) {
                        ProfileSession.instance.setProfile(
                          profile.copyWith(notificationsEnabled: value),
                        );
                      }
                    } catch (e) {
                      if (!mounted) return;
                      setState(() => notificationsEnabled = !value);
                      _showSnackBar('Could not save preference: $e');
                    } finally {
                      if (mounted) setState(() => isSaving = false);
                    }
                  },
          ),
          const SizedBox(height: 24),
          _sectionTitle('Account'),
          ListTile(
            leading: const Icon(Icons.lock_outline, color: cyan),
            title: const Text('Change password', style: TextStyle(color: Colors.white)),
            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
            onTap: _showChangePasswordDialog,
          ),
          const SizedBox(height: 24),
          _sectionTitle('About'),
          ListTile(
            leading: const Icon(Icons.info_outline, color: purple),
            title: const Text('App version', style: TextStyle(color: Colors.white)),
            subtitle: const Text('1.0.0', style: TextStyle(color: Colors.white54)),
          ),
          ListTile(
            leading: const Icon(Icons.train, color: purple),
            title: const Text('NextTrain', style: TextStyle(color: Colors.white)),
            subtitle: const Text(
              'AI-powered train delay estimates for Sri Lanka Railways',
              style: TextStyle(color: Colors.white54),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title.toUpperCase(),
        style: GoogleFonts.orbitron(color: cyan, letterSpacing: 1.5, fontSize: 13),
      ),
    );
  }

  void _showChangePasswordDialog() {
    final passwordController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: bgColor,
        title: const Text('Change password', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: passwordController,
          obscureText: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            labelText: 'New password',
            labelStyle: TextStyle(color: Colors.white70),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: cyan),
            onPressed: () async {
              final password = passwordController.text.trim();
              if (password.length < 6) {
                _showSnackBar('Password must be at least 6 characters');
                return;
              }
              try {
                await FirebaseAuth.instance.currentUser?.updatePassword(password);
                if (ctx.mounted) Navigator.pop(ctx);
                _showSnackBar('Password updated');
              } on FirebaseAuthException catch (e) {
                _showSnackBar(e.message ?? 'Could not update password');
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: cyan.withValues(alpha: 0.2)),
    );
  }
}
