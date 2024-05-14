class Folder {
  String? name;
  String? owner;
  String? id;
  Map<String, bool>? topics;

  Folder(this.name, this.owner, this.id, this.topics);

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'owner': owner,
      'id': id,
      'topics': topics,
    };
  }

  Folder.fromJson(Map<dynamic, dynamic> json) {
    name = json['name'];
    owner = json['owner'];
    id = json['id'];
    if (json['topics'] != null) {
      topics = Map<String, bool>.from(json['topics']);
    } else {
      topics = null;
    }
  }
}
