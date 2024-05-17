import 'dart:developer';
import 'package:Fluffy/constants/loading-indicator.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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

  UserActivity? userActivity;
  Topic? recentAccessTopic;

  // Timer? _timer;

  @override
  void initState() {
    syncUserActivity();
    // func to update topic every x seconds
    // _timer = Timer.periodic(Duration(minutes: 1), (timer) {
    //   if (mounted) {
    //     setState(() {});
    //   }
    // });
    super.initState();
  }

  @override
  void dispose() {
    // _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Dashboard",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.blue[50],
      ),
      body: userActivity != null && recentAccessTopic != null
          ? Column(
              children: [
                kIsWeb
                    ? Image.network(
                        recentAccessTopic!.ownerAvtUrl as String,
                        width: 36,
                        height: 36,
                        fit: BoxFit.cover,
                      )
                    : CachedNetworkImage(
                        height: 36,
                        imageUrl: recentAccessTopic!.ownerAvtUrl as String),
                Row(
                  children: [
                    Text("Topic title: ${recentAccessTopic?.title as String}",
                        style: TextStyle(color: Colors.black)),
                    SizedBox(
                      width: 20,
                    ),
                    Text("by ${recentAccessTopic?.owner}",
                        style: TextStyle(color: Colors.black))
                  ],
                ),
                Text(
                    "access since: ${getTimeDifference(userActivity?.timestamp as String)}",
                    style: TextStyle(color: Colors.black)),
              ],
            )
          : Center(child: LoadingIndicator(title: "Getting data")),
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
              setState(() {
                recentAccessTopic = topic;
              });
              // listen event callback
              topicRef.onValue.listen((data) {
                Topic topic1 = Topic.fromJson(
                    data.snapshot.value as Map<dynamic, dynamic>);
                setState(() {
                  recentAccessTopic = topic1;
                });
              });
            }
          }
        });
      } else {
        print('No data available.');
      }
    }, onError: (error) {
      // Xử lý lỗi
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
