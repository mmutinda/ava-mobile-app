import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:intl/intl.dart';
import 'package:isuze_pqcs/pages/claimforms/FiveS.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

// Define default font sizes for different sections
const double companyInfoFontSize = 12.0;
const double documentHeaderFontSize = 15.0;
const double customerInfoFontSize = 12.0;
const double tableHeaderFontSize = 14.0;
const double tableContentFontSize = 12.0;
const double totalFontSize = 14.0;
const double termsFontSize = 12.0;
// final Document document;
Future<Uint8List> generatedocumentPdf(Document document) async {
  final pdf = pw.Document();
  // Load Cambria font
  // final ByteData fontData = await rootBundle.load('assets/Century Gothic.ttf');
  // final pw.Font ttf = pw.Font.ttf(fontData);
  // Load logo imageS
  final ByteData logoByteData = await rootBundle.load('images/logo2.png');
  final ByteData logoByteData2 = await rootBundle.load('images/logo2.png');

  final Uint8List logoUint8List = logoByteData.buffer.asUint8List();
  final Uint8List logoUint8List2 = logoByteData2.buffer.asUint8List();
  final pw.MemoryImage logoImage = pw.MemoryImage(logoUint8List);
  final pw.MemoryImage stamp = pw.MemoryImage(logoUint8List2);

  pdf.addPage(
    pw.MultiPage(
      build: (pw.Context context) {
        return [
          pw.Container(
            color: PdfColors.white,
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
              children: [
                // Add company logo
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // Logo
                    pw.Container(
                      height: 100,
                      width: 100,
                      child: pw.Image(logoImage),
                    ),

                    // Title (Centered)
                    pw.Expanded(
                      flex: 3,
                      child: pw.Container(
                        alignment: pw.Alignment.center,
                        height: 60,
                        child: pw.Text(
                          '5S AUDIT CHECKLIST (FLOOR)',
                          style: pw.TextStyle(
                            // Use Times New Roman or a similar serif
                            // fontSize: 18,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                    // Metadata (Right-aligned)
                    pw.Container(
                      width: 160,
                      height: 60,
                      padding: const pw.EdgeInsets.symmetric(
                          horizontal: 4, vertical: 2),
                      child: pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Date',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              pw.Text(
                                document.date,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Document Reference',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              pw.Text(
                                document.documentRef,
                                style: pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Text(
                                'Revision',
                                style: pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                              pw.Text(
                                document.revision.toString(),
                                style: pw.TextStyle(
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                pw.Divider(),
                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    // SECTION and AUDITOR
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'SECTION:  ${document.section}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Text(
                            'AUDITOR: ${'.' * 40}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                    pw.SizedBox(height: 8),

                    // AUDITEE and DATE
                    pw.Row(
                      children: [
                        pw.Expanded(
                          child: pw.Text(
                            'AUDITEE: ${document.author}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                        pw.SizedBox(width: 10),
                        pw.Expanded(
                          child: pw.Text(
                            'DATE: ${document.date}',
                            style: pw.TextStyle(fontSize: 10),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                pw.SizedBox(height: 1 * PdfPageFormat.mm),
                //       pw.Row(
                //         crossAxisAlignment: pw.CrossAxisAlignment.end,
                //         children: [
                //           pw.Column(
                //             crossAxisAlignment: pw.CrossAxisAlignment.start,
                //             children: [
                //               pw.Text(
                //                 "BILL TO,",
                //                 style: pw.TextStyle(
                //                   fontWeight: pw.FontWeight.bold,
                //                   fontSize: customerInfoFontSize,
                //                 ),
                //               ),
                //               pw.Text(
                //                 '${document.customerName}',
                //                 // textAlign: pw.TextAlign.justify,
                //                 style: pw.TextStyle(fontSize: customerInfoFontSize),
                //               ),
                //               pw.Text(
                //                 '${document.customerDetails}',
                //                 // textAlign: pw.TextAlign.justify,
                //                 style: pw.TextStyle(fontSize: customerInfoFontSize),
                //               ),
                //             ],
                //           ),
                //           pw.Spacer(),
                //           pw.Column(
                //               crossAxisAlignment: pw.CrossAxisAlignment.end,
                //               children: [
                //                 pw.Table(
                //                   border: pw.TableBorder.all(color: PdfColors.grey),
                //                   children: [
                //                     pw.TableRow(
                //                       children: [
                //                         pw.SizedBox(
                //                           width: 100,
                //                           child: pw.Container(
                //                             padding: pw.EdgeInsets.all(5),
                //                             alignment: pw.Alignment.centerRight,
                //                             child: pw.Text(
                //                                 "document #${document.documentNumber.toString().padLeft(5, '0')}"),
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                     if (document.orderNumber != null &&
                //                         document.orderNumber!.isNotEmpty)
                //                       pw.TableRow(
                //                         children: [
                //                           pw.SizedBox(
                //                             width: 100,
                //                             child: pw.Container(
                //                               padding: pw.EdgeInsets.all(5),
                //                               alignment: pw.Alignment.centerRight,
                //                               child: pw.Text(
                //                                   "Order No: ${document.orderNumber}"),
                //                             ),
                //                           ),
                //                         ],
                //                       ),
                //                     pw.TableRow(
                //                       children: [
                //                         pw.SizedBox(
                //                           child: pw.Container(
                //                             padding: pw.EdgeInsets.all(5),
                //                             alignment: pw.Alignment.centerRight,
                //                             child: pw.Text(
                //                                 "Inv. Date: ${DateFormat('MMMM d, yyyy').format(document.date)}"),
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                     pw.TableRow(
                //                       children: [
                //                         pw.SizedBox(
                //                           child: pw.Container(
                //                             padding: pw.EdgeInsets.all(5),
                //                             alignment: pw.Alignment.centerRight,
                //                             child: pw.Text(
                //                                 "Due Date: ${DateFormat('MMMM d, yyyy').format(document.dueDate)}"),
                //                           ),
                //                         ),
                //                       ],
                //                     ),
                //                   ],
                //                 ),
                //                 pw.SizedBox(height: 5),
                //                 if (document.Currency?.isNotEmpty == true)
                //                   pw.RichText(
                //                     text: pw.TextSpan(
                //                       children: [
                //                         pw.TextSpan(
                //                           text: 'Currency',
                //                           style: pw.TextStyle(
                //                               fontWeight: pw.FontWeight.bold),
                //                         ),
                //                         pw.TextSpan(
                //                           text: ': ${document.Currency}',
                //                           style: pw.TextStyle(), // normal style
                //                         ),
                //                       ],
                //                     ),
                //                   ),
                //               ])
                //         ],
                //       ),

                //       pw.SizedBox(height: 2),
                //       // Generate table with dynamic rows
                //       pw.Table(
                //         border: pw.TableBorder.all(),
                //         columnWidths: {
                //           0: pw.FixedColumnWidth(40),
                //           1: pw.FixedColumnWidth(200),
                //           2: pw.FixedColumnWidth(40),
                //           3: pw.FlexColumnWidth(),
                //           4: pw.FlexColumnWidth(),
                //         },
                //         children: [
                //           // Header Row
                //           pw.TableRow(
                //             decoration: pw.BoxDecoration(color: PdfColors.green900),
                //             children: [
                //               for (var header in [
                //                 'S/N',
                //                 'Description',
                //                 'Qty',
                //                 'Unit Price',
                //                 'Total Amount'
                //               ])
                //                 pw.Padding(
                //                   padding: const pw.EdgeInsets.all(8),
                //                   child: pw.Text(header,
                //                       style: pw.TextStyle(
                //                           color: PdfColors.white,
                //                           fontWeight: pw.FontWeight.bold)),
                //                 ),
                //             ],
                //           ),

                //           // Data Rows
                //           for (var i = 0; i < document.items.length; i++)
                //             pw.TableRow(
                //               decoration: pw.BoxDecoration(
                //                 color: i % 2 == 0
                //                     ? PdfColors.white
                //                     : PdfColors.grey100, // Alternating row colors
                //               ),
                //               children: [
                //                 pw.Padding(
                //                   padding: const pw.EdgeInsets.all(8),
                //                   child: pw.Text('${i + 1}'),
                //                 ),
                //                 pw.Padding(
                //                   padding: const pw.EdgeInsets.all(8),
                //                   child: pw.Text(document.items[i].description),
                //                 ),
                //                 pw.Padding(
                //                   padding: const pw.EdgeInsets.all(8),
                //                   child:
                //                       pw.Text(document.items[i].quantity.toString()),
                //                 ),
                //                 pw.Padding(
                //                   padding: const pw.EdgeInsets.all(8),
                //                   child: pw.Text(NumberFormat.currency(symbol: '')
                //                       .format(document.items[i].amount)),
                //                 ),
                //                 pw.Padding(
                //                   padding: const pw.EdgeInsets.all(8),
                //                   child: pw.Text(NumberFormat.currency(symbol: '')
                //                       .format(document.items[i].amount *
                //                           document.items[i].quantity)),
                //                 ),
                //               ],
                //             ),
                //         ],
                //       ),

                //       pw.SizedBox(height: 16),
                //       pw.Stack(
                //         children: [
                //           pw.Container(
                //             alignment: pw.Alignment.centerRight,
                //             child: pw.Row(
                //               children: [
                //                 pw.Spacer(flex: 6),
                //                 pw.Expanded(
                //                   flex: 4,
                //                   child: pw.Column(
                //                     crossAxisAlignment: pw.CrossAxisAlignment.start,
                //                     children: [
                //                       pw.Row(
                //                         children: [
                //                           pw.Expanded(
                //                             child: pw.Text(
                //                               'SUB TOTAL',
                //                               style: pw.TextStyle(
                //                                   fontWeight: pw.FontWeight.bold),
                //                             ),
                //                           ),
                //                           pw.Text(
                //                             '${NumberFormat.currency(symbol: '').format(document.Subtotal)}',
                //                             style: pw.TextStyle(
                //                                 fontWeight: pw.FontWeight.bold),
                //                           ),
                //                         ],
                //                       ),
                //                       pw.Row(
                //                         children: [
                //                           pw.Expanded(
                //                             child: pw.Text(
                //                               'VAT 18 %',
                //                               style: pw.TextStyle(
                //                                   fontWeight: pw.FontWeight.bold),
                //                             ),
                //                           ),
                //                           pw.Text(
                //                             '${NumberFormat.currency(symbol: '').format(document.vatTotal)}',
                //                             style: pw.TextStyle(
                //                                 fontWeight: pw.FontWeight.bold),
                //                           ),
                //                         ],
                //                       ),
                //                       pw.Divider(),
                //                       pw.Row(
                //                         children: [
                //                           pw.Expanded(
                //                             child: pw.Text(
                //                               'TOTAL',
                //                               style: pw.TextStyle(
                //                                 fontSize: totalFontSize,
                //                                 fontWeight: pw.FontWeight.bold,
                //                               ),
                //                             ),
                //                           ),
                //                           pw.Text(
                //                             "${formattedAmount}",
                //                             style: pw.TextStyle(
                //                                 fontWeight: pw.FontWeight.bold),
                //                           ),
                //                         ],
                //                       ),
                //                       pw.SizedBox(height: 2 * PdfPageFormat.mm),
                //                       pw.Container(
                //                           height: 1, color: PdfColors.grey400),
                //                       pw.SizedBox(height: 0.5 * PdfPageFormat.mm),
                //                       pw.Container(
                //                           height: 1, color: PdfColors.grey400),
                //                     ],
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //           pw.Container(
                //             margin: pw.EdgeInsets.only(top: 105, right: 27),
                //             alignment: pw.Alignment.centerRight,
                //             child: pw.Transform.rotate(
                //               angle: -0.01, // Adjust the angle as needed (radians)
                //               // angle: 0.00, // Adjust the angle as needed (radians)
                //               child: pw.Text(
                //                 "${DateFormat('d MMM yyyy').format(document.date)}",
                //                 style: pw.TextStyle(
                //                   fontSize: 11,
                //                   color: PdfColors.red,
                //                   fontWeight: pw.FontWeight.bold,
                //                   lineSpacing: 1.2, // Adjust line height
                //                 ),
                //               ),
                //             ),
                //           ),
                //           pw.Container(
                //             margin: pw.EdgeInsets.only(top: 55),
                //             alignment: pw.Alignment.centerRight,
                //             child: pw.Image(
                //               stamp,
                //               // height: 202,
                //               // width: 190,
                //               height: 112,
                //               width: 190,
                //             ),
                //           ),
                //           pw.Container(
                //             margin: pw.EdgeInsets.only(top: 60),
                //             alignment: pw.Alignment.centerLeft,
                //             child: pw.Column(
                //               crossAxisAlignment: pw.CrossAxisAlignment.start,
                //               children: [
                //                 pw.Text(
                //                   'Terms & Conditions:',
                //                   style: pw.TextStyle(
                //                     fontWeight: pw.FontWeight.bold,
                //                     fontSize: termsFontSize,
                //                     // font: ttf,
                //                   ),
                //                 ),
                //                 pw.Text(
                //                   '1. The credit term is 30 days from the date of the document',
                //                   style: pw.TextStyle(
                //                     fontSize: termsFontSize,
                //                     font: ttf,
                //                   ),
                //                 ),
                //                 pw.Text(
                //                   '2. All payment must be made via bank',
                //                   style: pw.TextStyle(
                //                       fontSize: termsFontSize, font: ttf),
                //                 ),
                //                 pw.SizedBox(height: 5),
                //                 pw.Text(
                //                   'BANK A/C Info.',
                //                   style: pw.TextStyle(
                //                     fontWeight: pw.FontWeight.bold,
                //                     fontSize: termsFontSize,
                //                     // font: ttf,
                //                   ),
                //                 ),
                //                 pw.SizedBox(
                //                   width: 190,
                //                   child: pw.Row(
                //                     children: [
                //                       pw.Expanded(
                //                         child: pw.Text(
                //                           'A/C Name:',
                //                           style: pw.TextStyle(
                //                               fontSize: termsFontSize, font: ttf),
                //                         ),
                //                       ),
                //                       pw.Text(
                //                         'TGN COMPANY LTD',
                //                         style: pw.TextStyle(
                //                             fontSize: termsFontSize, font: ttf),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //                 pw.SizedBox(
                //                   width: 240,
                //                   child: pw.Row(
                //                     children: [
                //                       pw.Expanded(
                //                         child: pw.Text(
                //                           'A/C No:',
                //                           style: pw.TextStyle(
                //                               fontSize: termsFontSize, font: ttf),
                //                         ),
                //                       ),
                //                       pw.SizedBox(width: 10),
                //                       pw.Text(
                //                         '40810212259  (TZS A/C) NMB',
                //                         style: pw.TextStyle(
                //                             fontSize: termsFontSize, font: ttf),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //                 pw.SizedBox(
                //                   width: 240,
                //                   child: pw.Row(
                //                     children: [
                //                       pw.Expanded(
                //                         child: pw.Text(
                //                           'A/C No:',
                //                           style: pw.TextStyle(
                //                               fontSize: termsFontSize, font: ttf),
                //                         ),
                //                       ),
                //                       pw.SizedBox(width: 10),
                //                       pw.Text(
                //                         '40810212257  (USD A/C) NMB',
                //                         style: pw.TextStyle(
                //                             fontSize: termsFontSize, font: ttf),
                //                       ),
                //                     ],
                //                   ),
                //                 ),
                //               ],
                //             ),
                //           ),
                //         ],
                //       ),
                //       pw.SizedBox(height: 10), // Adds fixed spacing
                //       // pw.Spacer(),
                //       pw.Container(
                //         padding: pw.EdgeInsets.all(12),
                //         decoration: pw.BoxDecoration(
                //           borderRadius: pw.BorderRadius.circular(10),
                //           color: PdfColors.grey100,
                //         ),
                //         width: double.infinity,
                //         child: pw.Text(
                //           "Thank you for your inquiry. We look forward to doing more business with you.",
                //           style: pw.TextStyle(
                //               fontWeight: pw.FontWeight.bold,
                //               fontSize: termsFontSize,
                //               font: ttf),
                //           textAlign: pw.TextAlign.center,
                //         ),
                //       ),
              ],
            ),
          )
        ];
      },
      footer: (context) {
        return pw.Text("Page ${context.pageNumber} of ${context.pagesCount}",
            style: pw.TextStyle(fontSize: 10), textAlign: pw.TextAlign.center);
      },
    ),
  );

  return pdf.save();
}

// Helper function to build a TableCell
