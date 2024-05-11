import 'dart:ui';
import 'package:Fluffy/objects/user.dart' as localUser;
import 'package:Fluffy/objects/user.dart';
import 'package:Fluffy/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/constants/theme.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatelessWidget {
  Profile({super.key, required this.user});

  TheUser user;

  Future<void> signOutUser(BuildContext context) async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try {
      await auth.signOut();
      await googleSignIn.signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("userID");
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => LogInPage(
                    title: 'Login',
                  )));
    } catch (error) {
      print('Error signing out: $error');
    }
  }

  ImageProvider<Object> getAvatar() {
    ImageProvider<Object> avatar;
    if (user.avatarUrl.isNotEmpty) {
      avatar = NetworkImage(user.avatarUrl,scale: 1.0,);
    } else {
      avatar = AssetImage("assets/images/profile-img.jpg");
    }
    return avatar;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      backgroundColor: LabColors.bgColorScreen,
      body: Stack(
        children: <Widget>[

          Column(
            children: [
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                    image: DecorationImage(
                        image:AssetImage("assets/images/bg-profile.png"),
                        fit: BoxFit.cover)),
                child: Stack(
                  children: <Widget>[
                    SafeArea(
                      bottom: false,
                      right: false,
                      left: false,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 0, right: 0, top: 20),
                        child: Center(
                          child: Column(
                            children: [
                              CircleAvatar(
                                  backgroundImage: getAvatar(),
                                  radius: 65.0),
                              Padding(
                                padding: const EdgeInsets.only(top: 24.0),
                                child: Text(user.displayName.toString(),
                                    style: TextStyle(
                                        color: LabColors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 22)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Text(user.email.toString(),
                                    style: TextStyle(
                                        color: LabColors.white.withOpacity(0.85),
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600)),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(
                                    top: 24.0, left: 42, right: 32),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              Container(),
            ],
          ),
          Align(
            alignment: Alignment.topRight,
            child: Padding(
              padding: const EdgeInsets.only(left: 0.0, top: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    margin: EdgeInsets.only(right: 8.0),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: LabColors.white,
                        backgroundColor: LabColors.info,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(32.0),
                        ),
                        padding: EdgeInsets.symmetric(
                            vertical: 10, horizontal: 12),
                      ),
                      onPressed: () {
                        // Respond to button press
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                      child: Text("Follow", style: TextStyle(fontSize: 13.0)),
                    ),
                  ),
                  SizedBox(height: 8,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(136, 136, 136, 1.0), // background color
                      shape: CircleBorder(), // circular shape
                      padding: EdgeInsets.all(0), // padding inside the button
                      elevation: 4.0, // elevation of button
                      fixedSize: Size(38, 38), // size of the button
                    ),
                    onPressed: () {},
                    child: Icon(Icons.edit, size: 14.0, color: Colors.white),
                  ),
                  SizedBox(height: 8,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color.fromRGBO(136, 136, 136, 1.0), // background color
                      shape: CircleBorder(), // circular shape
                      padding: EdgeInsets.all(0), // padding inside the button
                      elevation: 4.0, // elevation of button
                      fixedSize: Size(38, 38), // size of the button
                    ),
                    onPressed: () {
                      signOutUser(context);
                    },
                    child: Icon(Icons.logout, size: 14.0, color: Colors.white),
                  )
                ],
              ),
            ),
          ),
          Container()
        ],
      ),
    );
  }
}
