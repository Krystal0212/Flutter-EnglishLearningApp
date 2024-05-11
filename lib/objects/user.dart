import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class TheUser {
  String displayName;
  String avatarUrl;
  String email;
  String id;
  Map<String, dynamic> recentActivity;

  static const defaultAvatarLink = "https://firebasestorage.googleapis.com/v0/b/cross-platform-final-term.appspot.com/o/profile-img.jpg?alt=media&token=a3619fea-311e-4529-bbc6-dc9809ce8f80";

  // Default constructor
  TheUser({
    this.displayName = '',
    this.avatarUrl = defaultAvatarLink,
    this.email = '',
    this.id = '',
    Map<String, dynamic>? recentActivity,
  }) : recentActivity = recentActivity ??
            {'lastVisitedTime': "", 'owner': "", "score": 0, "topicTitle": ""};

  // Named constructor for creating User object from map
  TheUser.fromMap(Map<String, dynamic> map)
      : displayName = map['displayName'] ?? '',
        avatarUrl = map['avatarUrl'] ?? defaultAvatarLink,
        email = map['email'] ?? '',
        id = map['id'] ?? '',
        recentActivity = map['recentActivity'] != null
            ? Map<String, dynamic>.from(map['recentActivity'])
            : {'lastVisitedTime': "", 'owner': "", "score": 0, "topicTitle": ""};

  Future<void> saveUserDataToDatabase() async {
    DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
    await databaseReference.child('User').child(id).set(toMap());
  }

// Convert User object to Map
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

Future<TheUser> fetchUserDataFromDatabase(User fetchedUser) async {
  DatabaseReference databaseReference = FirebaseDatabase.instance.reference();
  DataSnapshot dataSnapshot =
      (await databaseReference.child('User').child(fetchedUser.uid).once()).snapshot;

  if (dataSnapshot.value != null) {
    Map<String, dynamic> data =
    Map<String, dynamic>.from(dataSnapshot.value as Map<dynamic, dynamic>);

    return TheUser.fromMap(data);
  } else {
    TheUser currentUser = TheUser(
        displayName: fetchedUser.displayName!,
        avatarUrl: fetchedUser.photoURL ?? TheUser.defaultAvatarLink,
        id: fetchedUser.uid,
        email: fetchedUser.email!,
        recentActivity: null);
    currentUser.saveUserDataToDatabase();
    return currentUser;
  }
}