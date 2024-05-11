import 'dart:ui';
import 'package:Fluffy/objects/word.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter_flip_card/flutter_flip_card.dart';


class MyFlippingCard extends StatelessWidget {
  final Word word;
  //final String image;

  const MyFlippingCard({
    super.key,
    required this.word
    //required this.image,
  });



  static late double cardWidth,
      cardHeight,
      cardImgRadius;

  static const double cardBorderRadius = 15,
      cardContextBorderRadius = 10;

  final Color frontCardColor = const Color(0xFFa49fd3),
      backCardColor = const Color(0xFFcba7bd),
      defAreaColor = Colors.white,
      imgAreaColor = Colors.white70,
      cardBorderColor = Colors.black;

  static FlutterTts flutterTts = FlutterTts();
  static const enVoice = 'en-US',
               vietVoice = 'fr-FR';


  Future _speak(String inputText, String language) async{
    flutterTts.setLanguage(language);
    flutterTts.setVolume(1);
    await flutterTts.speak(inputText);
  }

  Future _stop() async{
    await flutterTts.stop();
  }

  //  ----------------------------------------------------- //
  //                       card design                      //
  //  ----------------------------------------------------- //
  Widget cardContext(String word, String? description,String language, String image) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        //Image
        LayoutBuilder(
            builder: (context,constraints){
              cardImgRadius = kIsWeb ? constraints.maxWidth * 0.3
                  : constraints.maxWidth * 0.6;

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

        //white box
        Container(
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
            controller: GestureFlipCardController(),
            enableController: true,

            frontWidget: Center(
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
                child: cardContext(word.english as String,word.description as String,enVoice,'assets/images/stelle.png'),
              ),
            ),
            backWidget: Center(
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
                child: cardContext(word.vietnamese as String,word.description as String,vietVoice,'assets/images/stelle2.png'),
              ),
            )
        );
      },
    );
  }
}