import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../objects/folder.dart';
import '../objects/topic.dart';
import '../topicDetail/topicDetailWidget.dart';

class FolderDetail extends StatefulWidget {
  Folder folder;

  FolderDetail({super.key, required this.folder});

  @override
  State<FolderDetail> createState() => _FolderDetailState();
}

class _FolderDetailState extends State<FolderDetail> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Folder> folders = [];
  List<Topic> topics = [];
  final TextEditingController _folderNameEditingController =
      TextEditingController();
  final _folderKey = GlobalKey<FormFieldState>();
  FocusNode focusForFolderName = FocusNode();

  @override
  void initState() {
    syncFolderFromDatabase();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        backgroundColor: Colors.blue[50],
        automaticallyImplyLeading: true,
        title: Text(widget.folder.name as String),
        centerTitle: true,
        actions: <Widget>[
          IconButton(
              onPressed: () {
                showBottomSheetMenu();
              },
              icon: Icon(FluentIcons.settings_32_filled))
        ],
      ),
      body: !topics.isEmpty
          ? Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Center(
                    child: Text(
                      "(Swipe to remove a topic from folder)",
                      style: TextStyle(color: Colors.black.withOpacity(0.5)),
                    ),
                  ),
                ),
                SizedBox(
                  height: 500,
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      Topic topic = topics[index];
                      return topicBlock(topic);
                    },
                    itemCount: topics.length,
                  ),
                ),
              ],
            )
          : Center(
              child: Text("Nothing here currently"),
            ),
    );
  }

  void showBottomSheetMenu() {
    showModalBottomSheet<void>(
      backgroundColor: Colors.white,
      isDismissible: false,
      context: context,
      builder: (BuildContext context) {
        return SizedBox(
          height: 150,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        editFolderDialog();
                      },
                      child: Row(
                        children: [
                          Icon(
                            FluentIcons.edit_12_filled,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            'Edit folder',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        showConfirmDeleteFolderDialog();
                      },
                      child: Row(
                        children: [
                          Icon(
                            FluentIcons.delete_12_filled,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            'Delete folder',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Expanded(child: SizedBox()),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  color: Colors.blue as Color, width: 1.5),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            backgroundColor: Colors.white),
                        child: Text(
                          'Cancel',
                          style: TextStyle(color: Colors.blue),
                        ),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ),
                  ]),
            ),
          ),
        );
      },
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  void syncFolderFromDatabase() {
    loadTopicsFromFolder(widget.folder);
    // listen to all change in Topic node
    dbRef.child('Folder').onChildChanged.listen((data) {
      Folder changedFolder =
          Folder.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      if (changedFolder.id == widget.folder.id) {
        setState(() {
          widget.folder = changedFolder;
        });
      }
    });
  }

  void loadTopicsFromFolder(Folder folder) {
    folder.topics?.forEach((topicId, exists) async {
      if (exists) {
        DatabaseReference topicRef =
            FirebaseDatabase.instance.ref('Topic/$topicId');
        DataSnapshot snapshot = await topicRef.get();
        if (snapshot.exists) {
          Topic topic = Topic.fromJson(snapshot.value as Map<dynamic, dynamic>);
          setState(() {
            topics.add(topic);
          });
        }
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
      });
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

  Widget topicBlock(Topic topic) {
    return Dismissible(
      key: ValueKey(topic),
      direction: DismissDirection.endToStart,
      confirmDismiss: (DismissDirection direction) async {
        if (direction == DismissDirection.endToStart) {
          showConfirmDeleteTopicDialog(topic);
        }
        return null;
      },
      background: Container(
        color: Colors.red.withOpacity(1),
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Image.asset(height: 60, "lib/icon/delete.png"),
      ),
      child: Card(
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
                MaterialPageRoute(
                    builder: (context) => TopicDetail(topic: topic)));
          },
          shape: RoundedRectangleBorder(
            side: BorderSide(color: Colors.blue[300] as Color, width: 1),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }

  void showConfirmDeleteTopicDialog(Topic topic) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CupertinoColors.white,
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
                child: Text('Are you sure you want to remove this topic ?',
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
                    side:
                        BorderSide(color: Colors.blue[300] as Color, width: 2),
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
                swipeToDeleteTopic(topic);
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
      },
    );
  }

  void deleteFolder() {
    dbRef.child('Folder/${widget.folder.id}').remove().then((value) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Folder deleted",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )));
    });
  }

  bool validateCreateFolder() {
    if (_folderKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void editFolderDialog() {
    showDialog(
        context: context,
        builder: (context) {
          _folderNameEditingController.text = widget.folder.name!;
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
                  // header
                  Row(
                    children: [
                      Expanded(child: SizedBox()),
                      Expanded(
                        flex: 4,
                        child: Text("Edit folder",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      TextButton(
                          onPressed: () {
                            if (validateCreateFolder()) {
                              updateFolder();
                            } else {
                              WidgetsBinding.instance.addPostFrameCallback((_) {
                                focusForFolderName.requestFocus();
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
                  //content
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextFormField(
                      enableInteractiveSelection: false,
                      focusNode: focusForFolderName,
                      key: _folderKey,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      validator: (titleText) {
                        if (titleText == null || titleText.isEmpty) {
                          return "Please enter folder name";
                        }
                        return null;
                      },
                      cursorColor: Colors.blue,
                      controller: _folderNameEditingController,
                      decoration: const InputDecoration(
                          hintText: "Enter folder name",
                          helperText: "Folder",
                          focusedBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.blue)),
                          enabledBorder: UnderlineInputBorder(
                              borderSide: BorderSide(color: Colors.black)),
                          helperStyle: TextStyle(fontSize: 13)),
                    ),
                  ),
                ],
              ));
        });
  }

  void updateFolder() {
    String? id = widget.folder.id;
    String name = _folderNameEditingController.text;
    String? owner = auth.currentUser?.displayName;
    Folder updatedFolder = Folder(name, owner, id, widget.folder.topics);
    dbRef.child("Folder/$id").update(updatedFolder.toMap()).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.blue,
          content: Text(
            "Updated",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )));
      Navigator.of(context).pop();
    });
  }

  void showConfirmDeleteFolderDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: CupertinoColors.white,
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
                child: Text('Are you sure you want to delete this topic ?',
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
                    side:
                        BorderSide(color: Colors.blue[300] as Color, width: 2),
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
                deleteFolder();
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
      },
    );
  }

  // Function to handle deletion
  void swipeToDeleteTopic(Topic topic) {
    String? folderId = widget.folder.id;
    String? topicId = topic.id;
    dbRef.child('Folder/$folderId/topics/$topicId').remove().then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Topic deleted",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )));
      // update UI
      int index = topics.indexOf(topic);
      if (index != -1) {
        topics.removeAt(index);
        setState(() {});
      }
    });
  }
}
