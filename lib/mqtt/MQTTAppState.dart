
import 'package:flutter/cupertino.dart';

enum MQTTAppConnectionState { connected, disconnected, connecting }
class MQTTAppState with ChangeNotifier{
  MQTTAppConnectionState _appConnectionState = MQTTAppConnectionState.disconnected;
  String _receivedText = '';
  String _historyText = '';
  bool _isSaved = false;

  void setReceivedText(String text) {
    _receivedText = text;
    _historyText = '$_historyText\n$_receivedText';
    notifyListeners();
  }

  void setSavedSettings(bool isSaved){
    _isSaved = isSaved;
  }

  void setAppConnectionState(MQTTAppConnectionState state) {
    _appConnectionState = state;
    notifyListeners();
  }

  String get getReceivedText => _receivedText;
  String get getHistoryText => _historyText;
  bool get isSaved => _isSaved;

  MQTTAppConnectionState get getAppConnectionState => _appConnectionState;

}