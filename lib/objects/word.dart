class Word {
  String? english;
  String? vietnamese;
  String? description;

  Word(this.english, this.vietnamese, this.description);

  Map<String, dynamic> toMap() {
    return {
      'english': english,
      'vietnamese': vietnamese,
      'description': description
    };
  }

  Word.fromJson(Map<dynamic, dynamic> json) {
    english = json['english'];
    vietnamese = json['vietnamese'];
    description = json['description'];
  }
}
