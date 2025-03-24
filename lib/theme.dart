import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';



class ThemeSettingsScreen extends StatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  State<ThemeSettingsScreen> createState() => _ThemeSettingsScreenState();
}

class _ThemeSettingsScreenState extends State<ThemeSettingsScreen> {
  bool isLightTheme = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryBlue,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/backarrow.png', width: 24),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true, // Keep this
        title: const Text(
          "UniBridge",
          style: TextStyle(color: Colors.white,),
        ),
        flexibleSpace: Center( // Ensures title is truly centered
          child: Padding(
            padding: const EdgeInsets.only(left: 40), // Adjust to center properly
          ),
        ),
      ),

      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            _themeOption(title: "Light", value: isLightTheme, onChanged: (value) {
              setState(() {
                isLightTheme = true;
              });
            }),
            _themeOption(title: "Dark", value: !isLightTheme, onChanged: (value) {
              setState(() {
                isLightTheme = false;
              });
            }),
          ],
        ),
      ),
    );
  }

  Widget _themeOption({required String title, required bool value, required ValueChanged<bool> onChanged}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
          Switch(
            value: value,
            activeColor: AppColors.primaryBlue,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
