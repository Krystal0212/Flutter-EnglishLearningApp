//import 'dart:ffi';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
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
  Timer? _timer;

  @override
  void initState() {
    updateTimeStamp();
    // func to update topic every x seconds
    _timer = Timer.periodic(Duration(seconds: 35), (timer) {
      updateTimeStamp();
    });
    super.initState();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text("Dashboard"),
          backgroundColor: Colors.blue[50],
        ),
        body: userActivity != null
            ? Column(
                children: [
                  CachedNetworkImage(
                      height: 36,
                      imageUrl: recentAccessTopic!.ownerAvtUrl as String),
                  Row(
                    children: [
                      Text(
                          "Topic title: ${recentAccessTopic?.title as String}"),
                      SizedBox(
                        width: 20,
                      ),
                      Text("by ${recentAccessTopic?.owner}")
                    ],
                  ),
                  Text(
                      "access since: ${getTimeDifference(userActivity?.timestamp as String)}"),
                ],
              )
            : Container());
  }

  void updateTimeStamp() async {
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
