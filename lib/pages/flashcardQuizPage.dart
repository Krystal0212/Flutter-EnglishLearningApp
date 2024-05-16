import 'dart:math';
import 'package:Fluffy/objects/word.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/objects/card.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';
import '../objects/topic.dart';

class FlashcardQuizPage extends StatefulWidget {
  const FlashcardQuizPage({super.key, required this.topic});

  final Topic topic;

  @override
  State<FlashcardQuizPage> createState() => _FlashcardQuizPageState();
}

class _FlashcardQuizPageState extends State<FlashcardQuizPage> {
  static Color appbarColor = Colors.blue[200] as Color,
      appbarTextColor = Colors.black,
      cardPageBackground = Colors.blue[50] as Color;

  static double appbarTextSize = 20;
  static bool isAutoFlashcard = false;

  late PageController _controller;
  static int _currentIndex = 0;
  final double _viewportFraction = kIsWeb ? 0.4 : 0.65;

  late List<Word> wordList;

  late Map<String, GestureFlipCardController> cardDeckControllers = {};
  late Map<String, MyFlippingCard> cardDecks = {};

  @override
  void initState() {
    initWordList();
    generateCardDeck();
    initCardsAnimation();
    super.initState();
  }

  @override
  void dispose() {
    returnDefaultState();
    super.dispose();
  }

  void returnDefaultState() {
    cardDecks = {};
    cardDeckControllers = {};
    isAutoFlashcard = false;
  }

  void generateCardDeck() {
    for (int i = 0; i < widget.topic.word!.length; i++) {
      cardDeckControllers['cardController$i'] = GestureFlipCardController();
      cardDecks['card$i'] = MyFlippingCard(
        word: wordList[i],
        flippingCardController: cardDeckControllers['cardController$i']!,
      );
    }
  }

  void initWordList() {
    wordList = widget.topic.word as List<Word>;
    //wordList.shuffle(Random());
  }

