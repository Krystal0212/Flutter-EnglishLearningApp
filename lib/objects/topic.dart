import 'participant.dart';
import 'word.dart';

class Topic {
  String? access;
  String? createDate;
  String? id;
  String? title;
  String? owner;
  String? ownerAvtUrl;
  List<Participant>? participant;
  List<Word>? word;

  Topic(this.access, this.createDate, this.id, this.title, this.owner,
      this.ownerAvtUrl, this.participant, this.word);

  Map<String, dynamic> toMap() {
    return {
      'access': access,
      'createDate': createDate,
      'id': id,
      'title': title,
      'owner': owner,
      'ownerAvtUrl': ownerAvtUrl,
      'participant': participant?.map((p) => p.toMap()).toList(),
      'word': word?.map((w) => w.toMap()).toList(),
    };
  }

  Topic.fromJson(Map<dynamic, dynamic> json) {
    access = json['access'];
    createDate = json['createDate'];
    id = json['id'];
    title = json['title'];
    owner = json['owner'];
    ownerAvtUrl = json['ownerAvtUrl'];
    if (json['participant'] != null) {
      participant = List<Participant>.from(
          json['participant'].map((x) => Participant.fromJson(x)));
    }
    if (json['word'] != null) {
      word = List<Word>.from(json['word'].map((x) => Word.fromJson(x)));
    }
  }
}
