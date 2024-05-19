import 'dart:developer';
import 'dart:math' as math;
import 'package:Fluffy/constants/dashboard-loading-indicator.dart';
import 'package:Fluffy/constants/gifs-lab.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

import '../objects/topic.dart';
import '../objects/userActivity.dart';
import 'dart:async';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late final StreamSubscription<User?> userSubscription;

  UserActivity? userActivity;
  Topic? recentAccessTopic;

  @override
  void initState() {
    syncUserActivity();
    checkCurrentUser();
    userSubscription = auth.userChanges().listen((User? user) {
      if (user != null) {
        if (mounted) {
          setState(() {});
        }
      }
    });
    super.initState();
  }

  Future<void> checkCurrentUser() async {
    User? user = auth.currentUser;
    if (user != null) {
      await user.reload();
    }
  }

  @override
  void dispose() {
    // _timer?.cancel();
    userSubscription.cancel();
    super.dispose();
  }

  final List<Map<String, String>> quotes = [
    {
      'quote':
          "Live as if you were to die tomorrow. Learn as if you were to live forever.",
      'author': "Mahatma Gandhi",
    },
    {
      'quote':
          "Education is the most powerful weapon which you can use to change the world.",
      'author': "Nelson Mandela",
    },
    {
      'quote':
          "The beautiful thing about learning is that nobody can take it away from you.",
      'author': "B.B. King",
    },
    {
      'quote':
          "Develop a passion for learning. If you do, you will never cease to grow.",
      'author': "Anthony J. D'Angelo",
    },
  ];

  Map<String, String> getRandomQuote() {
    final random = math.Random();
    int index = random.nextInt(quotes.length);
    return quotes[index];
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var parentHeight = MediaQuery.of(context).size.height;
    var parentWidth = MediaQuery.of(context).size.width;

    final randomQuote = getRandomQuote();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFDFCFB),
        // Set your custom color here
        scaffoldBackgroundColor: Color(0xFFFDFCFB),
        // Set scaffold background color
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFDFCFB), // Set AppBar background color
          titleTextStyle: TextStyle(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: Scaffold(
        backgroundColor: CupertinoColors.white,
        body: userActivity != null && recentAccessTopic != null
            ? SingleChildScrollView(
                child: Container(
                  color: Color(0xFF7B88D9),
                  child: Column(children: [
                    FadeInUp(
                      duration: Duration(milliseconds: 600),
                      child: Container(
                        height: parentHeight * 0.25,
                        width: parentWidth,
                        child: Padding(
                          padding: EdgeInsets.only(
                              top: parentHeight * 0.05,
                              left: parentWidth * 0.05,
                              right: parentWidth * 0.075),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Welcome back, ",
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Colors.white,
                                              fontWeight: FontWeight.w500,
                                              letterSpacing: 1),
                                        ),
                                        Text(
                                          FirebaseAuth.instance.currentUser!
                                              .displayName!,
                                          style: TextStyle(
                                              fontSize: 25,
                                              color: Color(0xFF000000),
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 1),
                                        ),
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Text(
                                              "Last topic access since :\n${getTimeDifference(userActivity!.timestamp.toString())}",
                                              style: TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.white54,
                                                  fontWeight: FontWeight.w500,
                                                  letterSpacing: 1),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10.0),
                                    // Adjust the radius as needed
                                    child: kIsWeb
                                        ? Image.network(
                                            FirebaseAuth.instance.currentUser!
                                                .photoURL!,
                                            width: 90,
                                            height: 90,
                                            fit: BoxFit.cover,
                                          )
                                        : CachedNetworkImage(
                                            height: 90,
                                            imageUrl: FirebaseAuth.instance
                                                .currentUser!.photoURL!,
                                          ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    FadeInUp(
                      duration: Duration(milliseconds: 800),
                      child: Container(
                        padding: EdgeInsets.only(
                            top: 25,
                            left: parentWidth * 0.125,
                            right: parentWidth * 0.125),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                              topLeft: Radius.circular(50),
                              topRight: Radius.circular(50)),
                        ),
                        height: parentHeight * 0.9,
                        width: parentWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              '" ${randomQuote['quote']} "',
                              style: TextStyle(
                                  fontSize: 16, fontStyle: FontStyle.italic),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Text(
                                  '- ${randomQuote['author']} -',
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 6),
                            Container(
                              constraints: BoxConstraints(
                                maxWidth: 500,
                                maxHeight: 500 / 1.8,
                              ),
                              width: MediaQuery.of(context).size.width * 0.7,
                              height:
                                  (MediaQuery.of(context).size.width * 0.7) /
                                      1.8,
                              child: Image.network(
                                LabGifs.exploreUrl,
                                fit: BoxFit.cover,
                              ),
                            ),
                            SizedBox(height: 10),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Recently Accessed Topic : ",
                                      style: TextStyle(
                                          fontSize: 16, letterSpacing: 1),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Text(
                                      (recentAccessTopic?.title as String)
                                          .toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1,
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            SizedBox(height: 5),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text("by "),
                                Text(
                                  "${recentAccessTopic!.owner!}   ",
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blueAccent),
                                ),
                                kIsWeb
                                    ? Image.network(
                                        recentAccessTopic!.ownerAvtUrl
                                            as String,
                                        width: 30,
                                        height: 30,
                                        fit: BoxFit.cover,
                                      )
                                    : CachedNetworkImage(
                                        height: 36,
                                        imageUrl: recentAccessTopic!.ownerAvtUrl
                                            as String),
                              ],
                            ),
                            SizedBox(height: 10),
                          ],
                        ),
                      ),
                    )
                  ]),
                ),
              )
            : Center(child: DashboardLoadingIndicator()),
      ),
    );
  }

  void syncUserActivity() async {
    // get data first time for the UI to show
    DataSnapshot snapshot =
        await dbRef.child('UserActivity/${auth.currentUser?.uid}').get();
    if (snapshot.exists) {
      userActivity =
          UserActivity.fromJson(snapshot.value as Map<dynamic, dynamic>);
      userActivity?.topics?.forEach((topicId, exists) async {
        if (exists) {
          DatabaseReference topicRef =
              FirebaseDatabase.instance.ref('Topic/$topicId');
          DataSnapshot snapshot = await topicRef.get();
          if (snapshot.exists) {
            Topic topic =
                Topic.fromJson(snapshot.value as Map<dynamic, dynamic>);
            setState(() {
              recentAccessTopic = topic;
            });
          }
        }
      });
    }

    // listen event to user's activity
    dbRef.child('UserActivity/${auth.currentUser?.uid}').onValue.listen((data) {
      if (data.snapshot.value != null) {
        UserActivity changedUserActivity =
            UserActivity.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
        userActivity = changedUserActivity;
        userActivity?.topics?.forEach((topicId, exists) async {
          if (exists) {
            DatabaseReference topicRef =
                FirebaseDatabase.instance.ref('Topic/$topicId');
            DataSnapshot snapshot = await topicRef.get();
            if (snapshot.exists) {
              Topic topic =
                  Topic.fromJson(snapshot.value as Map<dynamic, dynamic>);
              if (mounted) {
                setState(() {
                  recentAccessTopic = topic;
                });
              }
              // listen event callback
              topicRef.onValue.listen((data) {
                if (data.snapshot.value != null) {
                  Topic topic1 = Topic.fromJson(
                      data.snapshot.value as Map<dynamic, dynamic>);
                  if (mounted) {
                    setState(() {
                      recentAccessTopic = topic1;
                    });
                  }
                }
              });
            }
          }
        });
      } else {
        print('No data available.');
      }
    }, onError: (error) {
      log('Error: $error');
    });
  }

  String getTimeDifference(String input) {
    int timestamp = int.parse(input);
    DateTime accessTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    Duration difference = DateTime.now().difference(accessTime);

    if (difference.inMinutes < 1) {
      return 'access recently';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minutes ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hours ago';
    } else {
      return '${difference.inDays} days ago';
    }
  }
}
