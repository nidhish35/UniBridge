import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constraints/app_colors.dart';
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
  int _selectedIndex = 1;
  bool _showEducationQuestions = true;
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

  void _deleteQuestion(String questionId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();

      // Reference to the question document
      DocumentReference questionRef =
      FirebaseFirestore.instance.collection('questions').doc(questionId);

      // Fetch all answers associated with the question
      QuerySnapshot answerSnapshot = await FirebaseFirestore.instance
          .collection('answers')
          .where('questionId', isEqualTo: questionId)
          .get();

      if (answerSnapshot.docs.isEmpty) {
        debugPrint("No answers found for this question.");
      } else {
        debugPrint("Deleting ${answerSnapshot.docs.length} answers.");
      }

      // Add all answers to batch delete
      for (var doc in answerSnapshot.docs) {
        debugPrint("Deleting answer: ${doc.id}");
        batch.delete(doc.reference);
      }

      // Add the question to batch delete
      batch.delete(questionRef);
      debugPrint("Deleting question: $questionId");

      // Commit the batch deletion
      await batch.commit();
      debugPrint("Batch commit successful!");

      // Update the UI after deletion
      setState(() {
        questions.removeWhere((q) => q.id == questionId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Question and its answers deleted successfully!")),
      );
    } catch (e) {
      debugPrint("Error deleting question and answers: $e");

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete question: $e")),
      );
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
        onDelete: _deleteQuestion,  // Pass delete function
      );
    } else if (_selectedIndex == 0) {
      return const ProfileScreen();
    } else if (_selectedIndex == 2) {
      return AskQuestionsScreen(
        onQuestionPosted: () {
          setState(() {
            _selectedIndex = 1; // Switch back to Home tab
            _fetchQuestions(); // Refresh questions list
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
  final Function(String) onDelete; // Add delete function

  const HomeContent({
    super.key,
    required this.questions,
    required this.isEducation,
    required this.onCategoryChanged,
    required this.onDelete,  // Add delete function
  });

  @override
  Widget build(BuildContext context) {
    final filteredQuestions = questions.where((q) => isEducation
        ? q.category == "Education"
        : q.category != "Education").toList();

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
        Expanded(
          child: filteredQuestions.isEmpty
              ? const Center(child: Text("No questions found"))
              : ListView.builder(
            itemCount: filteredQuestions.length,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemBuilder: (context, index) => QuestionCard(
              question: filteredQuestions[index],
              onDelete: onDelete, // Pass delete function
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
  final String id;
  final String category;
  final Color categoryColor;
  final String questionText;
  final int likes;
  final int dislikes;

  Question({
    required this.id,
    required this.category,
    required this.categoryColor,
    required this.questionText,
    required this.likes,
    required this.dislikes,
  });

  factory Question.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return Question(
      id: doc.id,
      category: data['category'] ?? 'Unknown',
      categoryColor: _getCategoryColor(data['category'] ?? 'General'),
      questionText: data['questionText'] ?? '',
      likes: (data['likes'] ?? 0).toInt(),
      dislikes: (data['dislikes'] ?? 0).toInt(),
    );
  }

  static Color _getCategoryColor(String category) {
    switch (category) {
      case "Education":
        return AppColors.mintGreen;
      case "General":
        return AppColors.goldenYellow;
      default:
        return AppColors.lightBlue;
    }
  }
}

class QuestionCard extends StatelessWidget {
  final Question question;
  final Function(String) onDelete;

  const QuestionCard({super.key, required this.question, required this.onDelete});

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                IconButton(
                  icon: Image.asset('assets/images/Delete.png', width: 24),
                  onPressed: () => onDelete(question.id),  // Call delete function
                ),
              ],
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
                    MaterialPageRoute(builder: (context) => AllAnswerScreen(questionId: question.id)),
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
                    MaterialPageRoute(builder: (context) => AnswerScreen(questionId: question.id)),
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
