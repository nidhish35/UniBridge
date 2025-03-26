import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constraints/app_colors.dart';
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
  int _selectedIndex = 1;
  bool _showEducationQuestions = false;
  List<Question> questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  Future<void> _fetchQuestions() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('questions').get();

      List<Question> fetchedQuestions = snapshot.docs
          .map((doc) => Question.fromFirestore(doc))
          .toList();

      setState(() {
        questions = fetchedQuestions;
        _isLoading = false;
      });
    } catch (e) {
      print("Error fetching questions: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1 ? _buildAppBar() : null,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _getPage(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _getPage() {
    if (_selectedIndex == 1) {
      return HomeContent(
        questions: questions,
        isEducation: _showEducationQuestions,
        onCategoryChanged: (isEducation) {
          setState(() {
            _showEducationQuestions = isEducation;
          });
        },
        refreshQuestions: _fetchQuestions,
      );
    } else if (_selectedIndex == 0) {
      return const ProfileScreen();
    } else if (_selectedIndex == 2) {
      return AskQuestionsScreen(
        onQuestionPosted: () {
          setState(() {
            _selectedIndex = 1;
            _fetchQuestions();
          });
        },
      );
    } else if (_selectedIndex == 3) {
      return const SettingsScreen();
    }
    return const SizedBox.shrink();
  }

  AppBar _buildAppBar() {
    return AppBar(
      elevation: 0,
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
  final bool isEducation;
  final ValueChanged<bool> onCategoryChanged;
  final VoidCallback refreshQuestions;

  const HomeContent({
    super.key,
    required this.questions,
    required this.isEducation,
    required this.onCategoryChanged,
    required this.refreshQuestions,
  });

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = questions.where((q) => isEducation
        ? q.category.contains("School")
        : !q.category.contains("School")).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CategoryButton(
                text: "Education Questions",
                isSelected: isEducation,
                onTap: () => onCategoryChanged(true),
              ),
              CategoryButton(
                text: "General Questions",
                isSelected: !isEducation,
                onTap: () => onCategoryChanged(false),
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
                    MaterialPageRoute(
                      builder: (context) => AskQuestionsScreen(
                        onQuestionPosted: refreshQuestions,
                      ),
                    ),
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
        Expanded(
          child: filteredQuestions.isEmpty
              ? const Center(child: Text("No questions found"))
              : ListView.builder(
            itemCount: filteredQuestions.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => QuestionCard(
              question: filteredQuestions[index],
            ),
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

  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Question(
      category: data['category'] ?? 'General',
      categoryColor: _getCategoryColor(data['category'] ?? 'General'),
      questionText: data['questionText'] ?? '',
      likes: (data['likes'] ?? 0).toInt(),
      dislikes: (data['dislikes'] ?? 0).toInt(),
    );
  }

  static Color _getCategoryColor(String category) {
    if (category.contains("School of Business")) {
      return AppColors.mintGreen;
    } else if (category.contains("School of Technology")) {
      return AppColors.goldenYellow;
    } else {
      return AppColors.lightBlue;
    }
  }
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
                style: const TextStyle(
                    fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text(question.questionText,
                style: const TextStyle(fontSize: 14)),
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
                    MaterialPageRoute(
                        builder: (context) => const AllAnswerScreen()),
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
                    MaterialPageRoute(
                        builder: (context) => const AnswerScreen()),
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