/// Fallback implementation for platforms without a supported report exporter.
Future<void> saveReportFile(
  List<int> bytes,
  String filename,
  String mimeType,
) async {
  throw UnsupportedError('Report download is not supported on this platform.');
}
