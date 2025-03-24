import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:email_validator/email_validator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'constraints/app_colors.dart';
import 'home.dart';
import 'profile.dart'; // Make sure this import exists

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscureText = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmailAndPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (userCredential.user != null && mounted) {
        _navigateToHome();
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-in cancelled')),
        );
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Create or update user document with Google data
        await _firestore.collection('users').doc(user.uid).set({
          'uid': user.uid,
          'fullName': user.displayName ?? 'New User',
          'email': user.email ?? '',
          'gender': 'Not specified', // Default value
          'shortBio': 'Tell us about yourself', // Default value
          'longBio': 'More about you...', // Default value
          'photoUrl': user.photoURL ?? '',
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        if (mounted) {
          _navigateToHome();
        }
      }
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e, provider: 'Google');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const QuestionScreen()),
    );
  }

  void _handleAuthError(FirebaseAuthException e, {String provider = ''}) {
    String errorMessage;
    switch (e.code) {
      case 'invalid-email':
        errorMessage = 'Invalid email format';
        break;
      case 'user-not-found':
      case 'wrong-password':
        errorMessage = 'Invalid email or password';
        break;
      case 'user-disabled':
        errorMessage = 'Account disabled';
        break;
      case 'account-exists-with-different-credential':
        errorMessage = 'Account already exists with different method';
        break;
      default:
        errorMessage = '${provider.isNotEmpty ? '$provider ' : ''}Sign-In failed: ${e.message}';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(errorMessage)),
    );
  }

  Future<void> _sendPasswordResetEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !EmailValidator.validate(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email')),
      );
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent')),
      );
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo Section
                  _buildLogoSection(),
                  const SizedBox(height: 20),

                  // Title Section
                  _buildTitleSection(),
                  const SizedBox(height: 20),

                  // Email Input
                  TextFormField(
                    controller: _emailController,
                    validator: (value) => EmailValidator.validate(value ?? '')
                        ? null
                        : 'Please enter a valid email',
                    decoration: _inputDecoration('Email'),
                  ),
                  const SizedBox(height: 16),

                  // Password Input
                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscureText,
                    validator: (value) => (value?.length ?? 0) >= 6
                        ? null
                        : 'Minimum 6 characters required',
                    decoration: _inputDecoration('Password').copyWith(
                      suffixIcon: IconButton(
                        icon: Icon(_obscureText
                            ? Icons.visibility_off
                            : Icons.visibility),
                        onPressed: () => setState(() => _obscureText = !_obscureText),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Forgot Password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _sendPasswordResetEmail,
                      child: const Text(
                        "Forgot Password?",
                        style: TextStyle(color: Colors.black54),
                      ),
                    ),
                  ),

                  // Login Button
                  _buildLoginButton(),
                  const SizedBox(height: 16),

                  // Social Media Login
                  _buildSocialLoginSection(),
                  const SizedBox(height: 20),

                  // Registration Prompt
                  _buildRegistrationPrompt(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogoSection() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Image.asset('assets/images/logo.png'),
        ),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "UniBridge",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        const Text(
          "Login Account",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.primaryBlue,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          "A place where you can ask and get better understanding of the world",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.black54),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithEmailAndPassword,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 14),
          backgroundColor: AppColors.primaryBlue,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25)),
        ),
        child: _isLoading
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text("Login",
            style: TextStyle(fontSize: 16, color: Colors.white)),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(child: Divider(color: Colors.black26)),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Text("or continue with",
                  style: TextStyle(color: Colors.black54)),
            ),
            Expanded(child: Divider(color: Colors.black26)),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SocialMediaIcon(
              assetPath: "assets/images/google.png",
              onTap: _signInWithGoogle,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegistrationPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an Account? "),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/register'),
          child: const Text(
            "Create One",
            style: TextStyle(
                color: AppColors.primaryBlue,
                fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _SocialMediaIcon extends StatelessWidget {
  final String assetPath;
  final VoidCallback onTap;

  const _SocialMediaIcon({
    required this.assetPath,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: CircleAvatar(
        radius: 22,
        backgroundColor: Colors.white,
        backgroundImage: AssetImage(assetPath),
      ),
    );
  }
}