import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../objects/participant.dart';
import '../objects/topic.dart';
import '../objects/word.dart';

class MultipleChoiceQuizPage extends StatefulWidget {
  const MultipleChoiceQuizPage(
      {super.key,
      required this.topic,
      required this.isShuffle,
      required this.isChangeLanguage});

  final Topic topic;
  final bool isShuffle;
  final bool isChangeLanguage;

  @override
  State<MultipleChoiceQuizPage> createState() => _MultipleChoiceQuizPageState();
}

class _MultipleChoiceQuizPageState extends State<MultipleChoiceQuizPage> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;

  late final PageController _pageController;
  static late double mainPageWidth, mainPageHeight;
  static late List<Word> wordList;

  static Map<int, String> userSelection = {};
  static List<int> finishedQuestCorrectly = [];
  static List<int> finishedQuestWrongly = [];
  static List<int> skippedQuest = [];
  static List<Map<String, dynamic>> questList = [];

  static int currentIndex = 0;
  static bool isShownOnce = false;
  static bool isNewHighScore = false;
  static String resultTitle = '';
  static dynamic resultTitleColor = Colors.black;
  static bool isProcessingNotification = false;
  static int score = 0, highScore = 0;
  static final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    _pageController = PageController(viewportFraction: 1);
    wordList = List.from(widget.topic.word as List<Word>);
    initWordSufficient();
    super.initState();
    initConfetti();
  }

  Widget highScoreBadge() {
    return Container(
      width: kIsWeb ? 170 : 120,
      height: kIsWeb ? 170 : 120,
      alignment: Alignment.topCenter,
      child: Transform.rotate(
        angle: 50,
        child: Image.asset('assets/images/new_record.png'),
      ),
    );
  }

  void updateScoreToDatabase(int score) {
    int index = widget.topic.participant!
        .indexWhere((p) => p.userID == auth.currentUser?.uid);
    if (widget.topic.participant![index].multipleChoicesResult == null ||
        widget.topic.participant![index].multipleChoicesResult! < score) {
      Participant toUpdateParticipant = Participant(
          auth.currentUser?.uid,
          auth.currentUser?.displayName,
          score,
          widget.topic.participant![index].fillWordResult);
      dbRef
          .child("Topic/${widget.topic.id}/participant/$index")
          .update(toUpdateParticipant.toMap())
          .then((value) {});
    }
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }

  void clearCache() {
    userSelection = {};
    finishedQuestCorrectly = [];
    finishedQuestWrongly = [];
    skippedQuest = [];
    questList = [];
    currentIndex = 0;
    isShownOnce = false;
    resultTitle = '';
    resultTitleColor = Colors.black;
    score = 0;
    highScore = 0;
    isNewHighScore = false;
  }

  //text to speak word
  Future speak(String inputText) async {
    await flutterTts.setLanguage(widget.isChangeLanguage ? "en-US" : "vi-VN");
    flutterTts.setVolume(1);
    await flutterTts.speak(inputText);
  }

  //implement confetti for summary page
  void initConfetti() {
    _confettiControllerLeft =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiControllerRight =
        ConfettiController(duration: const Duration(seconds: 3));
  }

  //generate progress color for progress bar indicator
  Color getColorForProgress(double progress) {
    if (progress >= 0.9) {
      return const Color(0xFF4cac10);
    } else if (progress >= 0.8) {
      return const Color(0xFF6eb810);
    } else if (progress >= 0.7) {
      return const Color(0xFF93c411);
    } else if (progress >= 0.6) {
      return const Color(0xFFbdd011);
    } else if (progress >= 0.5) {
      return const Color(0xFFdcce11);
    } else if (progress >= 0.4) {
      return const Color(0xFFe9b411);
    } else if (progress >= 0.3) {
      return const Color(0xFFef9516);
    } else if (progress >= 0.2) {
      return const Color(0xFFf17621);
    } else if (progress >= 0.1) {
      return const Color(0xFFf35b2b);
    } else {
      return const Color(0xFFf44336);
    }
  }

  //implement progress indicator for quiz page
  Widget progressIndicatorWidget() {
    return LinearProgressIndicator(
      minHeight: mainPageHeight * 0.01,
      value: userSelection.length.toDouble() / (questList.length),
      valueColor: AlwaysStoppedAnimation<Color>(
        getColorForProgress(
            userSelection.length.toDouble() / (questList.length)),
      ),
    );
  }

  //check if enough word to show in result
  void initWordSufficient() {
    if (wordList.length < 4) {
      dispose();
      Navigator.pop(context);
    } else {
      if (widget.isShuffle) {
        wordList.shuffle(Random());
      }
      generateMultipleChoiceQuestions();
    }
  }

  //make answer random
  Map<String, dynamic> shuffleAnswer(int index) {
    List<Word> listOfWord = List.from(wordList);
    List<String> answerList;
    Map<String, dynamic> mainQuestion;

    //print(listOfWord[index]);
    listOfWord.removeAt(index);
    listOfWord.shuffle(Random());

    if (widget.isChangeLanguage) {
      answerList = [
        wordList[index].vietnamese as String,
        listOfWord[0].vietnamese as String,
        listOfWord[1].vietnamese as String,
        listOfWord[2].vietnamese as String,
      ];

      answerList.shuffle(Random());

      mainQuestion = {
        "question": wordList[index].english as String,
        "result": wordList[index].vietnamese as String,
        "answer": answerList
      };
    } else {
      answerList = [
        wordList[index].english as String,
        listOfWord[0].english as String,
        listOfWord[1].english as String,
        listOfWord[2].english as String,
      ];

      answerList.shuffle(Random());

      mainQuestion = {
        "question": wordList[index].vietnamese as String,
        "result": wordList[index].english as String,
        "answer": answerList
      };
    }

    return mainQuestion;
  }

  // create one page
  void generateMultipleChoiceQuestions() {
    for (int i = 0; i < wordList.length; i++) {
      questList.add(shuffleAnswer(i));
    }
  }

  //check if user complete all question
  static bool isFinished() {
    if (userSelection.length == wordList.length) {
      return true;
    }
    return false;
  }

  //summary page Score title
  Widget mainResultTitle() {
    resultTitle = "Your Score: $score";
    if (finishedQuestCorrectly.length == userSelection.length) {
      resultTitleColor = [
        Colors.purple,
        Colors.indigo,
        Colors.blue,
        Colors.green,
        Colors.yellow,
        Colors.orange,
        Colors.red,
      ].toList();
      return GradientAnimationText(
        colors: resultTitleColor as List<Color>,
        text: Text(
          resultTitle,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: kIsWeb ? 55 : 30,
          ),
        ),
        duration: const Duration(milliseconds: 500),
      );
    } else if (finishedQuestCorrectly.length >= userSelection.length * 0.75) {
      resultTitleColor = const Color(0xFFd4af37);
      return Text(
        resultTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: kIsWeb ? 55 : 30, color: resultTitleColor),
      );
    } else if (finishedQuestCorrectly.length >= userSelection.length * 0.5) {
      resultTitleColor = const Color(0xFFBcc6cc);
      return Text(
        resultTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: kIsWeb ? 55 : 30, color: resultTitleColor),
      );
    } else if (finishedQuestCorrectly.length >= userSelection.length * 0.25) {
      resultTitleColor = const Color(0xFF5B391E);
      return Text(
        resultTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: kIsWeb ? 55 : 30, color: resultTitleColor),
      );
    } else {
      resultTitleColor = Colors.black87;
      return Text(
        resultTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: kIsWeb ? 55 : 30, color: resultTitleColor),
      );
    }
  }

  //return color of correctness of user answers
  Color isAnswerChosenCorrectlyColor(
      String? userOption, String result, String currentOption, int shade) {
    if (userSelection[currentIndex] == null) {
      return Colors.blue[shade] as Color;
    }

    if (userSelection[currentIndex] == currentOption) {
      if (result == currentOption) {
        return Colors.green[shade] as Color;
      }
      return Colors.red[shade] as Color;
    }

    if (result == currentOption) {
      return Colors.green[shade] as Color;
    }
    return Colors.grey[shade * 2] as Color;
  }

  //return icon of correctness of user answers
  Color isAnswerChosenCorrectlyIcon(String? userOption, String result,
      String currentOption, Color defaultColor) {
    if (userSelection[currentIndex] == null) {
      return defaultColor;
    }

    if (userSelection[currentIndex] == currentOption) {
      if (result == currentOption) {
        return Colors.green.shade200;
      }
      return Colors.red.shade200;
    }

    if (result == currentOption) {
      return Colors.green.shade200;
    }
    return Colors.grey.shade400;
  }

  //4 tiles of answers
  Widget answerCardWidget(String option, String result, int index) {
    return TextButton(
      onPressed: () async {
        if (userSelection[currentIndex] == null) {
          setState(() {
            userSelection[currentIndex] = option;
          });
          if (option == result) {
            finishedQuestCorrectly.add(currentIndex);
          } else {
            finishedQuestWrongly.add(currentIndex);
          }
        }
        await Future.delayed(const Duration(milliseconds: 400));
        if (isFinished()) return showResultDialog();
        _pageController.nextPage(
            duration: const Duration(milliseconds: 350), curve: Curves.easeIn);
      },
      style: TextButton.styleFrom(
          backgroundColor: isAnswerChosenCorrectlyColor(
              userSelection[currentIndex], result, option, 200),
          side: BorderSide(
              color: isAnswerChosenCorrectlyColor(
                  userSelection[currentIndex], result, option, 400),
              width: 3),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))),
      child: Container(
        alignment: Alignment.center,
        width: kIsWeb ? mainPageWidth * 0.17 : mainPageWidth,
        height: kIsWeb ? mainPageHeight * 0.22 : mainPageHeight * 0.1,
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.symmetric(horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.blue.shade500,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$index',
                style: const TextStyle(
                    fontSize: kIsWeb ? 20 : 15, color: Colors.black),
              ),
            ),
            Expanded(
                child: Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.only(right: 40),
              child: Text(
                option,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: kIsWeb ? 25 : 20,
                ),
              ),
            ))
          ],
        ),
      ),
    );
  }

  //container hold 4 tiles of answer
  Widget answerGroupWidget(List<String> optionList, String result) {
    return Container(
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 10),
        width: kIsWeb ? mainPageWidth * 0.4 : mainPageWidth * 0.95,
        height: mainPageHeight * 0.5,
        child: kIsWeb
            ?
            //in web view
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      answerCardWidget(optionList[0], result, 0),
                      answerCardWidget(optionList[1], result, 1),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      answerCardWidget(optionList[2], result, 2),
                      answerCardWidget(optionList[3], result, 3),
                    ],
                  ),
                ],
              )
            :
            //in mobile view
            Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  answerCardWidget(optionList[0], result, 0),
                  answerCardWidget(optionList[1], result, 1),
                  answerCardWidget(optionList[2], result, 2),
                  answerCardWidget(optionList[3], result, 3),
                ],
              ));
  }

  //container hold question
  Widget questionGroupWidget(String question) {
    return Container(
        //alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(vertical: 10),
        padding: const EdgeInsets.all(30),
        width: kIsWeb ? mainPageWidth * 0.42 : mainPageWidth,
        height: kIsWeb ? mainPageHeight * 0.23 : mainPageHeight * 0.28,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          mainAxisSize: MainAxisSize.max,
          children: [
            Text(
              question,
              textAlign: TextAlign.start,
              style: const TextStyle(
                  color: Colors.black87,
                  fontSize: kIsWeb ? 40 : 35,
                  fontWeight: FontWeight.bold),
            ),
            IconButton(
                iconSize: kIsWeb ? 35 : 30,
                onPressed: () {
                  speak(question);
                  //_stop();
                },
                icon: const Icon(Icons.volume_down)),
            const Text(
              "Choose the correct answer",
              textAlign: TextAlign.start,
              style: TextStyle(
                  color: Colors.black54,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            )
          ],
        ));
  }

  //main content of page (hold question and answer tiles)
  Widget multipleChoicePageWidget() {
    return Column(
      children: [
        progressIndicatorWidget(),
        Container(
            width: mainPageWidth,
            height: mainPageHeight * 0.99,
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (!isProcessingNotification &&
                    scrollNotification is ScrollUpdateNotification) {
                  isProcessingNotification = true;
                  if (scrollNotification.scrollDelta! < 0 &&
                      isProcessingNotification) {
                    // User is scrolling down
                    if (currentIndex < wordList.length - 1) {
                      _pageController
                          .nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeIn)
                          .then((_) {
                        isProcessingNotification = false;
                      });
                      return true;
                    }
                  } else if (scrollNotification.scrollDelta! > 0 &&
                      isProcessingNotification) {
                    // User is scrolling up
                    if (currentIndex > 0) {
                      _pageController
                          .previousPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut)
                          .then((_) {
                        isProcessingNotification = false;
                      });
                      return true;
                    }
                  }
                }
                return false; // Return true to allow further handling of the notification
              },
              child: PageView.builder(
                allowImplicitScrolling: false,
                scrollDirection: Axis.vertical,
                controller: _pageController,
                onPageChanged: (i) {
                  setState(() {
                    currentIndex = i;
                  });
                },
                pageSnapping: true,
                itemCount: wordList.length,
                itemBuilder: (context, index) {
                  return Container(
                    color: CupertinoColors.white,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Question widget
                        questionGroupWidget(
                            questList[index]['question'] as String),

                        //Answer widget
                        answerGroupWidget(
                            questList[index]['answer'] as List<String>,
                            questList[index]['result']),

                        userSelection[currentIndex] == null
                            ? AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: !skippedQuest.contains(currentIndex)
                                    ? TextButton(
                                        child: Container(
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                              color: Colors.grey[400],
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                              border: Border.all(
                                                color: Colors.grey.shade800,
                                                width: 3,
                                              )),
                                          child: const Text(
                                            "I don't Know",
                                            style: TextStyle(
                                                color: Colors.black54,
                                                fontSize: 20),
                                          ),
                                        ),
                                        onPressed: () async {
                                          skippedQuest.add(currentIndex);
                                          userSelection[currentIndex] =
                                              'Skipped';
                                          setState(() {});
                                          await Future.delayed(const Duration(
                                              milliseconds: 300));
                                          if (isFinished()) {
                                            return setState(() {
                                              showResultDialog();
                                            });
                                          }
                                          if (currentIndex <
                                              wordList.length - 1) {
                                            _pageController.nextPage(
                                                duration: const Duration(
                                                    milliseconds: 300),
                                                curve: Curves.easeIn);
                                          }
                                        })
                                    : Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.grey.shade800,
                                              width: 3,
                                            )),
                                        child: const Text(
                                          'You have skipped this quest',
                                          style: TextStyle(
                                              color: Colors.black54,
                                              fontSize: 20),
                                        ),
                                      ),
                              )
                            : AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                child: !skippedQuest.contains(currentIndex)
                                    ? const SizedBox.shrink()
                                    : Container(
                                        padding: const EdgeInsets.all(15),
                                        decoration: BoxDecoration(
                                            color: Colors.grey[400],
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            border: Border.all(
                                              color: Colors.grey.shade800,
                                              width: 3,
                                            )),
                                        child: const Text(
                                          'You have skipped this quest',
                                          style: TextStyle(fontSize: 20),
                                        ),
                                      ),
                              ),
                      ],
                    ),
                  );
                },
              ),
            )),
      ],
    );
  }

  //finished page that has content and redirect button (if web)
  Widget multipleChoiceQuizMainPage() {
    return Stack(
      children: [
        //main content
        Center(
          child: multipleChoicePageWidget(),
        ),

        //floating button
        if (kIsWeb)
          Container(
            margin: const EdgeInsets.all(40),
            alignment: Alignment.centerRight,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FloatingActionButton(
                  heroTag: 'btn1',
                  shape: const CircleBorder(),
                  onPressed: () {
                    if (currentIndex > 0) {
                      _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeIn);
                    }
                  },
                  child: const Icon(Icons.arrow_upward),
                ),
                FloatingActionButton(
                  heroTag: 'btn2',
                  shape: const CircleBorder(),
                  onPressed: () {
                    if (currentIndex < wordList.length - 1) {
                      _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut);
                    }
                  },
                  child: const Center(
                    child: Icon(Icons.arrow_downward),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  //summary dialog when user finished
  void showResultDialog() {
    score = finishedQuestCorrectly.length * 500;
    int index = widget.topic.participant!
        .indexWhere((p) => p.userID == auth.currentUser?.uid);
    if (widget.topic.participant![index].multipleChoicesResult == null) {
      highScore = -1;
      isNewHighScore = true;
    } else if (widget.topic.participant![index].multipleChoicesResult! <
        score) {
      highScore = score;
      isNewHighScore = true;
    } else {
      highScore = widget.topic.participant![index].multipleChoicesResult!;
      isNewHighScore = false;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: CupertinoColors.white,
          child: Container(
            width: kIsWeb ? mainPageWidth * 0.8 : mainPageWidth * 0.95,
            height: kIsWeb ? mainPageHeight * 0.8 : mainPageHeight * 0.85,
            child: Stack(
              children: [
                Container(
                  margin: EdgeInsets.only(top: 10, left: 10),
                  alignment: Alignment.topLeft,
                  child: RepaintBoundary(
                    child: ConfettiWidget(
                      confettiController: _confettiControllerLeft,
                      blastDirection: pi / 6,
                      // 45 degrees
                      emissionFrequency: 0.2,
                      // Adjusted emission frequency
                      numberOfParticles: 5,
                      // Increased number of particles
                      maxBlastForce: 65,
                      // Increased blast force
                      minBlastForce: 8,
                      // Increased minimum blast force
                      gravity: 0.01,
                      // Adjusted gravity
                      colors: const [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.purple, // Added more colors
                        Colors.orange
                      ],
                    ),
                  ),
                ),
                Container(
                  margin: EdgeInsets.only(top: 10, right: 10),
                  alignment: Alignment.topRight,
                  child: RepaintBoundary(
                    child: ConfettiWidget(
                      confettiController: _confettiControllerRight,
                      blastDirection: 5 * pi / 6,
                      // 135 degrees
                      emissionFrequency: 0.2,
                      // Adjusted emission frequency
                      numberOfParticles: 5,
                      // Increased number of particles
                      maxBlastForce: 65,
                      // Increased blast force
                      minBlastForce: 8,
                      // Increased minimum blast force
                      gravity: 0.01,
                      // Adjusted gravity
                      colors: const [
                        Colors.red,
                        Colors.blue,
                        Colors.green,
                        Colors.yellow,
                        Colors.purple, // Added more colors
                        Colors.orange
                      ],
                    ),
                  ),
                ),
                resultContext(),
                if (isNewHighScore) highScoreBadge()
              ],
            ),
          ),
        );
      },
    );
    if (!isShownOnce) {
      if (finishedQuestCorrectly.length > userSelection.length * 0.5) {
        _confettiControllerLeft.play();
        _confettiControllerRight.play();
      }
      updateScoreToDatabase(score);
    }
    if (!isShownOnce) isShownOnce = true;
    setState(() {});
  }

  //summary data in summary dialog
  Widget resultContext() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          mainResultTitle(),
          if (highScore != -1)
            Text(
              'High Score: $highScore',
              style: TextStyle(fontSize: kIsWeb ? 30 : 22),
            ),
          const Text(
            'You have completed the quiz.',
            style: TextStyle(fontSize: 18),
          ),
          Container(
            margin: const EdgeInsets.all(10),
            width: kIsWeb ? mainPageWidth * 0.7 : mainPageWidth * 0.9,
            height: kIsWeb ? mainPageHeight * 0.35 : mainPageHeight * 0.5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                //Progress indicator
                if (kIsWeb)
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: const Text(
                          'Your Progress',
                          style: TextStyle(
                              fontSize: 25, fontWeight: FontWeight.bold),
                        ),
                      ),
                      SizedBox(
                        width: kIsWeb
                            ? mainPageHeight * 0.24
                            : mainPageWidth * 0.4,
                        height: kIsWeb
                            ? mainPageHeight * 0.24
                            : mainPageWidth * 0.4,
                        child: PieChart(
                          PieChartData(startDegreeOffset: 270.0, sections: [
                            //Correct answer
                            PieChartSectionData(
                                value: finishedQuestCorrectly.length.toDouble(),
                                color: Colors.green[400],
                                title: "Correct",
                                titleStyle: const TextStyle(
                                    color: CupertinoColors.white)),

                            //Wrong answer
                            PieChartSectionData(
                                value: finishedQuestWrongly.length.toDouble(),
                                color: Colors.red[400],
                                title: "Wrong",
                                titleStyle: const TextStyle(
                                    color: CupertinoColors.white)),

                            //Skipped answer
                            PieChartSectionData(
                                value: skippedQuest.length.toDouble(),
                                color: Colors.grey[700],
                                title: "Skip",
                                titleStyle: const TextStyle(
                                    color: CupertinoColors.white))
                          ]),
                        ),
                      )
                    ],
                  ),

                //Result statistic
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    if (!kIsWeb)
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(bottom: 15),
                            child: const Text(
                              'Your Progress',
                              style: TextStyle(
                                  fontSize: 25, fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: kIsWeb
                                ? mainPageHeight * 0.24
                                : mainPageWidth * 0.4,
                            height: kIsWeb
                                ? mainPageHeight * 0.24
                                : mainPageWidth * 0.4,
                            child: PieChart(
                              PieChartData(startDegreeOffset: 270.0, sections: [
                                //Correct answer
                                PieChartSectionData(
                                    value: finishedQuestCorrectly.length
                                        .toDouble(),
                                    color: Colors.green[400],
                                    title: "Correct",
                                    titleStyle: const TextStyle(
                                        color: CupertinoColors.white)),

                                //Wrong answer
                                PieChartSectionData(
                                    value:
                                        finishedQuestWrongly.length.toDouble(),
                                    color: Colors.red[400],
                                    title: "Wrong",
                                    titleStyle: const TextStyle(
                                        color: CupertinoColors.white)),

                                //Skipped answer
                                PieChartSectionData(
                                    value: skippedQuest.length.toDouble(),
                                    color: Colors.grey[700],
                                    title: "Skip",
                                    titleStyle: const TextStyle(
                                        color: CupertinoColors.white))
                              ]),
                            ),
                          )
                        ],
                      ),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        width:
                            kIsWeb ? mainPageWidth * 0.3 : mainPageWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.green[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.green, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Correct',
                              style: TextStyle(
                                  color: Colors.green,
                                  fontSize: kIsWeb ? 35 : 20),
                            ),
                            Text(
                              '${finishedQuestCorrectly.length}',
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontSize: kIsWeb ? 35 : 20),
                            ),
                          ],
                        )),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        width:
                            kIsWeb ? mainPageWidth * 0.3 : mainPageWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.red[200],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.red, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Incorrect',
                              style: TextStyle(
                                  color: Colors.red,
                                  fontSize: kIsWeb ? 35 : 20),
                            ),
                            Text(
                              '${finishedQuestWrongly.length}',
                              style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: kIsWeb ? 35 : 20),
                            ),
                          ],
                        )),
                    Container(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        width:
                            kIsWeb ? mainPageWidth * 0.3 : mainPageWidth * 0.6,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: Colors.grey[700] as Color, width: 2),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Skipped',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: kIsWeb ? 35 : 20),
                            ),
                            Text(
                              '${skippedQuest.length}',
                              style: TextStyle(
                                  color: Colors.grey[700],
                                  fontSize: kIsWeb ? 35 : 20),
                            ),
                          ],
                        )),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            clearCache();
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Multiple Choice',
          style: TextStyle(
              color: CupertinoColors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blueAccent,
        actions: [
          if (isShownOnce)
            IconButton(
              icon: const Icon(
                color: CupertinoColors.white,
                Icons.insert_chart_outlined,
                size: 20,
              ),
              onPressed: () {
                showResultDialog();
              },
            )
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          mainPageWidth = constraints.maxWidth;
          mainPageHeight = constraints.maxHeight;
          return multipleChoiceQuizMainPage();
        },
      ),
    );
  }
}
