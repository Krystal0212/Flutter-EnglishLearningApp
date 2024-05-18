import 'package:Fluffy/objects/word.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';


class MyCard {
  Word word;

  MyCard(this.word);

  MyFlippingCard myFlippingCard({
    required GestureFlipCardController flippingCardController,
  }) {
    return MyFlippingCard(
      word: word,
      flippingCardController: flippingCardController,
    );
  }

  MyNormalCard myNormalCard({
    required bool isResultShown,
    required bool isChangeLanguage
  }) {
    return MyNormalCard(
        word: word,
        isResultShown: isResultShown,
        isChangeLanguage: isChangeLanguage,
    );
  }
}

//========================================================================//
//                        MyFlippingCard Class                            //
//========================================================================//
class MyFlippingCard extends StatelessWidget {
  final dynamic word;
  final GestureFlipCardController flippingCardController;
  //final String image;

  const MyFlippingCard({
    super.key,
    required this.word,
    required this.flippingCardController
    //required this.image,
  });

  static late double cardWidth,
      cardHeight,
      cardImgRadius;

  static const double cardBorderRadius = 15,
      cardContextBorderRadius = 10;

  final Color frontCardColor = const Color(0xFFa49fd3),
      backCardColor = const Color(0xFFcba7bd),
      defAreaColor = CupertinoColors.white,
      imgAreaColor = CupertinoColors.white,
      cardBorderColor = Colors.black;

  static final FlutterTts flutterTts = FlutterTts();

  Future _speak(String inputText, String language) async{
    flutterTts.setLanguage(language);
    flutterTts.setVolume(1);
    await flutterTts.speak(inputText);
  }

  void flipCard(){
    flippingCardController.flipcard();
  }

  void speakEng(){
    _speak(word.english as String, 'en-US');
  }

  void speakVie(){
    _speak(word.vietnamese as String, 'vi-VN');
  }


  //  ----------------------------------------------------- //
  //                       card design                      //
  //  ----------------------------------------------------- //
  Widget cardContext(String word, String? description, String image, {String language = 'en-US'}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Image
        Expanded(
            child: Center(
              child: LayoutBuilder(
                  builder: (context,constraints){
                    cardImgRadius = kIsWeb ? constraints.maxWidth * 0.3
                        : constraints.maxWidth * 0.5;
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(20),
                      width: cardImgRadius*1.1,
                      height: cardImgRadius*1.1,
                      decoration: BoxDecoration(
                          color: imgAreaColor,
                          borderRadius: BorderRadius.circular(cardImgRadius)
                      ),
                      child: Image.asset(image, width: cardImgRadius,height: cardImgRadius,),
                    );
                  }
              ),
            )
        ),

        //white box
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          width: cardWidth - 40,
          height: cardHeight / 2,
          decoration: BoxDecoration(
            color: defAreaColor,
            borderRadius: BorderRadius.circular(cardContextBorderRadius),
            border: Border.all(
                width: 3,
                style: BorderStyle.solid,
                color: cardBorderColor
            ),
          ),

          //box's context
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              //Key word & speaking button
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Column(
                    children: [
                      //Key word
                      Text(
                        word,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),

                      //Speaking button
                      IconButton(
                          iconSize: 40,
                          onPressed: () {
                            _speak(word,language);
                            //_stop();
                          },
                          icon: const Icon(Icons.volume_down)),
                    ],
                  )
              ),

              //Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  description??"No description",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }

  //  ----------------------------------------------------- //
  //             return final single card design            //
  //  ----------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints){
        cardHeight = constraints.maxHeight * 0.8;
        cardWidth = constraints.maxWidth*0.9;
        return GestureFlipCard(
            animationDuration: const Duration(milliseconds: 400),
            axis: FlipAxis.horizontal,
            controller: flippingCardController,
            enableController: true,

            frontWidget: GestureDetector(
              onTap:() => flippingCardController.flipcard(),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: frontCardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(cardBorderRadius)),
                    border: Border.all(
                        width: 3,
                        style: BorderStyle.solid,
                        color: Colors.black
                    ),
                  ),
                  width: cardWidth,
                  height: cardHeight,
                  child: cardContext(word.english as String,word.description as String,'assets/images/stelle.png'),
                ),
              ),
            ),
            backWidget: GestureDetector(
              onTap: ()=> flippingCardController.flipcard(),
              child: Center(
                child: Container(
                  decoration: BoxDecoration(
                    color: backCardColor,
                    borderRadius: const BorderRadius.all(Radius.circular(cardBorderRadius)),
                    border: Border.all(
                        width: 3,
                        style: BorderStyle.solid,
                        color: Colors.black

                    ),
                  ),
                  width: cardWidth,
                  height: cardHeight,
                  child: cardContext(word.vietnamese as String,word.description as String,'assets/images/stelle2.png', language: 'vi-VN'),
                ),
              ),
            )
        );
      },
    );
  }
}

