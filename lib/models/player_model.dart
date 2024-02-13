class Player {
  String teamUID;
  String uniformNumber;
  String? playerName;
  String? playerImg;

  Player(
      {required String teamID,
      required String number,
      required String name,
      String? img})
      : teamUID = teamID,
        uniformNumber = number,
        playerName = name,
        playerImg = img;

  Map<String, dynamic>toJson() {
    return {
      "teamId": teamUID,
      "uniformNumber": uniformNumber,
      "playerName": playerName,
      "playerImg": playerImg,
      "time":DateTime.now()
    };
  }
}
