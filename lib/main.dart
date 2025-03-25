import 'package:flutter/material.dart';
import 'login.dart';
import 'register.dart';
import 'splash.dart';
import 'forgotpass.dart'; // Import Forgot Password Screen
import 'educationquestion.dart';// Import Home Screen
import 'generalquestion.dart';
import 'allquestion.dart';
import 'askquestions.dart';
import 'giveanswer.dart';
import 'profile.dart';
import 'settings.dart';
import 'changepass.dart';
import 'theme.dart';
import 'myquestion.dart';
import 'editques.dart';
import 'answers.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';


void main() async {
  // Initialize Flutter binding
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Start the app
  runApp(MyApp());
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
      initialRoute: '/splash', // Set splash screen as the initial screen
      routes: {
        '/splash': (context) => const SplashScreen(), // Splash Screen
        '/login': (context) => const LoginScreen(), // Login Screen
        '/register': (context) => const RegisterScreen(), // Register Screen
        '/forgot_password': (context) => const ForgotPasswordScreen(), // Forgot Password Screen
        '/educationquestion': (context) => const QuestionScreen(), // Home Screen
        '/generalquestion': (context) => const GeneralQuestionScreen(),
        '/allquestion': (context) => const AllQuestionsScreen(),
        '/askquestion' : (context) => const AskQuestionsScreen(),
        '/giveanswer': (context) => const AnswerScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/changepass': (context) => const ChangePasswordScreen(),
        '/theme': (context) => const ThemeSettingsScreen(),
        '/myquestion': (context) => const MyQuestionScreen(),
        '/editques': (context) => const EditQuestion(),
        '/answers': (context) => const AllAnswerScreen(),



      },
    );
  }
}
