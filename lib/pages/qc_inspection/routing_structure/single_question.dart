import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qc_inspection/routing_structure/issuedialog.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SingleQuestion extends StatefulWidget {
  final int id;
  final String lotNo;
  final String question;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<String> onInputValueChanged;
  final ValueChanged<String> onValueChanged2;
  final String? initialRadioValue;
  final String? initialDecripValue;
  final String? hasDescription;
  final String? instruction; // Add instruction parameter
  final String? initialDefectCategory; // Add defect category parameter
  final ValueChanged<String>?
      onDefectCategoryChanged; // Add defect category callback
  final String? parts_to_scan; // Add parts to scan parameter
  final dynamic
      scandata; // Add scandata parameter for comparison (can be String or Map)
  final ValueChanged<List<String>> onUsersSelected;
  final can_sign;
  final int index;
  final checkanswered;
  final String? initialImage;
  final ValueChanged<File?> onImageChanged; // Allow null for deletion
  final List<Map<String, String>> users; // List of users with name and email
  final ValueChanged<Map<String, dynamic>?>?
      onClaimDataChanged; // Add claim data callback
  final String? initialStaffNo; // Add staff number parameter
  final String? StaffNo; // Add staff number parameter
  final ValueChanged<String>? onStaffNoChanged; // Add staff number callback
  const SingleQuestion(
      {super.key,
      required this.id,
      required this.lotNo,
      required this.onValueChanged,
      required this.onInputValueChanged,
      required this.onValueChanged2,
      required this.question,
      required this.onImageChanged,
      required this.onUsersSelected,
      this.initialRadioValue,
      required this.users,
      this.can_sign,
      this.checkanswered,
      required this.index,
      this.initialDecripValue,
      required this.initialImage,
      this.hasDescription,
      this.initialDefectCategory, // Add defect category parameter
      this.onDefectCategoryChanged, // Add defect category callback
      this.parts_to_scan, // Add parts to scan parameter
      this.scandata, // Add scandata parameter for comparison
      this.onClaimDataChanged, // Add claim data callback
      this.initialStaffNo, // Add staff number parameter
      this.StaffNo, // Add staff number parameter
      this.onStaffNoChanged, // Add staff number callback
      this.instruction}); // Add instruction parameter

  @override
  State<SingleQuestion> createState() => _SingleQuestionState();
}

