import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import '../objects/topic.dart';
import '../objects/word.dart';
import '../pages/fillWordQuizPage.dart';
import '../pages/flashcardQuizPage.dart';

class TopicDetail extends StatefulWidget {
  final Topic topic;

  const TopicDetail({super.key, required this.topic});

  @override
  State<TopicDetail> createState() => _TopicDetailState();
}

class _TopicDetailState extends State<TopicDetail> {

  static FlutterTts flutterTts = FlutterTts();
  static const enVoice = 'en-US';

  Future _speak(String inputText, String language) async{
    flutterTts.setLanguage(language);
    flutterTts.setVolume(1);
    await flutterTts.speak(inputText);
  }


  Widget topicAndUserWidget(){
    return Row(
      children: [
        ClipOval(
          child: CachedNetworkImage(
            width: 36,
            height: 36,
            fit: BoxFit.cover,
            imageUrl: widget.topic.ownerAvtUrl == 'url here'
                ? 'https://firebasestorage.googleapis.com/v0/b/finaltermandroid-ba01a.appspot.com/o/icons8-avatar-64.png?alt=media&token=efb2e06d-589a-40f0-96a0-a1eddfdbb352'
                : widget.topic.ownerAvtUrl as String,
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
    );
  }

  Widget quizAndTermsWidget(){
    return Column(
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
                      builder: (context)=>
                          FlashcardQuizPage(topic: widget.topic)
                  )
              );
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
            onTap: () {},
          ),
        ),
        Card(
          elevation: 4,
          margin: EdgeInsets.all(9),
          color: Colors.blue[50],
          child: ListTile(
            leading: Icon(FluentIcons.pen_16_regular),
            title: Text("Fill words"),
            onTap: () {Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context)=>
                        FillWordQuizPage(topic: widget.topic)
                )
            );},
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
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    _speak(word.english as String, enVoice);
                  },
                    icon: Icon(FluentIcons.speaker_2_16_filled)),
                IconButton(
                    onPressed: () {

                    }, icon: Icon(FluentIcons.star_12_regular)),
              ],
            ),
            SizedBox(
              height: 4,
            ),
            Text(
              word.vietnamese as String,
              style: TextStyle(fontSize: 20)
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(child: Text(" MINI FLASH CARD HERE")),
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
              topicAndUserWidget(),
              SizedBox(
                height: 8,
              ),
              quizAndTermsWidget()
            ],
          ),
        ),
      ),
    );
  }
}
