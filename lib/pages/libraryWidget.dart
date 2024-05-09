import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Fluffy/library/setWidget.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library> {
  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  TextEditingController _topicTitleEditingController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  // List<Topic> topics = fetchTopicFromDatabase();
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          bottom: const TabBar(
            tabAlignment: TabAlignment.start,
            tabs: [
              Tab(
                text: "Set",
              ),
              Tab(
                text: "Public",
              ),
              Tab(
                text: "Folder",
              ),
            ],
            isScrollable: true,
          ),
          title: Text("Library"),
        ),
        body: const TabBarView(children: [
          Set(),
          Icon(Icons.directions_transit),
          Icon(Icons.directions_bike),
        ]),
      ),
    );
  }

// List<Topic> fetchTopicFromDatabase() {
//   return topics;
// }
}
