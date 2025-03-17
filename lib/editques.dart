import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'myquestion.dart';
import 'home.dart';
import 'hometwo.dart';
import 'allquestion.dart';
import 'askquestions.dart';
import 'giveanswer.dart';
import 'profile.dart';
import 'settings.dart';
import 'answers.dart';


class EditQuestion extends StatefulWidget {
  const EditQuestion({super.key});

  @override
  State<EditQuestion> createState() => _EditQuestionState();
}

class _EditQuestionState extends State<EditQuestion> {
  String selectedSection = "Education Questions Section";
  String selectedCategory = "School of Business (SOB)";
  final TextEditingController questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/Arrow.png',width: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "UniBridge",
          style: TextStyle(
            color: AppColors.primaryBlue,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              const Text(
                "Your Questions",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                "A place where you can ask and get better understanding of the world",
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 10),

              // Hint Box
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.mintGreen.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  "Start a question with “what, how, why etc. Try to keep it short and to the point.”",
                  style: TextStyle(color: AppColors.primaryBlue, fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),

              // Section Selection
              const Text(
                "Select the section where you want to post your question?*",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryBlue,
                ),
              ),
              const SizedBox(height: 8),

              // Radio Buttons for Question Section
              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text("Education Questions Section"),
                    value: "Education Questions Section",
                    groupValue: selectedSection,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedSection = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text("General Questions Section"),
                    value: "General Questions Section",
                    groupValue: selectedSection,
                    activeColor: AppColors.primaryBlue,
                    onChanged: (value) {
                      setState(() {
                        selectedSection = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),

              // Dropdown for School Category
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedCategory,
                    isExpanded: true,
                    items: [
                      "School of Business (SOB)",
                      "School of Technology (SOT)",
                      "School of Law (SOL)"
                    ].map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value!;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 10),

              // Question Input Field
              TextField(
                controller: questionController,
                maxLines: 4,
                maxLength: 250,
                decoration: InputDecoration(
                  hintText: "Write your question here...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Cancel and Update Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                      side: const BorderSide(color: AppColors.primaryBlue),
                    ),
                    child: const Text(
                      "Cancel",
                      style: TextStyle(color: AppColors.primaryBlue),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const MyQuestionScreen()),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 12),
                    ),
                    child: const Text(
                      "Update",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),

      // Bottom Navigation Bar
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
