import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

Future<void> generateTrackingPdf(List<Map<String, dynamic>> trackingData) async {
  final ttf = await PdfGoogleFonts.notoSansRegular();
  final pdf = pw.Document();

  // Load the logo image from assets
  final logoBytes = await rootBundle.load('assets/image/Group 9585.png');
  final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

  pdf.addPage(
    pw.MultiPage(
      theme: pw.ThemeData.withFont(base: ttf),
      pageFormat: PdfPageFormat.a4,
      build: (pw.Context context) => [
        // Custom Header
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Logo
            pw.Container(
              width: 50,
              height: 50,
              child: pw.Image(logoImage),
            ),
            pw.SizedBox(width: 20),
            // Centered text
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Text('Salim Raza (413)', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold)),
                  pw.SizedBox(height: 4),
                  pw.Text('Employee Tracking Report', style: pw.TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 20),

        // Tracking Data Table
        pw.Table.fromTextArray(
          headers: [
            'Status',
            'Location',
            'Locality',
            'Lat',
            'Long',
            'Time',
            'Duration',
            'Time',
          ],
          data: trackingData.map((e) => [
            e['type'] ?? '',
            e['locality'] ?? '',
            e['subLocality'] ?? '',
            e['lat'].toString(),
            e['lng'].toString(),
            e['time'] ?? '',
            e['duration'] ?? '',
            DateFormat('hh:mm dd/MM/yyyy').format(DateTime.parse(e['timestamp'])),
          ]).toList(),
          headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          cellStyle: pw.TextStyle(fontSize: 8),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    ),
  );

  if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
    await Printing.layoutPdf(onLayout: (format) async => pdf.save());
  } else {
    print('Printing not supported on this platform');
  }
}
