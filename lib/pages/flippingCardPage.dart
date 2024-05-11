import 'dart:math';

//import 'package:finalterm_test/wordList.dart'; //await word list.!!
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:Fluffy/objects/card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const FlippingCardPage(title: 'Flutter Demo Home Page'),
    );
  }
}

class FlippingCardPage extends StatefulWidget {
  const FlippingCardPage({super.key, required this.title});
  final String title;

  @override
  State<FlippingCardPage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<FlippingCardPage> {

  static Color appbarColor = Colors.deepOrange,
      appbarTextColor = Colors.white,
      cardPageBackground = const Color(0xFFeac3b8);

  late PageController _controller;
  static int _currentIndex = 0;
  final double _viewportFraction = kIsWeb?0.4:0.65;

  late dynamic cards;

  @override
  void initState() {
    cards.shuffle(Random());
    initCardsAnimation();
    super.initState();
  }

  void initCardsAnimation() {
    setState(() {
      _controller = PageController(
          initialPage: _currentIndex,
          viewportFraction: _viewportFraction
      );
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _controller.animateTo(0, duration: const Duration(milliseconds: 1), curve: Curves.easeIn);
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
            itemCount: cards.length,
            itemBuilder: (context, index) {
              return animatedCard(context, index);
            },
          ),
        )
    );
  }

  //  ----------------------------------------------------- //
  //  Make card opacity and size decreased when not primary //
  //  ----------------------------------------------------- //
  Widget animatedCard(BuildContext context, int index){
    return AnimatedBuilder(
        animation: _controller,
        builder: (context,child) {
          double scale = 1.0;
          double opacity = 1.0;

          if (_controller.position.haveDimensions)
          {
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
        child: MyFlippingCard(
          english: cards[index]['english']!,
          vietnamese: cards[index]['vietnamese']!,
          eDef: cards[index]['eDef']!,
          vDef: cards[index]['vDef']!,
        )
    );
  }

  //  ----------------------------------------------------- //
  //      main page bottom context (indicator display)      //
  //  ----------------------------------------------------- //
  Widget bottomPageContext(){
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        //first card button
        SizedBox(
          child: FloatingActionButton(
            onPressed: () {
              if (_currentIndex != 0) {
                int animateTime =  _currentIndex*100 + 200;
                _controller.animateTo(
                    0 ,
                    duration: Duration(milliseconds: animateTime),
                    curve: Curves.easeIn);
              }
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.fast_rewind), // Use RoundedRectangleBorder for compatibility
          ),
        ),
        //previous arrow button
        SizedBox(
          child: FloatingActionButton(
            onPressed: () {
              if (_currentIndex > 0) {
                _controller.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeIn);
              }
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.arrow_back), // Use RoundedRectangleBorder for compatibility
          ),
        ),
        //number indicator
        Container(
          alignment: Alignment.center,
          height: 100,
          child: Text(
            '${_currentIndex+1}/${cards.length}',
            style: const TextStyle(
              fontSize: 30,
            ),
          ),
        ),
        //forward arrow button
        SizedBox(
          child: FloatingActionButton(
            onPressed: () {
              if (_currentIndex < cards.length) {
                _controller.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
              }
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.arrow_forward), // Use RoundedRectangleBorder for compatibility
          ),
        ),
        //last card button
        SizedBox(
          child: FloatingActionButton(
            onPressed: () {
              if (_currentIndex != cards.length-1) {
                int animateTime = (cards.length - _currentIndex)*100 + 200;
                _controller.animateToPage(
                    cards.length-1,
                    duration: Duration(milliseconds: animateTime),
                    curve: Curves.easeIn
                );
              }
            },
            shape: const CircleBorder(),
            child: const Icon(Icons.fast_forward), // Use RoundedRectangleBorder for compatibility
          ),
        ),
      ],
    );
  }

  //  ----------------------------------------------------- //
  //            main page context (Card display)            //
  //  ----------------------------------------------------- //
  Widget mainPageContext(){
    return Expanded(
      child: Align(
        alignment: Alignment.center,
        child: LayoutBuilder(
            builder: (context, constraints){
              double cardPageHeight = constraints.maxHeight;
              return SingleChildScrollView(
                child: cardPage(cardPageHeight),
              );
            }
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar : AppBar(
        centerTitle : true,
        title : const Text('Test Application'),
        backgroundColor: appbarColor,
        titleTextStyle: TextStyle(
            color: appbarTextColor,
            fontWeight: FontWeight.bold
        ),
      ),
      body:Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          mainPageContext(),
          bottomPageContext()
        ],
      ) ,
    );
  }
}