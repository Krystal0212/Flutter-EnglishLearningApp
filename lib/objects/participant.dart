class Participant {
  String? userID;
  int? multipleChoicesResult;
  int? fillWordResult;

  Participant(this.userID, this.multipleChoicesResult, this.fillWordResult);

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'multipleChoicesResult': multipleChoicesResult,
      'fillWordResult': fillWordResult
    };
  }

  Participant.fromJson(Map<dynamic, dynamic> json) {
    userID = json['userID'];
    multipleChoicesResult = json['multipleChoicesResult'];
    fillWordResult = json['fillWordResult'];
  }
}
