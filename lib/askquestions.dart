import 'package:flutter/material.dart';
import 'constraints/app_colors.dart';
import 'home.dart';
import 'hometwo.dart';
import 'allquestion.dart';
import 'askquestions.dart';
import 'giveanswer.dart';
import 'profile.dart';
import 'settings.dart';
import 'answers.dart';

class AskQuestionsScreen extends StatefulWidget {
  const AskQuestionsScreen({super.key});

  @override
  State<AskQuestionsScreen> createState() => _AskQuestionsScreenState();
}

class _AskQuestionsScreenState extends State<AskQuestionsScreen> {
  String? selectedCategory;
  final TextEditingController _questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        leading: IconButton(
          icon: Image.asset('assets/images/Arrow.png', width: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "UniBridge",
          style: TextStyle(color: AppColors.pureWhite),
        ),
        backgroundColor: AppColors.primaryBlue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Ask Questions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "A place where you can ask and get better understanding of the world",
              style: TextStyle(fontSize: 14, color: AppColors.darkGray),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.mintGreen.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                "Start a question with “What, How, Why etc. Try to keep it short and to the point.”",
                style: TextStyle(color: AppColors.darkGray),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Select the section where you want to post your question? *",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
            const SizedBox(height: 10),
            Column(
              children: [
                RadioListTile<String>(
                  title: const Text("Education Questions Section"),
                  value: "Education",
                  groupValue: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
                RadioListTile<String>(
                  title: const Text("General Questions Section"),
                  value: "General",
                  groupValue: selectedCategory,
                  onChanged: (value) {
                    setState(() {
                      selectedCategory = value;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Dropdown
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.mediumGray),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButton<String>(
                value: selectedCategory,
                isExpanded: true,
                hint: const Text("Select your ......"),
                underline: const SizedBox(),
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                  });
                },
                items: ["Education", "General"].map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            // Text Field for Question
            TextField(
              controller: _questionController,
              maxLines: 4,
              maxLength: 250,
              decoration: InputDecoration(
                hintText: "Write your Question",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: const Text(
                "(word limit 0-250)",
                style: TextStyle(color: AppColors.mediumGray, fontSize: 12),
              ),
            ),
            const SizedBox(height: 20),
            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  _submitQuestion();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  "Post the Question",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _submitQuestion() {
    if (_questionController.text.isEmpty || selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields before posting.")),
      );
      return;
    }
    // Handle question submission logic here
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Question posted in $selectedCategory section!")),
    );
    _questionController.clear();
  }
}