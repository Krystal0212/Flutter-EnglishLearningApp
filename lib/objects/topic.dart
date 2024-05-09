import 'participant.dart';
import 'word.dart';

class Topic {
  String access;
  String createDate;
  String id;
  String title;
  String owner;
  String ownerAvtUrl;
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
      'participant': participant,
      'word': participant
    };
  }
}
