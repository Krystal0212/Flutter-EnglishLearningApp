import 'dart:math';

import 'package:Fluffy/constants/gifs-lab.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

void main() => runApp(Home());

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String ownerName = "Krysztal";
  late String topicName = "Animals";
  late String score = "1000";

  final List<Map<String, String>> quotes = [
    {
      'quote':
          "Live as if you were to die tomorrow. Learn as if you were to live forever.",
      'author': "Mahatma Gandhi",
    },
    {
      'quote':
          "Education is the most powerful weapon which you can use to change the world.",
      'author': "Nelson Mandela",
    },
    {
      'quote':
          "The beautiful thing about learning is that nobody can take it away from you.",
      'author': "B.B. King",
    },
    {
      'quote':
          "Develop a passion for learning. If you do, you will never cease to grow.",
      'author': "Anthony J. D'Angelo",
    },
  ];

  Map<String, String> getRandomQuote() {
    final random = Random();
    int index = random.nextInt(quotes.length);
    return quotes[index];
  }

  @override
  Widget build(BuildContext context) {
    var parentHeight = MediaQuery.of(context).size.height;
    var parentWidth = MediaQuery.of(context).size.width;

    final randomQuote = getRandomQuote();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: Color(0xFFFDFCFB),
        // Set your custom color here
        scaffoldBackgroundColor: Color(0xFFFDFCFB),
        // Set scaffold background color
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFFDFCFB), // Set AppBar background color
          titleTextStyle: TextStyle(color: Colors.black),
          iconTheme: IconThemeData(color: Colors.black),
        ),
      ),
      home: Scaffold(
        body: Container(
          color: Color(0xFF7B88D9),
          child: Column(children: [
            Container(
              height: parentHeight * 0.2,
              width: parentWidth,
              child: Padding(
                padding: EdgeInsets.only(
                    top: parentHeight * 0.05, left: parentWidth * 0.1),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Welcome back, User",
                      style: TextStyle(
                          fontSize: 25,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Last access since : ",
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.white54,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1),
                    ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(
                  top: 25,
                  left: parentWidth * 0.125,
                  right: parentWidth * 0.125),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50),
                    topRight: Radius.circular(50)),
              ),
              height: parentHeight * 0.8,
              width: parentWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '" ${randomQuote['quote']} "',
                    style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '- ${randomQuote['author']} -',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  SizedBox(height: 6),
                  Container(
                    constraints: BoxConstraints(
                      maxWidth: 500,
                      maxHeight: 500 / 1.8,
                    ),
                    width: MediaQuery.of(context).size.width * 0.7,
                    height: (MediaQuery.of(context).size.width * 0.7) / 1.8,
                    child: Image.network(
                      LabGifs.exploreUrl,
                      fit: BoxFit.cover,
                    ),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Recently Accessed Topic :",
                            style: TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      SizedBox(width: 8),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            topicName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("by "),
                      Text(ownerName, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Colors.blueAccent),),
                      Text(" - Your Score : "),
                      Text(score, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold,color: Color(0xFFEA9078)),)
                    ],
                  ),
                  SizedBox(height: 10),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
