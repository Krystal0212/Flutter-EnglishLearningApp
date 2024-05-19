import 'dart:convert';
import 'dart:developer';

import 'package:Fluffy/objects/participant.dart';
import 'package:Fluffy/topicDetail/topicDetailWidget.dart';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/objects/topic.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../constants/loading-indicator.dart';
import '../objects/userActivity.dart';
import '../objects/word.dart';
import 'package:flutter/foundation.dart';

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
  bool isAccessible = false;
  FocusNode focusForTitle = FocusNode();
  List<TextEditingController> termControllers = [];
  List<TextEditingController> definitionControllers = [];
  List<TextEditingController> descriptionControllers = [];
  List<Widget> termsWidgets = [];

  @override
  void initState() {
    syncTopicFromDatabase();
    Future.delayed(const Duration(seconds: 3), () {
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
    for (var term in termControllers) {
      term.dispose();
    }
    for (var def in definitionControllers) {
      def.dispose();
    }
    for (var des in descriptionControllers) {
      des.dispose();
    }
    focusForTitle.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: false,
        title: Center(
          child: Text(
            "My study set",
            style: TextStyle(color: Colors.black),
          ),
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
        heroTag: 'btn1',
        backgroundColor: Colors.blue.shade300,
        onPressed: () {
          addTopicDialog();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget topicBlock(Topic topic) {
    return Stack(children: [
      Card(
        elevation: 4,
        margin: EdgeInsets.all(9),
        color: Colors.blue[50],
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Colors.blue[300] as Color, width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: ListTile(
          leading: ClipOval(
            child: CachedNetworkImage(
              width: 36,
              height: 36,
              fit: BoxFit.cover,
              imageUrl: topic.ownerAvtUrl as String,
              placeholder: (context, url) => CircularProgressIndicator(),
              errorWidget: (context, url, error) => Icon(Icons.error),
            ),
          ),
          title: Text(
            topic.title as String,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black),
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
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black.withOpacity(0.75)),
          ),
          onTap: () {
            updateUserActivity(topic);
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => TopicDetail(topic: topic)));
          },
        ),
      ),
      if (topic.access == "PRIVATE")
        Positioned(
          left: 5.0,
          top: 5.0,
          child: Image.asset(
            'lib/icon/locked.png',
            height: 20,
          ),
        ),
    ]);
  }

  void updateUserActivity(Topic topic) {
    String? key = auth.currentUser?.uid;
    Map<String, bool> topics = {'${topic.id}': true};
    UserActivity userActivity = UserActivity(
        DateTime.now().millisecondsSinceEpoch.toString(), key, topics);
    dbRef.child('UserActivity/$key').update(userActivity.toMap());
  }

  void syncTopicFromDatabase() {
    // listen once to fetch all topics,
    // then continue listen to future added topic
    // only topic that belongs to current user is gonna be added
    dbRef.child('Topic').onChildAdded.listen((data) {
      Topic topic =
          Topic.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      if (topic.owner == auth.currentUser?.displayName ||
          topic.participant!.any((p) => p.userID == auth.currentUser?.uid)) {
        setState(() {
          topics.insert(0, topic);
          isLoading = false;
        });
      }
    });
    // listen to all change in Topic node
    dbRef.child('Topic').onChildChanged.listen((data) {
      Topic changedTopic =
          Topic.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      bool isParticipant = changedTopic.participant
              ?.any((p) => p.userID == auth.currentUser?.uid) ??
          false;
      int index = topics.indexWhere((element) => element.id == changedTopic.id);

      if (isParticipant) {
        // neu topic chua tung xuat hien, se thuc hien them topic
        if (index == -1) {
          setState(() {
            topics.insert(0, changedTopic);
          });
        } else {
          setState(() {
            topics.removeAt(index);
            topics.insert(index, changedTopic);
          });
        }
      }
    });
    // listen to deleted topic event in Topic node
    dbRef.child('Topic').onChildRemoved.listen((data) {
      Topic deletedTopic =
          Topic.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      int index = topics.indexWhere((element) => element.id == deletedTopic.id);
      setState(() {
        topics.removeAt(index);
      });
    });
  }

  void addTopicDialog() {
    showDialog(
        context: context,
        builder: (context) {
          termControllers.clear();
          definitionControllers.clear();
          descriptionControllers.clear();
          focusNodes.clear();
          termsWidgets.clear();
          for (int i = 0; i < 4; i++) {
            FocusNode newFocusNode = FocusNode();
            TextEditingController newTermController = TextEditingController();
            TextEditingController newDefinitionController =
                TextEditingController();
            TextEditingController newDescriptionController =
                TextEditingController();

            // Function to handle deletion
            void onDelete() {
              int index = termControllers.indexOf(newTermController);
              if (index != -1) {
                termControllers.removeAt(index);
                definitionControllers.removeAt(index);
                descriptionControllers.removeAt(index);
                termsWidgets.removeAt(index);
                focusNodes.removeAt(index);
                setState(() {});
              }
            }

            termsWidgets.add(textFieldForTerm(newFocusNode, newTermController,
                newDefinitionController, newDescriptionController, onDelete));
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
                    Row(
                      children: [
                        Expanded(child: SizedBox()),
                        Expanded(
                          flex: 4,
                          child: Text("Create new topic",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        TextButton(
                            onPressed: () {
                              if (validateCreateTopic()) {
                                if (saveTopic(
                                    termControllers,
                                    definitionControllers,
                                    descriptionControllers)) {
                                  Navigator.of(context).pop();
                                }
                              } else {
                                WidgetsBinding.instance
                                    .addPostFrameCallback((_) {
                                  focusForTitle.requestFocus();
                                });
                              }
                            },
                            child: Text(
                              "Done",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                    // content
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: TextFormField(
                                enableInteractiveSelection: false,
                                focusNode: focusForTitle,
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
                                    focusedBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.blue)),
                                    enabledBorder: UnderlineInputBorder(
                                        borderSide:
                                            BorderSide(color: Colors.black)),
                                    helperStyle: TextStyle(fontSize: 13)),
                              ),
                            ),
                            SizedBox(
                              height: 12,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Text("Everyone can access "),
                                  SizedBox(
                                    width: 12,
                                  ),
                                  Switch(
                                      activeColor: Colors.blue,
                                      inactiveTrackColor: Colors.white,
                                      value: isAccessible,
                                      onChanged: (value) {
                                        setState(() {
                                          isAccessible = value;
                                        });
                                      }),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 16,
                            ),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 20),
                              child: Row(
                                children: [
                                  Align(
                                    alignment: Alignment.centerLeft,
                                    child: Text(
                                      "(Swipe to delete a word)",
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.black.withOpacity(0.5),
                                      ),
                                    ),
                                  ),
                                  Expanded(child: SizedBox()),
                                  Align(
                                    alignment: Alignment.centerRight,
                                    child: IconButton(
                                      onPressed: () {
                                        importWords(setState);
                                      },
                                      icon: Icon(
                                        FluentIcons.arrow_upload_16_regular,
                                        color: Colors.blueAccent,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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

                                // Function to handle deletion
                                void onDelete() {
                                  int index = termControllers
                                      .indexOf(newTermController);
                                  if (index != -1) {
                                    termControllers.removeAt(index);
                                    definitionControllers.removeAt(index);
                                    descriptionControllers.removeAt(index);
                                    termsWidgets.removeAt(index);
                                    focusNodes.removeAt(index);
                                    setState(() {});
                                  }
                                }

                                setState(() {
                                  // add new word widget form
                                  termsWidgets.add(textFieldForTerm(
                                      newFocusNode,
                                      newTermController,
                                      newDefinitionController,
                                      newDescriptionController,
                                      onDelete));
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
      // Clear 2 list nay de tranh truong hop giu lai du lieu topic cu~
      participants.clear();
      words.clear();
      isAccessible = false;
    });
  }

  Widget textFieldForTerm(
      FocusNode focusNode,
      TextEditingController termController,
      TextEditingController definitionController,
      TextEditingController descriptionController,
      VoidCallback onDelete) {
    return Dismissible(
      key: ValueKey(termController),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        onDelete();
      },
      background: Container(
        color: Colors.red.withOpacity(1),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Image.asset(height: 60, "lib/icon/delete.png"),
      ),
      child: Container(
        color: Colors.blue[50],
        padding: EdgeInsets.all(8),
        margin: EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              enableInteractiveSelection: false,
              focusNode: focusNode,
              controller: termController,
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  helperText: "Term",
                  helperStyle: TextStyle(fontSize: 13)),
            ),
            SizedBox(height: 12),
            TextField(
              enableInteractiveSelection: false,
              controller: definitionController,
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  helperText: "Definition",
                  helperStyle: TextStyle(fontSize: 13)),
            ),
            SizedBox(height: 12),
            TextField(
              enableInteractiveSelection: false,
              controller: descriptionController,
              cursorColor: Colors.blue,
              decoration: InputDecoration(
                  focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.blue)),
                  enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.black)),
                  helperText: "Description (optional)",
                  helperStyle: TextStyle(fontSize: 13)),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> importWords(StateSetter setStateDialog) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);

    if (result != null && result.files.single.bytes != null) {
      final fileBytes = result.files.first.bytes;
      final csvString = utf8.decode(fileBytes!);
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);
      showAlertDialog("Added ${rows.length - 1} words below", Colors.green);
      for (var row in rows.skip(1)) {
        FocusNode newFocusNode = FocusNode();
        TextEditingController newTermController =
            TextEditingController(text: row[0]);
        TextEditingController newDefinitionController =
            TextEditingController(text: row[1]);
        TextEditingController newDescriptionController =
            TextEditingController(text: row.length > 2 ? row[2] : "");

        // Function to handle deletion
        void onDelete() {
          int index = termControllers.indexOf(newTermController);
          if (index != -1) {
            termControllers.removeAt(index);
            definitionControllers.removeAt(index);
            descriptionControllers.removeAt(index);
            termsWidgets.removeAt(index);
            focusNodes.removeAt(index);
            setStateDialog(() {});
          }
        }

        setStateDialog(() {
          termsWidgets.add(textFieldForTerm(newFocusNode, newTermController,
              newDefinitionController, newDescriptionController, onDelete));
          // add term controller for word
          termControllers.add(newTermController);
          // add definition controller for word
          definitionControllers.add(newDefinitionController);
          // add des controller for word
          descriptionControllers.add(newDescriptionController);
          // add focus node for word
          focusNodes.add(newFocusNode);
        });
      }
    }
  }

  bool saveTopic(
      List<TextEditingController> termControllers,
      List<TextEditingController> definitionControllers,
      List<TextEditingController> descriptionControllers) {
    String? key = dbRef.child("Topic").push().key;
    // VAN DE O DAY KHI MERGE CODE
    // SUA cách gán name bằng đối tượng User từ DB (hoac la khong can ?)
    String? name = auth.currentUser?.displayName;
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('dd/MM/yyyy').format(now);
    // Get word list, we have to clear it first to get rid of old data
    words.clear();
    for (int i = 0; i < termControllers.length; i++) {
      if (termControllers[i].text.isNotEmpty &&
          definitionControllers[i].text.isNotEmpty) {
        words.add(Word(termControllers[i].text, definitionControllers[i].text,
            descriptionControllers[i].text));
      }
    }
    if (words.length >= 4) {
      // Get current user as the first participant
      Participant participant = Participant(
          auth.currentUser?.uid, auth.currentUser?.displayName, null, null);
      participants.add(participant);
      Topic toAddTopic = Topic(
          isAccessible == false ? "PRIVATE" : "PUBLIC",
          formattedDate,
          key!,
          _topicTitleEditingController.text,
          name!,
          // SUA O DAY KHI CO DUOC AVT CUA USER
          auth.currentUser?.photoURL,
          participants,
          words);

      dbRef.child("Topic/$key").set(toAddTopic.toMap()).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.blue,
            content: Text(
              "Success",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )));
        _topicTitleEditingController.clear();
      });
      return true;
    } else {
      showAlertDialog("Please fill at least 4 words", Colors.red);
      return false;
    }
  }

  bool validateCreateTopic() {
    if (_titleKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void showAlertDialog(String notification, Color color) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: color,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: color == Colors.red
                    ? Icon(
                        size: 36,
                        Icons.warning_amber,
                        color: Colors.amberAccent,
                      )
                    : Icon(
                        size: 36,
                        Icons.check,
                        color: CupertinoColors.white,
                      ),
              ),
              SizedBox(
                height: 12,
              ),
              Text(notification,
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
        );
      },
    );
  }
}
