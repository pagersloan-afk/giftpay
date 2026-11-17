import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

/// Saves a report to a temporary file and opens the native share sheet.
Future<void> saveReportFile(
  List<int> bytes,
  String filename,
  String mimeType,
) async {
  final directory = await getTemporaryDirectory();
  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes, flush: true);
  await Share.shareXFiles(
    [XFile(file.path, mimeType: mimeType)],
    text: filename,
  );
}
