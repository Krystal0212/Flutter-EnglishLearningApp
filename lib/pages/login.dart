import 'package:Fluffy/pages/homeNav.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:github_sign_in_plus/github_sign_in_plus.dart';
import 'register.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

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
  late TextEditingController emailController;
  late TextEditingController passwordController;

  bool showPassword = false;

  User? user;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    auth.authStateChanges().listen((event) {
      setState(() {
        user = event;
      });
    });
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
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
                    "Login",
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
                    boxShadow: [
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
                            hintStyle: TextStyle(color: Colors.grey[700])),
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
                      ),
                    )
                  ],
                ),
              )),
          SizedBox(
            height: 40,
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
            height: 40,
          ),
          FadeInUp(
              duration: Duration(milliseconds: 1900), child: casualSignIn()),
          SizedBox(
            height: 10,
          ),
          FadeInUp(
              duration: Duration(milliseconds: 2000),
              child: TextButton(
                onPressed: () {},
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
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
                    "New To This App? Let's Sign Up",
                    style: TextStyle(color: Color.fromRGBO(143, 148, 251, 1)),
                  ))),
          SizedBox(
            height: 20,
          ),
        ],
      ),
    );
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
        String validateResult =
            validateInput(emailController.text, passwordController.text);
        if (validateResult == "Validated") {
          try {
            UserCredential userCredential =
                await auth.signInWithEmailAndPassword(
              email: emailController.text,
              password: passwordController.text,
            );

            // Store userID in shared preferences
            String userID = userCredential.user!.uid;

            await LogUserIn(userID);
          } on FirebaseAuthException catch (error) {
            if (error.code == 'wrong-password' ||
                error.code == 'invalid-credential') {
              // Show a snackbar indicating that the password is incorrect
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('Incorrect password. Please try again.'),
                ),
              );
            } else if (error.code ==
                'account-exists-with-different-credential') {
              RegisteredDialog();
            } else {
              print(error);
            }
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
      children: [googleSignInButton(), githubSignInButton()],
    );
  }

  Widget googleSignInButton() {
    return ElevatedButton(
      onPressed: () async {
        late UserCredential userCredential;
        try {
          if (kIsWeb) {
            // The `GoogleAuthProvider` can only be used while running on the web
            GoogleAuthProvider authProvider = GoogleAuthProvider();

            userCredential = await auth.signInWithPopup(authProvider);
          } else {
            final GoogleSignInAccount? googleUser =
                await GoogleSignIn().signIn();
            final GoogleSignInAuthentication googleAuth =
                await googleUser!.authentication;

            // Create a GoogleAuthProvider credential
            final AuthCredential credential = GoogleAuthProvider.credential(
              accessToken: googleAuth.accessToken,
              idToken: googleAuth.idToken,
            );

            // Sign in to Firebase with Google credentials
            userCredential =
                await FirebaseAuth.instance.signInWithCredential(credential);
            final User? user = userCredential.user;

            assert(!user!.isAnonymous);
            assert(await user!.getIdToken() != null);

            final User? currentUser = auth.currentUser;
            assert(user!.uid == currentUser!.uid);
          }

          String userID = userCredential.user?.uid ?? "User ID not found";

          if (userID != "User ID not found") {
            LogUserIn(userID);
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            RegisteredDialog();
          }
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
        final GithubAuthProvider githubProvider = GithubAuthProvider();
        late UserCredential userCredential;

        githubProvider.addScope('user:email');

        try {
          //Platform is web
          if (kIsWeb) {
            userCredential =
                await FirebaseAuth.instance.signInWithPopup(githubProvider);

            String userID = userCredential.user!.uid;
            LogUserIn(userID);
          } else {
            //Platform is mobile

            final GitHubSignIn gitHubSignIn = GitHubSignIn(
                clientId: 'Ov23liBeBpdnsMt5BO3a',
                clientSecret: '339fdd7c0ded5227d9a50c63e22e157caf262de2',
                redirectUrl:
                    'https://cross-platform-final-term.firebaseapp.com/__/auth/handler');

            final result = await gitHubSignIn.signIn(context);
            if (result.token != null) {
              // Create a credential from the GitHub access token
              final String token = result.token!;
              final AuthCredential credential =
                  GithubAuthProvider.credential(token);

              // Once signed in, return the UserCredential
              userCredential =
                  await FirebaseAuth.instance.signInWithCredential(credential);
            }

            String userID = userCredential.user!.uid;
            LogUserIn(userID);
            // final url = 'https://github.com/login/oauth/authorize' +
            //     '?client_id=Ov23liBeBpdnsMt5BO3a'
            //     '&scope=user:email';
            //
            // // Perform the authentication
            // final result = await FlutterWebAuth.authenticate(
            //     url: url,
            //     callbackUrlScheme:
            //         "com.example.finalterm"); // Your custom scheme set in native code
            //
            // // Extract token from result
            // final token = Uri.parse(result).queryParameters['code'];
            // if (token != null) {
            //   // Use the token to sign in with Firebase
            //   final AuthCredential credential =
            //       GithubAuthProvider.credential(token);
            //   userCredential =
            //       await FirebaseAuth.instance.signInWithCredential(credential);
            //   LogUserIn(userCredential?.user!.uid);
            // }
          }
        } on FirebaseAuthException catch (e) {
          if (e.code == 'account-exists-with-different-credential') {
            RegisteredDialog();
          }
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

  Future<void> LogUserIn(String userID) async {
    await storeUserID(userID);
    // print(userID);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Login successful.'),
      ),
    );

    Navigator.pushReplacement(
        context,
        MaterialPageRoute(
            builder: (context) => MyHomePage(
                  userID: userID,
                )));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [getBackGround(), getLogInTextFieldsAndNavigators()],
          ),
        ),
      ),
    );
  }
}
