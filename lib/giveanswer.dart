import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'educationquestion.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class AnswerScreen extends StatefulWidget {
  final String questionId;

  const AnswerScreen({super.key, required this.questionId});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isPosting = false;

  Future<void> _postAnswer() async {
    if (_answerController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    try {
      await FirebaseFirestore.instance
          .collection('answers')
          .add({
        'questionId': widget.questionId,
        'answerText': _answerController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });

      Navigator.pop(context);
    } catch (e) {
      print("Error posting answer: $e");
    } finally {
      setState(() => _isPosting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Give Answer", style: TextStyle(color: AppColors.pureWhite)),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _answerController,
              decoration: InputDecoration(
                hintText: "Type your answer...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isPosting ? null : _postAnswer,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.pureWhite,
              ),
              child: _isPosting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text("Post Answer"),
            ),
          ],
        ),
      ),
    );
  }
}
