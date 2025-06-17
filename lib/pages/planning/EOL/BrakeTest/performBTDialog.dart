import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/constants.dart';

class BtTestPerformPage extends StatefulWidget {
  final EOLType;
  @override
  const BtTestPerformPage({super.key, required this.EOLType});
  _BtTestPerformPageState createState() => _BtTestPerformPageState();
}

class _BtTestPerformPageState extends State<BtTestPerformPage> {
  File? _imageFile;
  String selectedValue = 'NO';

  Future<void> _captureImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Perform ${widget.EOLType} Test"),
        backgroundColor: mycolor,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: Text(
                    "Did the unit pass ${widget.EOLType}?",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      color: mycolor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                ChoiceChip(
                  label: Text('YES'),
                  selected: selectedValue == 'YES',
                  selectedColor: Colors.red,
                  onSelected: (selected) {
                    setState(() {
                      selectedValue = 'YES';
                    });
                  },
                  labelStyle: TextStyle(
                    color: selectedValue == 'YES' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(width: 10),
                ChoiceChip(
                  label: Text('NO'),
                  selected: selectedValue == 'NO',
                  selectedColor: Colors.green,
                  onSelected: (selected) {
                    setState(() {
                      selectedValue = 'NO';
                    });
                  },
                  labelStyle: TextStyle(
                    color: selectedValue == 'NO' ? Colors.white : Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            GestureDetector(
              onTap: _captureImage,
              child: Container(
                width: double.infinity,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(12),
                  image: _imageFile != null
                      ? DecorationImage(
                          image: FileImage(_imageFile!),
                          fit: BoxFit.cover,
                        )
                      : null,
                  color: Colors.grey.shade100,
                ),
                child: _imageFile == null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt,
                                size: 40, color: Colors.grey),
                            SizedBox(height: 8),
                            Text(
                              "Tap to capture image",
                              style: TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context, {
                          'selectedValue': selectedValue,
                          'image': _imageFile,
                        });
                      },
                      icon: Icon(Icons.send),
                      label: widget.EOLType == 'BT'
                          ? Text("To Wheel Alignment")
                          : Text("To Quality Control"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
