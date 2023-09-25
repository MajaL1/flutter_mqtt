class UserSettings {
  String id;
 
  UserSettings({required this.id});

  Map<String, dynamic> toJson() {
    return {"id": id};
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
        id: json["id"]
    );
  }
}
