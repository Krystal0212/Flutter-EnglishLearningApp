import 'dart:developer';

import 'package:Fluffy/constants/loading-indicator.dart';
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

class MyProfileState extends State<Profile> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleAuthProvider authProvider = GoogleAuthProvider();
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  late ImageProvider<Object> imageAvatar;
  late bool isLoading;
  late File image;
  late Uint8List webImage;

  // there are some problems with this userName
  // so I comment it
  // late String userName;
  late User user;
  late bool isCasualUser;
  late bool isGoogleUser;

  final String defaultLink =
      "https://firebasestorage.googleapis.com/v0/b/cross-platform-final-term.appspot.com/o/profile-img.jpg?alt=media&token=a3619fea-311e-4529-bbc6-dc9809ce8f80";

  final String mailGifUrl =
      "https://raw.githubusercontent.com/Shashank02051997/FancyGifDialog-Android/master/GIF's/gif7.gif";
  final String errorGifUrl = "";

  @override
  initState() {
    super.initState();
    imageAvatar = AssetImage(defaultLink);
    isLoading = false;
    isCasualUser = false;
    isGoogleUser = false;
    user = auth.currentUser!;
    // userName = user.displayName ?? 'User';
    // getAvatar();
    getProviders();
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
                    placeholder: (context, url) => CircularProgressIndicator(),
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
            padding: const EdgeInsets.only(top: 24.0),
            child: Text(auth.currentUser?.displayName as String,
                style: TextStyle(
                    color: LabColors.black,
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
        ],
      ),
    );
  }

  // Future<void> getAvatar() async {
  //   setIndicatorTrue();
  //   setState(() {
  //     imageAvatar = NetworkImage(
  //       auth.currentUser!.photoURL ?? defaultLink,
  //       scale: 1.0,
  //     );
  //     imageAvatar = "";
  //   });
  //   setIndicatorFalse();
  // }

  Future<void> getProviders() async {
    for (UserInfo provider in user.providerData) {
      if (provider.providerId == "google.com") {
        setState(() {
          isGoogleUser = true;
        });
      } else if (provider.providerId == "password") {
        setState(() {
          isCasualUser = true;
        });
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

  Future<void> changeAvatar() async {
    setIndicatorTrue();
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
        setState(() {
          imageAvatar = NetworkImage(url);
        });
        showResultSnackbar("Changed avatar successfully");
      }
    } else {
      showResultSnackbar("Could not get the image data");
    }
    setIndicatorFalse();
  }

  Future<void> setPasswordForUser(String email, String password) async {
    try {
      setIndicatorTrue();
      AuthCredential credential = EmailAuthProvider.credential(
          email: email.trim(), password: password.trim());

      User? user = auth.currentUser;

      await user?.linkWithCredential(credential);
      await user?.sendEmailVerification();
      setIndicatorFalse();
    } on FirebaseAuthException catch (e) {
      setIndicatorFalse();

      String gifUrl =
          "https://raw.githubusercontent.com/Shashank02051997/FancyGifDialog-Android/master/GIF's/gif7.gif";
      String content = "Failed to set your password. Please try again";
      String title = "There is something wrong";

      if (e.code == 'provider-already-linked') {
        content =
            "This account is already linked. Please use another account to link.";
      }

      showGifDialog(gifUrl, title, content);
    }
  }

  Future<void> linkEmailPasswordForAccount() {
    TextEditingController passwordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    return showDialog<void>(
        context: context,
        barrierDismissible: false, // User must tap a button to dismiss
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Create password for your account'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please enter your new password:'),
                  TextField(
                    obscureText: false,
                    controller: passwordController,
                    decoration: InputDecoration(hintText: "Password"),
                  ),
                  TextField(
                    obscureText: false,
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
                    await setPasswordForUser(
                        auth.currentUser!.email!, password);

                    setState(() {
                      isCasualUser = true;
                    });

                    Navigator.of(context).pop();

                    String gifUrl = mailGifUrl;
                    String title = "Set password successfully";
                    String content =
                        "Verification email has been sent. Please check your email !";
                    showGifDialog(gifUrl, title, content);
                    return;
                    // validateResult = "Verification email has been sent. Please check your email !";
                  }
                  if (validateResult != "") {
                    String gifUrl =
                        "https://raw.githubusercontent.com/Shashank02051997/FancyGifDialog-Android/master/GIF's/gif7.gif";
                    String title = "There is something wrong";
                    String content = "$validateResult . Please try again !";
                    showGifDialog(gifUrl, title, content);
                  }
                },
              ),
            ],
          );
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
        String validateResult =
            "Wrong password, please enter valid password of account";

        showResultSnackbar(validateResult);
      } else {
        print("Error re-authenticating: ${e.code}");
      }
      return false;
    }
  }

  Future<void> changePasswordForAccount() {
    TextEditingController passwordController = TextEditingController();
    TextEditingController newPasswordController = TextEditingController();
    TextEditingController confirmPasswordController = TextEditingController();

    return showDialog<void>(
        context: context,
        barrierDismissible: false, // User must tap a button to dismiss
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Set a new password'),
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  Text('Please enter requirements'),
                  TextField(
                    obscureText: false,
                    controller: passwordController,
                    decoration: InputDecoration(hintText: "Your Password"),
                  ),
                  TextField(
                    obscureText: false,
                    controller: newPasswordController,
                    decoration: InputDecoration(hintText: "New Password"),
                  ),
                  TextField(
                    obscureText: false,
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
                    setIndicatorTrue();
                    String email = user.email!;
                    bool reAuthen = await reAuthenticateUser(email, password);

                    if (reAuthen) {
                      await auth.currentUser?.updatePassword(newPassword);
                      validateResult = "Changed password successfully";
                    }
                  }
                  Navigator.of(context).pop();

                  setIndicatorFalse();

                  if (validateResult != "") {
                    showResultSnackbar(validateResult);
                  }
                },
              ),
            ],
          );
        });
  }

  void showResultSnackbar(String validateResult) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        duration: Duration(seconds: 2),
        content: Text(validateResult),
      ));
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
              onPressed: (!isGoogleUser)
                  ? () async {
                      try {
                        late String? idToken;
                        late String? userEmail;

                        if (kIsWeb) {
                          UserCredential userCredential =
                              await auth.signInWithPopup(authProvider);
                          idToken = await userCredential.user?.getIdToken();
                          userEmail = userCredential.user?.email;
                        } else {
                          final GoogleSignInAccount? googleUser =
                              await GoogleSignIn().signIn();
                          final GoogleSignInAuthentication googleAuth =
                              await googleUser!.authentication;

                          idToken = googleAuth.idToken;
                          userEmail = googleUser.email;
                        }

                        AuthCredential credential =
                            GoogleAuthProvider.credential(
                          idToken: idToken,
                        );

                        final User? currentUser = auth.currentUser;
                        assert(userEmail == currentUser!.email);

                        await auth.currentUser?.linkWithCredential(credential);
                      } on FirebaseAuthException catch (e) {
                        switch (e.code) {
                          case "provider-already-linked":
                            showResultSnackbar(
                                "The provider has already been linked to the user.");
                          default:
                            print("Unknown error: ${e.code}");
                            break;
                        }
                        setIndicatorFalse();
                      }
                    }
                  : () {},
              child: Center(
                child: Text(isGoogleUser
                    ? "Google account linked"
                    : "Link with your Google account"),
              )),
        ],
      ),
    );
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
                await updateUserTopicField('owner', userNameController.text);
                await updateUserParticipantData(userNameController.text);
                await auth.currentUser
                    ?.updateDisplayName(userNameController.text);
                await auth.currentUser?.reload();
                setState(() {
                  // userName = auth.currentUser!.displayName!;
                });
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
                                fit: BoxFit.cover)),
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

  Future<void> updateUserParticipantData(String newName) async {
    final user = FirebaseAuth.instance.currentUser;
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
}
