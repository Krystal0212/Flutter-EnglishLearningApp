import 'dart:developer';

import 'package:Fluffy/objects/participant.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

import '../objects/topic.dart';

class TopicAchievementPage extends StatefulWidget {
  final Topic topic;

  const TopicAchievementPage({super.key, required this.topic});

  @override
  State<TopicAchievementPage> createState() => _TopicAchievementPageState();
}

class _TopicAchievementPageState extends State<TopicAchievementPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();

  static late List<String> img;

  static late double mainPageWidth, mainPageHeight;

  static late List<Participant> participantsList;

  @override
  void initState() {
    //getParticipant();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clearCache() {}

  Future<String> takeImg(String uid) async {
    String path = 'userAvatar/$uid';
    String url = '';

    try {
      url = await FirebaseStorage.instance.ref(path).getDownloadURL();
      return url;
    } catch (e) {
      url = await FirebaseStorage.instance
          .ref()
          .child('profile-img.jpg')
          .getDownloadURL();
      return url;
    }
  }

  //take participant in topic and sort
  Future<List<String>> getParticipant() async {
    participantsList = List.from(widget.topic.participant!);

    participantsList.sort((a, b) {
      int totalA = (a.multipleChoicesResult ??= 0) + (a.fillWordResult ??= 0);
      int totalB = (b.multipleChoicesResult ??= 0) + (b.fillWordResult ??= 0);
      return totalB.compareTo(totalA);
    });

    img = [];

    for (Participant p in participantsList) {
      //log(name: p.userName ?? 'null userName', p.userID as String);
      p.userName ??= 'N/A';
    }

    int particiList = participantsList.length > 3 ? 3 : participantsList.length;
    //log('$particiList');
    for (int i = 0; i < particiList; i++) {
      //log(name: '$i', participantsList[i].userID as String);
      String a = await takeImg(participantsList[i].userID as String);
      //log(a);
      img.add(a);
    }

    return img;
  }

  //score board widget
  Widget scoreboard() {
    return FutureBuilder(
        future: getParticipant(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              //('${snapshot.data}');
              return Container(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //2nd place participant
                        if (participantsList.length > 1)
                          Container(
                              alignment: Alignment.topCenter,
                              margin: EdgeInsets.symmetric(
                                  horizontal: kIsWeb ? 15 : 5),
                              decoration: BoxDecoration(
                                color: Color(0xFFcbd0d4),
                                border: Border.all(
                                    color: Color(0xFF77868e), width: 3),
                                borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(100),
                                    topRight: Radius.circular(100)),
                              ),
                              width: kIsWeb ? 190 : mainPageWidth * 0.289,
                              height: kIsWeb ? 250 : mainPageHeight * 0.28,
                              child: Column(
                                children: [
                                  //user avatar
                                  SizedBox(
                                    width: kIsWeb ? 150 : mainPageWidth * 0.23,
                                    height: kIsWeb ? 125 : mainPageWidth * 0.3,
                                    child: Stack(
                                        alignment: Alignment.topCenter,
                                        children: [
                                          //user avatar border
                                          Container(
                                            margin: EdgeInsets.only(top: 15),
                                            width: kIsWeb
                                                ? 150
                                                : mainPageWidth * 0.19,
                                            height: kIsWeb
                                                ? 150
                                                : mainPageWidth * 0.19,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Color(0xFF77868e),
                                                width: 3, // border width
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                fit: BoxFit.fill,
                                                imageUrl: snapshot.data![1],
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          ),

                                          //ranking medal
                                          Positioned(
                                              top: 75,
                                              child: Container(
                                                decoration: BoxDecoration(
                                                    color: Color(0xFF5f6c73),
                                                    border: Border.all(
                                                        color:
                                                            Color(0xFF77868e),
                                                        width: 3),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            100)),
                                                child: Image.asset(
                                                    width: 40,
                                                    height: 40,
                                                    'lib/icon/secondPlaceMedal.png'),
                                              )),
                                        ]),
                                  ),

                                  //user name
                                  Container(
                                    child: Text(
                                      '${participantsList[1].userName}',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),

                                  //user score
                                  Container(
                                    child: Text(
                                      'Score: '
                                      '${(participantsList[1].multipleChoicesResult ??= 0) + (participantsList[1].fillWordResult ??= 0)}',
                                      textAlign: TextAlign.start,
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              )),

                        //1st place participant
                        if (participantsList.isNotEmpty)
                          Container(
                            alignment: Alignment.topCenter,
                            decoration: BoxDecoration(
                              color: Color(0xFFffff89),
                              border: Border.all(
                                  color: Color(0xFFd4af37), width: 3),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  topRight: Radius.circular(100)),
                            ),
                            width: kIsWeb ? 190 : mainPageWidth * 0.289,
                            height: kIsWeb ? 250 : mainPageHeight * 0.32,
                            child: Column(
                              children: [
                                //user avatar
                                SizedBox(
                                  width: kIsWeb ? 150 : mainPageWidth * 0.23,
                                  height: kIsWeb ? 150 : mainPageWidth * 0.35,
                                  child: Stack(
                                    alignment: Alignment.topCenter,
                                    children: [
                                      //user avatar border
                                      Positioned(
                                          top: 40,
                                          child: Container(
                                            width: kIsWeb
                                                ? 90
                                                : mainPageWidth * 0.19,
                                            height: kIsWeb
                                                ? 90
                                                : mainPageWidth * 0.19,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Color(0xFFd4af37),
                                                width: 3, // border width
                                              ),
                                            ),
                                            child: ClipOval(
                                              child: CachedNetworkImage(
                                                fit: BoxFit.fill,
                                                imageUrl: snapshot.data![0],
                                                placeholder: (context, url) =>
                                                    CircularProgressIndicator(),
                                                errorWidget:
                                                    (context, url, error) =>
                                                        Icon(Icons.error),
                                              ),
                                            ),
                                          )),

                                      //animated crown
                                      SizedBox(
                                        width: 80,
                                        height: 80,
                                        child: Image.asset(
                                            'assets/gifs/crown.gif'),
                                      ),

                                      //ranking medal
                                      Positioned(
                                          top: 100,
                                          child: Container(
                                            decoration: BoxDecoration(
                                                color: Color(0xFF9d8022),
                                                border: Border.all(
                                                    color: Color(0xFFd4af37),
                                                    width: 3),
                                                borderRadius:
                                                    BorderRadius.circular(100)),
                                            child: Image.asset(
                                                width: 40,
                                                height: 40,
                                                'lib/icon/firstPlaceMedal.png'),
                                          )),
                                    ],
                                  ),
                                ),

                                //user name
                                Container(
                                  child: Text(
                                    '${participantsList[0].userName}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                //user score
                                Container(
                                  child: Text(
                                    'Score: '
                                    '${(participantsList[0].multipleChoicesResult ??= 0) + (participantsList[0].fillWordResult ??= 0)}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                        //3rd place participant
                        if (participantsList.length > 2)
                          Container(
                            alignment: Alignment.topCenter,
                            margin: EdgeInsets.symmetric(
                                horizontal: kIsWeb ? 15 : 5),
                            decoration: BoxDecoration(
                              color: Color(0xFF9c4e15),
                              border: Border.all(
                                  color: Color(0xFF5b2a03), width: 3),
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(100),
                                  topRight: Radius.circular(100)),
                            ),
                            width: kIsWeb ? 190 : mainPageWidth * 0.289,
                            height: kIsWeb ? 250 : mainPageHeight * 0.28,
                            child: Column(
                              children: [
                                //user avatar
                                SizedBox(
                                  width: kIsWeb ? 150 : mainPageWidth * 0.23,
                                  height: kIsWeb ? 125 : mainPageWidth * 0.3,
                                  child: Stack(
                                      alignment: Alignment.topCenter,
                                      children: [
                                        //user avatar border
                                        Container(
                                          width: kIsWeb
                                              ? 90
                                              : mainPageWidth * 0.19,
                                          height: kIsWeb
                                              ? 90
                                              : mainPageWidth * 0.19,
                                          margin: EdgeInsets.only(top: 15),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Color(0xFF5b2a03),
                                              width: 3, // border width
                                            ),
                                          ),
                                          child: ClipOval(
                                            child: CachedNetworkImage(
                                              fit: BoxFit.fill,
                                              imageUrl: snapshot.data![2],
                                              placeholder: (context, url) =>
                                                  CircularProgressIndicator(),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                        ),

                                        //ranking medal
                                        Positioned(
                                            top: 75,
                                            child: Container(
                                              decoration: BoxDecoration(
                                                  color: Color(0xFF743504),
                                                  border: Border.all(
                                                      color: Color(0xFF5b2a03),
                                                      width: 3),
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          100)),
                                              child: Image.asset(
                                                  width: 40,
                                                  height: 40,
                                                  'lib/icon/thirdPlaceMedal.png'),
                                            )),
                                      ]),
                                ),

                                //user name
                                Container(
                                  child: Text(
                                    '${participantsList[2].userName}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),

                                //user score
                                Container(
                                  child: Text(
                                    'Score: '
                                    '${(participantsList[2].multipleChoicesResult ??= 0) + (participantsList[2].fillWordResult ??= 0)}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),

                    //the rest participant
                    if (participantsList.length > 3)
                      Expanded(
                          child: Container(
                        padding: EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          border:
                              Border.all(color: Colors.grey.shade800, width: 3),
                        ),
                        width: 600,
                        child: ListView.builder(
                            itemCount: participantsList.length > 47
                                ? 47
                                : participantsList.length - 3,
                            itemBuilder: (context, index) {
                              return Container(
                                alignment: Alignment.center,
                                margin: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade500,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                      color: Colors.grey.shade800, width: 2),
                                ),
                                child: ListTile(
                                  leading: Text(
                                    '#${index + 4}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  title: Text(
                                    '${participantsList[index + 3].userName}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                  trailing: Text(
                                    'Score: '
                                    '${(participantsList[index + 3].multipleChoicesResult ??= 0) + (participantsList[index + 3].fillWordResult ??= 0)}',
                                    textAlign: TextAlign.start,
                                    style: TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade800,
                                    ),
                                  ),
                                ),
                              );
                            }),
                      ))
                  ],
                ),
              );
            }
          }
          print('return circular');
          return Center(
            child: Container(
              width: mainPageWidth * 0.4,
              height: mainPageWidth * 0.4,
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () {
            clearCache();
            Navigator.pop(context);
          },
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.all(8),
            child: Tooltip(
              triggerMode: TooltipTriggerMode.tap,
              showDuration: Duration(seconds: 6),
              textStyle: TextStyle(
                  color: CupertinoColors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
              decoration: BoxDecoration(color: Colors.blueAccent),
              message:
                  '1 correct answer = 500 scores\nHall of Fame score = Multiple choices quiz + Fill word quiz',
              child: Icon(
                Icons.info,
                size: 24.0,
                color: CupertinoColors.white,
              ),
            ),
          )
        ],
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text('Hall of Fame'),
        backgroundColor: Colors.amber,
        titleTextStyle: const TextStyle(
            color: CupertinoColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 25),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          mainPageWidth = constraints.maxWidth;
          mainPageHeight = constraints.maxHeight;
          return Center(
            child: Container(
              color: CupertinoColors.white,
              width: kIsWeb ? mainPageWidth * 0.7 : mainPageWidth,
              height: kIsWeb ? mainPageHeight * 0.85 : mainPageHeight,
              child: scoreboard(),
            ),
          );
        },
      ),
    );
  }
}
