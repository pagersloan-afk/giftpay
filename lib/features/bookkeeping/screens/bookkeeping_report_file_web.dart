import 'dart:html' as html;
import 'dart:typed_data';

/// Downloads a report directly through the browser without using path_provider.
Future<void> saveReportFile(
  List<int> bytes,
  String filename,
  String mimeType,
) async {
  final data = Uint8List.fromList(bytes);
  final blob = html.Blob(<Object>[data], mimeType);
  final url = html.Url.createObjectUrlFromBlob(blob);
  final anchor = html.AnchorElement(href: url)
    ..download = filename
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
  html.Url.revokeObjectUrl(url);
}
