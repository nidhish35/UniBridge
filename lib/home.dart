import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'hometwo.dart';
import 'allquestion.dart';
import 'askquestions.dart';
import 'giveanswer.dart';
import 'profile.dart';
import 'settings.dart';
import 'answers.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final List<Question> questions = [
    Question(
      category: "School of Business (SOB)",
      categoryColor: AppColors.mintGreen,
      questionText: "What is the difference between product design and UI/UX design?",
      likes: 3,
      dislikes: 1,
    ),
    Question(
      category: "School of Technology (SOT)",
      categoryColor: AppColors.goldenYellow,
      questionText: "What is the difference between product design and UI/UX design?",
      likes: 3,
      dislikes: 1,
    ),
    Question(
      category: "School of Law (SOL)",
      categoryColor: AppColors.lightBlue,
      questionText: "What is the difference between...",
      likes: 0,
      dislikes: 0,
    ),
  ];

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
      body: Column(
        children: [
          // Tab buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _categoryButton(
                  "Education Questions",
                  isSelected: true,
                  onTap: () {}, // Already on this screen, so do nothing
                ),
                _categoryButton(
                  "General Questions",
                  isSelected: false,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const GeneralQuestionScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
          // Post a Question Section
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.mintGreen,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Want to Post a Question?",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 4),
                const Text("Start a question with 'What, How, Why, etc.'"),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AskQuestionsScreen(), // Navigate to ask_question.dart
                        ),
                      );

                    },
                    icon: Image.asset('assets/images/Add.png', width: 24),
                    label: const Text("Post a Question"),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryCoral,
                      foregroundColor: AppColors.pureWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
          // Popular Questions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Popular Questions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllQuestionsScreen()),
                    );
                  },
                  child: const Text(
                    "View All Questions",
                    style: TextStyle(color: AppColors.mediumGray),
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: questions.length,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemBuilder: (context, index) {
                return QuestionCard(question: questions[index]);
              },
            ),
          ),
        ],
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

  Widget _categoryButton(String text, {required bool isSelected, required VoidCallback onTap}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : AppColors.lightGray,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isSelected ? AppColors.pureWhite : AppColors.darkGray,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Data model for a question
class Question {
  final String category;
  final Color categoryColor;
  final String questionText;
  final int likes;
  final int dislikes;

  Question({
    required this.category,
    required this.categoryColor,
    required this.questionText,
    required this.likes,
    required this.dislikes,
  });
}

// Widget for a single question card
class QuestionCard extends StatelessWidget {
  final Question question;

  const QuestionCard({super.key, required this.question});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: question.categoryColor,
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                question.category,
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(question.questionText, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                Image.asset('assets/images/Like.png', width: 24),
                const SizedBox(width: 4),
                Text(question.likes.toString()),
                const SizedBox(width: 10),
                Image.asset('assets/images/Like-2.png', width: 24),
                const SizedBox(width: 4),
                Text(question.dislikes.toString()),
                const Spacer(),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AllAnswerScreen()),
                    );
                  },
                  icon: Image.asset('assets/images/Show.png'),
                  label: const Text("See Answer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pureWhite,
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AnswerScreen()),
                    );
                  },
                  icon: Image.asset('assets/images/Pencil.png'),
                  label: const Text("Give Answer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.pureWhite,
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
