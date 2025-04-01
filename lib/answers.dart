import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constraints/app_colors.dart';

class AllAnswerScreen extends StatelessWidget {
  final String questionId;

  const AllAnswerScreen({super.key, required this.questionId});

  Future<DocumentSnapshot?> fetchQuestion() async {
    try {
      var doc = await FirebaseFirestore.instance.collection('questions').doc(questionId).get();
      if (doc.exists) {
        return doc;
      }
    } catch (e) {
      debugPrint("Error fetching question: $e");
    }
    return null;
  }

  Future<DocumentSnapshot?> fetchUserProfile(String userId) async {
    try {
      var doc = await FirebaseFirestore.instance.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("UniBridge", style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('assets/images/backarrow-white.png', width: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          // Fetch Question
          FutureBuilder<DocumentSnapshot?>(
            future: fetchQuestion(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                return const Center(child: Text("Question not found"));
              }

              var questionData = snapshot.data!.data() as Map<String, dynamic>;
              String category = questionData['category'] ?? "Unknown";

              // Check category and set color
              Color categoryColor = (category == "General") ? Colors.yellow[700]! : Colors.green[200]!;

              return Container(
                width: double.infinity,
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: categoryColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Ques. ${questionData['questionText'] ?? 'No question text available'}",
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              );
            },
          ),

          // Answers List
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
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
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: answers.length,
                  itemBuilder: (context, index) {
                    var answerData = answers[index].data() as Map<String, dynamic>;
                    String userId = answerData['userId'] ?? '';

                    return FutureBuilder<DocumentSnapshot?>(
                      future: fetchUserProfile(userId),
                      builder: (context, userSnapshot) {
                        String fullName = "Unknown User"; // Default name

                        if (userSnapshot.hasData && userSnapshot.data != null && userSnapshot.data!.exists) {
                          var userData = userSnapshot.data!.data() as Map<String, dynamic>;
                          fullName = userData['fullName'] ?? fullName; // Fetch full name
                        }

                        return Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 4,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                fullName, // Now correctly fetches the full name
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                answerData['answerText'] ?? '',
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
