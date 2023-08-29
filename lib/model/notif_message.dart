import 'dart:convert';

class NotifMessage {
  int? id;
  String title;
  String ?description;
  bool ? on;

  NotifMessage(
      {this.id = 0,
      required this.title,
      required this.description,
      required this.on}) {}

  // Class Function
  showNotifInfo() {
    print("Nofification message : ${id}, ${title}, ${description}, ${on}");
  }

  factory NotifMessage.fromJson(Map<String, dynamic> map) {
    return NotifMessage(
        id: map["id"],
        title: map["title"],
        description: map["description"],
        on: map["on"]);
  }

  Map<String, dynamic> toJson() {
    return {"id": id, "title": title, "description": description, "on": on};
  }

  List<NotifMessage> notifMessageFromJson(String jsonData) {
    final data = json.decode(jsonData);
    return List<NotifMessage>.from(
        data.map((item) => NotifMessage.fromJson(item)));
  }

  String notifMessageToJson(NotifMessage data) {
    final jsonData = data.toJson();
    return json.encode(jsonData);
  }

  @override
  String toString() {
    return 'Notification{id: $id, name: $title}';
  }

  void main() {
    //var notifMessage = new NotifMessage(title: '');
  }
}
