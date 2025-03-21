import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'myquestion.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _selectedGender = "Female"; // Default selected gender

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          "UniBridge",
          style: TextStyle(color: AppColors.pureWhite,),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 100,
            color: Colors.grey[200],
            child: Align(
              alignment: Alignment.bottomCenter,
              child: CircleAvatar(
                radius: 40,
                backgroundColor: Colors.black,
                child: Image.asset('assets/images/profile.png', width: 40, height: 40),
              ),
            ),
          ),
          const SizedBox(height: 20),
          _buildTextField(hintText: "Ritika Chandak"),
          const SizedBox(height: 10),
          _buildTextField(hintText: "ritikachandak@gmail.com"),
          const SizedBox(height: 10),
          _buildGenderSelection(),
          const SizedBox(height: 10),
          _buildTextField(hintText: "Short Bio"),
          const SizedBox(height: 10),
          _buildTextField(hintText: "Long Bio", maxLines: 4),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const MyQuestionScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
            ),
            child: const Text("My Questions"),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required String hintText, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        maxLines: maxLines,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _genderButton("Male"),
          _genderButton("Female"),
          _genderButton("Others"),
        ],
      ),
    );
  }

  Widget _genderButton(String text) {
    bool isSelected = _selectedGender == text;

    return Expanded(
      child: GestureDetector(
        onTap: () => _selectGender(text), // Update selected gender
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBlue),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
