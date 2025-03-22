import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constraints/app_colors.dart';
import 'login.dart';
import 'theme.dart';
import 'changepass.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  Future<void> _logOut(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Logout failed: ${e.toString()}')),
      );
    }
  }

  Future<void> _deleteAccount(BuildContext context) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Confirmation dialog
    bool confirm = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Deactivation'),
        content: const Text('This will permanently delete your account. Continue?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await user.delete();

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
            (Route<dynamic> route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Account deleted successfully')),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Deactivation failed: ${e.message ?? 'Unknown error'}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          "UniBridge",
          style: TextStyle(color: AppColors.pureWhite),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _settingsOption(
              icon: Image.asset('assets/images/Help.png'),
              title: "Help",
              onTap: () {},
            ),
            _settingsOption(
              icon: Image.asset('assets/images/Info.png'),
              title: "About",
              onTap: () {},
            ),
            _settingsOption(
              icon: Image.asset('assets/images/Brush.png'),
              title: "Theme",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ThemeSettingsScreen()),
                );
              },
            ),
            _settingsOption(
              icon: Image.asset('assets/images/change pins.png'),
              title: "Change Password",
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ChangePasswordScreen()),
                );
              },
            ),
            const SizedBox(height: 30),
            _actionButton(
              text: "Log Out",
              color: AppColors.primaryBlue,
              textColor: AppColors.pureWhite,
              onTap: () => _logOut(context),
            ),
            const SizedBox(height: 10),
            _actionButton(
              text: "Deactivate Account",
              color: Colors.transparent,
              textColor: Colors.red,
              borderColor: Colors.red,
              onTap: () => _deleteAccount(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _settingsOption({
    required Widget icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon,
      title: Text(title),
      onTap: onTap,
    );
  }

  Widget _actionButton({
    required String text,
    required Color color,
    required Color textColor,
    Color? borderColor,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: double.infinity,
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: color,
          foregroundColor: textColor,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: borderColor != null
                ? BorderSide(color: borderColor)
                : BorderSide.none,
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}