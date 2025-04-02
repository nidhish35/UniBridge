import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'login.dart';
import 'register.dart';
import 'splash.dart';
import 'forgotpass.dart';
import 'educationquestion.dart';
import 'generalquestion.dart';
import 'askquestions.dart';
import 'profile.dart';
import 'settings.dart';
import 'changepass.dart';
import 'theme.dart';
import 'myquestion.dart';
import 'editques.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniBridge',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const AuthCheck(), // AuthCheck determines the first screen dynamically
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/forgot_password': (context) => const ForgotPasswordScreen(),
        '/educationquestion': (context) => const QuestionScreen(),
        '/generalquestion': (context) => const GeneralQuestionScreen(),
        '/askquestion': (context) => const AskQuestionsScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/changepass': (context) => const ChangePasswordScreen(),
        '/theme': (context) => const ThemeSettingsScreen(),
        '/myquestion': (context) => const MyQuestionScreen(),
        '/editques': (context) => const EditQuestion(),
      },
    );
  }
}

/// **Checks if user is logged in or not**
class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const SplashScreen(); // Show splash screen while checking
        }

        if (snapshot.hasData) {
          return const QuestionScreen(); // User is logged in, go to home
        }

        return const LoginScreen(); // Otherwise, go to login screen
      },
    );
  }
}
