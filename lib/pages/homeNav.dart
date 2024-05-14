import 'package:Fluffy/objects/user.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/pages/profile.dart';
import 'homeWidget.dart';
import 'libraryWidget.dart';

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
    return Scaffold(
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
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        //disable zoom
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.topic), label: 'Library'),
          const BottomNavigationBarItem(
              icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
      ),
    );
  }
}
