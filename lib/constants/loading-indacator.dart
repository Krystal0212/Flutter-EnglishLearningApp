import 'dart:async';
import 'package:flutter/material.dart';

class LoadingIndicator extends StatefulWidget {
  @override
  State<LoadingIndicator> createState() => LoadingTextAnimationState();
}

class LoadingTextAnimationState extends State<LoadingIndicator>{

  String loadingText = "Loading";
  int dotCount = 0;
  late Timer timer;

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 4; // Cycle through 0 to 3
        loadingText = "Loading" + "." * dotCount; // Concatenate dots based on count
      });
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 220, // Adjust the width as needed to fit the text
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(20), // Rounded rectangle
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5), // Shadow color with opacity
              spreadRadius: 5,
              blurRadius: 7,
              offset: Offset(0, 3), // Changes position of shadow
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min, // Aligns the Column's children to the center
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ), // Rounded corners at the top of the image
              child: Image.asset(
                'assets/gifs/campfire-loading-indicator.gif',
                width: 200,
                height: 200,
                fit: BoxFit.cover, // Ensures the image covers the container
              ),
            ),
            Padding(
                padding: EdgeInsets.all(10), // Padding around the text
                child: Text(
                  loadingText,
                  style: TextStyle(
                    fontFamily: 'Gill Sans Ultra Bold', // Use the font family name declared in pubspec.yaml
                    fontSize: 22,
                    color: Colors.black,
                  ),
                )
            ),
          ],
        ),
      ),
    );
  }
}
