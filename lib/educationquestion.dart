import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constraints/app_colors.dart';
import 'askquestions.dart';
import 'giveanswer.dart';
import 'profile.dart';
import 'settings.dart';
import 'answers.dart';
import 'package:firebase_auth/firebase_auth.dart';


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
  }

  Stream<List<Question>> _questionStream() {
    return FirebaseFirestore.instance.collection('questions').snapshots().map(
          (snapshot) => snapshot.docs.map((doc) => Question.fromFirestore(doc)).toList(),
    );
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
      return StreamBuilder<List<Question>>(
        stream: _questionStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No questions found"));
          }
          return HomeContent(
            questions: snapshot.data!,
            isEducation: _showEducationQuestions,
            onCategoryChanged: (isEducation) {
              setState(() {
                _showEducationQuestions = isEducation;
              });
            },
            onDelete: _deleteQuestion,
          );
        },
      );
    } else if (_selectedIndex == 0) {
      return const ProfileScreen();
    } else if (_selectedIndex == 2) {
      return AskQuestionsScreen(
        onQuestionPosted: () {
          setState(() {
            _selectedIndex = 1; // Switch back to Home tab
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

class QuestionCard extends StatefulWidget {
  final Question question;
  final Function(String) onDelete;

  const QuestionCard({super.key, required this.question, required this.onDelete});

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  bool _isLiking = false;
  bool _isDisliking = false;

  void _updateLikes(bool isLike) async {
    if (_isLiking || _isDisliking) return; // Prevents multiple taps

    setState(() {
      if (isLike) {
        _isLiking = true;
      } else {
        _isDisliking = true;
      }
    });

    try {
      DocumentReference questionRef =
      FirebaseFirestore.instance.collection('questions').doc(widget.question.id);

      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(questionRef);
        if (!snapshot.exists) return;

        int currentLikes = (snapshot['likes'] ?? 0) as int;
        int currentDislikes = (snapshot['dislikes'] ?? 0) as int;

        if (isLike) {
          transaction.update(questionRef, {'likes': currentLikes + 1});
        } else {
          transaction.update(questionRef, {'dislikes': currentDislikes + 1});
        }
      });

    } catch (e) {
      debugPrint("Error updating likes/dislikes: $e");
    }

    setState(() {
      _isLiking = false;
      _isDisliking = false;
    });
  }

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
            // Category & Delete Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: widget.question.categoryColor,
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: Text(
                    widget.question.category,
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: Image.asset('assets/images/Delete.png', width: 24),
                  onPressed: () => widget.onDelete(widget.question.id),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Question Text
            Text(widget.question.questionText, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 10),

            // Like & Dislike Buttons
            Row(
              children: [
                GestureDetector(
                  onTap: () => _updateLikes(true),
                  child: Row(
                    children: [
                      Image.asset('assets/images/Like.png', width: 24),
                      const SizedBox(width: 4),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('questions')
                            .doc(widget.question.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Text(widget.question.likes.toString());
                          int updatedLikes = (snapshot.data!['likes'] ?? 0) as int;
                          return Text(updatedLikes.toString());
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: () => _updateLikes(false),
                  child: Row(
                    children: [
                      Image.asset('assets/images/Like-2.png', width: 24),
                      const SizedBox(width: 4),
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('questions')
                            .doc(widget.question.id)
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) return Text(widget.question.dislikes.toString());
                          int updatedDislikes = (snapshot.data!['dislikes'] ?? 0) as int;
                          return Text(updatedDislikes.toString());
                        },
                      ),
                    ],
                  ),
                ),
                const Spacer(),

                // See Answer Button
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AllAnswerScreen(questionId: widget.question.id)),
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

                // Give Answer Button
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AnswerScreen(questionId: widget.question.id)),
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
