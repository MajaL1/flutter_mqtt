import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class AppInitializer {
  static bool _tzInitialized = false;

  static Future<void> init() async {
    if (!_tzInitialized) {
      tz.initializeTimeZones();
      _tzInitialized = true;
    }
  }
}
