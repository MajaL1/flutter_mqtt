class SensorTypeConstants {

  static String getSensorType(int? typ) {
    switch (typ) {
      case 0:
        return "Notset";
      case 1:
        return "WS";
      case 2:
        return "WSD";
      case 3:
        return "LEVEL_NO_TEMP";
      case 4:
        return "LEVEL";
      case 5:
        return "CAP";
      case 6:
        return "SU10";
      case 7:
        return "SU11";
      case 8:
        return "SU12";
      case 6:
        return "SP10";
      case 7:
        return "SP15";
      case 8:
        return "SP20";
      case 9:
        return "SP25";
      case 10:
        return "SP30";
      case 11:
        return "SP40";
      case 12:
        return "SP150";
      case 13:
        return "SP200";
      default:
        return "NotSet";
    }
  }
}
