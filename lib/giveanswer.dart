import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'hometwo.dart';
import 'home.dart';
import 'allquestion.dart';
import 'askquestions.dart';
import 'giveanswer.dart';
import 'profile.dart';
import 'settings.dart';
import 'answers.dart';
import 'myquestion.dart';

class AnswerScreen extends StatefulWidget {
  const AnswerScreen({super.key});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final TextEditingController _answerController = TextEditingController();

  @override
  void dispose() {
    _answerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UniBridge", style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/Arrow.png',width: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.mintGreen,
                borderRadius: BorderRadius.circular(5),
              ),
              child: const Text(
                "School of Business (SOB)",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.lightGray,
                  child: Icon(Icons.person, color: AppColors.darkGray),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.lightGray.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      "Ques. What is the difference between product design and UI/UX design?",
                      style: TextStyle(fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Expanded(
              child: TextField(
                controller: _answerController,
                maxLines: null,
                minLines: 6,
                maxLength: 500,
                decoration: InputDecoration(
                  hintText: "Write your Answer",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QuestionScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: AppColors.pureWhite,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: const Text("Post the Answer"),
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
