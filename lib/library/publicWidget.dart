import 'package:flutter/material.dart';
import 'package:Fluffy/objects/topic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/painting.dart';

import '../objects/participant.dart';
import '../topicDetail/topicDetailWidget.dart';

class Public extends StatefulWidget {
  const Public({super.key});

  @override
  State<Public> createState() => _PublicState();
}

class _PublicState extends State<Public> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Topic> topics = [];
  List<Topic> foundTopics = [];

  @override
  void initState() {
    syncTopicFromDatabase();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsets.only(top: 15.0, bottom: 15),
          child: Center(
            child: Text("Discover new topics everyday"),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(kToolbarHeight),
          child: Padding(
            padding: const EdgeInsets.all(5.0),
            child: Container(
              padding: EdgeInsets.only(bottom: 6, top: 4, right: 12, left: 12),
              child: TextField(
                onChanged: (value) => filterTopic(value),
                cursorColor: Colors.blue,
                decoration: const InputDecoration(
                    labelText: "Search for a topic",
                    labelStyle: TextStyle(color: Colors.black),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.blue,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(20.0)),
                      borderSide: BorderSide(color: Colors.blue),
                    ),
                    enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(20.0)),
                        borderSide: BorderSide(color: Colors.black)),
                    helperStyle: TextStyle(fontSize: 13)),
              ),
            ),
          ),
        ),
      ),
      body: !foundTopics.isEmpty
          ? ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                Topic topic = foundTopics[index];
                return topicBlock(topic);
              },
              itemCount: foundTopics.length,
            )
          : Center(
              child: Text("No topic currently"),
            ),
    );
  }

  Widget topicBlock(Topic topic) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(9),
      color: Colors.blue[50],
      child: ListTile(
        leading: ClipOval(
          child: CachedNetworkImage(
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            imageUrl: topic.ownerAvtUrl as String,
            placeholder: (context, url) => CircularProgressIndicator(),
          ),
        ),
        title: Text(
          topic.title as String,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
        subtitle: Wrap(
          runSpacing: 4.0,
          children: [
            Container(
                padding: EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.white,
                ),
                child: Text('${topic.word?.length} terms',
                    style: TextStyle(color: Colors.blue[800]))),
          ],
        ),
        trailing: Text(
          topic.owner as String,
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
        onTap: () {
          onClickPublicTopic(topic);
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue[300] as Color, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void syncTopicFromDatabase() {
    // listen once to fetch all topics,
    // then continue listen to future added topic
    dbRef.child('Topic').onChildAdded.listen((data) {
      Topic topic = Topic.fromJson(data.snapshot.value as Map);
      if (topic.access == 'PUBLIC') {
        topics.insert(0, topic);
        foundTopics.insert(0, topic);
        setState(() {});
      }
    });
    // listen to all change in Topic node
    dbRef.child('Topic').onChildChanged.listen((data) {
      Topic changedTopic =
          Topic.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      int index = topics.indexWhere((element) => element.id == changedTopic.id);
      setState(() {
        topics.removeAt(index);
        topics.insert(index, changedTopic);
        // also update this list
        foundTopics.removeAt(index);
        foundTopics.insert(index, changedTopic);
      });
    });
    // listen to deleted topic event in Topic node
    dbRef.child('Topic').onChildRemoved.listen((data) {
      Topic deletedTopic =
          Topic.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      int index = topics.indexWhere((element) => element.id == deletedTopic.id);
      setState(() {
        topics.removeAt(index);
        foundTopics.removeAt(index);
      });
    });
  }

  Future<void> onClickPublicTopic(Topic topic) async {
    String? userName = auth.currentUser?.displayName;
    String? uId = auth.currentUser?.uid;
    if (userName == topic.owner) {
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TopicDetail(topic: topic)));
      return;
    }
    DataSnapshot snapshot = await dbRef.child('Topic/${topic.id}').get();
    if (snapshot.exists) {
      Topic topic = Topic.fromJson(snapshot.value as Map<dynamic, dynamic>);
      bool isParticipant =
          topic.participant?.any((p) => p.userID == uId) ?? false;

      if (isParticipant) {
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => TopicDetail(topic: topic)));
      } else {
        showAddToSetDialog(topic, uId);
      }
    }
  }

  void showAddToSetDialog(Topic topic, String? uId) {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            surfaceTintColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            title: Center(
              child: Image.asset(
                height: 65,
                'lib/icon/question.png',
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Text('Add topic: ${topic.title} to your set ?',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.black, fontSize: 20)),
                ),
                SizedBox(
                  height: 12,
                ),
              ],
            ),
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(
                          color: Colors.blue[300] as Color, width: 2),
                    ),
                    backgroundColor: CupertinoColors.white),
                onPressed: () => Navigator.pop(context, 'NO'),
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 8, right: 20, left: 20),
                  child: const Text('NO',
                      style: TextStyle(color: Colors.blue, fontSize: 20)),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              TextButton(
                style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    backgroundColor: Colors.lightBlue),
                onPressed: () {
                  Navigator.pop(context, 'YES');
                  addParticipantToTopic(topic, uId);
                },
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 8, bottom: 8, right: 20, left: 20),
                  child: const Text('YES',
                      style: TextStyle(color: Colors.white, fontSize: 20)),
                ),
              ),
            ],
            actionsAlignment: MainAxisAlignment.center,
          );
        });
  }

  void addParticipantToTopic(Topic topic, String? uId) {
    Participant newParticipant = Participant(uId, null, null);
    topic.participant?.add(newParticipant);
    List<Participant> newParticipantsList = topic.participant!;
    dbRef
        .child('Topic/${topic.id}/participant')
        .set(newParticipantsList.map((w) => w.toMap()).toList())
        .then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        backgroundColor: Colors.blue,
        content: Text(
          "Topic added to study set",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ));
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => TopicDetail(topic: topic)));
    });
  }

  void filterTopic(String value) {
    List<Topic> results = [];
    if (value.isEmpty) {
      results = topics;
    } else {
      // topics ở đây đóng vai trò như 1 set origin
      // nếu trực tiếp dùng topics để làm data cho ListView thay vì tạo ra
      // 1 list khác sẽ làm mất đi set origin
      results = topics
          .where((topic) =>
              topic.title!.toLowerCase().contains(value.toLowerCase()))
          .toList();
    }

    setState(() {
      foundTopics = results;
    });
  }
}
