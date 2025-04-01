import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'constraints/app_colors.dart';

class MyQuestionScreen extends StatefulWidget {
  const MyQuestionScreen({super.key});

  @override
  State<MyQuestionScreen> createState() => _MyQuestionScreenState();
}

class _MyQuestionScreenState extends State<MyQuestionScreen> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Questions",
          style: TextStyle( color: Colors.white),
        ),
        backgroundColor: AppColors.primaryBlue,
        leading: IconButton(
          icon: Image.asset('assets/images/backarrow-white.png', width: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _currentUser == null
          ? const Center(child: Text("User not logged in"))
          : StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('questions')
            .where('userId', isEqualTo: _currentUser!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No questions found"));
          }

          final questions = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            child: ListView.builder(
              itemCount: questions.length,
              itemBuilder: (context, index) {
                var questionData = questions[index];

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 1,
                        blurRadius: 3,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category Badge
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getCategoryColor(questionData['category']),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          questionData['category'] ?? 'Unknown',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Question Text
                      Text(
                        questionData['questionText'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Like, Dislike, and Delete Button Row
                      Row(
                        children: [
                          Image.asset('assets/images/Like.png', width: 24),
                          const SizedBox(width: 10),
                Image.asset('assets/images/Like-2.png', width: 24),
                          const Spacer(),
                          ElevatedButton.icon(
                            onPressed: () => _deleteQuestion(questionData.id),
                            icon: Image.asset('assets/images/Delete.png', width: 24),
                            label: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(color: Colors.red),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  // Category color logic
  Color _getCategoryColor(String category) {
    if (category.toLowerCase() == "education") {
      return Colors.green;
    } else if (category.toLowerCase() == "general") {
      return Colors.yellow;
    }
    return Colors.grey;
  }

  // Like & Dislike Icon with Counter
  Widget _iconWithText(IconData icon, int count) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 4),
        Text(count.toString(), style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // Delete Question Functionality
  Future<void> _deleteQuestion(String questionId) async {
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

      for (var doc in answerSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Delete the question itself
      batch.delete(questionRef);

      // Commit the batch operation
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Question and its answers deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete question: $e")),
      );
    }
  }
}
