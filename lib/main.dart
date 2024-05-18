
import 'package:Fluffy/pages/homeNav.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:Fluffy/pages/login.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyEnglishLearningApp());
}

class MyEnglishLearningApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? currentUser = auth.currentUser;

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: currentUser == null
            ? LogInPage(title: 'Login')
            : MyHomePage(user: currentUser)
    );
  }

}
