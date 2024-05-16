import 'package:Fluffy/constants/loading-indicator-card.dart';
import 'package:Fluffy/pages/homeNav.dart';

import 'register.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:Fluffy/constants/loading-indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:github_sign_in_plus/github_sign_in_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogInPage extends StatefulWidget {
  LogInPage({super.key, required this.title});

  String title;

  @override
  State<LogInPage> createState() => LogInPageState();
}

Future<void> storeUserID(String userID) async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('userID', userID);
}

class LogInPageState extends State<LogInPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleAuthProvider authProvider = GoogleAuthProvider();
  final GithubAuthProvider githubProvider = GithubAuthProvider();
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController resetPasswordController;

  bool isLoading = false;
  bool showPassword = false;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    resetPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void setIndicatorFalse() {
    setState(() {
      isLoading = false;
    });
  }

  void setIndicatorTrue(){
    setState(() {
      isLoading = true;
    });
  }

  Widget getBackGround() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage('assets/images/background.png'),
              fit: BoxFit.fill)),
      child: Stack(
        children: <Widget>[
          Positioned(
            child: FadeInUp(
              duration: Duration(milliseconds: 1600),
              child: Container(
                margin: EdgeInsets.only(top: 230, right: 190),
                child: Center(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 65,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            left: 30,
            width: 80,
            height: 200,
            child: FadeInUp(
                duration: Duration(seconds: 1),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/light-1.png'))),
                )),
          ),
          Positioned(
            left: 140,
            width: 80,
            height: 150,
            child: FadeInUp(
                duration: Duration(milliseconds: 1200),
                child: Container(
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage('assets/images/light-2.png'))),
                )),
          ),
          Positioned(
            right: 40,
            top: 40,
            width: 80,
            height: 150,
            child: FadeInUp(
              duration: Duration(milliseconds: 1300),
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/clock.png'))),
              ),
            ),
          ),
          Positioned(
            right: 160,
            top: 300,
            width: 70,
            height: 120,
            child: FadeInUp(
              duration: Duration(milliseconds: 1600),
              child: Container(
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image: AssetImage('assets/images/gradient_star.png'))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget getLogInTextFieldsAndNavigators() {
    return Padding(
      padding: EdgeInsets.all(30.0),
      child: Column(
        children: <Widget>[
          FadeInUp(
              duration: Duration(milliseconds: 1800),
              child: Container(
                padding: EdgeInsets.all(5),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Color.fromRGBO(143, 148, 251, 1)),
                    boxShadow: const [
                      BoxShadow(
                          color: Color.fromRGBO(143, 148, 251, .2),
                          blurRadius: 20.0,
                          offset: Offset(0, 10))
                    ]),
                child: Column(
                  children: <Widget>[
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(143, 148, 251, 1)))),
                      child: TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.grey[700]),
                        ),
                        style: TextStyle(
                          color: Colors.grey[900], // Sets the color of the input text
                          fontSize: 15.0, // Sets the size of the input text
                          fontWeight: FontWeight.bold, // Sets the weight of the input text
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        obscureText: !showPassword,
                        controller: passwordController,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: "Password",
                          hintStyle: TextStyle(color: Colors.grey[700]),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                showPassword =
                                    !showPassword; // Toggle the state to show or hide the password
                              });
                            },
                            child: Icon(
                              showPassword
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey[700],
                            ),
                          ),
                        ),
                        style: TextStyle(
                          color: Colors.grey[900], // Sets the color of the input text
                          fontSize: 15.0, // Sets the size of the input text
                          fontWeight: FontWeight.bold, // Sets the weight of the input text
                        ),
                      ),
                    )
                  ],
                ),
              )),
          SizedBox(
            height: 18,
          ),
          FadeInUp(
              duration: Duration(milliseconds: 1900),
              child: Container(
                height: 50,
                child: Center(
                    child: signInGroup(),
                    ),
              )),
          SizedBox(
            height: 18,
          ),
          FadeInUp(
              duration: Duration(milliseconds: 1900), child: casualSignIn()),
          SizedBox(
            height: 10,
          ),
          FadeInUp(
              duration: Duration(milliseconds: 2000),
              child: TextButton(
                onPressed: () {
                  showEmailDialog(context);
                },
                child: Text(
                  "Forgot Password ?",
                  style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1),
                  fontSize: 18),
                ),
              )),
          SizedBox(
            height: 2,
          ),
          FadeInUp(
              duration: Duration(milliseconds: 2100),
              child: TextButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => SignUpPage(
                                  title: 'Sign Up',
                                )));
                  },
                  child: Text(
                    "New To This App ? Let's Sign Up",
                    style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1),
                        fontSize: 18),
                  ))),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void showEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Reset Password"),
          content: TextField(
            controller: resetPasswordController,
            decoration: InputDecoration(hintText: "Enter your email"),
            keyboardType: TextInputType.emailAddress,
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text("Confirm"),
              onPressed: () {
                resetPassword(resetPasswordController.text);
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> resetPassword(String email) async {
    try {
      await auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      print(e.code);
      print(e.message);
    }
  }

  String validateInput(String? email, String password) {
    if (email == null || email.isEmpty) {
      return 'Please enter your email';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    if (passwordController.text.isEmpty) {
      return "Password field is empty";
    }
    return 'Validated';
  }

  Widget casualSignIn() {
    return InkWell(
      onTap: () async {
        setIndicatorTrue();

        String validateResult =
            validateInput(emailController.text, passwordController.text);
        if (validateResult == "Validated") {
          try {
            await auth
                .signInWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            )
                .then((_) {
              if (auth.currentUser != null) {
                // Access user details
                User user = auth.currentUser!;


                if (!user.emailVerified) {
                  UnverifiedDialog();
                } else {
                  LogUserIn(user);
                }
              }
            }).whenComplete(() {
              setIndicatorFalse();
            });
          } on FirebaseAuthException catch (error) {
            if (error.code == 'wrong-password' || error.code == 'invalid-credential') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('Account is not existed or incorrect password. Please try again.'),
                ),
              );
            } else if (error.code == 'account-exists-with-different-credential') {
              RegisteredDialog();
            } else {
              print(error);
            }

            setIndicatorFalse();
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            content: Text(validateResult),
          ));
        }
      },
      child: Container(
        height: 50,
        decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: LinearGradient(colors: [
              Color.fromRGBO(143, 148, 251, 1),
              Color.fromRGBO(143, 148, 251, .6),
            ])),
        child: Center(
          child: Text(
            "Login",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget signInGroup() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [googleSignInButton()],
    );
  }

  Widget googleSignInButton() {
    return ElevatedButton(
      onPressed: () async {
        late UserCredential userCredential;
        setIndicatorTrue();

        try {
          if (kIsWeb) {
            userCredential = await auth.signInWithPopup(authProvider);
          } else {
            final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
            final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;

            // Create a GoogleAuthProvider credential
            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );

            // Sign in to Firebase with Google credentials
            userCredential = await auth.signInWithCredential(credential);
          }

          String userID = userCredential.user?.uid ?? "User ID not found";
          User user = userCredential.user!;

          if (userID != "User ID not found") {
            LogUserIn(user);
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            RegisteredDialog();
          }
          setIndicatorFalse();
        }
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(), // Circular shape
        elevation: 0, // No shadow, // Padding can be adjusted
      ),
      child: Image.asset(
        'assets/images/google.png',
        width: 40,
        height: 40,
      ),
    );
  }

  Widget githubSignInButton() {
    return ElevatedButton(
      onPressed: () async {
        late UserCredential userCredential;
        setIndicatorTrue();
        githubProvider.addScope('user:email');

        try {
          if (kIsWeb) {
            //Platform is web
            userCredential = await auth.signInWithPopup(githubProvider);
          }
          else {
            //Platform is mobile
            final GitHubSignIn gitHubSignIn = GitHubSignIn(
                clientId: 'Ov23liBeBpdnsMt5BO3a',
                clientSecret: '339fdd7c0ded5227d9a50c63e22e157caf262de2',
                redirectUrl: 'https://cross-platform-final-term.firebaseapp.com/__/auth/handler');

            final result = await gitHubSignIn.signIn(context);
            if (result.token != null) {
              // Create a credential from the GitHub access token
              final String token = result.token!;
              final AuthCredential credential =
                  GithubAuthProvider.credential(token);

              // Once signed in, return the UserCredential
              userCredential =
                  await auth.signInWithCredential(credential);
            }
          }

          final User? userFromCredential = userCredential.user;
          final User? currentUser = auth.currentUser;
          assert(userFromCredential!.uid == currentUser!.uid);

          String userID = userCredential.user?.uid ?? "User ID not found";
          User user = userCredential.user!;

          if (userID != "User ID not found") {
            LogUserIn(user);
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            RegisteredDialog();
          }
          setIndicatorFalse();
        }
      },
      style: ElevatedButton.styleFrom(
        shape: CircleBorder(), // Circular shape
        elevation: 0, // No shadow, // Padding can be adjusted
      ),
      child: Image.asset(
        'assets/images/github.png',
        width: 40,
        height: 40,
      ),
    );
  }

  void UnverifiedDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Account is not verified'),
          content:
              Text('Please verify your email in our email verification sent !'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  void RegisteredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
              'Your Fluffy account is not registered for this sign-in method'),
          content: Text(
              'Please enable this method for using when logging in with the methods you registered'),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> LogUserIn(User currentUser) async {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        duration: Duration(seconds: 1),
        content: Text('Login successful.'),
      ),
    );

    setIndicatorFalse();

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(
                  user: currentUser,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [getBackGround(), getLogInTextFieldsAndNavigators()],
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                // Semi-transparent overlay
                child: Center(
                  child: LoadingIndicatorCard(), // Your custom loading indicator
                ),
              ),
            ),
        ],
      ),
    );
  }
}
