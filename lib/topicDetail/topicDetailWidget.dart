import 'package:Fluffy/pages/flashcardQuizPage.dart';
import 'package:Fluffy/pages/multipleChoiceQuizPage.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../objects/folder.dart';
import '../objects/topic.dart';
import '../objects/word.dart';
import '../pages/fillWordQuizPage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';

class TopicDetail extends StatefulWidget {
  Topic topic;

  TopicDetail({super.key, required this.topic});

  @override
  State<TopicDetail> createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetail> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final TextEditingController _topicTitleEditingController =
      TextEditingController();
  final _titleKey = GlobalKey<FormFieldState>();
  List<FocusNode> focusNodes = [];
  static FlutterTts flutterTts = FlutterTts();

  // thay doi list word mới, participant khong thay doi
  List<Word> words = [];
  FocusNode focusForTitle = FocusNode();
  List<Folder> folders = [];

  @override
  void initState() {
    syncTopicFromDatabase();
    super.initState();
  }

  @override
  void dispose() {
    for (var focusNode in focusNodes) {
      focusNode.dispose();
    }
    _topicTitleEditingController.dispose();
    super.dispose();
  }

  Future _speak(String inputText, String language) async {
    flutterTts.setLanguage(language);
    flutterTts.setVolume(1);
    await flutterTts.speak(inputText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CupertinoColors.white,
      appBar: AppBar(
        surfaceTintColor: Colors.transparent,
        forceMaterialTransparency: true,
        automaticallyImplyLeading: true,
        actions: <Widget>[
          Padding(
            padding: EdgeInsets.all(8),
            child: InkWell(
              onTap: () {},
              child: Image.asset(
                'lib/icon/trophy.png',
                height: 25,
              ),
            ),
          ),
          IconButton(
              onPressed: () {
                showBottomSheetMenu();
              },
              icon: Icon(FluentIcons.settings_32_filled))
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("MINI FLASH CARD HERE"),
              SizedBox(
                height: 8,
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.topic.title as String,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                ),
              ),
              SizedBox(
                height: 8,
              ),
              Row(
                children: [
                  ClipOval(
                    child: CachedNetworkImage(
                      width: 36,
                      height: 36,
                      fit: BoxFit.cover,
                      imageUrl: widget.topic.ownerAvtUrl as String,
                      placeholder: (context, url) =>
                          CircularProgressIndicator(),
                    ),
                  ),
                  SizedBox(
                    width: 8,
                  ),
                  IntrinsicHeight(
                    child: Row(
                      children: [
                        Text(widget.topic.owner as String),
                        SizedBox(
                          width: 20,
                        ),
                        VerticalDivider(
                          color: Colors.grey,
                          thickness: 1,
                        ),
                        SizedBox(
                          width: 20,
                        ),
                        Text("${widget.topic.word?.length} terms"),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 8,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.all(9),
                    color: Colors.blue[50],
                    child: ListTile(
                      leading: Icon(FluentIcons.copy_16_regular),
                      title: Text("Flashcard"),
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    FlashcardQuizPage(topic: widget.topic)));
                      },
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.all(9),
                    color: Colors.blue[50],
                    child: ListTile(
                      leading: Icon(Icons.quiz_outlined),
                      title: Text("Multiple choices"),
                      onTap: () {
                        showSelectionDialog(context, isMultipleQuiz: true);
                      },
                    ),
                  ),
                  Card(
                    elevation: 4,
                    margin: EdgeInsets.all(9),
                    color: Colors.blue[50],
                    child: ListTile(
                      leading: Icon(FluentIcons.pen_16_regular),
                      title: Text("Fill words"),
                      onTap: () {
                        showSelectionDialog(context, isMultipleQuiz: false);
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(top: 8, left: 8, bottom: 8),
                    child: Text(
                      "Terms",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      padding: EdgeInsets.all(5),
                      itemCount: widget.topic.word?.length,
                      itemBuilder: (BuildContext context, int index) {
                        if (widget.topic.word?[index] != null) {
                          Word? word = widget.topic.word?[index];
                          return wordBlock(word!);
                        }
                        return null;
                      },
                    ),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  void showSelectionDialog(BuildContext context, {bool? isMultipleQuiz}) {
    // Initial states for options
    bool language = false;
    bool shuffle = false;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Dialog(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListTile(
                    title: Text('Language'),
                    subtitle: Text('(default: English)'),
                    trailing: Switch(
                      value: language,
                      onChanged: (bool value) {
                        setState(() {
                          language = value;
                        });
                      },
                    ),
                  ),
                  ListTile(
                    title: Text('Shuffle'),
                    subtitle: Text('(default: Off)'),
                    trailing: Switch(
                      value: shuffle,
                      onChanged: (bool value) {
                        setState(() {
                          shuffle = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: (){
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            if (isMultipleQuiz!){
                              return MultipleChoiceQuizPage(
                                  topic: widget.topic,
                                  isChangeLanguage: language,
                                  isShuffle: shuffle
                              );
                            }
                            else {
                              return FillWordQuizPage(
                                  topic: widget.topic,
                                  isChangeLanguage: language,
                                  isShuffle: shuffle
                              );
                            }
                          }
                        )
                      );
                    },
                    child: Text('OK'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget wordBlock(Word word) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(4),
      color: Colors.blue[50],
      child: Padding(
        padding: EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    word.english as String,
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                IconButton(
                    onPressed: () {
                      _speak(word.english as String, 'en-US');
                    },
                    icon: Icon(FluentIcons.speaker_2_16_filled)),
                IconButton(
                    onPressed: () {},
                    icon: Icon(
                      FluentIcons.star_12_regular,
                      color: Colors.amber,
                    )),
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Text(word.vietnamese as String, style: TextStyle(fontSize: 20)),
          ],
        ),
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
          height:
              widget.topic.owner == auth.currentUser?.displayName ? 200 : 120,
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(15),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.topic.owner == auth.currentUser?.displayName)
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          editTopicDialog();
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
                              'Edit topic',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    if (widget.topic.owner == auth.currentUser?.displayName)
                      Divider(),
                    InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        addToFolderDialog();
                      },
                      child: Row(
                        children: [
                          Icon(
                            FluentIcons.folder_16_filled,
                            color: Colors.blue,
                          ),
                          SizedBox(
                            width: 12,
                          ),
                          Text(
                            'Add to folder',
                            style: TextStyle(fontSize: 15),
                          ),
                        ],
                      ),
                    ),
                    Divider(),
                    if (widget.topic.owner == auth.currentUser?.displayName)
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          showConfirmDeleteDialog();
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
                              'Delete topic',
                              style: TextStyle(fontSize: 15),
                            ),
                          ],
                        ),
                      ),
                    if (widget.topic.owner == auth.currentUser?.displayName)
                      Divider(),
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

  void editTopicDialog() {
    showDialog(
        context: context,
        builder: (context) {
          _topicTitleEditingController.text = widget.topic.title!;
          List<TextEditingController> termControllers = [];
          List<TextEditingController> definitionControllers = [];
          List<TextEditingController> descriptionControllers = [];

          List<Widget> termsWidgets = [];
          for (int i = 0; i < widget.topic.word!.length; i++) {
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
            // set text for each termsWidget
            termControllers[i].text = widget.topic.word![i].english as String;
            definitionControllers[i].text =
                widget.topic.word![i].vietnamese as String;
            descriptionControllers[i].text =
                widget.topic.word![i].description as String;
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
                          child: Text("Edit topic",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                        ),
                        TextButton(
                            onPressed: () {
                              if (validateCreateTopic()) {
                                updateTopic(
                                    termControllers,
                                    definitionControllers,
                                    descriptionControllers);
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
                            ))
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
                                    helperStyle: TextStyle(
                                        fontSize: 13, color: Colors.black)),
                              ),
                            ),
                            SizedBox(
                              height: 12,
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
                                      onPressed: importWords,
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

  Future<void> importWords() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      final fileBytes = result.files.first.bytes;
      final csvString = String.fromCharCodes(fileBytes!);
      List<List<dynamic>> rows = const CsvToListConverter().convert(csvString);

      List<Word> newWords = rows.skip(1).map((row) {
        return Word(row[0], row[1], row.length > 2 ? row[2] : "");
      }).toList();

      setState(() {
        words.addAll(newWords);
      });
    }
  }

  bool validateCreateTopic() {
    if (_titleKey.currentState!.validate()) {
      return true;
    } else {
      return false;
    }
  }

  void updateTopic(
      List<TextEditingController> termControllers,
      List<TextEditingController> definitionControllers,
      List<TextEditingController> descriptionControllers) {
    // lay lai key cua topic hien tai
    String? key = widget.topic.id;
    String? name = widget.topic.owner;
    // Get word list, have to clear first too
    words.clear();
    for (int i = 0; i < termControllers.length; i++) {
      if (termControllers[i].text.isNotEmpty &&
          definitionControllers[i].text.isNotEmpty) {
        words.add(Word(termControllers[i].text, definitionControllers[i].text,
            descriptionControllers[i].text));
      }
    }
    if (words.length >= 4) {
      Topic updatedTopic = Topic(
          widget.topic.access,
          widget.topic.createDate,
          key!,
          _topicTitleEditingController.text,
          name!,
          // SUA O DAY KHI CO DUOC AVT CUA USER (co le la khong can)
          widget.topic.ownerAvtUrl,
          widget.topic.participant,
          words);

      dbRef.child("Topic/$key").update(updatedTopic.toMap()).then((value) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.blue,
            content: Text(
              "Updated",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )));
        Navigator.of(context).pop();
      });
    } else {
      showAlertDialog();
    }
  }

  void showAlertDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          backgroundColor: Colors.red,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Icon(Icons.warning_amber),
              ),
              SizedBox(
                height: 12,
              ),
              Text("Please fill at least 4 words",
                  style: TextStyle(color: Colors.white, fontSize: 20)),
            ],
          ),
        );
      },
    );
  }

  void syncTopicFromDatabase() {
    loadFolderFromDatabase();
    // listen to all change in Topic node
    dbRef.child('Topic').onChildChanged.listen((data) {
      Topic changedTopic =
          Topic.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      if (changedTopic.id == widget.topic.id) {
        setState(() {
          widget.topic = changedTopic;
        });
      }
    });
  }

  void showConfirmDeleteDialog() {
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
                deleteTopic();
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

  void deleteTopic() {
    dbRef.child('Topic/${widget.topic.id}').remove().then((value) {
      // remove this topic in every folder
      removeTopicIdFromFolders(widget.topic.id);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          backgroundColor: Colors.redAccent,
          content: Text(
            "Topic deleted",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          )));
      Navigator.of(context).pop();
    });
  }

  void removeTopicIdFromFolders(String? topicId) {
    dbRef.child('Folder').once().then((DatabaseEvent event) {
      if (event.snapshot.exists) {
        Map<dynamic, dynamic> folders =
            event.snapshot.value as Map<dynamic, dynamic>? ?? {};
        folders.forEach((key, value) {
          if (value is Map<dynamic, dynamic> && value.containsKey('topics')) {
            Map<dynamic, dynamic> topics =
                value['topics'] as Map<dynamic, dynamic>;
            if (topics.containsKey(topicId)) {
              topics.remove(topicId);
              dbRef.child('Folder/$key/topics').set(topics);
            }
          }
        });
      }
    }).catchError((error) {
      print("Error fetching folders: $error");
    });
  }

  void addToFolderDialog() {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            insetPadding: EdgeInsets.all(10),
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
                  padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                  child: Center(
                    child: Text("Pick a folder",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 15)),
                  ),
                ),
                SizedBox(
                  height: 300,
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 2.2,
                    ),
                    itemBuilder: (BuildContext context, int index) {
                      Folder folder = folders[index];
                      return folderBlock(folder);
                    },
                    itemCount: folders.length,
                  ),
                ),
                SizedBox(
                  height: 20,
                )
              ],
            ),
          );
        });
  }

  void loadFolderFromDatabase() {
    dbRef.child('Folder').onChildAdded.listen((data) {
      Folder folder =
          Folder.fromJson(data.snapshot.value as Map<dynamic, dynamic>);
      if (folder.ownerUid == auth.currentUser?.uid) {
        setState(() {
          folders.insert(0, folder);
        });
      }
    });
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
                child: Text(
                    folder.topics == null
                        ? '0 topics'
                        : '${folder.topics?.length} topics',
                    style: TextStyle(color: Colors.blue[800]))),
          ],
        ),
        onTap: () {
          Navigator.of(context).pop();
          showConfirmFolderDialog(folder);
        },
        shape: RoundedRectangleBorder(
          side: BorderSide(
              color: Colors.purpleAccent.withOpacity(0.75), width: 1),
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  void showConfirmFolderDialog(Folder folder) {
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
                child: Text(
                    'Add topic ${widget.topic.title} to folder ${folder.name}?',
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
                addToFolder(folder);
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

  void addToFolder(Folder folder) {
    String? folderId = folder.id;
    String? topicId = widget.topic.id;
    dbRef.child('Folder/$folderId/topics/$topicId').get().then((snapshot) {
      if (snapshot.exists) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            backgroundColor: Colors.red,
            content: Text(
              "Topic already exists in the folder",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )));
      } else {
        dbRef.child('Folder/$folderId/topics/$topicId').set(true).then((value) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.blue,
              content: Text(
                "Added successfully",
                style:
                    TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              )));
        });
      }
    });
  }
}
