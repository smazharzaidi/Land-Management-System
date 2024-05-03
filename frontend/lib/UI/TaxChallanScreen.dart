import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../Functionality/TaxChallanLogic.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class TaxChallanScreen extends StatefulWidget {
  final String khasraNumber;
  final String tehsil;
  final String division;
  final String userType;

  const TaxChallanScreen({
    Key? key,
    required this.khasraNumber,
    required this.tehsil,
    required this.division,
    required this.userType,
  }) : super(key: key);

  @override
  _TaxChallanScreenState createState() => _TaxChallanScreenState();
}

class _TaxChallanScreenState extends State<TaxChallanScreen> {
  late Future<Map<String, dynamic>> _challanDetails;
  TaxChallanLogic _logic = TaxChallanLogic();

  @override
  void initState() {
    super.initState();
    _challanDetails = _logic.fetchChallanData(
        widget.khasraNumber, widget.tehsil, widget.division, widget.userType);
  }

  pw.Document generateChallanPdf(Map<String, dynamic> data) {
    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          build: (pw.Context context) {
            return pw.Padding(
              padding: pw.EdgeInsets.all(10),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('CHALLAN FORM No.32-A',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  pw.Row(
                    mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                    children: [
                      pw.Text('CHALLAN OF CASH PAID INTO THE CENTRAL TREASURY',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 18)),
                      pw.Text('National Bank of Pakistan',
                          style: pw.TextStyle(
                              fontWeight: pw.FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.symmetric(vertical: 60),
                    child: pw.Table(border: pw.TableBorder.all(), children: [
                      pw.TableRow(children: [
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Personal Details',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16)),
                              pw.Text('Name: ${data['name']}',
                                  style: pw.TextStyle(fontSize: 14)),
                              pw.Text(
                                  'Tax Filer Status: ${data['filer_status']}',
                                  style: pw.TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Property Details',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16)),
                              pw.Text('Tehsil: ${data['tehsil']}',
                                  style: pw.TextStyle(fontSize: 14)),
                              pw.Text('Khasra No: ${data['khasra_number']}',
                                  style: pw.TextStyle(fontSize: 14)),
                              pw.Text('Division: ${data['division']}',
                                  style: pw.TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Transfer Details',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16)),
                              pw.Text('Transfer Type: ${data['transfer_type']}',
                                  style: pw.TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Transaction Details',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16)),
                              pw.Text(
                                  'Tax Amount Payable: ${data['tax_amount_payable']}',
                                  style: pw.TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                        pw.Padding(
                          padding: pw.EdgeInsets.all(8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Payment Details',
                                  style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold,
                                      fontSize: 16)),
                              pw.Text('Bank Name: ',
                                  style: pw.TextStyle(fontSize: 14)),
                              pw.Text('Branch: ',
                                  style: pw.TextStyle(fontSize: 14)),
                              pw.Text('Date: ',
                                  style: pw.TextStyle(fontSize: 14)),
                            ],
                          ),
                        ),
                      ])
                    ]),
                  ),
                  pw.Padding(
                    padding: pw.EdgeInsets.symmetric(vertical: 60),
                    child: pw.Row(
                      mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
                      children: [
                        pw.Text('Signature: ____________________',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 16)),
                        pw.Text('Date: ____________________',
                            style: pw.TextStyle(
                                fontWeight: pw.FontWeight.bold, fontSize: 16)),
                      ],
                    ),
                  ),
                  pw.Text('Challan generated on ${DateTime.now()}',
                      style: pw.TextStyle(fontSize: 14)),
                ],
              ),
            );
          }),
    );
    return pdf;
  }

  Future<bool> requestStoragePermission() async {
    var status = await Permission.storage.request();
    return status.isGranted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tax Challan'),
        backgroundColor: Colors.green,
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _challanDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          var data = snapshot.data!;
          var pdf = generateChallanPdf(data);
          return PdfPreview(
            build: (format) => pdf.save(),
            canChangePageFormat: false,
            canChangeOrientation: false,
            canDebug: false,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          var status = await Permission.storage.status;
          if (!status.isGranted) {
            await Permission.storage.request();
          }

          if (await Permission.storage.isGranted) {
            var data = await _challanDetails;
            var pdf = await generateChallanPdf(data);
            final bytes = await pdf.save();
            String? path = await FilePicker.platform.getDirectoryPath();

            if (path != null) {
              final file = File('$path/challan-${widget.khasraNumber}.pdf');
              await file.writeAsBytes(bytes);
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Saved to ${file.path}')));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('No directory selected')));
            }
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text("Storage permission not granted")));
          }
        },
        child: Icon(Icons.download),
      ),
    );
  }
}