//========================================================================//
//                           MyNormalCard Class                           //
//========================================================================//
class MyNormalCard extends StatelessWidget {
  final Word word;
  final bool isResultShown;
  final bool isChangeLanguage;
  //final String image;

  const MyNormalCard({
    super.key,
    required this.word,
    required this.isResultShown,
    required this.isChangeLanguage
    //required this.image,
  });

  static late double cardWidth,
      cardHeight,
      cardImgRadius;

  static const double cardBorderRadius = 15,
      cardContextBorderRadius = 10;

  final Color frontCardColor = const Color(0xFFa49fd3),
      backCardColor = const Color(0xFFcba7bd),
      defAreaColor = CupertinoColors.white,
      imgAreaColor = CupertinoColors.white,
      cardBorderColor = Colors.black;

  final String cardBackground = 'assets/images/cardBackgroundImage.jpg';
  static final String img1 = 'assets/images/stelle.png',
                     img2 = 'assets/images/stelle2.png';

  static FlutterTts flutterTts = FlutterTts();

  Future _speak(String inputText) async{
    print('dang speak word $inputText');
    flutterTts.setVolume(1);
    await flutterTts.speak(inputText);
  }


  //  ----------------------------------------------------- //
  //                       card design                      //
  //  ----------------------------------------------------- //
  Widget cardContext(String image, String? description, String word) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Image
        Expanded(
            child: Center(
              child: LayoutBuilder(
                  builder: (context,constraints){
                    cardImgRadius = kIsWeb ? constraints.maxWidth * 0.4
                        : constraints.maxWidth * 0.45;
                    return Container(
                      alignment: Alignment.center,
                      margin: const EdgeInsets.all(20),
                      width: cardImgRadius*1.1,
                      height: cardImgRadius*1.1,
                      decoration: BoxDecoration(
                          color: imgAreaColor,
                          borderRadius: BorderRadius.circular(cardImgRadius)
                      ),
                      child: Image.asset(image, width: cardImgRadius,height: cardImgRadius,),
                    );
                  }
              ),
            )
        ),

        //white box
        Container(
          margin: const EdgeInsets.only(bottom: 20),
          width: cardWidth - 40,
          height: cardHeight / 2,
          decoration: BoxDecoration(
            color: defAreaColor,
            borderRadius: BorderRadius.circular(cardContextBorderRadius),
            border: Border.all(
                width: 3,
                style: BorderStyle.solid,
                color: cardBorderColor
            ),
          ),

          //box's context
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [

              //Key word & speaking button
              Padding(
                  padding: const EdgeInsets.fromLTRB(0, 10, 0, 10),
                  child: Column(
                    children: [
                      //Key word
                      Text(
                        word,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      //Speaking button
                      IconButton(
                          iconSize: 40,
                          onPressed: () {
                            print('speak word $word');
                            _speak(word);
                            //_stop();
                          },
                          icon: const Icon(Icons.volume_down)
                      ),
                    ],
                  )
              ),

              //Description
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15),
                child: Text(
                  description??"No description",
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 15,
                  ),
                ),
              )
            ],
          ),
        )
      ],
    );
  }


  //  ----------------------------------------------------- //
  //             return final single card design            //
  //  ----------------------------------------------------- //
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
        builder: (context,constraints){
          cardWidth = constraints.maxWidth;
          cardHeight = constraints.maxHeight;
          return Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: AssetImage(cardBackground),
                  fit: BoxFit.fill
              ),
              borderRadius: const BorderRadius.all(Radius.circular(cardBorderRadius)),
              border: Border.all(
                  width: 3,
                  style: BorderStyle.solid,
                  color: Colors.black
              ),
            ),
            width: cardWidth,
            height: cardHeight,
            child: isResultShown?
            cardContext(
                img1,
                word.description as String,
                isChangeLanguage ?
                  word.english as String : word.vietnamese as String
            ):
            cardContext(
                img2,
                word.description as String,
                isChangeLanguage ?
                  word.english as String : word.vietnamese as String
            ),
          );
        }
    );
  }
}