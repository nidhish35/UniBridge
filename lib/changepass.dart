import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'home.dart';
import 'profile.dart';
import 'askquestions.dart';
import 'settings.dart';
import 'home.dart';
import 'hometwo.dart';
import 'allquestion.dart';
import 'askquestions.dart';
import 'giveanswer.dart';
import 'profile.dart';
import 'settings.dart';
import 'answers.dart';
import 'myquestion.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  void _updatePassword() {
    // Add logic to handle password update
    String newPassword = _newPasswordController.text;
    String confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showMessage("Please enter both fields");
      return;
    }
    if (newPassword != confirmPassword) {
      _showMessage("Passwords do not match");
      return;
    }

    // TODO: Add API call or logic for updating password
    _showMessage("Password updated successfully");
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/Arrow.png',width: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("UniBridge", style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 30),
            const Text(
              "Change Password",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.primaryBlue),
            ),
            const SizedBox(height: 8),
            const Text(
              "Create a stronger password to stay protected",
              style: TextStyle(color: AppColors.darkGray),
            ),
            const SizedBox(height: 20),
            _passwordInputField("New Password", _newPasswordController),
            const SizedBox(height: 15),
            _passwordInputField("Re-enter Password", _confirmPasswordController),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Update Password", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Go back to login or previous screen
                },
                child: const Text(
                  "Back to Login",
                  style: TextStyle(fontSize: 14, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
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
  }}

  Widget _passwordInputField(String hintText, TextEditingController controller) {
    return TextField(
      controller: controller,
      obscureText: true,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.lightGray),
        ),
      ),
    );
  }

