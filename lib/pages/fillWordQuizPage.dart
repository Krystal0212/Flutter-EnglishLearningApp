import 'dart:math';
import 'package:Fluffy/objects/participant.dart';
import 'package:confetti/confetti.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gradient_animation_text/flutter_gradient_animation_text.dart';
import '../objects/card.dart';
import '../objects/topic.dart';
import '../objects/word.dart';

class FillWordQuizPage extends StatefulWidget {
  const FillWordQuizPage(
      {super.key,
      required this.topic,
      required this.isShuffle,
      required this.isChangeLanguage});

  final Topic topic;
  final bool isShuffle;
  final bool isChangeLanguage;

  @override
  State<FillWordQuizPage> createState() => _FillWordQuizPageState();
}

class _FillWordQuizPageState extends State<FillWordQuizPage>
    with SingleTickerProviderStateMixin {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;

  static late List<Word> wordList;
  static List<int> finishedCard = [];
  static List<int> finishedCardCorrectly = [];
  static List<int> finishedCardWrongly = [];
  static List<int> skippedCard = [];
  static Map<int, String> userInputResult = {}, filteredUserInputResult = {};
  late List<Word> filteredWordList;

  static const double mainIconSize = kIsWeb ? 50 : 20;
  static late double mainPageWidth, mainPageHeight;
  static int currentIndex = 0;
  static bool isQuizFinished = false;
  static String resultTitle = '';
  static dynamic resultTitleColor = Colors.black;
  static int score = 0;
  static String actionText = 'Result';
  static int selectedSummaryOption = 0;

  final TextEditingController _textResultController = TextEditingController();
  late PageController _pageController;
  late ConfettiController _confettiControllerLeft;
  late ConfettiController _confettiControllerRight;

  @override
  void initState() {
    initConfetti();
    initPageViewController();
    initWordList();
    super.initState();
    filteredWordList = wordList;
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }

  //initiate confetti controller
  void initConfetti() {
    _confettiControllerLeft =
        ConfettiController(duration: const Duration(seconds: 2));
    _confettiControllerRight =
        ConfettiController(duration: const Duration(seconds: 2));
  }

  //clear cache when quit page
  void clearCache() {
    finishedCard = [];
    finishedCardCorrectly = [];
    finishedCardWrongly = [];
    skippedCard = [];
    userInputResult = {};
    currentIndex = 0;
    isQuizFinished = false;
    resultTitle = '';
    resultTitleColor = Colors.black;
    actionText = 'Result';
    score = 0;
    selectedSummaryOption = 0;
  }

  //short snack bar function
  void callSnackBar(String message, int duration, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Center(
        child: Text(
          message,
        ),
      ),
      duration: Duration(milliseconds: duration),
      backgroundColor: color,
    ));
  }

  //initiate data into word list
  void initWordList() {
    wordList = List.from(widget.topic.word as List<Word>);
    if (widget.isShuffle) {
      wordList.shuffle(Random());
    }
  }

  //initiate controller for page view
  void initPageViewController() {
    setState(() {
      _pageController =
          PageController(initialPage: currentIndex, viewportFraction: 1.8);
    });
  }

  //skip action for skip button
  void setSkipToUnanswered() {
    for (int i = 0; i < wordList.length; i++) {
      if (!finishedCard.contains(i)) {
        finishedCard.add(i);
        skippedCard.add(i);
        userInputResult[i] = "Not Answered";
      }
    }
  }

  //check if user has answer/skip all question
  bool isAllAnswered() {
    return wordList.length == finishedCard.length;
  }

  //return summary page and run confetti if high score
  void summaryAndShowConfetti() {
    isQuizFinished = true;
    if (finishedCardCorrectly.length > wordList.length * 0.5) {
      _confettiControllerLeft.play();
      _confettiControllerRight.play();
    }
  }

  //action when user submit input
  void submitCardButton(Word word) async {
    String result = _textResultController.text.trim().toString();

    if (_textResultController.text.isNotEmpty) {
      if (!isAnswered(currentIndex)) {
        finishedCard.add(currentIndex);
        userInputResult[currentIndex] = result;

        if (isAnsweredCorrectly(word)) {
          callSnackBar('Awesome !', 2000, Colors.green.shade300);
        } else {
          callSnackBar('Wrong !', 2000, Colors.red.shade300);
        }

        setState(() {});
        _textResultController.clear();

        await Future.delayed(const Duration(milliseconds: 4000));
      }

      if (isAllAnswered()) {
        setState(() {
          summaryAndShowConfetti();
        });
      } else if (isAnswered(currentIndex)) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    } else {
      callSnackBar("Skipped!", 2000, Colors.grey.shade300);
      finishedCard.add(currentIndex);
      userInputResult[currentIndex] = "Not Answered";
      skippedCard.add(currentIndex);
      setState(() {});
      await Future.delayed(const Duration(milliseconds: 4000));
      if (isAllAnswered()) {
        setState(() {
          summaryAndShowConfetti();
        });
      } else if (isAnswered(currentIndex)) {
        _pageController.nextPage(
            duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
      }
    }
  }

  //cycle option for summary page
  void cycleGroupOption(int option) {
    setState(() {
      if (selectedSummaryOption == 0) {
        selectedSummaryOption = option;
      } else if (selectedSummaryOption == option) {
        selectedSummaryOption = 0;
      } else {
        selectedSummaryOption = option;
      }
      filterWords();
    });
  }

  void filterWords() {
    setState(() {
      filteredUserInputResult = {};
      filteredWordList = [];
      int index = 0;
      switch (selectedSummaryOption) {
        case 1:
          for (int i = 0; i < wordList.length; i++) {
            if (finishedCardCorrectly.contains(i)) {
              filteredWordList.add(wordList[i]);
            }
          }
          userInputResult.forEach((key, value) {
            if (finishedCardCorrectly.contains(key)) {
              filteredUserInputResult[index] = value;
              index++;
            }
          });
          break;
        case 2:
          for (int i = 0; i < wordList.length; i++) {
            if (finishedCardWrongly.contains(i)) {
              filteredWordList.add(wordList[i]);
            }
          }
          userInputResult.forEach((key, value) {
            if (finishedCardWrongly.contains(key)) {
              filteredUserInputResult[index] = value;
              index++;
            }
          });
          break;
        case 3:
          for (int i = 0; i < wordList.length; i++) {
            if (skippedCard.contains(i)) {
              filteredWordList.add(wordList[i]);
            }
          }
          userInputResult.forEach((key, value) {
            if (skippedCard.contains(key)) {
              filteredUserInputResult[index] = value;
              index++;
            }
          });
          break;
        default:
          filteredWordList = wordList;
          filteredUserInputResult = userInputResult;
          break;
      }
    });

    for (Word word in filteredWordList) {
      print(word.english);
    }
    print(filteredUserInputResult);
  }

  //check if user answer correctly (part of submitCardButton)
  bool isAnsweredCorrectly(Word word) {
    String answer = widget.isChangeLanguage
        ? word.vietnamese!.toLowerCase().toString()
        : word.english!.toLowerCase().toString();
    if (_textResultController.text.toLowerCase().trim() == answer) {
      finishedCardCorrectly.add(currentIndex);
      return true;
    }
    finishedCardWrongly.add(currentIndex);
    return false;
  }

  //check if user has already answer this question
  bool isAnswered(int currentIndex) {
    if (finishedCard.contains(currentIndex)) {
      return true;
    }
    return false;
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

  //initiate linear progress indicator widget
  Widget progressIndicatorWidget() {
    return LinearProgressIndicator(
      minHeight: mainPageHeight * 0.01,
      value: currentIndex.toDouble() / (wordList.length - 1),
      valueColor: AlwaysStoppedAnimation<Color>(
        getColorForProgress(currentIndex.toDouble() / (wordList.length - 1)),
      ),
    );
  }

  //initiate user input widget
  Widget userInputFieldWidget(Word word) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Curved left border text field
        Container(
          width: kIsWeb ? mainPageHeight * 0.5 : mainPageWidth * 0.6,
          height: kIsWeb ? mainPageHeight * 0.1 : 70,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.blue[100],
            borderRadius: const BorderRadius.only(
              topLeft:
                  Radius.circular(20.0), // Adjust the curve radius as needed
              bottomLeft: Radius.circular(20.0),
            ),
            border: Border.all(
                color: Colors.blueAccent, width: 3), // Example border style
          ),
          child: TextField(
            cursorColor: Colors.blue,
            controller: _textResultController,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 10.0),
              hintText: 'Enter the word',
            ),
          ),
        ),
        // IconButton
        Container(
          width: kIsWeb ? mainPageHeight * 0.15 : mainPageWidth * 0.2,
          height: kIsWeb ? mainPageHeight * 0.1 : 70,
          decoration: const BoxDecoration(
            color: Colors.blueAccent,
            borderRadius: BorderRadius.only(
              topRight:
                  Radius.circular(20.0), // Adjust the curve radius as needed
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: IconButton(
            onPressed: () {
              submitCardButton(word);
            },
            icon: const Icon(
              Icons.subdirectory_arrow_left,
              color: Colors.white70,
            ),
            iconSize: mainIconSize,
          ),
        ),
      ],
    );
  }

  //reveal answer to user when user submit/skip question
  Widget userRevealAnswerWidget(int currentIndex) {
    return Container(
      width: kIsWeb ? mainPageHeight * 0.65 : mainPageWidth * 0.8,
      height: kIsWeb ? mainPageHeight * 0.1 : 70,
      decoration: BoxDecoration(
        color: finishedCardCorrectly.contains(currentIndex)
            ? Colors.green
            : skippedCard.contains(currentIndex)
                ? Colors.grey[700]
                : Colors.red,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Center(
        child: Text(
          userInputResult[currentIndex] ?? "Not Answered",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  //initiate title for summary page and update user score
  Widget summaryTitleWidget() {
    double titleFontSize = kIsWeb ? 70 : 30;
    score = finishedCardCorrectly.length * 500;
    updateScoreToDatabase(score);
    resultTitle = "Your Score: $score";
    if (finishedCardCorrectly.length == finishedCard.length) {
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
          style: TextStyle(
            fontSize: titleFontSize,
          ),
        ),
        duration: const Duration(milliseconds: 500),
      );
    } else if (finishedCardCorrectly.length >= finishedCard.length * 0.75) {
      resultTitleColor = const Color(0xFFd4af37);
      return Text(
        resultTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: titleFontSize, color: resultTitleColor),
      );
    } else if (finishedCardCorrectly.length >= finishedCard.length * 0.5) {
      resultTitleColor = const Color(0xFFBcc6cc);
      return Text(
        resultTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: titleFontSize, color: resultTitleColor),
      );
    } else if (finishedCardCorrectly.length >= finishedCard.length * 0.25) {
      resultTitleColor = const Color(0xFF5B391E);
      return Text(
        resultTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: titleFontSize, color: resultTitleColor),
      );
    } else {
      resultTitleColor = Colors.black87;
      return Text(
        resultTitle,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: titleFontSize, color: resultTitleColor),
      );
    }
  }

  // update score when user finished quiz
  void updateScoreToDatabase(int score) {
    int index = widget.topic.participant!
        .indexWhere((p) => p.userID == auth.currentUser?.uid);
    if (widget.topic.participant![index].fillWordResult == null ||
        widget.topic.participant![index].fillWordResult! < score) {
      print('update score');
      Participant toUpdateParticipant = Participant(auth.currentUser?.uid,
          widget.topic.participant![index].multipleChoicesResult ?? 0, score);
      dbRef
          .child("Topic/${widget.topic.id}/participant/$index")
          .update(toUpdateParticipant.toMap())
          .then((value) {});
    }
    print('not update score');
  }

  //||===========================||
  //||          Quiz page        ||
  //||===========================||
  Widget quizPage() {
    return LayoutBuilder(
      builder: (context, constraints) {
        mainPageWidth = constraints.maxWidth;
        mainPageHeight = constraints.maxHeight * 0.99;
        return Column(
          children: [progressIndicatorWidget(), quizPageContext()],
        );
      },
    );
  }

  //||===========================||
  //|| Context inside quiz page  ||
  //||===========================||
  Widget quizPageContext() {
    return SizedBox(
      width: mainPageWidth,
      height: mainPageHeight,
      child: PageView.builder(
          pageSnapping: true,
          //physics: const NeverScrollableScrollPhysics(),
          controller: _pageController,
          onPageChanged: (int index) {
            setState(() {
              currentIndex = index;
            });
          },
          itemCount: wordList.length,
          itemBuilder: (context, index) {
            return SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  //upper page context
                  SizedBox(
                      width: kIsWeb ? mainPageHeight * 0.65 : mainPageWidth,
                      height:
                          kIsWeb ? mainPageHeight * 0.83 : mainPageWidth * 1.4,
                      child: upperPageContext(wordList[currentIndex])),
                  //bottom page context
                  SizedBox(
                      width: kIsWeb ? mainPageHeight : mainPageWidth,
                      height:
                          kIsWeb ? mainPageHeight * 0.17 : mainPageHeight * 0.2,
                      child: bottomPageContext(wordList[currentIndex]))
                ],
              ),
            );
          }),
    );
  }

  //||===========================||
  //||  Upper quiz page context  ||
  //||===========================||
  Widget upperPageContext(Word word) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 20),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 800),
          child: isAnswered(currentIndex)
              ? MyCard(word).myNormalCard(
                  isResultShown: isAnswered(currentIndex),
                  isChangeLanguage: widget.isChangeLanguage)
              : MyCard(word).myNormalCard(
                  isResultShown: isAnswered(currentIndex),
                  isChangeLanguage: widget.isChangeLanguage),
        ));
  }

  //||===========================||
  //|| Bottom quiz page context  ||
  //||===========================||
  Widget bottomPageContext(Word word) {
    return Container(
        width: mainPageWidth,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //move to previous button in web
            kIsWeb
                ? IconButton(
                    onPressed: () {
                      if (currentIndex > 0) {
                        _pageController.previousPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeIn);
                      }
                    },
                    icon: const Icon(Icons.arrow_back),
                    iconSize: mainIconSize,
                  )
                : const SizedBox.shrink(),

            //text field accept user input
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isAnswered(currentIndex)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Result: ",
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                fontSize: kIsWeb ? 22 : 17,
                                fontWeight: FontWeight.bold),
                          ),
                          Text(
                            widget.isChangeLanguage
                                ? wordList[currentIndex].vietnamese as String
                                : wordList[currentIndex].english as String,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: Colors.red,
                                fontSize: kIsWeb ? 22 : 17,
                                fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    : SizedBox.shrink(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: isAnswered(currentIndex)
                        ? userRevealAnswerWidget(currentIndex)
                        : userInputFieldWidget(word),
                  ),
                ),
              ],
            ),

            //move to next button in web
            kIsWeb
                ? IconButton(
                    onPressed: () async {
                      if (currentIndex < wordList.length - 1) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      } else {
                        if (finishedCard.length == wordList.length) {
                          //await Future.delayed(const Duration(milliseconds: 4000));
                          setState(() {});
                          summaryAndShowConfetti();
                        } else {
                          setSkipToUnanswered();
                          setState(() {});
                          await Future.delayed(
                              const Duration(milliseconds: 4000));
                          setState(() {});
                          summaryAndShowConfetti();
                        }
                      }
                    },
                    icon: const Icon(Icons.arrow_forward),
                    iconSize: mainIconSize,
                  )
                : const SizedBox.shrink(),
          ],
        ));
  }

  //||===========================||
  //||        summary page       ||
  //||===========================||
  Widget summaryPage() {
    return SizedBox(
      width: mainPageWidth,
      height: mainPageHeight,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
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
              ],
            ),
            //result title
            Container(
              child: summaryTitleWidget(),
            ),

            //result data
            Container(
              margin: const EdgeInsets.all(10),
              width: kIsWeb ? mainPageWidth * 0.7 : mainPageWidth,
              height: mainPageHeight * 0.35,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  //Progress indicator
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        child: const Text(
                          'Your Progress',
                          style: TextStyle(
                              fontSize: kIsWeb ? 30 : 25,
                              fontWeight: FontWeight.bold),
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
                              value: finishedCardCorrectly.length.toDouble(),
                              color: Colors.green[400],
                              title: kIsWeb
                                  ? "Correct"
                                  : "Correct: ${finishedCardCorrectly.length}",
                              titleStyle: const TextStyle(color: Colors.white),
                            ),

                            //Wrong answer
                            PieChartSectionData(
                              value: finishedCardWrongly.length.toDouble(),
                              color: Colors.red[400],
                              title: kIsWeb
                                  ? "Wrong"
                                  : "Wrong: ${finishedCardWrongly.length}",
                              titleStyle: const TextStyle(color: Colors.white),
                            ),

                            //Skipped answer
                            PieChartSectionData(
                              value: skippedCard.length.toDouble(),
                              color: Colors.grey[700],
                              title: kIsWeb
                                  ? "Skip"
                                  : "Skip: ${skippedCard.length}",
                              titleStyle: const TextStyle(color: Colors.white),
                            )
                          ]),
                        ),
                      )
                    ],
                  ),

                  //Result statistic
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                          onPressed: () {
                            cycleGroupOption(1);
                          },
                          style: TextButton.styleFrom(
                              minimumSize: Size(mainPageWidth * 0.3, 40),
                              backgroundColor: Colors.green[200],
                              side: BorderSide(color: Colors.green, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Correct',
                                textAlign:
                                    kIsWeb ? TextAlign.start : TextAlign.center,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: kIsWeb ? 35 : 20),
                              ),
                              kIsWeb
                                  ? Text(
                                      '${finishedCardCorrectly.length}',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontSize: kIsWeb ? 35 : 20),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          )),
                      TextButton(
                          onPressed: () {
                            cycleGroupOption(2);
                          },
                          style: TextButton.styleFrom(
                              minimumSize: Size(mainPageWidth * 0.3, 40),
                              backgroundColor: Colors.red[200],
                              side: BorderSide(color: Colors.red, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Incorrect',
                                textAlign:
                                    kIsWeb ? TextAlign.start : TextAlign.center,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: kIsWeb ? 35 : 20),
                              ),
                              kIsWeb
                                  ? Text(
                                      '${finishedCardWrongly.length}',
                                      style: const TextStyle(
                                          color: Colors.red,
                                          fontSize: kIsWeb ? 35 : 20),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          )),
                      TextButton(
                          onPressed: () {
                            cycleGroupOption(3);
                          },
                          style: TextButton.styleFrom(
                              minimumSize: Size(mainPageWidth * 0.3, 40),
                              backgroundColor: Colors.grey[300],
                              side: BorderSide(
                                  color: Colors.grey[700] as Color, width: 2),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              )),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Skipped',
                                textAlign:
                                    kIsWeb ? TextAlign.start : TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: kIsWeb ? 35 : 20),
                              ),
                              kIsWeb
                                  ? Text(
                                      '${skippedCard.length}',
                                      style: TextStyle(
                                          color: Colors.grey[700],
                                          fontSize: kIsWeb ? 35 : 20),
                                    )
                                  : SizedBox.shrink(),
                            ],
                          )),
                    ],
                  )
                ],
              ),
            ),

            //result progress
            Expanded(
                flex: 1,
                child: Container(
                  width: kIsWeb ? mainPageWidth * 0.7 : mainPageWidth,
                  child: ListView.builder(
                      itemCount: filteredWordList.length,
                      itemBuilder: (context, index) {
                        var word = filteredWordList[index];
                        //filteredUserInputResult = userInputResult;
                        //var wordIndex = wordList.indexOf(word);
                        var borderColor, tileColor, showIcon;

                        if (selectedSummaryOption == 1) {
                          borderColor = Colors.green;
                          tileColor = Colors.green[200];
                          showIcon = const Icon(
                            Icons.check,
                            color: Colors.green,
                            size: mainIconSize,
                          );
                        } else if (selectedSummaryOption == 2) {
                          borderColor = Colors.red;
                          tileColor = Colors.red[200];
                          showIcon = const Icon(Icons.close,
                              color: Colors.red, size: mainIconSize);
                        } else if (selectedSummaryOption == 3) {
                          borderColor = Colors.grey;
                          tileColor = Colors.grey[400];
                          showIcon = Icon(Icons.backspace_outlined,
                              color: Colors.grey[700], size: mainIconSize);
                        } else {
                          filteredUserInputResult = userInputResult;
                          borderColor = finishedCardCorrectly.contains(index)
                              ? Colors.green
                              : skippedCard.contains(index)
                                  ? Colors.grey
                                  : Colors.red;
                          tileColor = finishedCardCorrectly.contains(index)
                              ? Colors.green[200]
                              : skippedCard.contains(index)
                                  ? Colors.grey[400]
                                  : Colors.red[200];
                          showIcon = finishedCardCorrectly.contains(index)
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.green,
                                  size: mainIconSize,
                                )
                              : skippedCard.contains(index)
                                  ? Icon(Icons.backspace_outlined,
                                      color: Colors.grey[700],
                                      size: mainIconSize)
                                  : const Icon(Icons.close,
                                      color: Colors.red, size: mainIconSize);
                        }

                        //if (){}
                        return Container(
                          margin: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            color: tileColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: borderColor, width: 2),
                          ),
                          child: ListTile(
                            trailing: showIcon,
                            textColor: Colors.black,
                            titleTextStyle:
                                const TextStyle(fontSize: kIsWeb ? 25 : 18),
                            subtitleTextStyle:
                                const TextStyle(fontSize: kIsWeb ? 20 : 15),
                            subtitle: Text(
                              'Your answer: ${filteredUserInputResult[index]}',
                            ),
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    textAlign: TextAlign.left,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    'Result: ${word.vietnamese}',
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    textAlign: TextAlign.right,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    widget.isChangeLanguage
                                        ? 'Vietnamese'
                                        : 'English'
                                            ': ${word.english}',
                                  ),
                                )
                              ],
                            ),
                          ),
                        );
                      }),
                ))
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              clearCache();
              Navigator.pop(context);
            },
          ),
          actions: [
            (currentIndex == wordList.length - 1 && !isQuizFinished)
                ? TextButton(
                    onPressed: () async {
                      setState(() {
                        actionText = "Processing. . .";
                      });
                      if (currentIndex < wordList.length - 1) {
                        _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut);
                      } else {
                        if (finishedCard.length == wordList.length) {
                          //await Future.delayed(const Duration(milliseconds: 4000));
                          setState(() {});
                          summaryAndShowConfetti();
                        } else {
                          setSkipToUnanswered();
                          setState(() {});
                          await Future.delayed(
                              const Duration(milliseconds: 4000));
                          setState(() {});
                          summaryAndShowConfetti();
                        }
                      }
                    },
                    style: TextButton.styleFrom(
                        side:
                            BorderSide(color: Colors.green.shade700, width: 3),
                        backgroundColor: Colors.green.shade300),
                    child: Text(
                      actionText,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  )
                : const SizedBox.shrink()
          ],
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text('Fill word quiz'),
          backgroundColor: Colors.blueAccent,
          titleTextStyle: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 25),
        ),
        body: AnimatedSwitcher(
          duration: const Duration(milliseconds: 1000),
          child: isQuizFinished ? summaryPage() : quizPage(),
        ));
  }
}

