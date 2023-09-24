class TopicData {
  String name;
  int rw;

  TopicData({required this.name, required this.rw});

  Map<String, dynamic> toJson() {
    return {"name": name, "rw": rw};
  }

  factory TopicData.fromJson(Map<String, dynamic> json) {
    return TopicData(
      name: json["name"] as String,
      rw: json["rw"] as int,
    );
  }
}
