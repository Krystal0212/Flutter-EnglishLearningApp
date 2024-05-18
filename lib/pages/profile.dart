import 'dart:async';
import 'dart:developer';
import 'package:Fluffy/constants/avatar-loading-indicator.dart';
import 'package:Fluffy/constants/loading-indicator.dart';
import 'package:Fluffy/constants/gifs-lab.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:Fluffy/pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/constants/theme.dart';
import 'package:giffy_dialog/giffy_dialog.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart' as path;
import 'dart:io';

class Profile extends StatefulWidget {
  Profile({super.key});

  @override
  State<Profile> createState() => MyProfileState();
}

class MyProfileState extends State<Profile> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleAuthProvider authProvider = GoogleAuthProvider();
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  late bool isLoading;
  late File image;
  late Uint8List webImage;

  // there are some problems with this userName
  // so I comment it
  // late String userName;
  late User user;
  late bool isCasualUser;
  late bool isGoogleUser;
  late final StreamSubscription<User?> userSubscription;

  final String defaultLink =
      "https://firebasestorage.googleapis.com/v0/b/cross-platform-final-term.appspot.com/o/profile-img.jpg?alt=media&token=a3619fea-311e-4529-bbc6-dc9809ce8f80";

  @override
  initState() {
    super.initState();
    isLoading = false;
    isCasualUser = false;
    isGoogleUser = false;
    user = auth.currentUser!;
    // userName = user.displayName ?? 'User';
    checkCurrentUser();
    userSubscription = auth.userChanges().listen((User? user) {
      if (user != null) {
        if (mounted) {
          setState(() {});
        }
      }
    });
    getProviders();
  }

  @override
  void dispose() {
    userSubscription.cancel();
    super.dispose();
  }

  Future<void> checkCurrentUser() async {
    User? user = auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  void setIndicatorFalse() {
    setState(() {
      // userName = user.displayName.toString();
      isLoading = false;
    });
  }

  void setIndicatorTrue() {
    setState(() {
      isLoading = true;
    });
  }

  Widget profileBox() {
    return Center(
      child: Column(
        children: [
          Container(
            width: 155,
            height: 155,
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 85,
                  child: CachedNetworkImage(
                    imageUrl: auth.currentUser!.photoURL!,
                    placeholder: (context, url) => AvatarLoadingIndicator(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                    imageBuilder: (context, imageProvider) => Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        image: DecorationImage(
                          image: imageProvider,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Align(
                    alignment: Alignment.bottomRight,
                    child: Container(
                      margin: EdgeInsets.only(bottom: 10, right: 10),
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: Colors.white, // Background color for the icon
                        shape: BoxShape.circle,
                      ),
                      child: IconButton(
                        onPressed: () {
                          changeAvatar();
                        },
                        icon: Icon(
                          Icons.add_photo_alternate,
                          size: 16,
                        ),
                        color: Colors.black,
                      ),
                    ))
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 30.0),
            child: Text(auth.currentUser?.displayName as String,
                style: TextStyle(
                    color: LabColors.black,
                    fontWeight: FontWeight.bold,
                    fontSize: 30)),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 15.0),
            child: Text(user.email.toString(),
                style: TextStyle(
                    color: LabColors.black.withOpacity(0.85),
                    fontSize: 25,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  void getProviders() {
    User user = auth.currentUser!;
    for (UserInfo provider in user.providerData) {
      if (provider.providerId == "google.com") {
        if (mounted) {
        setState(() {
          isGoogleUser = true;
        });}
      }
      if (provider.providerId == "password") {
        if (mounted) {
        setState(() {
          isCasualUser = true;
        });}
      }
    }
  }

  Future<void> signOutUser() async {
    setIndicatorTrue();
    try {
      await auth.signOut();
      if (mounted) {
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => LogInPage(
                      title: 'Login',
                    )));
      }
    } catch (error) {
      print('Error signing out: $error');
    }
    setIndicatorFalse();
  }

  Future<String> sendAvatarToFirebaseStorage(
      dynamic image, String fileName) async {
    if (image != null && fileName != "") {
      String UID = auth.currentUser!.uid;
      UploadTask uploadTask;
      Reference storageReference =
          FirebaseStorage.instance.ref().child('userAvatar/$UID');

      if (kIsWeb) {
        SettableMetadata metadata = SettableMetadata(contentType: 'image/jpeg');
        uploadTask = storageReference.putData(image, metadata);
      } else {
        uploadTask = storageReference.putFile(image);
      }

      await uploadTask.whenComplete(() => null);
      String? downloadUrl = await storageReference.getDownloadURL();

      return downloadUrl;
    } else {
      return "";
    }
  }

  Future<void> updateUserParticipantData(String newName) async {
    final user = auth.currentUser;
    if (user != null) {
      DataSnapshot topicsSnapshot = await dbRef.child("Topic").get();

      if (topicsSnapshot.exists) {
        Map<dynamic, dynamic> topics =
        topicsSnapshot.value as Map<dynamic, dynamic>;
        topics.forEach((key, value) async {
          if (value is Map<dynamic, dynamic> && value['participant'] != null) {
            List<dynamic> participants =
            List<dynamic>.from(value['participant']);
            participants.asMap().forEach((index, participant) async {
              if (participant is Map<dynamic, dynamic> &&
                  participant['userID'] == user.uid) {
                await dbRef
                    .child('Topic/$key/participant/$index/userName')
                    .set(newName);
              }
            });
          }
        });
      }
    }
  }

  Future<void> updateUserTopicField(String field, String? fieldData) async {
    try {
      String? currentUserName = auth.currentUser?.displayName;

      if (currentUserName == null) return;

      Query query =
      dbRef.child('Topic').orderByChild('owner').equalTo(currentUserName);

      query.once().then((DatabaseEvent event) {
        if (event.snapshot.exists) {
          Map<dynamic, dynamic> topics =
              event.snapshot.value as Map<dynamic, dynamic>? ?? {};
          topics.forEach((key, value) {
            dbRef.child('Topic/$key').update({field: fieldData});
          });
        }
      });
    } catch (error) {
      log("Error updating topic fields: $error");
    }
  }



  Future<void> changeUsername() async {
    TextEditingController userNameController = TextEditingController();

    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change Username'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Please enter your new username:'),
                TextField(
                  controller: userNameController,
                  decoration: InputDecoration(hintText: "New Username"),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Submit'),
              onPressed: () async {
                String newUserName = userNameController.text;

                if (newUserName.isEmpty) {
                  String title = "There is something wrong !";
                  String content = "Username could not be empty";
                  showGifDialog(LabGifs.errorGifUrl, title, content);
                } else {
                  await updateUserTopicField('owner', userNameController.text);
                  await updateUserParticipantData(userNameController.text);
                  await auth.currentUser
                      ?.updateDisplayName(userNameController.text);
                  await auth.currentUser?.reload();
                  setState(() {
                    // userName = auth.currentUser!.displayName!;
                  });
                  Navigator.of(context).pop();

                  String title = "Woohoo !";
                  String content = "Changed username successfully";
                  showGifDialog(LabGifs.changeGifUrl, title, content);
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> changeAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    String url = "";

    if (pickedFile != null) {
      if (kIsWeb) {
        webImage = await pickedFile.readAsBytes();
        url = await sendAvatarToFirebaseStorage(webImage, pickedFile.name);
      } else {
        url = await sendAvatarToFirebaseStorage(
            File(pickedFile.path), path.basename(pickedFile.path));
      }

      if (url.isNotEmpty) {
        await auth.currentUser?.updatePhotoURL(url);
        await auth.currentUser?.reload();
        await updateUserTopicField('ownerAvtUrl', auth.currentUser?.photoURL);
        String title = "Woohoo !";
        String content = "Changed avatar successfully";
        showGifDialog(LabGifs.changeGifUrl, title, content);
      }
    } else {
      String title = "There is something wrong !";
      String content = "Could not get the image data";
      showGifDialog(LabGifs.errorGifUrl, title, content);
    }
  }

  Future<void> setPasswordForUser(String email, String password) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
          email: email.trim(), password: password.trim());

      User? user = auth.currentUser;

      await user?.linkWithCredential(credential);
      await user?.reload();
      await user?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      String content = "Failed to set your password. Please try again";
      String title = "There is something wrong !";

      if (e.code == 'provider-already-linked') {
        content =
            "This account is already linked. Please use another account to link";
      }

      showGifDialog(LabGifs.errorGifUrl, title, content);
    }
  }

  Future<void> linkEmailPasswordForAccount() {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    bool isPasswordHidden = true;

    return showDialog<void>(
        context: context,
        barrierDismissible: false, // User must tap a button to dismiss
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Create password for your account'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Please enter your new password:'),
                    TextField(
                      obscureText: isPasswordHidden,
                      controller: passwordController,
                      decoration: InputDecoration(
                        hintText: "Password",
                        suffixIcon: GestureDetector(
                          onTap: () {
                            setState(() {
                              isPasswordHidden =
                                  !isPasswordHidden; // Toggle the state to show or hide the password
                            });
                          },
                          child: Icon(
                            isPasswordHidden
                                ? Icons.visibility_off
                                : Icons.visibility,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    TextField(
                      obscureText: true,
                      controller: confirmPasswordController,
                      decoration: InputDecoration(hintText: "Confirm Password"),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                ),
                TextButton(
                  child: Text('Submit'),
                  onPressed: () async {
                    String validateResult = "";
                    String password = passwordController.text;
                    String confirmPassword = confirmPasswordController.text;

                    if (password.isEmpty) {
                      validateResult = "Password field is empty";
                    } else if (confirmPassword.isEmpty) {
                      validateResult = "Confirm password field is empty";
                    } else if (password != confirmPassword) {
                      validateResult = "Passwords are not match";
                    } else if (password == confirmPassword) {
                      await setPasswordForUser(auth.currentUser!.email!, password);
                      await auth.currentUser?.reload();
                      getProviders();

                      Navigator.of(context).pop();

                      String title = "Set password successfully";
                      String content =
                          "Verification email has been sent. Please check your email !";
                      showGifDialog(LabGifs.mailGifUrl, title, content);
                      return;
                    }
                    Navigator.of(context).pop();
                    if (validateResult != "") {
                      String title = "There is something wrong !";
                      String content = "$validateResult . Please try again !";
                      showGifDialog(LabGifs.errorGifUrl, title, content);
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  Future<bool> reAuthenticateUser(String email, String password) async {
    try {
      AuthCredential credential = EmailAuthProvider.credential(
          email: email.trim(), password: password.trim());
      await auth.currentUser?.reauthenticateWithCredential(credential);
      return true;
    } on FirebaseAuthException catch (e) {
      if (e.code == "invalid-credential") {
        String title = "There is something wrong !";
        String content =
            "Wrong password, please enter valid password of account";
        showGifDialog(LabGifs.errorGifUrl, title, content);
      } else {
        String title = "There is something wrong !";
        String content =
            "Wrong password, please enter valid password of account";
        showGifDialog(LabGifs.errorGifUrl, title, content);
        print("Error re-authenticating: ${e.code}");
      }
      return false;
    }
  }

  Future<void> changePasswordForAccount() {
    TextEditingController passwordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();
    bool isPasswordHidden = true;
    bool isNewPasswordHidden = true;

    return showDialog<void>(
        context: context,
        barrierDismissible: false, // User must tap a button to dismiss
        builder: (BuildContext context) {
          return StatefulBuilder(
              builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Set a new password'),
              content: SingleChildScrollView(
                child: ListBody(
                  children: <Widget>[
                    Text('Please enter requirements'),
                    TextField(
                      obscureText: isPasswordHidden,
                      controller: passwordController,
                      decoration: InputDecoration(
                          hintText: "Your Password",
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isPasswordHidden =
                                    !isPasswordHidden; // Toggle the state to show or hide the password
                              });
                            },
                            child: Icon(
                              isPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[700],
                            ),
                          )),
                    ),
                    TextField(
                      obscureText: isNewPasswordHidden,
                      controller: newPasswordController,
                      decoration: InputDecoration(
                          hintText: "New Password",
                          suffixIcon: GestureDetector(
                            onTap: () {
                              setState(() {
                                isNewPasswordHidden =
                                    !isNewPasswordHidden; // Toggle the state to show or hide the password
                              });
                            },
                            child: Icon(
                              isNewPasswordHidden
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: Colors.grey[700],
                            ),
                          )),
                    ),
                    TextField(
                      obscureText: true,
                      controller: confirmPasswordController,
                      decoration: InputDecoration(hintText: "Confirm Password"),
                    ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Dismiss the dialog
                  },
                ),
                TextButton(
                  child: Text('Submit'),
                  onPressed: () async {
                    String validateResult = "";
                    String newPassword = newPasswordController.text;
                    String password = passwordController.text;
                    String confirmPassword = confirmPasswordController.text;

                    if (password.isEmpty) {
                      validateResult = "Password field is empty";
                    } else if (newPassword.isEmpty) {
                      validateResult = "New password field is empty";
                    }
                    if (confirmPassword.isEmpty) {
                      validateResult = "Confirm password field is empty";
                    } else if (newPassword != confirmPassword) {
                      validateResult = "New passwords are not match";
                    } else if (newPassword == confirmPassword) {
                      String email = user.email!;
                      bool reAuthen = await reAuthenticateUser(email, password);

                      if (reAuthen) {
                        await auth.currentUser?.updatePassword(newPassword);
                        await auth.currentUser?.reload();
                        Navigator.of(context).pop();

                        String title = "Changed password successfully";
                        String content =
                            "Now you could use your new password to sign in";
                        showGifDialog(LabGifs.correctUrl, title, content);
                        return;
                      }
                    }
                    Navigator.of(context).pop();

                    if (validateResult != "") {
                      String title = "There is something wrong !";
                      String content = "$validateResult . Please try again !";
                      showGifDialog(LabGifs.errorGifUrl, title, content);
                    }
                  },
                ),
              ],
            );
          });
        });
  }

  Future<void> linkGoogleAccountForUser() async {
    try {
      setIndicatorTrue();

      late String? idToken;
      late String? userEmail;
      String username = auth.currentUser!.displayName!;

      if (kIsWeb) {
        UserCredential userCredential =
            await auth.signInWithPopup(authProvider);
        idToken = await userCredential.user?.getIdToken();
        userEmail = userCredential.user?.email;
      } else {
        final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
        final GoogleSignInAuthentication googleAuth =
            await googleUser!.authentication;

        idToken = googleAuth.idToken;
        userEmail = googleUser.email;
      }

      auth.currentUser!.updateDisplayName(username);
      setState(() {
        isGoogleUser = true;
      });

      String title = "Linked Google account successfully";
      String content =
          "Now you can sign in your app by using your Google account too !";
      showGifDialog(LabGifs.linkGoogleUrl, title, content);

      // AuthCredential credential = GoogleAuthProvider.credential(
      //   idToken: idToken,
      // );
      //
      // final User? currentUser = auth.currentUser;
      // assert(userEmail == currentUser!.email);
      //
      // await auth.currentUser?.linkWithCredential(credential);
      setIndicatorFalse();
    } on FirebaseAuthException catch (e) {
      setIndicatorFalse();
      switch (e.code) {
        case "provider-already-linked":
          String title = "There is something wrong !";
          String content =
              "The Google account has already been linked to the user";
          showGifDialog(LabGifs.errorGifUrl, title, content);
        default:
          print("Unknown error: ${e.code}");
          break;
      }
    }
  }

  void showGifDialog(String gifUrl, String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return GiffyDialog.image(
          backgroundColor: CupertinoColors.white,
          surfaceTintColor: Colors.transparent,
          Image.network(
            gifUrl,
            height: 200,
            fit: BoxFit.cover,
          ),
          title: Text(
            title,
            textAlign: TextAlign.center,
          ),
          content: Text(
            content,
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, 'OK'),
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.green, // Button background color
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Widget linkingAccountsGroup() {
    return Container(
      width: MediaQuery.of(context).size.width * 0.7,
      child: Column(
        children: [
          SizedBox(height: 20),
          (isGoogleUser && !isCasualUser)
              ? ElevatedButton(
                  onPressed: () async {
                    linkEmailPasswordForAccount();
                  },
                  child: Center(
                    child: Text("Create a password for your account"),
                  ))
              : SizedBox(),
          isCasualUser
              ? ElevatedButton(
                  onPressed: () async {
                    changePasswordForAccount();
                  },
                  child: Center(
                    child: Text("Change password"),
                  ))
              : SizedBox(),
          SizedBox(height: 20),
          ElevatedButton(
              onPressed: (!isGoogleUser) ? linkGoogleAccountForUser : () {},
              child: Center(
                child: Text(isGoogleUser
                    ? "Google account linked"
                    : "Link with your Google account"),
              )),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      backgroundColor: LabColors.bgColorScreen,
      body: Stack(
        children: [
          Column(
            children: [
              Stack(
                children: <Widget>[
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                            image: DecorationImage(
                                image:
                                    AssetImage("assets/gifs/dog-and-cat.gif"),
                                fit: BoxFit.cover)
                        ),
                        child: Stack(
                          children: <Widget>[
                            SafeArea(
                              right: false,
                              left: false,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 0, right: 0, top: 70, bottom: 42),
                                child: profileBox(),
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
                            width: 140,
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
                                changeUsername();
                              },
                              child: Text("Change Username",
                                  style: TextStyle(fontSize: 13.0)),
                            ),
                          ),
                          SizedBox(height: 5),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  Color.fromRGBO(136, 136, 136, 1.0),
                              // background color
                              shape: CircleBorder(),
                              // circular shape
                              padding: EdgeInsets.all(0),
                              // padding inside the button
                              elevation: 4.0,
                              // elevation of button
                              fixedSize: Size(38, 38), // size of the button
                            ),
                            onPressed: () {
                              signOutUser();
                            },
                            child: Icon(Icons.logout,
                                size: 14.0, color: Colors.white),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              linkingAccountsGroup(),
            ],
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
        ],
      ),
    );
  }
}
