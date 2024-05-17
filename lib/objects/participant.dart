class Participant {
  String? userID;
  String? userName;
  int? multipleChoicesResult;
  int? fillWordResult;

  Participant(this.userID, this.userName, this.multipleChoicesResult,
      this.fillWordResult);

  Map<String, dynamic> toMap() {
    return {
      'userID': userID,
      'userName': userName,
      'multipleChoicesResult': multipleChoicesResult,
      'fillWordResult': fillWordResult
    };
  }

  Participant.fromJson(Map<dynamic, dynamic> json) {
    userID = json['userID'];
    userName = json['userName'];
    multipleChoicesResult = json['multipleChoicesResult'];
    fillWordResult = json['fillWordResult'];
  }
}
