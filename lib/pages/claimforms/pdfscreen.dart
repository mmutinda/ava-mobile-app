import 'dart:io';
import 'package:flutter/material.dart';
import 'package:pdfrx/pdfrx.dart';
import 'package:share_plus/share_plus.dart';

class PdfPreviewScreen extends StatelessWidget {
  final String filePath;
  final String name;

  const PdfPreviewScreen({Key? key, required this.filePath, required this.name})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Preview'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () async {
              final file = File(filePath);
              if (await file.exists()) {
                await Share.shareXFiles([XFile(file.path)],
                    text: 'Check out this PDF: $name');
              } else {
                // Handle file not found
                print('File not found at $filePath');
              }
            },
          ),
          // IconButton(
          //   icon: Icon(Icons.save),
          //   onPressed: () {
          //     _savePdf(filePath, name);
          //   },
          // ),
        ],
      ),
      body: PdfViewer.file(
        filePath,
      ),
    );
  }
}
