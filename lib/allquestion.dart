import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';


class AllQuestionsScreen extends StatefulWidget {
  const AllQuestionsScreen({super.key});

  @override
  State<AllQuestionsScreen> createState() => _AllQuestionsScreenState();
}

class _AllQuestionsScreenState extends State<AllQuestionsScreen> {
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
      questionText: "What is the difference between product design and UI/UX design?",
      likes: 3,
      dislikes: 1,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Image.asset('assets/images/Arrow.png', width: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "UniBridge",
          style: TextStyle(color: AppColors.primaryBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Title
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "All Questions",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ),

          // Category Selector
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                _categoryChip("School of Business (SOB)", isSelected: true),
                _categoryChip("School of Technology (SOT)"),
                _categoryChip("School of Law (SOL)"),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // List of Questions
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
    );
  }

  Widget _categoryChip(String text, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primaryBlue : Colors.white,
        border: Border.all(color: AppColors.primaryBlue),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: isSelected ? Colors.white : AppColors.primaryBlue,
          fontWeight: FontWeight.bold,
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
                color: question.categoryColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Text(
                question.category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: question.categoryColor,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(question.questionText, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),
            Row(
              children: [
                const Icon(Icons.thumb_up, size: 18, color: AppColors.mediumGray),
                const SizedBox(width: 4),
                Text(question.likes.toString()),
                const SizedBox(width: 10),
                const Icon(Icons.thumb_down, size: 18, color: AppColors.mediumGray),
                const SizedBox(width: 4),
                Text(question.dislikes.toString()),
                const Spacer(),
                OutlinedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.remove_red_eye, size: 16),
                  label: const Text("See Answer"),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.edit, size: 16),
                  label: const Text("Give Answer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
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
