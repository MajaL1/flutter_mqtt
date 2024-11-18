import 'package:mqtt_test/widgets/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPrefs1{
  static late SharedPreferences _sharedPrefs;

  static final SharedPrefs1 _instance = SharedPrefs1._internal();

  factory SharedPrefs1() => _instance;

  SharedPrefs1._internal();

  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  String get username => _sharedPrefs.getString(keyUsername) ?? "";

  set username(String value) {
    _sharedPrefs.setString(keyUsername, value);
  }

  String get token => _sharedPrefs.getString(keyToken) ?? "";

  set token(String value) {
    _sharedPrefs.setString(keyToken, value);
  }
}