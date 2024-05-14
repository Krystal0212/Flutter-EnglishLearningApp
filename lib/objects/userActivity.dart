class UserActivity {
  String? timestamp;
  String? uid;
  Map<String, bool>? topics;

  UserActivity(this.timestamp, this.uid, this.topics);

  Map<String, dynamic> toMap() {
    return {
      'timestamp': timestamp,
      'uid': uid,
      'topics': topics,
    };
  }

  UserActivity.fromJson(Map<dynamic, dynamic> json) {
    timestamp = json['timestamp'];
    uid = json['uid'];
    if (json['topics'] != null) {
      topics = Map<String, bool>.from(json['topics']);
    } else {
      topics = null;
    }
  }
}