/*
Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          width: mainPageWidth * 0.3,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.green[200],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.green,
                                width: 2
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Correct',
                                textAlign: kIsWeb?TextAlign.start:TextAlign.center,
                                style: TextStyle(
                                    color: Colors.green,
                                    fontSize: kIsWeb? 35 : 20
                                ),
                              ),
                              kIsWeb?
                              Text(
                                '${finishedCardCorrectly.length}',
                                style: const TextStyle(
                                    color: Colors.green,
                                    fontSize: kIsWeb? 35 : 20
                                ),
                              )
                                  :SizedBox.shrink(),
                            ],
                          )
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          alignment: Alignment.center,
                          width: mainPageWidth * 0.3,
                          decoration: BoxDecoration(
                            color: Colors.red[200],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.red,
                                width: 2
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Incorrect',
                                textAlign: kIsWeb?TextAlign.start:TextAlign.center,
                                style: TextStyle(
                                    color: Colors.red,
                                    fontSize: kIsWeb? 35 : 20
                                ),
                              ),
                              kIsWeb?
                              Text(
                                '${finishedCardWrongly.length}',
                                style: const TextStyle(
                                    color: Colors.red,
                                    fontSize: kIsWeb? 35 : 20
                                ),
                              )
                                  :SizedBox.shrink(),
                            ],
                          )
                      ),
                      Container(
                          padding: const EdgeInsets.symmetric(horizontal: 15),
                          width: mainPageWidth * 0.3,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: Colors.grey[300],
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                                color: Colors.grey[700] as Color,
                                width: 2
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                'Skipped',
                                textAlign: kIsWeb?TextAlign.start:TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: kIsWeb? 35 : 20
                                ),
                              ),
                              kIsWeb?
                              Text(
                                '${skippedCard.length}',
                                style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: kIsWeb? 35 : 20
                                ),
                              )
                                  :SizedBox.shrink(),
                            ],
                          )
                      )
 */
