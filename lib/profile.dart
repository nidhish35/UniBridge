import 'dart:io';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'constraints/app_colors.dart';
import 'myquestion.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _shortBioController;
  late TextEditingController _longBioController;
  String _selectedGender = "Female";
  User? _currentUser;
  String _profileImageUrl = '';
  XFile? _pickedImage;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _shortBioController = TextEditingController();
    _longBioController = TextEditingController();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    if (_currentUser == null) return;

    DocumentSnapshot userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(_currentUser!.uid)
        .get();

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc['fullName'] ?? '';
        _emailController.text = userDoc['email'] ?? '';
        _selectedGender = userDoc['gender'] ?? 'Female';
        _shortBioController.text = userDoc['shortBio'] ?? '';
        _longBioController.text = userDoc['longBio'] ?? '';
        _profileImageUrl = userDoc['photoUrl'] ?? '';
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _pickedImage = pickedFile;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_currentUser == null) return;

    try {
      String? imageUrl;
      if (_pickedImage != null) {
        Reference storageRef = FirebaseStorage.instance
            .ref()
            .child('profile_images/${_currentUser!.uid}');
        UploadTask uploadTask = storageRef.putFile(File(_pickedImage!.path));
        TaskSnapshot snapshot = await uploadTask;
        imageUrl = await snapshot.ref.getDownloadURL();
      }

      Map<String, dynamic> updateData = {
        'fullName': _nameController.text,
        'gender': _selectedGender,
        'shortBio': _shortBioController.text,
        'longBio': _longBioController.text,
      };

      if (imageUrl != null) {
        updateData['photoUrl'] = imageUrl;
        setState(() {
          _profileImageUrl = imageUrl!;
          _pickedImage = null;
        });
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .update(updateData);

      if (_nameController.text.isNotEmpty) {
        await _currentUser!.updateDisplayName(_nameController.text);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating profile: $e')),
      );
    }
  }

  void _selectGender(String gender) {
    setState(() {
      _selectedGender = gender;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _shortBioController.dispose();
    _longBioController.dispose();
    super.dispose();
  }

  Widget _buildProfileImage() {
    return GestureDetector(
      onTap: _pickImage,
      child: CircleAvatar(
        radius: 40,
        backgroundColor: Colors.grey[300],
        child: _pickedImage != null
            ? ClipOval(
          child: Image.file(
            File(_pickedImage!.path),
            width: 76,
            height: 76,
            fit: BoxFit.cover,
          ),
        )
            : (_profileImageUrl.isNotEmpty
            ? ClipOval(
          child: Image.network(
            _profileImageUrl,
            width: 76,
            height: 76,
            fit: BoxFit.cover,
          ),
        )
            : const Icon(Icons.camera_alt, size: 40, color: Colors.grey)),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        readOnly: hintText == "Email",
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          filled: true,
          fillColor: Colors.grey[100],
        ),
      ),
    );
  }

  Widget _genderButton(String text) {
    bool isSelected = _selectedGender == text;
    return Expanded(
      child: GestureDetector(
        onTap: () => _selectGender(text),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primaryBlue : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.primaryBlue),
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                text,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.primaryBlue,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _genderButton("Male"),
          _genderButton("Female"),
          _genderButton("Others"),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: AppColors.primaryBlue,
        title: const Text(
          "UniBridge",
          style: TextStyle(color: AppColors.pureWhite),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 100,
              color: Colors.grey[200],
              child: Align(
                alignment: Alignment.bottomCenter,
                child: _buildProfileImage(),
              ),
            ),
            const SizedBox(height: 20),
            _buildTextField(_nameController, "Full Name"),
            const SizedBox(height: 10),
            _buildTextField(_emailController, "Email"),
            const SizedBox(height: 10),
            _buildGenderSelection(),
            const SizedBox(height: 10),
            _buildTextField(_shortBioController, "Short Bio"),
            const SizedBox(height: 10),
            _buildTextField(_longBioController, "Long Bio", maxLines: 4),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text("Save Profile"),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const MyQuestionScreen()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[300],
                foregroundColor: AppColors.primaryBlue,
                padding:
                const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
              child: const Text("My Questions"),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}