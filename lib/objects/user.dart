import 'package:firebase_database/firebase_database.dart';

class User {
  String displayName;
  String avatarUrl;
  String email;
  String id;
  Map<String, dynamic> recentActivity;

  // Default constructor
  User({
    this.displayName = '',
    this.avatarUrl = 'assets/images/bg-profile.png',
    this.email = '',
    this.id = '',
    Map<String, dynamic>? recentActivity,
  }) : recentActivity = recentActivity ??
            {'lastVisitedTime': "", 'owner': "", "score": 0, "topicTitle": ""};

  User.fromMap(Map<String, dynamic> map)
      : displayName = map['displayName'] ?? '',
        avatarUrl = map['avtUrl'] ?? 'assets/images/bg-profile.png',
        email = map['email'] ?? '',
        id = map['id'] ?? '',
        recentActivity = map['recentActivity'] != null
            ? Map<String, dynamic>.from(map['recentActivity'])
            : {
                'lastVisitedTime': "",
                'owner': "",
                "score": 0,
                "topicTitle": ""
              };

  Future<void> saveUserDataToDatabase() async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child('User').child(id).set(toMap());
  }

  Map<String, dynamic> toMap() {
    return {
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'email': email,
      'id': id,
      'recentActivity': recentActivity,
    };
  }

  @override
  String toString() {
    return 'User{displayName: $displayName, avatarUrl: $avatarUrl, email: $email, id: $id, recentActivity: $recentActivity}';
  }
}

Future<User> fetchUserDataFromDatabase(String userID) async {
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  DataSnapshot dataSnapshot =
      (await databaseReference.child('User').child(userID).once()).snapshot;

  if (dataSnapshot.value != null) {
    Map<String, dynamic> data =
        Map<String, dynamic>.from(dataSnapshot.value as Map<dynamic, dynamic>);

    return User.fromMap(data);
  } else {
    print("User not exist");
    return User();
  }
}
