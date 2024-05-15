class Folder {
  String? name;
  String? ownerUid;
  String? id;
  Map<String, bool>? topics;

  Folder(this.name, this.ownerUid, this.id, this.topics);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'ownerUid': ownerUid,
      'id': id,
      'topics': topics,
    };
  }

  Folder.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    ownerUid = json['ownerUid'];
    id = json['id'];
    if (json['topics'] != null) {
      topics = Map<String, bool>.from(json['topics']);
    } else {
      topics = null;
    }
  }
}
