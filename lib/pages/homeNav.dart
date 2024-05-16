import 'package:Fluffy/objects/user.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/pages/profile.dart';
import 'homeWidget.dart';
import 'libraryWidget.dart';
import 'package:motion_tab_bar/MotionBadgeWidget.dart';
import 'package:motion_tab_bar/MotionTabBar.dart';
import 'package:motion_tab_bar/MotionTabBarController.dart';
import 'package:motion_tab_bar/MotionTabItem.dart';
import 'package:motion_tab_bar/helpers/HalfClipper.dart';
import 'package:motion_tab_bar/helpers/HalfPainter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.userID});

  final String userID;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex;
  late List<Widget> _pages;
  late PageController _pageController;
  User? user;
  bool isSwitched = false;

  void getUser() async {
    User fetchedUser = await fetchUserDataFromDatabase(widget.userID);
    setState(() {
      user = fetchedUser;
      _pages = [
        Home(),
        Library(),
        Profile(user: user!),
      ];
    });
    print(user.toString());
  }

  @override
  void initState() {
    selectedIndex = 0;
    _pageController = PageController(initialPage: selectedIndex);

    getUser();
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
