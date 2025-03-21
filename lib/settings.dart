import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'profile.dart';
import 'home.dart';
import 'askquestions.dart';
import 'changepass.dart';
import 'theme.dart';
import 'constraints/app_colors.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: AppColors.primaryBlue,
          title: const Text(
            "UniBridge",
            style: TextStyle(color: AppColors.pureWhite,),
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
              onTap: () {
                // Navigate to Help screen
              },
            ),
            _settingsOption(
              icon: Image.asset('assets/images/Info.png'),
              title: "About",
              onTap: () {
                // Navigate to About screen
              },
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
              onTap: () {
                // Log out action
              },
            ),
            const SizedBox(height: 10),
            _actionButton(
              text: "Deactivate Account",
              color: Colors.transparent,
              textColor: Colors.red,
              borderColor: Colors.red,
              onTap: () {
                // Deactivate account action
              },
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
            side: borderColor != null ? BorderSide(color: borderColor) : BorderSide.none,
          ),
        ),
        child: Text(text, style: const TextStyle(fontSize: 16)),
      ),
    );
  }
}
