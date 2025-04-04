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

  Stream<List<Question>> _getQuestionsStream() {
    return FirebaseFirestore.instance
        .collection('questions')
        .snapshots()
        .map((snapshot) => snapshot.docs
        .map((doc) => Question.fromFirestore(doc))
        .toList());
  }

  void _incrementLike(String questionId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final voteRef = FirebaseFirestore.instance
        .collection('questions')
        .doc(questionId)
        .collection('votes')
        .doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot voteSnapshot = await transaction.get(voteRef);
      DocumentSnapshot questionSnapshot = await transaction.get(
          FirebaseFirestore.instance.collection('questions').doc(questionId));

      if (!questionSnapshot.exists) throw Exception("Question does not exist");

      Map<String, dynamic> questionData = questionSnapshot.data() as Map<String, dynamic>;
      int currentLikes = questionData['likes'] ?? 0;
      int currentDislikes = questionData['dislikes'] ?? 0;

      if (voteSnapshot.exists) {
        String previousVote = voteSnapshot['type'];
        if (previousVote == 'like') return;
        currentDislikes--;
        currentLikes++;
        transaction.update(questionSnapshot.reference, {
          'likes': currentLikes,
          'dislikes': currentDislikes,
        });
        transaction.update(voteRef, {'type': 'like'});
      } else {
        currentLikes++;
        transaction.update(questionSnapshot.reference, {'likes': currentLikes});
        transaction.set(voteRef, {'type': 'like'});
      }
    }).catchError((error) => print("Error updating like: $error"));
  }

  void _incrementDislike(String questionId) async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final voteRef = FirebaseFirestore.instance
        .collection('questions')
        .doc(questionId)
        .collection('votes')
        .doc(userId);

    FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot voteSnapshot = await transaction.get(voteRef);
      DocumentSnapshot questionSnapshot = await transaction.get(
          FirebaseFirestore.instance.collection('questions').doc(questionId));

      if (!questionSnapshot.exists) throw Exception("Question does not exist");

      Map<String, dynamic> questionData = questionSnapshot.data() as Map<String, dynamic>;
      int currentLikes = questionData['likes'] ?? 0;
      int currentDislikes = questionData['dislikes'] ?? 0;

      if (voteSnapshot.exists) {
        String previousVote = voteSnapshot['type'];
        if (previousVote == 'dislike') return;
        currentLikes--;
        currentDislikes++;
        transaction.update(questionSnapshot.reference, {
          'likes': currentLikes,
          'dislikes': currentDislikes,
        });
        transaction.update(voteRef, {'type': 'dislike'});
      } else {
        currentDislikes++;
        transaction.update(questionSnapshot.reference, {'dislikes': currentDislikes});
        transaction.set(voteRef, {'type': 'dislike'});
      }
    }).catchError((error) => print("Error updating dislike: $error"));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _selectedIndex == 1 ? _buildAppBar() : null,
      body: _getPage(),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _getPage() {
    if (_selectedIndex == 1) {
      return StreamBuilder<List<Question>>(
        stream: _getQuestionsStream(),
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
            onLike: _incrementLike,
            onDislike: _incrementDislike,
          );
        },
      );
    } else if (_selectedIndex == 0) {
      return const ProfileScreen();
    } else if (_selectedIndex == 2) {
      return AskQuestionsScreen(
        onQuestionPosted: () {
          setState(() {
            _selectedIndex = 1;
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
  final Function(String) onLike;
  final Function(String) onDislike;

  const HomeContent({
    super.key,
    required this.questions,
    required this.isEducation,
    required this.onCategoryChanged,
    required this.onLike,
    required this.onDislike,
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
                text: "Education",
                isSelected: isEducation,
                onTap: () => onCategoryChanged(true),
              ),
              const SizedBox(width: 10),
              CategoryButton(
                text: "General",
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
              onLike: onLike,
              onDislike: onDislike,
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
                fontSize: 14,
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
  final Function(String) onLike;
  final Function(String) onDislike;

  const QuestionCard({
    super.key,
    required this.question,
    required this.onLike,
    required this.onDislike,
  });

  @override
  _QuestionCardState createState() => _QuestionCardState();
}

class _QuestionCardState extends State<QuestionCard> {
  String? userVote;

  @override
  void initState() {
    super.initState();
    _getUserVote();
  }

  Future<void> _getUserVote() async {
    final userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId == null) return;

    final voteRef = FirebaseFirestore.instance
        .collection('questions')
        .doc(widget.question.id)
        .collection('votes')
        .doc(userId);

    final voteSnapshot = await voteRef.get();
    if (voteSnapshot.exists) {
      setState(() {
        userVote = voteSnapshot['type'];
      });
    }
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
              ],
            ),
            const SizedBox(height: 8),
            Text(
              widget.question.questionText,
              style: const TextStyle(fontSize: 14),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                // Like button
                GestureDetector(
                  onTap: () {
                    widget.onLike(widget.question.id);
                    setState(() {
                      userVote = 'like';
                    });
                  },
                  child: Image.asset(
                    'assets/images/Like.png',
                    width: 20,
                    color: userVote == 'like' ? Colors.green : null,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  widget.question.likes.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                const SizedBox(width: 8),

                // Dislike button
                GestureDetector(
                  onTap: () {
                    widget.onDislike(widget.question.id);
                    setState(() {
                      userVote = 'dislike';
                    });
                  },
                  child: Image.asset(
                    'assets/images/Like-2.png',
                    width: 20,
                    color: userVote == 'dislike' ? Colors.red : null,
                  ),
                ),
                const SizedBox(width: 2),
                Text(
                  widget.question.dislikes.toString(),
                  style: const TextStyle(fontSize: 12),
                ),
                const Spacer(),

                // Answers button
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AllAnswerScreen(questionId: widget.question.id),
                    ),
                  ),
                  icon: Image.asset('assets/images/Show.png', width: 16),
                  label: const Text("Answers"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pureWhite,
                    foregroundColor: AppColors.primaryBlue,
                    side: const BorderSide(color: AppColors.primaryBlue),
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 24),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                ),
                const SizedBox(width: 8),

                // Give Answer button
                ElevatedButton.icon(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AnswerScreen(questionId: widget.question.id),
                    ),
                  ),
                  icon: Image.asset('assets/images/Pencil.png', width: 16),
                  label: const Text("Answer"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.pureWhite,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    minimumSize: const Size(0, 24),
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
