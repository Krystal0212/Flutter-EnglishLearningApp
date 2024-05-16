import 'package:Fluffy/folderDetail/folderDetailWidget.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../objects/folder.dart';
import 'package:flutter/foundation.dart';

class FolderTab extends StatefulWidget {
  const FolderTab({super.key});

  @override
  State<FolderTab> createState() => _FolderTabState();
}

class _FolderTabState extends State<FolderTab>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  List<Folder> folders = [];
  final TextEditingController _folderNameEditingController =
      TextEditingController();
  final _folderKey = GlobalKey<FormFieldState>();
  FocusNode focusForFolderName = FocusNode();

  @override
  void initState() {
    syncTopicFromDatabase();
    super.initState();
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
            "My folder",
            style: TextStyle(color: Colors.black),
          ),
        ),
      ),
      body: !folders.isEmpty
          ? GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: kIsWeb ? 5 : 2.2,
              ),
              itemBuilder: (BuildContext context, int index) {
                Folder folder = folders[index];
                return folderBlock(folder);
              },
              itemCount: folders.length,
            )
          : Center(
              child: Text("No folder currently"),
            ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'btn2',
        backgroundColor: Colors.blue.shade300,
        onPressed: () {
          addFolderDialog();
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget folderBlock(Folder folder) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(9),
      color: Colors.blue[50],
      child: ListTile(
        leading: Image.asset(
          'lib/icon/folder.png',
          height: 36,
        ),
        title: Text(
          folder.name as String,
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
                child: Text(
                    folder.topics == null
                        ? '0 topics'
                        : '${folder.topics?.length} topics',
                    style: TextStyle(color: Colors.blue[800]))),
          ],
        ),
        onTap: () {
          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => FolderDetail(folder: folder)));
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.purpleAccent.withOpacity(0.75), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void addFolderDialog() {
    showDialog(
        context: context,
        builder: (context) {
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
                        child: Text("Create new folder",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 15)),
                      ),
                      TextButton(
                          onPressed: () {
                            if (validateCreateFolder()) {
                              saveFolder();
                              Navigator.of(context).pop();
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

  bool validateCreateFolder() {
    if (_folderKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void saveFolder() {
    String? id = dbRef.child("Folder").push().key;
    String name = _folderNameEditingController.text;
    String? ownerUid = auth.currentUser?.uid;
    Folder toAddFolder = Folder(name, ownerUid, id, null);
    dbRef.child("Folder/$id").set(toAddFolder.toMap()).then((value) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.blue,
          content: Text(
            "Success",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )));
      _folderNameEditingController.clear();
    });
  }

  void syncTopicFromDatabase() {
    // listen once to fetch all folders,
    // then continue listen to future added folder
    // only folder that belongs to current user is gonna be added
    dbRef.child('Folder').onChildAdded.listen((data) {
      Folder folder =
          Folder.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      if (folder.ownerUid == auth.currentUser?.uid) {
        setState(() {
          folders.insert(0, folder);
        });
      }
    });
    // listen to all change in Folder node
    dbRef.child('Folder').onChildChanged.listen((data) {
      Folder changedFolder =
          Folder.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      int index =
          folders.indexWhere((element) => element.id == changedFolder.id);
      setState(() {
        folders.removeAt(index);
        folders.insert(index, changedFolder);
      });
    });
    // listen to deleted folder event in Folder node
    dbRef.child('Folder').onChildRemoved.listen((data) {
      Folder deletedFolder =
          Folder.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      int index =
          folders.indexWhere((element) => element.id == deletedFolder.id);
      setState(() {
        folders.removeAt(index);
      });
    });
  }
}
