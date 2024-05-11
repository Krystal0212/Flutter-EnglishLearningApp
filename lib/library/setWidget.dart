import 'dart:developer';

import 'package:Fluffy/objects/participant.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/objects/topic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../objects/word.dart';

class Set extends StatefulWidget {
  const Set({super.key});

  @override
  State<Set> createState() => _SetState();
}

class _SetState extends State<Set> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _topicTitleEditingController =
      TextEditingController();
  final _titleKey = GlobalKey<FormFieldState>();
  List<FocusNode> focusNodes = [];

  List<Topic> topics = [];
  List<Participant> participants = [];
  List<Word> words = [];
  bool isLoading = true;

  @override
  void initState() {
    fetchTopicFromDatabase();
    Future.delayed(const Duration(seconds: 5), () {
      if (topics.isEmpty) {
        setState(() {
          isLoading = false;
        });
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _topicTitleEditingController.dispose();
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Center(
          child: Text("My study set"),
        ),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
              color: Colors.blue,
            ))
          : topics.isEmpty
              ? Center(child: Text("No topic currently"))
              : ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return topicBlock(topics[index]);
                  },
                  itemCount: topics.length,
                ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue.shade300,
        onPressed: () {
          addTopicDialog();
        },
        child: Icon(
          Icons.add,
          color: Colors.black54,
        ),
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
        onTap: () {},
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
    // only topic that belongs to current user is gonna be added
    dbRef.child('Topic').onChildAdded.listen((data) {
      Topic topic =
          Topic.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      // add participant checking step here in the future
      if (topic.owner == auth.currentUser?.displayName) {
        setState(() {
          topics.insert(0, topic);
          isLoading = false;
        });
      }
    });
  }

  void addTopicDialog() {
    showDialog(
        context: context,
        builder: (context) {
          List<TextEditingController> termControllers = [];
          List<TextEditingController> definitionControllers = [];
          List<TextEditingController> descriptionControllers = [];

          List<Widget> termsWidgets = [];
          for (int i = 0; i < 4; i++) {
            FocusNode newFocusNode = FocusNode();
            TextEditingController newTermController = TextEditingController();
            TextEditingController newDefinitionController =
                TextEditingController();
            TextEditingController newDescriptionController =
                TextEditingController();

            termsWidgets.add(textFieldForTerm(newFocusNode, newTermController,
                newDefinitionController, newDescriptionController));
            // add term controller for word
            termControllers.add(newTermController);
            // add definition controller for word
            definitionControllers.add(newDefinitionController);
            // add des controller for word
            descriptionControllers.add(newDescriptionController);
            // add focus node for word
            focusNodes.add(newFocusNode);
          }
          return StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Dialog(
                backgroundColor: CupertinoColors.white,
                surfaceTintColor: Colors.transparent,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.blue[300] as Color, width: 1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    //Header
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text("Create new topic",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 15)),
                          ),
                          TextButton(
                              onPressed: () {
                                if (validateCreateTopic()) {
                                  saveTopic(
                                      termControllers,
                                      definitionControllers,
                                      descriptionControllers);
                                }
                              },
                              child: Text(
                                "Done",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ))
                        ],
                      ),
                    ),
                    // content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                key: _titleKey,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                validator: (titleText) {
                                  if (titleText == null || titleText.isEmpty) {
                                    return "Please enter title";
                                  }
                                  return null;
                                },
                                cursorColor: Colors.blue,
                                controller: _topicTitleEditingController,
                                decoration: const InputDecoration(
                                    helperText: "Title",
                                    hintText: "Topic, chapter,...",
                                    helperStyle: TextStyle(fontSize: 13)),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            ...termsWidgets,
                            SizedBox(
                              height: 12,
                            ),
                          ],
                        ),
                      ),
                    ),
                    //Footer
                    Padding(
                      padding:
                          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue),
                              onPressed: () {
                                TextEditingController newTermController =
                                    TextEditingController();
                                TextEditingController newDefinitionController =
                                    TextEditingController();
                                TextEditingController newDescriptionController =
                                    TextEditingController();

                                FocusNode newFocusNode = FocusNode();
                                setState(() {
                                  // add new word widget form
                                  termsWidgets.add(textFieldForTerm(
                                      newFocusNode,
                                      newTermController,
                                      newDefinitionController,
                                      newDescriptionController));
                                  // add term controller for new word
                                  termControllers.add(newTermController);
                                  // add definition controller for new word
                                  definitionControllers
                                      .add(newDefinitionController);
                                  // add des controller for word
                                  descriptionControllers
                                      .add(newDescriptionController);
                                  // add focus node for new word (no need)
                                  focusNodes.add(newFocusNode);
                                });

                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  newFocusNode.requestFocus();
                                });
                              },
                              child: Icon(
                                Icons.add,
                                color: Colors.white,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }).then((value) {
      _topicTitleEditingController.clear();
      participants.clear();
      words.clear();
    });
  }

  Widget textFieldForTerm(
      FocusNode focusNode,
      TextEditingController termController,
      TextEditingController definitionController,
      TextEditingController descriptionController) {
    return Container(
      color: Colors.blue[50],
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.all(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            focusNode: focusNode,
            controller: termController,
            cursorColor: Colors.blue,
            decoration: InputDecoration(
                helperText: "Term", helperStyle: TextStyle(fontSize: 13)),
          ),
          SizedBox(
            height: 12,
          ),
          TextField(
            controller: definitionController,
            cursorColor: Colors.blue,
            decoration: InputDecoration(
                helperText: "Definition", helperStyle: TextStyle(fontSize: 13)),
          ),
          SizedBox(
            height: 12,
          ),
          TextField(
            controller: descriptionController,
            cursorColor: Colors.blue,
            decoration: const InputDecoration(
                helperText: "Description (optional)",
                helperStyle: TextStyle(fontSize: 13)),
          ),
        ],
      ),
    );
  }

  void saveTopic(
      List<TextEditingController> termControllers,
      List<TextEditingController> definitionControllers,
      List<TextEditingController> descriptionControllers) {
    String? key = dbRef.child("Topic").push().key;
    String? name = auth.currentUser?.displayName;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yy').format(now);
    // Get current user as the first participant
    Participant participant = Participant(auth.currentUser?.uid, null, null);
    participants.add(participant);
    // Get word list
    for (int i = 0; i < termControllers.length; i++) {
      if (termControllers[i].text.isNotEmpty &&
          definitionControllers[i].text.isNotEmpty) {
        words.add(Word(termControllers[i].text, definitionControllers[i].text,
            descriptionControllers[i].text));
      }
    }
    if (words.length >= 4) {
      Topic toAddTopic = Topic(
          "PRIVATE",
          formattedDate,
          key!,
          _topicTitleEditingController.text,
          name!,
          "url here",
          participants,
          words);

      dbRef.child("Topic/$key").set(toAddTopic.toMap()).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.blue,
            content: Text(
              "Success",
              style: TextStyle(color: Colors.white),
            )));
        Navigator.of(context).pop();
        _topicTitleEditingController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.red,
          content: Text("Please fill at least 4 words",
              style: TextStyle(color: Colors.white))));
    }
  }

  bool validateCreateTopic() {
    if (_titleKey.currentState!.validate()) return true;
    return false;
  }
}
