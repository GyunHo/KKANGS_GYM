class League {
  String leagueName;

  League({required String name}) : leagueName = name;

  toJson() {
    return {"name": leagueName,"time":DateTime.now()};
  }
}
