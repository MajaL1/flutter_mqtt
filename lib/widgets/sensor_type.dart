class SensorTypeConstants {
  static const String Notset = "Notset";
  static const String WS = "WS";
  static const String WSD = "WSD";
  static const String LEVEL_NO_TEMP = "LEVEL_NO_TEMP";
  static const String LEVEL = "LEVEL";
  static const String CAP = "CAP";
  static const String SU10 = "SU10";
  static const String SU11 = "SU11";
  static const String SU12 = "SU12";
  static const String SP10 = "SP10";
  static const String SP15 = "SP15";
  static const String SP20 = "SP20";
  static const String SP25 = "SP25";
  static const String SP30 = "SP30";
  static const String SP40 = "SP40";
  static const String SP150 = "SP150";
  static const String SP200 = "SP200";

  static String getSensorType(int? typ) {
    switch (typ) {
      case 0:
        return Notset;
      case 1:
        return WS;
      case 2:
        return WSD;
      case 3:
        return LEVEL_NO_TEMP;
      case 4:
        return LEVEL;
      case 5:
        return CAP;
      case 6:
        return SU10;
      case 7:
        return SU11;
      case 8:
        return SU12;
      case 9:
        return SP25;
      case 10:
        return SP30;
      case 11:
        return SP40;
      case 12:
        return SP150;
      case 13:
        return SP200;
      default:
        return Notset;
    }
  }
}
