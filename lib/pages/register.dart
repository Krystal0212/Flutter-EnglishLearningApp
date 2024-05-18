
import 'package:Fluffy/constants/loading-indicator.dart';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignUpPage extends StatefulWidget {
  SignUpPage({super.key, required this.title});

  String title;

  @override
  State<SignUpPage> createState() => SignUpPageState();
}

class SignUpPageState extends State<SignUpPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late TextEditingController userNameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

  bool isLoading = false;
  bool showPassword = false;

  User? user;

  @override
  void initState() {
    super.initState();
    userNameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
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
            left: 10,
            top: 30,
            child: FadeInUp(
              duration: Duration(milliseconds: 1600),
              child: Container(
                margin: EdgeInsets.only(top: 230, right: 190),
                child: Center(
                  child: Text(
                    widget.title,
                    style: TextStyle(
                        color: Colors.black54,
                        fontSize: 55,
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
            right: 120,
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

  Widget getSignInTextFields() {
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
                        controller: userNameController,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "User",
                            hintStyle: TextStyle(color: Colors.grey[700])),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(143, 148, 251, 1)))),
                      child: TextField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Email",
                            hintStyle: TextStyle(color: Colors.grey[700])),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(
                                  color: Color.fromRGBO(143, 148, 251, 1)))),
                      child: TextField(
                        controller: passwordController,
                        obscureText: true,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Password",
                            hintStyle: TextStyle(color: Colors.grey[700])),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(8.0),
                      child: TextField(
                        controller: confirmPasswordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        decoration: InputDecoration(
                            border: InputBorder.none,
                            hintText: "Confirm Password",
                            hintStyle: TextStyle(color: Colors.grey[700])),
                      ),
                    )
                  ],
                ),
              )),
          SizedBox(
            height: 50,
          ),
          FadeInUp(
              duration: Duration(milliseconds: 1900),
              child: signUpUserButton()
          ),
          SizedBox(
            height: 30,
          ),
        ],
      ),
    );
  }

  String validateInput(String userName, String email, String password,
      String confirmPassword) {
    if (userName.contains(" ")) {
      return "Username should not contain spaces";
    } else if (userName.length > 10) {
      return "Username too long";
    }
    else if (email == null || email.isEmpty) {
      return 'Please enter your email';
    }
    else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 'Please enter a valid email';
    }
    else if (passwordController.text.isEmpty) {
      return "Password field is empty";
    }
    else if (confirmPasswordController.text.isEmpty){
      return "Confirm password field is empty";
    }
    else if (password != confirmPassword) {
      return "Passwords are not match";
    }
    else return 'Validated';
  }

  Widget signUpUserButton() {
    return InkWell(
      onTap: () async {
        String validateResult =
        validateInput(
            userNameController.text,
            emailController.text,
            passwordController.text,
            confirmPasswordController.text
        );
        if (validateResult == "Validated") {
          setState(() {
            isLoading = true; // Stop loading
          });
          try {
            UserCredential userCredential = await auth.createUserWithEmailAndPassword(
              email: emailController.text.trim(),
              password: passwordController.text.trim(),
            );

            await userCredential.user!.sendEmailVerification();

            await userCredential.user!.updateDisplayName(userNameController.text);
            await userCredential.user!.updatePhotoURL("https://firebasestorage.googleapis.com/v0/b/cross-platform-final-term.appspot.com/o/profile-img.jpg?alt=media&token=a3619fea-311e-4529-bbc6-dc9809ce8f80");
            await userCredential.user!.reload();

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: Duration(seconds: 2),
                content: Text("Verification email has been sent. Please check your email !"),
              ),
            );

            Navigator.of(context).pop();

          } on FirebaseAuthException catch (error) {
            if (error.code == 'email-already-in-use') {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: Duration(seconds: 2),
                  content: Text('Email registered, please log in'),
                ),
              );
            } else {
              print('Failed to register user: ${error.toString()}');
            }
          }
          setState(() {
            isLoading = false; // Stop loading
          });
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
            "Sign Up",
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Container(
              child: Column(
                children: [getBackGround(), getSignInTextFields()],
              ),
            ),
          ),
          if (isLoading)
            Positioned.fill(
              child: Container(
                color: Colors.black.withOpacity(0.5),
                // Semi-transparent overlay
                child: Center(
                  child: LoadingIndicator(), // Your custom loading indicator
                ),
              ),
            ),
          Positioned(
            top: 10,
            left: 10,
            child: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
