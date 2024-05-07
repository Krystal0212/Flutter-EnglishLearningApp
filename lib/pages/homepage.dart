import 'package:Fluffy/objects/user.dart';
import 'package:flutter/material.dart';
import 'package:Fluffy/pages/profile.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.userID});

  final String userID;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int selectedIndex = 0;
  late User user;
  List<Widget> widgetOptions = <Widget>[
    Text('Loading...'), // Placeholder widget
  ];

  void getUser() async{
    user = await fetchUserDataFromDatabase(widget.userID);
    widgetOptions = <Widget>[
      Text('Home'),
      Text('Topic'),
      Profile(user: user),
    ];
    print(user.toString());
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  void onItemTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child:
        widgetOptions
            .elementAt(selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed, //disable zoom
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          const BottomNavigationBarItem(icon: Icon(Icons.topic), label: 'Topic'),
          const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: selectedIndex,
        selectedItemColor: Colors.lightBlue,
        unselectedItemColor: Colors.grey,
        onTap: onItemTapped,
      ),
    );
  }
}
