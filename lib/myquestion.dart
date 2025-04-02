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
  final TextEditingController _editController = TextEditingController();

  @override
  void dispose() {
    _editController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "My Questions",
          style: TextStyle(color: Colors.white),
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
                final questionText = questionData['questionText'];
                final likes = questionData['likes'] ?? 0;
                final dislikes = questionData['dislikes'] ?? 0;

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
                        questionText,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Interaction Row
                      Row(
                        children: [
                          // Likes
                          _buildVoteWidget('assets/images/Like.png', likes),
                          const SizedBox(width: 15),

                          // Dislikes
                          _buildVoteWidget('assets/images/Like-2.png', dislikes),
                          const Spacer(),

                          // Edit Button
                          ElevatedButton.icon(
                            onPressed: () => _showEditDialog(
                              context,
                              questionData.id,
                              questionText,
                            ),
                            icon: Image.asset('assets/images/Pencil.png', width: 20),
                            label: const Text("Edit"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryBlue,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 10),

                          // Delete Button
                          ElevatedButton.icon(
                            onPressed: () => _deleteQuestion(questionData.id),
                            icon: Image.asset('assets/images/Delete.png', width: 24),
                            label: const Text(
                              "Delete",
                              style: TextStyle(color: Colors.red),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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

  Widget _buildVoteWidget(String iconPath, int count) {
    return Row(
      children: [
        Image.asset(iconPath, width: 24),
        const SizedBox(width: 4),
        Text(
          count.toString(),
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  void _showEditDialog(BuildContext context, String questionId, String currentText) {
    _editController.text = currentText;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Question"),
        content: TextField(
          controller: _editController,
          maxLines: 3,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
            hintText: "Enter your question",
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_editController.text.trim().isNotEmpty) {
                await _updateQuestion(questionId, _editController.text.trim());
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
            ),
            child: const Text("Save", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Future<void> _updateQuestion(String questionId, String newText) async {
    try {
      await FirebaseFirestore.instance
          .collection('questions')
          .doc(questionId)
          .update({'questionText': newText});

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Question updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to update question: $e")),
      );
    }
  }

  Color _getCategoryColor(String category) {
    if (category.toLowerCase() == "education") {
      return Colors.green;
    } else if (category.toLowerCase() == "general") {
      return Colors.yellow;
    }
    return Colors.grey;
  }

  Future<void> _deleteQuestion(String questionId) async {
    try {
      WriteBatch batch = FirebaseFirestore.instance.batch();
      DocumentReference questionRef = FirebaseFirestore.instance.collection('questions').doc(questionId);

      QuerySnapshot answerSnapshot = await FirebaseFirestore.instance
          .collection('answers')
          .where('questionId', isEqualTo: questionId)
          .get();

      for (var doc in answerSnapshot.docs) {
        batch.delete(doc.reference);
      }

      batch.delete(questionRef);
      await batch.commit();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Question and answers deleted successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to delete: $e")),
      );
    }
  }
}