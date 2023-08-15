import 'dart:convert';

class Alarm {
  int id;
  String name;
  String ? date;
  String description;
  //late String title;



  Alarm({this.id = 0, required this.name, required this.date, required this.description}) {
    // TODO: implement Alarm
    //this.date = DateTime.tryParse(date as String);
    //throw UnimplementedError();
    //this.date = DateTime.parse(map['date']),
  }

  factory Alarm.fromJson(Map<String, dynamic> map) {
    return Alarm(
        id: map["id"], name: map["name"], date: map["date"], description: map["description"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "name": name, "date" : date, "description": description};
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