class _SingleQuestionState extends State<SingleQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  Uint8List? _signatureImage;
  late TextEditingController inputController;
  late TextEditingController staffNoController; // Add staff number controller
  File? _image; // Holds the captured image
  bool _isInstructionExpanded = false; // Track instruction expansion state
  bool _isNotifyUsersExpanded = false; // Track notify users expansion state
  String? selectedDefectCategory; // Track selected defect category
  bool _isScanned = false; // Track if scanning is completed
  String? _scannedData; // Store scanned data
  bool _scanningRequired = false; // Track if scanning is required
  bool _scanMatched = false; // Track if scan result matches expected data
  bool _claimCaptured = false; // Track if claim has been captured

  // Store claim data for editing
  String _claimDescription = '';
  String _claimPartNo = '';
  String? _claimCategory;
  String? _claimType;
  String? _claimClassification;
  File? _claimImage;

  // Initialize claim template with job card format
  Map<String, dynamic> _initializeClaimTemplate() {
    return {
      'question_id': widget.id,
      'question_text': widget.question,
      'issue_description': '',
      'part_number': '',
      'issue_category': null,
      'issue_type': null,
      'defect_classification': null,
      'image_path': null,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  // // Defect categories data
  // final List<Map<String, String>> defectCategories = [
  //   {"name": "A-Critical", "classification": "A"},
  //   {"name": "B- Major", "classification": "B"},
  //   {"name": "C-Minor", "classification": "C"},
  //   {"name": "D-Cosmetic", "classification": "D"},
  // ];

  @override
  bool get wantKeepAlive => true;

  // Helper method to validate defect category
  // String? _validateDefectCategory(String? category) {
  //   if (category == null) return null;

  //   // Check if the category exists in our defectCategories list
  //   bool exists =
  //       defectCategories.any((cat) => cat['classification'] == category);
  //   return exists ? category : null;
  // }

  @override
  void initState() {
    super.initState();
    inputController = TextEditingController(text: widget.initialDecripValue);
    inputController.addListener(_handleValueChanged);

    // Initialize staff number controller
    staffNoController =
        TextEditingController(text: widget.initialStaffNo ?? widget.StaffNo);
    staffNoController.addListener(_handleStaffNoChanged);

    // // Validate and set initial defect category
    // selectedDefectCategory =
    //     _validateDefectCategory(widget.initialDefectCategory);

    // Check if scanning is required
    _scanningRequired =
        widget.parts_to_scan != null && widget.parts_to_scan!.isNotEmpty;

    // If already answered, mark as scanned
    if (widget.initialRadioValue != null) {
      _isScanned = true;
    }
  }

  @override
  void dispose() {
    inputController.removeListener(_handleValueChanged);
    inputController.dispose();
    staffNoController.removeListener(_handleStaffNoChanged);
    staffNoController.dispose();
    super.dispose();
  }

  void _handleValueChanged() {
    widget.onInputValueChanged(inputController.text);
  }

  void _handleStaffNoChanged() {
    if (widget.onStaffNoChanged != null) {
      // Always update the staff number value, even if empty
      // This allows validation to catch missing staff numbers
      widget.onStaffNoChanged!(staffNoController.text);
    }
  }

  void _handleImageChanged() {
    widget.onImageChanged(_image!);
  }

  // Show staff number dialog
  // Show staff number dialog with disabled state when answered
  Future<void> _showStaffNumberDialog() async {
    // Don't show dialog if question is already answered
    if (widget.initialRadioValue != null) {
      return;
    }

    TextEditingController dialogController =
        TextEditingController(text: staffNoController.text);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            String? errorMessage;

            return Dialog(
              backgroundColor: Colors.transparent,
              child: Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.person,
                          color: Colors.blue.shade700,
                          size: 24,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Staff Number',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    TextFormField(
                      controller: dialogController,
                      decoration: InputDecoration(
                        hintText: 'Enter your staff number',
                        prefixIcon: Icon(Icons.badge_outlined,
                            color: Colors.blue.shade700),
                        contentPadding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: mycolor, width: 2),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        errorText: errorMessage,
                      ),
                      style: TextStyle(fontSize: 16),
                      keyboardType: TextInputType.number,
                      maxLength: 10,
                      autofocus: true,
                      onChanged: (value) {
                        // Clear error when user starts typing
                        if (errorMessage != null) {
                          setDialogState(() {
                            errorMessage = null;
                          });
                        }
                      },
                    ),
                    SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: Colors.grey.shade400),
                            ),
                            child: Text(
                              'Cancel',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ),
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              // Validate staff number is not empty
                              if (dialogController.text.trim().isEmpty) {
                                setDialogState(() {
                                  errorMessage = 'Staff number cannot be empty';
                                });
                                return;
                              }

                              // Save if valid
                              setState(() {
                                staffNoController.text = dialogController.text;
                              });
                              if (widget.onStaffNoChanged != null) {
                                widget.onStaffNoChanged!(dialogController.text);
                              }
                              Navigator.of(context).pop();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mycolor,
                              padding: EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: Text(
                              'Save',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  /// Capture image from camera
  // ignore: unused_element
  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _handleImageChanged(); // Notify parent
      });
    }
  }

  void _deleteImage() {
    print("Deleting image...");
    setState(() {
      _image = null; // Set image to null when deleting
    });

    // Pass null to onImageChanged to indicate deletion
    widget.onImageChanged(null);

    print("Image deleted, _image is now: $_image");
  }

  List<String> selectedUsers = [];

  // Method to handle scanning
  Future<void> _startScanning() async {
    try {
      // Show scanning dialog
      String? scannedResult = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return _buildScannerDialog();
        },
      );

      if (scannedResult != null) {
        setState(() {
          _scannedData = scannedResult;
          _isScanned = true;

          // Compare scanned data with scandata
          String expectedData = '';
          if (widget.scandata is Map) {
            // If scandata is a Map, extract the relevant field
            expectedData = widget.scandata['code'] ??
                widget.scandata['data'] ??
                widget.scandata.toString();
          } else if (widget.scandata is String) {
            expectedData = widget.scandata;
          } else {
            expectedData = widget.scandata?.toString() ?? '';
          }

          // Check if scan matches expected data
          _scanMatched = _scannedData == expectedData;

          // Only allow answering if scan matches
          if (_scanMatched) {
            // Automatically set to OK when scan matches
            okay = "OK";
            widget.onValueChanged("OK");
          } else {
            // Don't set answer when scan doesn't match
            okay = null;
            widget.onValueChanged("");
          }
        });
      }
    } catch (e) {
      // Handle scanning error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scanning failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Build scanner dialog with automatic camera
  Widget _buildScannerDialog() {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        height: 400,
        width: 300,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: mycolor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.qr_code_scanner, color: Colors.white, size: 24),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Scan ${widget.parts_to_scan}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white),
                  ),
                ],
              ),
            ),
            // QR Scanner
            Expanded(
              child: Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: QRView(
                    key: GlobalKey(debugLabel: 'QR'),
                    onQRViewCreated: (QRViewController controller) {
                      controller.scannedDataStream.listen((scanData) {
                        controller.dispose();
                        Navigator.of(context).pop(scanData.code);
                      });
                    },
                    overlay: QrScannerOverlayShape(
                      borderColor: mycolor,
                      borderRadius: 10,
                      borderLength: 30,
                      borderWidth: 10,
                      cutOutSize: 200,
                    ),
                  ),
                ),
              ),
            ),
            // Instructions
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Point camera at the barcode/QR code',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Method to show dialog asking for scan or manual entry
  Future<void> _showScanOptionDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Choose Input Method',
            style: TextStyle(
              color: mycolor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content:
              Text('How would you like to input the ${widget.parts_to_scan}?'),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _startScanning(); // Start camera scanning
              },
              icon: Icon(Icons.qr_code_scanner, color: mycolor),
              label: Text(
                'Scan Barcode',
                style: TextStyle(color: mycolor),
              ),
            ),
            TextButton.icon(
              onPressed: () {
                Navigator.of(context).pop();
                _showManualEntryDialog(); // Show manual entry dialog
              },
              icon: Icon(Icons.keyboard, color: mycolor),
              label: Text(
                'Manual Entry',
                style: TextStyle(color: mycolor),
              ),
            ),
          ],
        );
      },
    );
  }

  // Method to show manual entry dialog
  Future<void> _showManualEntryDialog() async {
    TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Manual Entry',
            style: TextStyle(
              color: mycolor,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Enter ${widget.parts_to_scan} manually:'),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller,
                autofocus: true,
                decoration: InputDecoration(
                  labelText: 'Enter ${widget.parts_to_scan}',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.edit, color: mycolor),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Cancel',
                style: TextStyle(color: Colors.grey),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                if (controller.text.isNotEmpty) {
                  setState(() {
                    _isScanned = true;
                    _scannedData = controller.text;

                    // Compare manual entry with scandata
                    String expectedData = '';
                    if (widget.scandata is Map) {
                      expectedData = widget.scandata['code'] ??
                          widget.scandata['data'] ??
                          widget.scandata.toString();
                    } else if (widget.scandata is String) {
                      expectedData = widget.scandata;
                    } else {
                      expectedData = widget.scandata?.toString() ?? '';
                    }

                    // Check if manual entry matches expected data
                    _scanMatched = _scannedData == expectedData;

                    // Only allow answering if scan matches
                    if (_scanMatched) {
                      // Automatically set to OK when scan matches
                      okay = "OK";
                      widget.onValueChanged("OK");
                    } else {
                      // Don't set answer when scan doesn't match
                      okay = null;
                      widget.onValueChanged("");
                    }
                  });
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: mycolor,
              ),
              child: Text(
                'Submit',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // Helper method to clean HTML tags from instruction text

  String _cleanHtmlTags(String htmlString) {
    RegExp exp = RegExp(r"<[^>]*>", multiLine: true, caseSensitive: true);
    return htmlString.replaceAll(exp, '').replaceAll('&nbsp;', ' ').trim();
  }

  // Helper method to extract list items from HTML
  List<String> _extractListItems(String htmlString) {
    List<String> items = [];
    RegExp listItemExp =
        RegExp(r"<li>(.*?)</li>", multiLine: true, caseSensitive: true);
    Iterable<RegExpMatch> matches = listItemExp.allMatches(htmlString);

    for (RegExpMatch match in matches) {
      String item = match.group(1) ?? '';
      item = _cleanHtmlTags(item);
      if (item.isNotEmpty) {
        items.add(item);
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    print(widget.scandata);
    super.build(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with question number and status
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 2),
              ),
            ),
            child: Row(
              children: [
                // Question number
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: mycolor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Center(
                    child: Text(
                      '${widget.index + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                // Question text
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // Status indicator
                if (widget.initialRadioValue != null)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: Text(
                      "✓ Done",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Mobile-friendly instruction section
          if (widget.instruction != null && widget.instruction!.isNotEmpty)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200, width: 1),
              ),
              child: Column(
                children: [
                  // Compact header
                  InkWell(
                    onTap: () {
                      setState(() {
                        _isInstructionExpanded = !_isInstructionExpanded;
                      });
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Colors.blue.shade700,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Instructions',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            _isInstructionExpanded
                                ? Icons.keyboard_arrow_up
                                : Icons.keyboard_arrow_down,
                            color: Colors.blue.shade600,
                            size: 20,
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Expandable content
                  if (_isInstructionExpanded)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(8),
                          bottomRight: Radius.circular(8),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Check if it's HTML with list items
                          if (widget.instruction!.contains('<li>'))
                            ..._extractListItems(widget.instruction!)
                                .map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(
                                          top: 4, right: 8),
                                      width: 4,
                                      height: 4,
                                      decoration: BoxDecoration(
                                        color: Colors.blue.shade600,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        item,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.black87,
                                          height: 1.3,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList()
                          else
                            // Regular text instruction
                            Text(
                              _cleanHtmlTags(widget.instruction!),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                                height: 1.3,
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

          // Content area
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scanning section (if parts_to_scan is not null)
                if (widget.parts_to_scan != null) ...[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Scan Required:",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (!_isScanned) ...[
                        Container(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: _showScanOptionDialog,
                            icon: Icon(Icons.qr_code_scanner,
                                color: Colors.white),
                            label: Text(
                              'Scan ${widget.parts_to_scan}',
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mycolor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ] else ...[
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: _scanMatched
                                ? Colors.green[50]
                                : Colors.red[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _scanMatched
                                    ? Colors.green[300]!
                                    : Colors.red[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _scanMatched ? Icons.check_circle : Icons.error,
                                color: _scanMatched ? Colors.green : Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _scanMatched
                                          ? 'Scan Completed - Match Found'
                                          : 'Scan Completed - No Match',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: _scanMatched
                                            ? Colors.green[800]
                                            : Colors.red[800],
                                      ),
                                    ),
                                    Text(
                                      'Scanned: $_scannedData',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    // if (!_scanMatched)
                                    //   Text(
                                    //     'Scan result does not match expected value. Please scan the correct ${widget.parts_to_scan}.',
                                    //     style: TextStyle(
                                    //       fontSize: 11,
                                    //       color: Colors.red[700],
                                    //       fontStyle: FontStyle.italic,
                                    //     ),
                                    //   ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isScanned = false;
                                          _scannedData = null;
                                          _scanMatched = false;
                                          okay = null;
                                        });
                                        widget
                                            .onValueChanged(""); // Reset value
                                      },
                                      child: Text(
                                        'Tap to rescan',
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: mycolor,
                                          fontStyle: FontStyle.italic,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Rescan button
                              Container(
                                decoration: BoxDecoration(
                                  color: mycolor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                      color: mycolor.withOpacity(0.3)),
                                ),
                                child: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      _isScanned = false;
                                      _scannedData = null;
                                      _scanMatched = false;
                                      okay = null;
                                    });
                                    widget.onValueChanged(""); // Reset value
                                  },
                                  icon: Icon(
                                    Icons.refresh,
                                    color: mycolor,
                                    size: 20,
                                  ),
                                  tooltip: 'Rescan',
                                  padding: const EdgeInsets.all(8),
                                  constraints: const BoxConstraints(
                                    minWidth: 36,
                                    minHeight: 36,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 12),
                ],

                // Radio buttons and staff number - flexible layout
                Wrap(
                  alignment: WrapAlignment.start,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 12,
                  runSpacing: 8,
                  children: [
                    const Text(
                      'Answer:',
                      style: TextStyle(
                        // fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    // OK Radio
                    GestureDetector(
                      onTap: (widget.initialRadioValue != null ||
                              (_scanningRequired &&
                                  (!_isScanned || !_scanMatched)))
                          ? null
                          : () {
                              setState(() {
                                okay = "OK";
                                selectedDefectCategory = null;

                                // Clear all claim data when switching to OK
                                _claimCaptured = false;
                                _claimDescription = '';
                                _claimPartNo = '';
                                _claimCategory = null;
                                _claimType = null;
                                _claimClassification = null;
                                _claimImage = null;
                              });

                              // Clear claim data in parent via callback
                              if (widget.onClaimDataChanged != null) {
                                widget.onClaimDataChanged!(null);
                              }

                              widget.onValueChanged(okay!);
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: okay == "OK"
                              ? Colors.green.shade50
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: okay == "OK"
                                ? Colors.green.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: "OK",
                              groupValue: okay ?? widget.initialRadioValue,
                              onChanged: (widget.initialRadioValue != null ||
                                      (_scanningRequired &&
                                          (!_isScanned || !_scanMatched)))
                                  ? null
                                  : (value) {
                                      setState(() {
                                        okay = value!;
                                        selectedDefectCategory = null;

                                        // Clear all claim data when switching to OK
                                        _claimCaptured = false;
                                        _claimDescription = '';
                                        _claimPartNo = '';
                                        _claimCategory = null;
                                        _claimType = null;
                                        _claimClassification = null;
                                        _claimImage = null;
                                      });

                                      // Clear claim data in parent via callback
                                      if (widget.onClaimDataChanged != null) {
                                        widget.onClaimDataChanged!(null);
                                      }

                                      widget.onValueChanged(okay!);
                                    },
                              activeColor: Colors.green,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                            ),
                            Text(
                              'OK',
                              style: TextStyle(
                                // fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: (_scanningRequired &&
                                        (!_isScanned || !_scanMatched))
                                    ? Colors.grey.shade400
                                    : okay == "OK"
                                        ? Colors.green.shade700
                                        : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // NOK Radio
                    GestureDetector(
                      onTap: (widget.initialRadioValue != null ||
                              (_scanningRequired &&
                                  (!_isScanned || !_scanMatched)))
                          ? null
                          : () async {
                              // Initialize claim template
                              final claimTemplate = _initializeClaimTemplate();

                              // Show issue dialog as bottom sheet with initialized template
                              final result = await showModalBottomSheet<
                                  Map<String, dynamic>?>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) => Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.9,
                                  child: IssueDialog(
                                    lotNo: widget.lotNo,
                                    initialDescription: _claimDescription,
                                    initialPartNo: _claimPartNo,
                                    initialCategory: _claimCategory,
                                    initialType: _claimType,
                                    initialClassification: _claimClassification,
                                    initialImage: _claimImage,
                                  ),
                                ),
                              );

                              if (result != null) {
                                // Merge template with captured data
                                final completeClaimData = {
                                  ...claimTemplate,
                                  'issue_description':
                                      result['description'] ?? '',
                                  'part_number': result['partNo'] ?? '',
                                  'issue_category': result['category'],
                                  'issue_type': result['type'],
                                  'defect_classification':
                                      result['classification'],
                                  'image': result['image'],
                                  'updated_at':
                                      DateTime.now().toIso8601String(),
                                };

                                setState(() {
                                  okay = "NOK";
                                  _claimCaptured = true;
                                  // Store claim data
                                  _claimDescription =
                                      result['description'] ?? '';
                                  _claimPartNo = result['partNo'] ?? '';
                                  _claimCategory = result['category'];
                                  _claimType = result['type'];
                                  _claimClassification =
                                      result['classification'];
                                  _claimImage = result['image'];
                                });

                                // Send claim data to parent via callback
                                if (widget.onClaimDataChanged != null) {
                                  widget.onClaimDataChanged!(completeClaimData);
                                }

                                widget.onValueChanged(okay!);
                              } else {
                                // User cancelled the dialog, don't change the radio button state
                                // Keep the previous state by not updating 'okay'
                                print(
                                    "User cancelled claim dialog, keeping previous radio state");
                              }
                            },
                      child: Container(
                        decoration: BoxDecoration(
                          color: okay == "NOK"
                              ? Colors.red.shade50
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: okay == "NOK"
                                ? Colors.red.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<String>(
                              value: "NOK",
                              groupValue: okay ?? widget.initialRadioValue,
                              onChanged: (widget.initialRadioValue != null ||
                                      (_scanningRequired &&
                                          (!_isScanned || !_scanMatched)))
                                  ? null
                                  : (value) async {
                                      if (value == "NOK") {
                                        // Initialize claim template
                                        final claimTemplate =
                                            _initializeClaimTemplate();

                                        // Show issue dialog as bottom sheet with initialized template
                                        final result =
                                            await showModalBottomSheet<
                                                Map<String, dynamic>?>(
                                          context: context,
                                          isScrollControlled: true,
                                          backgroundColor: Colors.transparent,
                                          builder: (context) => Container(
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.9,
                                            child: IssueDialog(
                                              lotNo: widget.lotNo,
                                              initialDescription:
                                                  _claimDescription,
                                              initialPartNo: _claimPartNo,
                                              initialCategory: _claimCategory,
                                              initialType: _claimType,
                                              initialClassification:
                                                  _claimClassification,
                                              initialImage: _claimImage,
                                            ),
                                          ),
                                        );

                                        if (result != null) {
                                          // Merge template with captured data
                                          final completeClaimData = {
                                            ...claimTemplate,
                                            'issue_description':
                                                result['description'] ?? '',
                                            'part_number':
                                                result['partNo'] ?? '',
                                            'issue_category':
                                                result['category'],
                                            'issue_type': result['type'],
                                            'defect_classification':
                                                result['classification'],
                                            'image': result['image'],
                                            'updated_at': DateTime.now()
                                                .toIso8601String(),
                                          };

                                          setState(() {
                                            okay = value!;
                                            _claimCaptured = true;
                                            // Store claim data
                                            _claimDescription =
                                                result['description'] ?? '';
                                            _claimPartNo =
                                                result['partNo'] ?? '';
                                            _claimCategory = result['category'];
                                            _claimType = result['type'];
                                            _claimClassification =
                                                result['classification'];
                                            _claimImage = result['image'];
                                          });

                                          // Send claim data to parent via callback
                                          if (widget.onClaimDataChanged !=
                                              null) {
                                            widget.onClaimDataChanged!(
                                                completeClaimData);
                                          }

                                          widget.onValueChanged(okay!);
                                        } else {
                                          // User cancelled the dialog, don't change the radio button state
                                          // Keep the previous state by not updating 'okay'
                                          print(
                                              "User cancelled claim dialog, keeping previous radio state");
                                        }
                                      } else {
                                        setState(() {
                                          okay = value!;
                                          _claimCaptured = false;
                                        });

                                        // Clear claim data when switching from NOK
                                        if (widget.onClaimDataChanged != null) {
                                          widget.onClaimDataChanged!(null);
                                        }

                                        widget.onValueChanged(okay!);
                                      }
                                    },
                              activeColor: Colors.red,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                            ),
                            Text(
                              'NOK',
                              style: TextStyle(
                                // fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: (_scanningRequired &&
                                        (!_isScanned || !_scanMatched))
                                    ? Colors.grey.shade400
                                    : okay == "NOK"
                                        ? Colors.red.shade700
                                        : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                    ),
                    // Staff Number icon - tap to edit (disabled when answered)
                    GestureDetector(
                      onTap: widget.initialRadioValue != null
                          ? null
                          : () => _showStaffNumberDialog(),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: widget.initialRadioValue != null
                              ? Colors.grey.shade200 // Disabled state
                              : staffNoController.text.isNotEmpty
                                  ? Colors.blue.shade100
                                  : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                              color: widget.initialRadioValue != null
                                  ? Colors.grey.shade300 // Disabled border
                                  : staffNoController.text.isNotEmpty
                                      ? Colors.blue.shade300
                                      : Colors.grey.shade300,
                              width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.person,
                              color: widget.initialRadioValue != null
                                  ? Colors.grey.shade500 // Disabled icon
                                  : staffNoController.text.isNotEmpty
                                      ? Colors.blue.shade700
                                      : Colors.grey.shade600,
                              size: 16,
                            ),
                            if (staffNoController.text.isNotEmpty) ...[
                              const SizedBox(width: 4),
                              Text(
                                widget.initialRadioValue == null
                                    ? staffNoController.text
                                    : widget.initialStaffNo ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: widget.initialRadioValue != null
                                      ? Colors.grey.shade500 // Disabled text
                                      : Colors.blue.shade700,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Claim captured indicator
                if (_claimCaptured)
                  GestureDetector(
                    onTap: () async {
                      // Show issue dialog as bottom sheet for editing
                      final result =
                          await showModalBottomSheet<Map<String, dynamic>?>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => Container(
                          height: MediaQuery.of(context).size.height * 0.9,
                          child: IssueDialog(
                            initialDescription: _claimDescription,
                            initialPartNo: _claimPartNo,
                            initialCategory: _claimCategory,
                            initialType: _claimType,
                            initialClassification: _claimClassification,
                            initialImage: _claimImage,
                            lotNo: widget.lotNo,
                          ),
                        ),
                      );

                      if (result != null) {
                        // Initialize claim template
                        final claimTemplate = _initializeClaimTemplate();

                        // Merge template with updated data
                        final updatedClaimData = {
                          ...claimTemplate,
                          'issue_description': result['description'] ?? '',
                          'part_number': result['partNo'] ?? '',
                          'issue_category': result['category'],
                          'issue_type': result['type'],
                          'defect_classification': result['classification'],
                          'image': result['image'],
                          'updated_at': DateTime.now().toIso8601String(),
                        };

                        setState(() {
                          // Update stored claim data
                          _claimDescription = result['description'] ?? '';
                          _claimPartNo = result['partNo'] ?? '';
                          _claimCategory = result['category'];
                          _claimType = result['type'];
                          _claimClassification = result['classification'];
                          _claimImage = result['image'];
                        });

                        // Send updated claim data to parent via callback
                        if (widget.onClaimDataChanged != null) {
                          widget.onClaimDataChanged!(updatedClaimData);
                          print(
                              "Updated claim data sent to parent: $updatedClaimData");
                        }

                        // Claim updated successfully
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Claim updated successfully'),
                            backgroundColor: Colors.green,
                            duration: Duration(seconds: 2),
                          ),
                        );
                      }
                    },
                    child: Container(
                      margin: const EdgeInsets.only(top: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        border: Border.all(color: Colors.green.shade300),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            color: Colors.green.shade600,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Claim captured',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Warning message when scanning is required but not completed or doesn't match
                if (_scanningRequired && (!_isScanned || !_scanMatched))
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color:
                            (!_isScanned) ? Colors.orange[50] : Colors.red[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                            color: (!_isScanned)
                                ? Colors.orange[300]!
                                : Colors.red[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            (!_isScanned)
                                ? Icons.warning_amber_rounded
                                : Icons.error_outline,
                            color: (!_isScanned)
                                ? Colors.orange[700]
                                : Colors.red[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              (!_isScanned)
                                  ? 'Please scan the ${widget.parts_to_scan} first'
                                  : 'Scan result does not match. Please scan the correct ${widget.parts_to_scan} to answer this question.',
                              style: TextStyle(
                                fontSize: 12,
                                color: (!_isScanned)
                                    ? Colors.orange[700]
                                    : Colors.red[700],
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                // Description field for existing answers
                if (widget.initialRadioValue != null &&
                    widget.initialDecripValue != null &&
                    widget.initialDecripValue!.isNotEmpty)
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Text(
                          widget.initialDecripValue!,
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Signature section
                if (widget.can_sign == 'Yes' && widget.checkanswered == false)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      if (_signatureImage != null)
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.shade50,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: Colors.grey.shade200),
                          ),
                          child: Row(
                            children: [
                              Container(
                                height: 60,
                                width: 80,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.memory(
                                    _signatureImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Expanded(
                                child: Text(
                                  'Signature Captured',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.black87,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                              IconButton(
                                onPressed: () {
                                  setState(() {
                                    _signatureImage = null;
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red.shade600,
                                  size: 18,
                                ),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(
                                  minWidth: 30,
                                  minHeight: 30,
                                ),
                              ),
                            ],
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              showInDialog(
                                context,
                                builder: (context) => SignatureField(
                                  onSignatureChanged: (signature) async {
                                    setState(() {
                                      _signatureImage = signature;
                                    });
                                    String base64Image =
                                        'data:image/png;base64,' +
                                            base64Encode(_signatureImage!);
                                    widget.onValueChanged2(base64Image);
                                    Navigator.pop(context);
                                  },
                                ),
                                dialogAnimation:
                                    DialogAnimation.SLIDE_TOP_BOTTOM,
                              );
                            },
                            icon: Icon(
                              Icons.edit,
                              size: 16,
                              color: mycolor,
                            ),
                            label: const Text(
                              "Add Signature",
                              style: TextStyle(fontSize: 13),
                            ),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: mycolor,
                              side: BorderSide(color: mycolor),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),

                // Image display section
                if (okay == "NOK" ||
                    widget.initialImage != null ||
                    _image != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          // Captured image
                          if (_image != null)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              child: Stack(
                                alignment: Alignment.topRight,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                          color: Colors.grey.shade300),
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(6),
                                      child: Image.file(
                                        _image!,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    top: -8,
                                    right: -8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 14,
                                        ),
                                        onPressed: _deleteImage,
                                        padding: EdgeInsets.zero,
                                        constraints: const BoxConstraints(
                                          minWidth: 24,
                                          minHeight: 24,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          // Initial/existing image
                          if (widget.initialImage != null)
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(6),
                                child: CachedNetworkImage(
                                  imageUrl:
                                      "${Api.qc_image}${widget.initialImage}",
                                  width: 80,
                                  height: 80,
                                  fit: BoxFit.cover,
                                  placeholder: (context, url) => Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade100,
                                    child: const Center(
                                      child: CircularProgressIndicator(
                                          strokeWidth: 2),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.error,
                                        color: Colors.grey),
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),

                // Notify users section for NOK responses
                if (okay == "NOK" && widget.users.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                              color: Colors.orange.shade200, width: 1),
                        ),
                        child: Column(
                          children: [
                            // Compact header
                            InkWell(
                              onTap: () {
                                setState(() {
                                  _isNotifyUsersExpanded =
                                      !_isNotifyUsersExpanded;
                                });
                              },
                              borderRadius: BorderRadius.circular(8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 10),
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.orange.shade700,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Notify Users',
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.orange.shade700,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (selectedUsers.isNotEmpty)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade600,
                                          borderRadius:
                                              BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          '${selectedUsers.length}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    const Spacer(),
                                    Icon(
                                      _isNotifyUsersExpanded
                                          ? Icons.keyboard_arrow_up
                                          : Icons.keyboard_arrow_down,
                                      color: Colors.orange.shade600,
                                      size: 20,
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Expandable content
                            if (_isNotifyUsersExpanded)
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(8),
                                    bottomRight: Radius.circular(8),
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Select users to notify about this defect:',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    ...widget.users.map((user) {
                                      return Container(
                                        margin:
                                            const EdgeInsets.only(bottom: 2),
                                        decoration: BoxDecoration(
                                          color: selectedUsers
                                                  .contains(user['email'])
                                              ? Colors.orange.shade50
                                              : Colors.transparent,
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          border: Border.all(
                                            color: selectedUsers
                                                    .contains(user['email'])
                                                ? Colors.orange.shade200
                                                : Colors.transparent,
                                          ),
                                        ),
                                        child: CheckboxListTile(
                                          title: Text(
                                            user['name']!,
                                            style:
                                                const TextStyle(fontSize: 12),
                                          ),
                                          subtitle: Text(
                                            user['email']!,
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey.shade600,
                                            ),
                                          ),
                                          value: selectedUsers
                                              .contains(user['email']),
                                          onChanged: (bool? value) {
                                            setState(() {
                                              if (value == true) {
                                                selectedUsers
                                                    .add(user['email']!);
                                              } else {
                                                selectedUsers
                                                    .remove(user['email']!);
                                              }
                                              widget.onUsersSelected(
                                                  selectedUsers);
                                            });
                                          },
                                          dense: true,
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 8),
                                          controlAffinity:
                                              ListTileControlAffinity.leading,
                                          activeColor: Colors.orange.shade600,
                                        ),
                                      );
                                    }).toList(),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
