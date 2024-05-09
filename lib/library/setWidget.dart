import 'package:flutter/material.dart';
import 'package:Fluffy/objects/topic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class Set extends StatefulWidget {
  const Set({super.key});

  @override
  State<Set> createState() => _SetState();
}

class _SetState extends State<Set> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController _topicTitleEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // List<Topic> topics = fetchTopicFromDatabase();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text("your topic"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTopicDialog();
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // List<Topic> fetchTopicFromDatabase() {
  //   return topics;
  // }

  void addTopicDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            child: Container(
              padding: EdgeInsets.all(12),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _topicTitleEditingController,
                    decoration:
                        const InputDecoration(helperText: "Your topic name"),
                  ),
                  SizedBox(
                    height: 12,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        String? key = dbRef.child("Topic").push().key;
                        String? name = auth.currentUser?.displayName;
                        DateTime now = DateTime.now();
                        String formattedDate =
                            DateFormat('dd/MM/yy').format(now);

                        Topic toAddTopic = Topic(
                            "PRIVATE",
                            formattedDate,
                            key!,
                            _topicTitleEditingController.text,
                            name!,
                            "url here",
                            null,
                            null);

                        dbRef
                            .child("Topic/$key")
                            .set(toAddTopic.toMap())
                            .then((value) {
                          ScaffoldMessenger.of(context)
                              .showSnackBar(SnackBar(content: Text("Success")));
                          Navigator.of(context).pop();
                          _topicTitleEditingController.clear();
                        });
                      },
                      child: Text("Save"))
                ],
              ),
            ),
          );
        });
  }
}
