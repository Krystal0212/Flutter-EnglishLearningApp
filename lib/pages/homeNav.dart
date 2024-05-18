import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/pages/profile.dart';
import 'homeWidget.dart';
import 'libraryWidget.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.user});

  final User user;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex;
  final FirebaseAuth auth = FirebaseAuth.instance;
  late List<Widget> _pages = [
    Home(),
    Library(),
    Profile(),
  ];
  late PageController _pageController;
  User? user;

  @override
  void initState() {
    selectedIndex = 0;
    _pageController = PageController(initialPage: selectedIndex);
    user = auth.currentUser;
    // print(user.toString());

    super.initState();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
      _pageController.jumpToPage(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: CupertinoColors.white,
        body: user == null
            ? Center(
                child: CircularProgressIndicator(
                color: Colors.blue,
              ))
            : PageView(
                controller: _pageController,
                physics: NeverScrollableScrollPhysics(),
                children: _pages,
              ),
        bottomNavigationBar: MotionTabBar(
          initialSelectedTab: "Home",
          labels: const ["Home", "Library", "Profile"],
          icons: const [Icons.home, Icons.library_books, Icons.person],
          tabSize: 50,
          tabBarHeight: 55,
          textStyle: const TextStyle(
            fontSize: 12,
            color: Colors.blue,
            fontWeight: FontWeight.w500,
          ),
          tabIconColor: Colors.blue[400],
          tabIconSize: 28.0,
          tabIconSelectedSize: 26.0,
          tabSelectedColor: Colors.blue[400],
          tabIconSelectedColor: Colors.white,
          tabBarColor: Colors.white70,
          onTabItemSelected: onItemTapped,
        ),
      ),
    );
  }
}
