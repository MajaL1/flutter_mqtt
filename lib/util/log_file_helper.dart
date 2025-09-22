/*
import 'dart:io';

import 'package:logger/logger.dart';
//import 'package:path_provider/path_provider.dart';

class LogFileHelper {

  static Future<Logger> createLogger() async{
    final Directory directory = await getApplicationDocumentsDirectory();

    final File file = File('${directory.path}/logFile.txt');

    return  Logger(
      filter: null, // Use the default LogFilter (-> only log in debug mode)
      // printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
      output: FileOutput(file:file), // Use the default LogOutput (-> send everything to console)
    );
  }
  static Future<void> saveFileOnDevice() async {
    try {
      if (Platform.isAndroid) {
        final Directory directory = await getApplicationDocumentsDirectory();
        final File file = File('${directory.path}/logFile.txt');

        if (!directory.existsSync()) {
          // Create the directory if it doesn't exist
          await directory.create();
        }
        var logger = Logger(
          filter: null, // Use the default LogFilter (-> only log in debug mode)
         // printer: PrettyPrinter(), // Use the PrettyPrinter to format and print log
          output: FileOutput(file:file), // Use the default LogOutput (-> send everything to console)
        );
        logger.log(Level.info, "abcd");
      }

    } catch (e) {
      throw Exception(e);
    }
  }
}*/
