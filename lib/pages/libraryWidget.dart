import 'package:Fluffy/library/publicWidget.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:Fluffy/library/setWidget.dart';

import '../library/folderWidget.dart';

class Library extends StatefulWidget {
  const Library({super.key});

  @override
  State<Library> createState() => _LibraryState();
}

class _LibraryState extends State<Library>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  DatabaseReference dbRef = FirebaseDatabase.instance.ref();
  final FirebaseAuth auth = FirebaseAuth.instance;
  late TabController _tabController;

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _tabController = TabController(length: 3, vsync: this);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.blue,
            indicatorColor: Colors.blue,
            unselectedLabelColor: Colors.black,
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
          title: Text(
            "Library",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.blue[50],
        ),
        body: TabBarView(controller: _tabController, children: [
          Set(),
          Public(),
          FolderTab(),
        ]),
      ),
    );
  }
}
