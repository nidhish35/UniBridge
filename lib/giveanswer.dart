import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnswerScreen extends StatefulWidget {
  final String questionId;

  const AnswerScreen({super.key, required this.questionId});

  @override
  State<AnswerScreen> createState() => _AnswerScreenState();
}

class _AnswerScreenState extends State<AnswerScreen> {
  final TextEditingController _answerController = TextEditingController();
  bool _isPosting = false;
  String _questionText = "";
  String _category = "General";

  @override
  void initState() {
    super.initState();
    _fetchQuestion();
  }

  Future<void> _fetchQuestion() async {
    try {
      DocumentSnapshot questionSnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .doc(widget.questionId)
          .get();

      if (questionSnapshot.exists) {
        setState(() {
          _questionText = questionSnapshot['questionText'] ?? "Question not found";
          _category = questionSnapshot['category'] ?? "General";
        });
      }
    } catch (e) {
      print("Error fetching question: $e");
    }
  }

  Color _getCategoryColor() {
    return _category.toLowerCase() == "education"
        ? Colors.green.shade100
        : Colors.yellow.shade800;
  }

  Future<void> _postAnswer() async {
    if (_answerController.text.trim().isEmpty) return;

    setState(() => _isPosting = true);

    try {
      String userId = FirebaseAuth.instance.currentUser?.uid ?? "Unknown"; // Get logged-in user ID

      await FirebaseFirestore.instance.collection('answers').add({
        'questionId': widget.questionId,
        'answerText': _answerController.text.trim(),
        'userId': userId, // Store user ID with answer
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
      resizeToAvoidBottomInset: true, // ✅ Fix for overflow issue
      appBar: AppBar(
        title: const Text("UniBridge", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
        leading: IconButton(
          icon: Image.asset('assets/images/backarrow-white.png', width: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView( // ✅ Enables scrolling when keyboard opens
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_category.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getCategoryColor(),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _category,
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              // ❌ Removed the CircleAvatar icon
              Text(
                _questionText,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: TextField(
                  controller: _answerController,
                  maxLines: 5,
                  keyboardType: TextInputType.multiline, // ✅ Supports multiline input
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "Write your Answer",
                  ),
                ),
              ),
              const SizedBox(height: 8),
              const Align(
                alignment: Alignment.centerRight,
                child: Text("(word limit 0-500)", style: TextStyle(color: Colors.grey)),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isPosting ? null : _postAnswer,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: _isPosting
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Post the Answer", style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
              const SizedBox(height: 20), // ✅ Extra space to prevent keyboard overlap
            ],
          ),
        ),
      ),
    );
  }
}
