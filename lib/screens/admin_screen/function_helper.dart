import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:universal_html/html.dart' as uh;
import 'package:path/path.dart' as p;

Future<void> downloadSampleExcelFromAssets(
    String assetPath, String fileName) async {
  try {
    final ByteData data = await rootBundle.load(assetPath);
    final Uint8List bytes = data.buffer.asUint8List();

    await _saveFile(bytes, fileName);
  } catch (e) {
    print('Error accessing or saving excel from assets: $e');
    rethrow;
  }
}

Future<void> _saveFile(Uint8List bytes, String fileName) async {
  if (kIsWeb) {
    final blob = uh.Blob([bytes]);
    final url = uh.Url.createObjectUrlFromBlob(blob);
    final anchor = uh.AnchorElement(href: url)
      ..setAttribute('download', fileName)
      ..click();
    uh.Url.revokeObjectUrl(url);
  } else {
    final directory = await getApplicationDocumentsDirectory();
    final filePath = p.join(directory.path, fileName);
    final file = File(filePath);
    await file.writeAsBytes(bytes);

    if (Platform.isAndroid || Platform.isIOS) {
      // For mobile platforms, you might want to open the file using a file viewer
      // or share it using the share package.
      // Example using share package:
      // await Share.shareFiles([filePath], text: 'Sample Excel File');
      print("file saved to: $filePath"); // For debug purpose.
    } else if (Platform.isMacOS || Platform.isLinux || Platform.isWindows) {
      print("file saved to: $filePath"); // For debug purpose.
    }
  }
}
