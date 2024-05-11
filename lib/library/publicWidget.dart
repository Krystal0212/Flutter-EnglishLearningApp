import 'package:flutter/material.dart';
import 'package:Fluffy/objects/topic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../pages/flippingCardPage.dart';

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
  TextEditingController _topicTitleEditingController = TextEditingController();
  List<Topic> topics = [];

  @override
  void initState() {
    fetchTopicFromDatabase();
    super.initState();
  }

  @override
  void dispose() {
    _topicTitleEditingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("Discover new topics everyday"),
        ),
      ),
      body: !topics.isEmpty
          ? ListView.builder(
              itemBuilder: (BuildContext context, int index) {
                Topic topic = topics[index];
                return topicBlock(topic);
              },
              itemCount: topics.length,
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
            imageUrl: topic.ownerAvtUrl == 'url here'
                ? 'https://firebasestorage.googleapis.com/v0/b/finaltermandroid-ba01a.appspot.com/o/icons8-avatar-64.png?alt=media&token=efb2e06d-589a-40f0-96a0-a1eddfdbb352'
                : topic.ownerAvtUrl as String,
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
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context)=>FlippingCardPage(topic: topic,))
          );
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue[300] as Color, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void fetchTopicFromDatabase() {
    // listen once to fetch all topics,
    // then continue listen to future added topic
    dbRef.child('Topic').onChildAdded.listen((data) {
      Topic topic = Topic.fromJson(data.snapshot.value as Map);
      topics.insert(0, topic);
      setState(() {});
    });
  }
}
