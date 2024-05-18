import 'package:flutter/material.dart';

class AvatarLoadingIndicator extends StatefulWidget {
  AvatarLoadingIndicator({super.key, this.title});

  final String? title;

  @override
  State<AvatarLoadingIndicator> createState() => AvatarLoadingTextAnimationState();
}

class AvatarLoadingTextAnimationState extends State<AvatarLoadingIndicator>{
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
        width: 200,
        height: 200,// Adjust the width as needed to fit the text
        decoration: BoxDecoration(
          color: Colors.white, // Background color
          shape: BoxShape.circle, // Rounded rectangle
        ),
        child: ClipOval(
          child: Image.asset(
            'assets/gifs/brush-stroke.gif',
            width: 200,
            height: 200,
            fit: BoxFit.cover, // Ensures the image covers the container
          ),
        ),
      ),
    );
  }
}