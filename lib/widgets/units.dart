//{m/s,km/h,mph,knots,lit,hl,m3,gal,cm,mm}

class UnitsConstants {
  static const String ms = "m/s";
  static const String kmh = "km/h";
  static const String mph = "mph";
  static const String knots = "knots";
  static const String lit = "lit";
  static const String hl = "hl";
  static const String m3 = "m3";
  static const String gal = "gal";
  static const String cm = "cm";
  static const String mm = "mm";

  static String getUnits(int? typ) {
    switch (typ) {
      case 0:
        return ms;
      case 1:
        return kmh;
      case 2:
        return mph;
      case 3:
        return knots;
      case 4:
        return lit;
      case 5:
        return hl;
      case 6:
        return m3;
      case 7:
        return gal;
      case 8:
        return cm;
      case 9:
        return mm;
      default:
        return "NotSet";
    }
  }
}
