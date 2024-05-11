
import 'package:Fluffy/constants/loading-indacator.dart';
import 'package:Fluffy/objects/user.dart';
import 'package:Fluffy/pages/homepage.dart';
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
    User? currentUser = FirebaseAuth.instance.currentUser;
    return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: (currentUser != null && currentUser.emailVerified)
        ? FutureBuilder<TheUser>(
                  future: fetchUserDataFromDatabase(currentUser),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.hasError) {
                      // Handle errors appropriately
                      print("Error: ${userSnapshot.error}");
                    } else if (userSnapshot.hasData) {
                      return MyHomePage(user: userSnapshot.data!);
                    }
                    return Scaffold(
                      body: Center(
                        child: LoadingIndicator(),
                      ),
                    );
                  }
              )
        : LogInPage(title: 'Login')
    );
  }
}
