import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constraints/app_colors.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _updatePassword() async {
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
    if (newPassword.length < 6) {
      _showMessage("Password must be at least 6 characters long");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword);
        _showMessage("Password updated successfully");
        Navigator.pop(context); // Return to the previous screen
      } else {
        _showMessage("User not logged in");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        _showMessage("Please re-login before updating your password.");
      } else {
        _showMessage("Error: ${e.message}");
      }
    } catch (e) {
      _showMessage("An unexpected error occurred.");
    }

    setState(() {
      _isLoading = false;
    });
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
          icon: Image.asset('assets/images/backarrow-white.png', width: 24),
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
                onPressed: _isLoading ? null : _updatePassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("Update Password", style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context); // Go back to login or previous screen
                },
                child: const Text(
                  "Back to Settings",
                  style: TextStyle(fontSize: 14, color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

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
