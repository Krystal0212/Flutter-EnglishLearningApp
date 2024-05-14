import 'package:Fluffy/pages/homeNav.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'package:Fluffy/pages/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyEnglishLearningApp());
}

Future<String?> getUserID() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getString('userID');
}

class MyEnglishLearningApp extends StatelessWidget {
  MyEnglishLearningApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FutureBuilder(
        future: getUserID(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in, navigate to profile page
            return MyHomePage(userID: snapshot.data!);
          } else {
            // User is not logged in, navigate to login page
            return LogInPage(title: 'Login',);
          }
        },
      ),
    );
  }
}