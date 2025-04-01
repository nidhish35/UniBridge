import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AllAnswerScreen extends StatelessWidget {
  final String questionId;

  const AllAnswerScreen({super.key, required this.questionId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Answers", style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('answers')
            .where('questionId', isEqualTo: questionId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No answers yet"));
          }

          var answers = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: answers.length,
            itemBuilder: (context, index) {
              var answerData = answers[index].data() as Map<String, dynamic>;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
                margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    answerData['answerText'] ?? '',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