  void initCardsAnimation() {
    setState(() {
      _controller = PageController(
          initialPage: _currentIndex, viewportFraction: _viewportFraction);
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _controller.animateTo(0,
            duration: const Duration(milliseconds: 1), curve: Curves.easeIn);
      });
    });
  }

  //  ----------------------------------------------------- //
  //             Area for displaying single card            //
  //  ----------------------------------------------------- //
  Widget cardPage(double cardPageHeight) {
    return SizedBox(
        height: cardPageHeight,
        child: Container(
          color: cardPageBackground,
          child: PageView.builder(
            controller: _controller,
            onPageChanged: (int index) {
              setState(() {
                _currentIndex = index;
              });
            },
            itemCount: wordList.length,
            itemBuilder: (context, index) {
              return animatedCard(context, index);
            },
          ),
        ));
  }

  //  ----------------------------------------------------- //
  //  Make card opacity and size decreased when not primary //
  //  ----------------------------------------------------- //
  Widget animatedCard(BuildContext context, int index) {
    return AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          double scale = 1.0;
          double opacity = 1.0;
          if (_controller.position.haveDimensions) {
            double dimParam = _controller.page! - index;
            scale = (1 - (dimParam.abs() * 0.3)).clamp(0.7, 1.0);
            opacity = (1 - (dimParam.abs() * 0.5)).clamp(0.05, 1.0);
          }
          return Center(
            child: Transform.scale(
              scale: scale,
              child: Opacity(
                opacity: opacity,
                child: child,
              ),
            ),
          );
        },
        child: cardDecks['card$index']);
  }

  //  ----------------------------------------------------- //
  //      main page bottom context (indicator display)      //
  //  ----------------------------------------------------- //
  Widget bottomPageContext() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        //first card button
        SizedBox(
          child: FloatingActionButton(
            heroTag: 'btn1',
            onPressed: () async {
              setState(() {
                if (isAutoFlashcard) {
                  isAutoFlashcard = false;
                } else {
                  isAutoFlashcard = true;
                }
              });

              /*
              logic:
                speak + wait => flip => speak + wait => move then continue
               */

              while (_currentIndex < wordList.length && isAutoFlashcard) {
                if (isAutoFlashcard) {
                  if (cardDecks['card$_currentIndex']!
                      .flippingCardController
                      .state!
                      .isFront) {
                    cardDecks['card$_currentIndex']!.speakEng();
                  } else {
                    cardDecks['card$_currentIndex']!.speakVie();
                  }
                } else {
                  break;
                }

                await Future.delayed(Duration(milliseconds: 2500));
                if (isAutoFlashcard) {
                  cardDecks['card$_currentIndex']!.flipCard();
                } else {
                  break;
                }

                await Future.delayed(Duration(milliseconds: 2500));
                if (isAutoFlashcard) {
                  if (!cardDecks['card$_currentIndex']!
                      .flippingCardController
                      .state!
                      .isFrontStart) {
                    cardDecks['card$_currentIndex']!.speakVie();
                  } else {
                    cardDecks['card$_currentIndex']!.speakEng();
                  }
                } else {
                  break;
                }

                await Future.delayed(Duration(milliseconds: 2500));
                if (isAutoFlashcard) {
                  if (_currentIndex == wordList.length - 1) {
                    setState(() {
                      isAutoFlashcard = false;
                    });
                    break;
                  }
                  _controller.nextPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut);
                  await Future.delayed(Duration(milliseconds: 2500));
                } else {
                  break;
                }
              }
            },
            shape: const CircleBorder(),
            child: isAutoFlashcard
                ? Icon(Icons.pause)
                : Icon(Icons
                    .play_arrow), // Use RoundedRectangleBorder for compatibility
          ),
        ),
        //previous arrow button
        SizedBox(
          child: FloatingActionButton(
            heroTag: 'btn2',
            onPressed: () {
              if (_currentIndex > 0) {
                _controller.previousPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeIn);
              }
            },
            shape: const CircleBorder(),
            child: const Icon(Icons
                .arrow_back), // Use RoundedRectangleBorder for compatibility
          ),
        ),
        //number indicator
        Container(
          alignment: Alignment.center,
          height: 100,
          child: Text(
            '${_currentIndex + 1}/${wordList.length}',
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        //forward arrow button
        SizedBox(
          child: FloatingActionButton(
            heroTag: 'btn3',
            onPressed: () {
              if (_currentIndex < wordList.length) {
                _controller.nextPage(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut);
              }
            },
            shape: const CircleBorder(),
            child: const Icon(Icons
                .arrow_forward), // Use RoundedRectangleBorder for compatibility
          ),
        ),
        //last card button
        SizedBox(
          child: FloatingActionButton(
            heroTag: 'btn4',
            onPressed: () {
              if (_currentIndex != wordList.length - 1) {
                int animateTime = (wordList.length - _currentIndex) * 100 + 200;
                _controller.animateToPage(wordList.length - 1,
                    duration: Duration(milliseconds: animateTime),
                    curve: Curves.easeIn);
              }
            },
            shape: const CircleBorder(),
            child: const Icon(Icons
                .fast_forward), // Use RoundedRectangleBorder for compatibility
          ),
        ),
      ],
    );
  }

  //  ----------------------------------------------------- //
  //            main page context (Card display)            //
  //  ----------------------------------------------------- //
  Widget mainPageContext() {
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: LayoutBuilder(builder: (context, constraints) {
          double cardPageHeight = constraints.maxHeight;
          return SingleChildScrollView(
            child: cardPage(cardPageHeight),
          );
        }),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              returnDefaultState();
              Navigator.pop(context);
            },
          ),
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            'Flashcard',
            style: TextStyle(color: CupertinoColors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.blueAccent,
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [mainPageContext(), bottomPageContext()],
        ));
  }
}
