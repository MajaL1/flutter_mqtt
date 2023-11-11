import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import 'package:http/http.dart' as http;

class Utils {
  static Future<String> downloadFile(String URL, String filename) async {
    final direactory = await getApplicationSupportDirectory();
    final filepath = '${direactory.path}/$filename';
    final response = await http.get(Uri.parse(URL));
    print(response);

    final file = File(filepath);

    await file.writeAsBytes(response.bodyBytes);
    return filepath;
  }

  static Future<String> getImageFilePathFromAssets(
      String asset, String filename) async {
    final byteData = await rootBundle.load(asset);
    final temp_direactory = await getTemporaryDirectory();
    final file = File('${temp_direactory.path}/$filename');
    await file.writeAsBytes(byteData.buffer.asUint8List(byteData.offsetInBytes, byteData.lengthInBytes));

    return file.path;
  }
}