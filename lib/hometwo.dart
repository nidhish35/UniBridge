import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'allquestion.dart';
import 'askquestions.dart';
import 'giveanswer.dart';
import 'profile.dart';
import 'settings.dart';
import 'answers.dart';

class GeneralQuestionScreen extends StatefulWidget {
  const GeneralQuestionScreen({super.key});

  @override
  State<GeneralQuestionScreen> createState() => _GeneralQuestionScreenState();
}

class _GeneralQuestionScreenState extends State<GeneralQuestionScreen> {
  int _selectedIndex = 1; // Default to Home tab
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

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const ProfileScreen(),
      HomeContent(questions: questions),
      const AskQuestionsScreen(),
      const SettingsScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1 ? _buildAppBar() : null,
      body: _pages[_selectedIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/backarrow.png', width: 24),
          onPressed: () => Navigator.pop(context),
        ),
      title: const Text("UniBridge", style: TextStyle(color: AppColors.pureWhite)),
      backgroundColor: AppColors.primaryBlue,
      centerTitle: true,
    );
  }

  BottomNavigationBar _buildBottomNavigationBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.primaryBlue,
      selectedItemColor: AppColors.pureWhite,
      unselectedItemColor: AppColors.lightGray,
      currentIndex: _selectedIndex,
      onTap: (index) => setState(() => _selectedIndex = index),
      items: [
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/profile.png', width: 24, height: 24),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/Home.png', width: 24, height: 24),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/Add.png', width: 24, height: 24),
          label: "",
        ),
        BottomNavigationBarItem(
          icon: Image.asset('assets/images/settings.png', width: 24, height: 24),
          label: "",
        ),
      ],
    );
  }
}

class HomeContent extends StatelessWidget {
  final List<Question> questions;
  const HomeContent({super.key, required this.questions});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryButton(
                text: "Education Questions",
                isSelected: false,
                onTap: () {},
              ),
              CategoryButton(
                text: "General Questions",
                isSelected: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const GeneralQuestionScreen()),
                ),
              ),
            ],
          ),
        ),
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AskQuestionsScreen()),
                  ),
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
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text("Popular Questions", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AllQuestionsScreen()),
                ),
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
            itemBuilder: (context, index) => QuestionCard(question: questions[index]),
          ),
        ),
      ],
    );
  }
}

class CategoryButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryButton({
    super.key,
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AllAnswerScreen()),
                  ),
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
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const AnswerScreen()),
                  ),
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