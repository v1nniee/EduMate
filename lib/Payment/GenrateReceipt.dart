
import 'dart:io' as io;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class GenerateReceipt {
  Future<void> generateReceipt(
      String tutorSeekerName,
      String tutorName,
      String subject,
      String paymentAmount,
      DateTime startclassDate,
      DateTime endclassDate,
      DateTime paymentDate,
      BuildContext context) async {
    final pdf = pw.Document();

    // Define the styles
    final headerStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14);
    final titleStyle =
        pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 24);
    final contentStyle = pw.TextStyle(fontSize: 12);

    // Add a page to the PDF
    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Text('Edumate', style: titleStyle),
              ),
              pw.Header(
                level: 1,
                child: pw.Text('INVOICE', style: titleStyle),
              ),
              pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text('Bill To', style: headerStyle),
                          pw.Text(tutorSeekerName, style: contentStyle),
                          pw.Text('Pay To', style: headerStyle),
                          pw.Text(tutorName, style: contentStyle),
                        ]),
                    pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Text(
                              'Invoice Date: ${DateFormat('yyyy-MM-dd').format(paymentDate)}',
                              style: contentStyle),
                          pw.Text(
                              'Tuition Period: ${DateFormat('yyyy-MM-dd').format(startclassDate)} - ${DateFormat('yyyy-MM-dd').format(endclassDate)}',
                              style: contentStyle),
                          // ... other details ...
                        ]),
                  ]),
              pw.SizedBox(height: 20),
              // ignore: deprecated_member_use
              pw.Table.fromTextArray(
                context: context,
                data: <List<String>>[
                  <String>['QTY', 'DESCRIPTION', 'UNIT PRICE', 'AMOUNT'],
                  <String>[
                    '1',
                    'Tutoring for $subject',
                    paymentAmount,
                    paymentAmount
                  ],
                ],
                headerStyle: headerStyle,
                cellStyle: contentStyle,
                headerDecoration: const pw.BoxDecoration(
                  color: PdfColors.grey300,
                ),
                cellHeight: 30,
                cellAlignments: {
                  0: pw.Alignment.centerRight,
                  1: pw.Alignment.centerLeft,
                  2: pw.Alignment.centerRight,
                  3: pw.Alignment.centerRight,
                },
              ),
              pw.Divider(),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.end,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text('Subtotal', style: headerStyle),
                        pw.Text('Sales Tax (0%)',
                            style:
                                contentStyle), // Assuming no tax for educational services
                        pw.Text('TOTAL', style: headerStyle),
                      ],
                    ),
                    pw.SizedBox(width: 120),
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.end,
                      children: [
                        pw.Text(paymentAmount, style: contentStyle),
                        pw.Text('0.00', style: contentStyle), // Assuming no tax
                        pw.Text(paymentAmount, style: headerStyle),
                      ],
                    ),
                  ],
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(top: 20),
                child: pw.Text('Terms & Conditions', style: headerStyle),
              ),
              pw.Text(
                'Payment is due within 15 days. Please make checks payable to: Edumate.',
                style: contentStyle,
              ),
// Optionally add more text here for additional notes or terms.
            ],
          );
        },
      ),
    );

    // Display the PDF document
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );

    // Ask the user if they want to save the PDF
    bool saveFile = await _askToSaveFile(context);
    if (saveFile) {
      // Use the share_plus plugin to share the PDF file
      final output = await getTemporaryDirectory();
      final file = io.File("${output.path}/receipt.pdf");
      await file.writeAsBytes(await pdf.save());
      Share.shareFiles([file.path], text: 'Your receipt');
    }
  }

  Future<bool> _askToSaveFile(BuildContext context) async {
    // The showDialog function returns a Future that resolves to the value
    // (if any) that was passed to Navigator.pop when the dialog was closed.
    bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Receipt'),
          content: const Text('Would you like to save the receipt?'),
          actions: <Widget>[
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(false), // Dismiss with false
              child: const Text('No'),
            ),
            TextButton(
              onPressed: () =>
                  Navigator.of(context).pop(true), // Dismiss with true
              child: const Text('Yes'),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }
}
