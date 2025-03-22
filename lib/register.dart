import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'constraints/app_colors.dart';
import 'home.dart'; // Import your HomeScreen

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _obscureText = true;
  bool _isLoading = false;
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _registerWithEmailAndPassword() async {
    setState(() => _isLoading = true);
    try {
      final String email = _emailController.text.trim();
      final String password = _passwordController.text.trim();
      final String fullName = _fullNameController.text.trim();

      if (fullName.isEmpty || email.isEmpty || password.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please fill all fields')),
        );
        return;
      }

      if (password.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password must be at least 6 characters')),
        );
        return;
      }

      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name (optional)
      await userCredential.user?.updateDisplayName(fullName);

      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuestionScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      String errorMessage;
      switch (e.code) {
        case 'email-already-in-use':
          errorMessage = 'Email already registered';
          break;
        case 'invalid-email':
          errorMessage = 'Invalid email format';
          break;
        case 'weak-password':
          errorMessage = 'Password is too weak';
          break;
        default:
          errorMessage = 'Registration failed: ${e.message}';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage)),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
      await _auth.signInWithCredential(credential);

      if (userCredential.user != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const QuestionScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: ${e.message}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Column(
                  children: [
                    Image.asset('assets/images/logo.png', height: 50),
                    const SizedBox(height: 8),
                    const Text(
                      "UniBridge",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Title
                const Text(
                  "Create Account",
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
                const SizedBox(height: 20),

                // Full Name Input
                TextField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Email Input
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                const SizedBox(height: 16),

                // Password Input
                TextField(
                  controller: _passwordController,
                  obscureText: _obscureText,
                  decoration: InputDecoration(
                    labelText: "Password",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(25)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
                      onPressed: () => setState(() => _obscureText = !_obscureText),
                    ),
                  ),
                ),

                // Login Option
                Align(
                  alignment: Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        const Text("Already have an Account? "),
                        GestureDetector(
                          onTap: () => Navigator.pushNamed(context, '/login'),
                          child: const Text(
                            "Login",
                            style: TextStyle(
                              color: AppColors.primaryBlue,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Register Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registerWithEmailAndPassword,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      backgroundColor: AppColors.primaryBlue,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                    ),
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text("Register", style: TextStyle(fontSize: 16, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 12),

                // Terms and Privacy Policy
                const Text(
                  "By continuing, you agree to accept our",
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GestureDetector(
                      onTap: () {}, // Add terms navigation
                      child: const Text(
                        "Terms of Services",
                        style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Text(" and ", style: TextStyle(fontSize: 12, color: Colors.black54)),
                    GestureDetector(
                      onTap: () {}, // Add privacy policy navigation
                      child: const Text(
                        "Privacy Policy",
                        style: TextStyle(fontSize: 12, color: Colors.red, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // OR Divider
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(child: Divider(color: Colors.black26)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                      child: Text("or continue with", style: TextStyle(color: Colors.black54)),
                    ),
                    Expanded(child: Divider(color: Colors.black26)),
                  ],
                ),
                const SizedBox(height: 16),

                // Social Media Icons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _SocialMediaIcon(
                      assetPath: "assets/images/google.png",
                      onTap: _signInWithGoogle,
                    ),
                    const SizedBox(width: 16),
                    _SocialMediaIcon(
                      assetPath: "assets/images/apple.png",
                      onTap: () {}, // Add Apple Sign-In
                    ),
                    const SizedBox(width: 16),
                    _SocialMediaIcon(
                      assetPath: "assets/images/facebook.png",
                      onTap: () {}, // Add Facebook Sign-In
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
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