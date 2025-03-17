import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'profile.dart';
import 'home.dart';
import 'askquestions.dart';
import 'changepass.dart';
import 'theme.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/Arrow.png',width: 24),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          "UniBridge",
          style: TextStyle(color: AppColors.pureWhite, fontWeight: FontWeight.bold),
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
              icon: Image.asset('assets/images/Info.png') ,
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
              icon: Image.asset('assets/images/change pins.png') ,
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
        bottomNavigationBar: Container(
          color: AppColors.primaryBlue, // Ensure background color is applied
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed, // Prevents transparency issues
            backgroundColor: Colors.transparent, // Keep transparent to inherit Container color
            selectedItemColor: AppColors.pureWhite, // Change selected icon color to white
            unselectedItemColor: AppColors.lightGray, // Adjust unselected color if needed
            currentIndex: 0, // Index for tracking the selected tab
            onTap: (index) {
              if (index == 0) { // Profile tab
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileScreen()),
                );
              } else if (index == 1) { // Home tab
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const QuestionScreen()),
                );
              } else if (index == 2) { // Add Question tab
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AskQuestionsScreen()),
                );
              } else if (index == 3) { // Settings tab
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              }
            },
            items: [
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/profile.png', width: 24, height: 24, color: AppColors.pureWhite),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/Home.png',width: 24, height: 24, color: AppColors.pureWhite),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/Add.png', width: 24, height: 24, color: AppColors.pureWhite),
                label: "",
              ),
              BottomNavigationBarItem(
                icon: Image.asset('assets/images/settings.png',width: 24, height: 24, color: AppColors.pureWhite),
                label: "",
              ),
            ],
          ),
        )

    );
  }
  Widget _settingsOption({
    required Widget icon, // Change from IconData to Widget
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: icon, // Now accepts both Icon and Image
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
