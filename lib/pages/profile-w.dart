import 'dart:ui';
import 'package:Fluffy/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/constants/theme.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatelessWidget {

  Future<void> signOutUser(BuildContext context)async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final GoogleSignIn googleSignIn = GoogleSignIn();

    try{
      await auth.signOut();
      await googleSignIn.signOut();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.remove("userID");
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => LogInPage(title: 'Login',)));
    }
    catch (error){
      print('Error signing out: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        extendBodyBehindAppBar: true,
        backgroundColor: LabColors.bgColorScreen,
        body: Flexible(
          child: Stack(
            children: <Widget>[
              Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Container(
                      decoration: BoxDecoration(
                          image: DecorationImage(
                              image: AssetImage("assets/images/bg-profile.png"),
                              fit: BoxFit.cover)),
                      child: Stack(
                        children: <Widget>[
                          SafeArea(
                            bottom: false,
                            right: false,
                            left: false,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0, right: 0),
                              child: Column(
                                children: [
                                  CircleAvatar(
                                      backgroundImage: AssetImage(
                                          "assets/images/profile-img.jpg"),
                                      radius: 65.0),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 24.0),
                                    child: Text("Ryan Scheinder",
                                        style: TextStyle(
                                            color: LabColors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: 22)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Text("Photographer",
                                        style: TextStyle(
                                            color: LabColors.white
                                                .withOpacity(0.85),
                                            fontSize: 15,
                                            fontWeight: FontWeight.w600)),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 24.0, left: 42, right: 32),
                                    child: Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.spaceAround,
                                      crossAxisAlignment:
                                      CrossAxisAlignment.end,
                                      mainAxisSize: MainAxisSize.max,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text("2K",
                                                style: TextStyle(
                                                    color: LabColors.white,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            Text("Friends",
                                                style: TextStyle(
                                                    color: LabColors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 12.0))
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text("26",
                                                style: TextStyle(
                                                    color: LabColors.white,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            Text("Comments",
                                                style: TextStyle(
                                                    color: LabColors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 12.0))
                                          ],
                                        ),
                                        Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                          MainAxisAlignment.center,
                                          children: [
                                            Text("48",
                                                style: TextStyle(
                                                    color: LabColors.white,
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                    FontWeight.bold)),
                                            Text("Bookmarks",
                                                style: TextStyle(
                                                    color: LabColors.white
                                                        .withOpacity(0.8),
                                                    fontSize: 12.0))
                                          ],
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Flexible(
                    flex: 1,
                    child: Container(
                        child: SingleChildScrollView(
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 32.0, right: 32.0, top: 42.0),
                              child: Column(children: [
                                Text("About me",
                                    style: TextStyle(
                                        color: LabColors.text,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 17.0)),
                                Padding(
                                  padding: const EdgeInsets.only(
                                      left: 24.0, right: 24, top: 30, bottom: 24),
                                  child: Text(
                                      "An artist of considerable range, Ryan - the name taken by Meblourne-raised, Brooklyn-based Nick Murphy - writes, performs and records all of his own music.",
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: LabColors.time)),
                                ),
                              ]),
                            ))),
                  ),
                ],
              ),
              Align(
                alignment: Alignment.center,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              foregroundColor: LabColors.white,
                              backgroundColor: LabColors.info,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(32.0),
                              ),
                              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 12),
                            ),
                            onPressed: () {
                              // Respond to button press
                              Navigator.pushReplacementNamed(context, '/home');
                            },
                            child: Text("Follow", style: TextStyle(fontSize: 13.0)),
                          )
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 4.0),
                        child: RawMaterialButton(
                          constraints: BoxConstraints.tight(Size(38, 38)),
                          onPressed: () {
                          },
                          elevation: 4.0,
                          fillColor: Color.fromRGBO(136, 136, 136, 1.0),
                          child: Icon(FontAwesomeIcons.twitter,
                              size: 14.0, color: Colors.white),
                          padding: EdgeInsets.all(0.0),
                          shape: CircleBorder(),
                        ),
                      ),
                      RawMaterialButton(
                        constraints: BoxConstraints.tight(Size(38, 38)),
                        onPressed: (){signOutUser(context);},
                        elevation: 4.0,
                        fillColor: Color.fromRGBO(136, 136, 136, 1.0),
                        child: Icon(Icons.logout,
                            size: 14.0, color: Colors.white),
                        padding: EdgeInsets.all(0.0),
                        shape: CircleBorder(),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

