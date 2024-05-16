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

  static late double mainPageWidth, mainPageHeight;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clearCache() {

  }

  Widget scoreboard() {
    return Container(
      color: Colors.green,
      width: mainPageWidth * 0.7,
      height: mainPageHeight * 0.8,
    );
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: (){
            clearCache();
            Navigator.pop(context);
          },
        ),
        automaticallyImplyLeading: false,
        centerTitle : true,
        title : const Text('Hall of Fame'),
        backgroundColor: Colors.red[800],
        titleTextStyle: const TextStyle(
            color: Colors.blue,
            fontWeight: FontWeight.bold,
            fontSize: 25
        ),
      ),
      body: LayoutBuilder(
        builder: (context,constraints){
          mainPageWidth = constraints.maxWidth;
          mainPageHeight = constraints.maxHeight;
          return Center(
            child: Container(
              color: CupertinoColors.white,
              width: mainPageWidth * 0.6,
              height: mainPageHeight * 0.6,
              child: scoreboard(),
            ),
          );
        },
      ),
    );
  }
}