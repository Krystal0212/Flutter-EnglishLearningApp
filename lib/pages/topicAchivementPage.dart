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
      padding: EdgeInsets.all(10),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [

              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.symmetric(horizontal: 15),
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
                width: 190,
                height: 250,
                child: Column(
                  children: [
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
                                'assets/images/stelle.png',
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

                    Container(
                      child: Text(
                        'Username',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        'Score: 2000',
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
                width: 190,
                height: 300,
                child: Column(
                  children: [
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
                                  'assets/images/stelle.png',
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

                    Container(
                      child: Text(
                        'Username',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        'Score: 2000',
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

              Container(
                alignment: Alignment.topCenter,
                margin: EdgeInsets.symmetric(horizontal: 15),
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
                width: 190,
                height: 250,
                child: Column(
                  children: [
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

                    Container(
                      child: Text(
                        'Username',
                        textAlign: TextAlign.start,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                    Container(
                      child: Text(
                        'Score: 2000',
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
                    itemCount: 47,
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
                            'Username',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey.shade800,
                            ),
                          ),

                          trailing: Text(
                            'Score: 1000',
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
              width: mainPageWidth * 0.7,
              height: mainPageHeight * 0.85,
              child: scoreboard(),
            ),
          );
        },
      ),
    );
  }
}
