import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'home.dart';
import 'hometwo.dart';
import 'allquestion.dart';
import 'askquestions.dart';
import 'giveanswer.dart';
import 'profile.dart';
import 'settings.dart';
import 'answers.dart';
import 'myquestion.dart';

class AllAnswerScreen extends StatefulWidget {
  const AllAnswerScreen({super.key});

  @override
  State<AllAnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AllAnswerScreen> {
  final List<String> answers = List.generate(
    10,
        (index) =>
    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Maecenas tincidunt, elit a consectetur elementum, turpis mi fringilla lorem, nec cursus nisl ex pretium ante.",
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.pureWhite,
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
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category Badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withOpacity(0.3),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                "School of Business (SOB)",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppColors.primaryBlue,
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Question Box
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppColors.lightGray,
                  child: Image.asset('assets/images/profile.png',width: 24),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
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

            // Answers Header
            const Text(
              "Answers (10)",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),

            // Answers List
            Expanded(
              child: ListView.builder(
                itemCount: answers.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: AppColors.lightGray,
                          child: Image.asset('assets/images/profile.png',width: 24),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: AppColors.lightGray.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Text(
                              answers[index],
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
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
  }
}
