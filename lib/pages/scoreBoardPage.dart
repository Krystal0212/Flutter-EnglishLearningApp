import 'package:Fluffy/objects/participant.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/widgets.dart';
import '../objects/topic.dart';

class TopicAchievementPage extends StatefulWidget {
  final Topic topic;

  const TopicAchievementPage({super.key, required this.topic});

  @override
  State<TopicAchievementPage> createState() => _TopicAchievementPageState();
}

class _TopicAchievementPageState extends State<TopicAchievementPage> {

  static late double mainPageWidth, mainPageHeight;

  static late List<Participant> participantsList;

  @override
  void initState() {
    getParticipant();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void clearCache() {

  }

  //take participant in topic and sort
  void getParticipant() {
    participantsList = List.from(widget.topic.participant!);

    participantsList.sort((a,b){
      int totalA = (a.multipleChoicesResult ??= 0) + (a.fillWordResult ??= 0);
      int totalB = (b.multipleChoicesResult ??= 0) + (b.fillWordResult ??= 0);
      return totalB.compareTo(totalA);
    });

    for (Participant p in participantsList){
      p.userName??='N/A';
    }
  }

  //score board widget
  Widget scoreboard() {
    return Container(
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //2nd place participant
              if (participantsList.length>1)
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.symmetric(horizontal: kIsWeb?15:5),
                decoration: BoxDecoration(
                  color: Color(0xFFcbd0d4),
                  border: Border.all(
                      color: Color(0xFF77868e),
                      width: 3
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100),
                      topRight: Radius.circular(100)
                  ),
                ),
                width: kIsWeb?190:mainPageWidth*0.3,
                height: kIsWeb?250:mainPageHeight*0.28,
                child: Column(
                  children: [
                    //user avatar
                    SizedBox(
                      width: 150,
                      height: 125,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children:[

                          //user avatar border
                          Container(
                            margin: EdgeInsets.only(top: 15),
                            width: 90,
                            height: 90,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFF77868e),
                                width: 3, // border width
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/stelle2.png',
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),

                          //ranking medal
                          Positioned(
                              top: 75,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFF5f6c73),
                                    border: Border.all(
                                        color: Color(0xFF77868e),
                                        width: 3
                                    ),
                                    borderRadius: BorderRadius.circular(100)
                                ),
                                child: Image.asset(
                                    width: 40,
                                    height: 40,
                                    'lib/icon/secondPlaceMedal.png'
                                ),
                              )
                          ),
                        ]
                      ),
                    ),

                    //user name
                    Container(
                      child: Text(
                        '${participantsList[1].userName}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    //user score
                    Container(
                      child: Text(
                        'Score: '
                            '${(participantsList[1].multipleChoicesResult??=0)
                            + (participantsList[1].fillWordResult??=0)
                        }',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                )
              ),

              //1st place participant
              if (participantsList.isNotEmpty)
                Container(
                  alignment: Alignment.topCenter,
                  decoration: BoxDecoration(
                    color: Color(0xFFffff89),
                    border: Border.all(
                        color: Color(0xFFd4af37),
                        width: 3
                    ),
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(100),
                        topRight: Radius.circular(100)
                    ),
                  ),
                  width: kIsWeb?190:mainPageWidth*0.3,
                  height: kIsWeb?250:mainPageHeight*0.32,
                  child: Column(
                    children: [
                      //user avatar
                      SizedBox(
                        width: 150,
                        height: 150,
                        child: Stack(
                          alignment: Alignment.topCenter,
                          children: [

                            //user avatar border
                            Positioned(
                                top: 40,
                                child: Container(
                                  width: 90,
                                  height: 90,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Color(0xFFd4af37),
                                      width: 3, // border width
                                    ),
                                  ),
                                  child: ClipOval(
                                    child: Image.asset(
                                      'assets/images/github.png',
                                    ),
                                  ),
                                )
                            ),

                            //animated crown
                            SizedBox(
                              width: 80,
                              height: 80,
                              child: Image.asset('assets/gifs/crown.gif'),
                            ),

                            //ranking medal
                            Positioned(
                                top: 100,
                                child: Container(
                                  decoration: BoxDecoration(
                                      color: Color(0xFF9d8022),
                                      border: Border.all(
                                          color: Color(0xFFd4af37),
                                          width: 3
                                      ),
                                      borderRadius: BorderRadius.circular(100)
                                  ),
                                  child: Image.asset(
                                      width: 40,
                                      height: 40,
                                      'lib/icon/firstPlaceMedal.png'
                                  ),
                                )
                            ),
                          ],
                        ),
                      ),

                      //user name
                      Container(
                        child: Text(
                          '${participantsList[0].userName}',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),

                      //user score
                      Container(
                        child: Text(
                          'Score: '
                          '${(participantsList[0].multipleChoicesResult ??= 0)
                              + (participantsList[0].fillWordResult ??= 0)
                          }',
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              //3rd place participant
              if (participantsList.length>2)
              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.symmetric(horizontal: kIsWeb?15:5),
                decoration: BoxDecoration(
                  color: Color(0xFF9c4e15),
                  border: Border.all(
                      color: Color(0xFF5b2a03),
                      width: 3
                  ),
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(100),
                      topRight: Radius.circular(100)
                  ),
                ),
                width: kIsWeb?190:mainPageWidth*0.3,
                height: kIsWeb?250:mainPageHeight*0.28,
                child: Column(
                  children: [
                    //user avatar
                    SizedBox(
                      width: 150,
                      height: 125,
                      child: Stack(
                        alignment: Alignment.topCenter,
                        children: [

                          //user avatar border
                          Container(
                            width: 90,
                            height: 90,
                            margin: EdgeInsets.only(top: 15),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Color(0xFF5b2a03),
                                width: 3, // border width
                              ),
                            ),
                            child: ClipOval(
                              child: Image.asset(
                                'assets/images/stelle.png',
                                fit: BoxFit.fitWidth,
                                width: 100,
                                height: 100,
                              ),
                            ),
                          ),

                          //ranking medal
                          Positioned(
                              top: 75,
                              child: Container(
                                decoration: BoxDecoration(
                                    color: Color(0xFF743504),
                                    border: Border.all(
                                        color: Color(0xFF5b2a03),
                                        width: 3
                                    ),
                                    borderRadius: BorderRadius.circular(100)
                                ),
                                child: Image.asset(
                                    width: 40,
                                    height: 40,
                                    'lib/icon/thirdPlaceMedal.png'
                                ),
                              )
                          ),
                        ]
                      ),
                    ),

                    //user name
                    Container(
                      child: Text(
                        '${participantsList[2].userName}',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    //user score
                    Container(
                      child: Text(
                        'Score: '
                            '${(participantsList[2].multipleChoicesResult??=0)
                            + (participantsList[2].fillWordResult??=0)
                        }',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (participantsList.length>3)
          Expanded(
              child: Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                      color: Colors.grey.shade800,
                      width: 3
                  ),
                ),
                width: 600,
                child: ListView.builder(
                    itemCount: participantsList.length > 47 ?
                    47 : participantsList.length-3,
                    itemBuilder: (context,index){
                      return Container(
                        alignment: Alignment.center,
                        margin: const EdgeInsets.all(3),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade500,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                              color: Colors.grey.shade800,
                              width: 2
                          ),
                        ),
                        child:ListTile(
                          leading: Text(
                            '#${index+4}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade700,
                            ),
                          ),

                          title: Text(
                            '${participantsList[index+3].userName}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),

                          trailing: Text(
                            'Score: '
                            '${(participantsList[index+3].multipleChoicesResult??=0)
                                + (participantsList[index+3].fillWordResult??=0)
                            }',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),
                        ),
                      );
                    }
                ),
              )
          )
        ],
      ),
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
            color: CupertinoColors.white,
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
              width: kIsWeb? mainPageWidth * 0.7 : mainPageWidth,
              height: kIsWeb? mainPageHeight * 0.85 : mainPageHeight,
              child: scoreboard(),
            ),
          );
        },
      ),
    );
  }
}
