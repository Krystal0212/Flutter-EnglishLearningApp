import 'package:flutter/material.dart';

class DashboardLoadingIndicator extends StatefulWidget {
  DashboardLoadingIndicator({super.key, this.title});

  final String? title;

  @override
  State<DashboardLoadingIndicator> createState() =>
      DashboardLoadingTextAnimationState();
}

class DashboardLoadingTextAnimationState
    extends State<DashboardLoadingIndicator> {
  int dotCount = 0;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 260, // Adjust the width as needed to fit the text
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          borderRadius: BorderRadius.circular(20), // Rounded rectangle
        ),
        child: Column(
          mainAxisSize:
              MainAxisSize.min, // Aligns the Column's children to the center
          children: <Widget>[
            ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ), // Rounded corners at the top of the image
              child: Image.asset(
                'assets/gifs/sparkle.gif',
                width: 300,
                height: 300,
                fit: BoxFit.cover, // Ensures the image covers the container
              ),
            ),
            Padding(
                padding: EdgeInsets.all(10), // Padding around the text
                child: Text(
                  "Hi there, welcome to Fluffy",
                  style: TextStyle(
                    fontFamily: 'Gill Sans Ultra Bold',
                    // Use the font family name declared in pubspec.yaml
                    fontSize: 22,
                    color: Colors.black,
                  ),
                )),
          ],
        ),
      ),
    );
  }
}
