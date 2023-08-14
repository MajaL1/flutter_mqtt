import 'dart:convert';

class Alarm {
  int id;
  String name;


  Alarm({this.id = 0, required this.name});

  factory Alarm.fromJson(Map<String, dynamic> map) {
    return Alarm(
        id: map["id"], name: map["name"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name};
  }

  @override
  String toString() {
    return 'Profile{id: $id, name: $name}';
  }

}

List<Alarm> alarmFromJson(String jsonData) {
  final data = json.decode(jsonData);
  return List<Alarm>.from(data.map((item) => Alarm.fromJson(item)));
}

String alarmToJson(Alarm data) {
  final jsonData = data.toJson();
  return json.encode(jsonData);
}