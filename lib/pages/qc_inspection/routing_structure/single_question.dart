import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class SingleQuestion extends StatefulWidget {
  final int id;
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
  const SingleQuestion(
      {super.key,
      required this.id,
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
      this.instruction}); // Add instruction parameter

  @override
  State<SingleQuestion> createState() => _SingleQuestionState();
}

class _SingleQuestionState extends State<SingleQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  Uint8List? _signatureImage;
  late TextEditingController inputController;
  File? _image; // Holds the captured image
  bool _isInstructionExpanded = false; // Track instruction expansion state
  bool _isNotifyUsersExpanded = false; // Track notify users expansion state
  String? selectedDefectCategory; // Track selected defect category
  bool _isScanned = false; // Track if scanning is completed
  String? _scannedData; // Store scanned data
  bool _scanningRequired = false; // Track if scanning is required
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

  // Defect categories data
  final List<Map<String, String>> defectCategories = [
    {"name": "A-Critical", "classification": "A"},
    {"name": "B- Major", "classification": "B"},
    {"name": "C-Minor", "classification": "C"},
    {"name": "D-Cosmetic", "classification": "D"},
  ];

  @override
  bool get wantKeepAlive => true;

  // Helper method to validate defect category
  String? _validateDefectCategory(String? category) {
    if (category == null) return null;

    // Check if the category exists in our defectCategories list
    bool exists =
        defectCategories.any((cat) => cat['classification'] == category);
    return exists ? category : null;
  }

  @override
  void initState() {
    super.initState();
    inputController = TextEditingController(text: widget.initialDecripValue);
    inputController.addListener(_handleValueChanged);

    // Validate and set initial defect category
    selectedDefectCategory =
        _validateDefectCategory(widget.initialDefectCategory);

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
    super.dispose();
  }

  void _handleValueChanged() {
    widget.onInputValueChanged(inputController.text);
  }

  void _handleImageChanged() {
    widget.onImageChanged(_image!);
  }

  /// Capture image from camera
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

          if (_scannedData == expectedData) {
            okay = "OK";
            widget.onValueChanged("OK");
          } else {
            // okay = "NOK";
            // widget.onValueChanged("NOK");
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

                    if (_scannedData == expectedData) {
                      okay = "OK";
                      widget.onValueChanged("OK");
                    } else {
                      // okay = "NOK";
                      // widget.onValueChanged("NOK");
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
                            color: Colors.green[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.green[300]!),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Scan Completed',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.green[800],
                                      ),
                                    ),
                                    Text(
                                      'Scanned: $_scannedData',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _isScanned = false;
                                          _scannedData = null;
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

                // Radio buttons - compact horizontal layout
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const Text(
                      'Answer:',
                      style: TextStyle(
                        // fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // OK Radio
                    GestureDetector(
                      onTap: (widget.initialRadioValue != null ||
                              (_scanningRequired))
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
                                      (_scanningRequired))
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
                                color: (_scanningRequired)
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
                              (_scanningRequired))
                          ? null
                          : () async {
                              // Initialize claim template
                              final claimTemplate = _initializeClaimTemplate();

                              // Show issue dialog with initialized template
                              final result =
                                  await showDialog<Map<String, dynamic>?>(
                                context: context,
                                barrierDismissible: true,
                                builder: (context) => IssueDialog(
                                  initialDescription: _claimDescription,
                                  initialPartNo: _claimPartNo,
                                  initialCategory: _claimCategory,
                                  initialType: _claimType,
                                  initialClassification: _claimClassification,
                                  initialImage: _claimImage,
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
                                      (_scanningRequired))
                                  ? null
                                  : (value) async {
                                      if (value == "NOK") {
                                        // Initialize claim template
                                        final claimTemplate =
                                            _initializeClaimTemplate();

                                        // Show issue dialog with initialized template
                                        final result = await showDialog<
                                            Map<String, dynamic>?>(
                                          context: context,
                                          barrierDismissible: true,
                                          builder: (context) => IssueDialog(
                                            initialDescription:
                                                _claimDescription,
                                            initialPartNo: _claimPartNo,
                                            initialCategory: _claimCategory,
                                            initialType: _claimType,
                                            initialClassification:
                                                _claimClassification,
                                            initialImage: _claimImage,
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
                                color: (_scanningRequired)
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
                  ],
                ),

                // Claim captured indicator
                if (_claimCaptured)
                  GestureDetector(
                    onTap: () async {
                      // Show issue dialog for editing
                      final result = await showDialog<Map<String, dynamic>?>(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) => IssueDialog(
                          initialDescription: _claimDescription,
                          initialPartNo: _claimPartNo,
                          initialCategory: _claimCategory,
                          initialType: _claimType,
                          initialClassification: _claimClassification,
                          initialImage: _claimImage,
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

                // Warning message when scanning is required but not completed
                if (_scanningRequired && !_isScanned)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.orange[300]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.orange[700],
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please scan the ${widget.parts_to_scan} first',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange[700],
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
                    widget.initialDecripValue != null)
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

class IssueDialog extends StatefulWidget {
  final String? initialDescription;
  final String? initialPartNo;
  final String? initialCategory;
  final String? initialType;
  final String? initialClassification;
  final File? initialImage;

  const IssueDialog({
    Key? key,
    this.initialDescription,
    this.initialPartNo,
    this.initialCategory,
    this.initialType,
    this.initialClassification,
    this.initialImage,
  }) : super(key: key);

  @override
  State<IssueDialog> createState() => _IssueDialogState();
}

class _IssueDialogState extends State<IssueDialog>
    with SingleTickerProviderStateMixin {
  final _issueDescriptionController = TextEditingController();
  final _partNoController = TextEditingController();
  File? _imageFile;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  bool _isSubmitting = false; // Add loading state

  String? _selectedIssueCategory;
  String? _selectedIssueType;
  String? _selectedDefectClassification;

  final List<String> _issueCategories = [
    'Process Issues',
    'Part Handling',
    'Paint Issues',
    'KDQR',
    'MMO',
  ];

  final Map<String, List<String>> _issueCategoriesAndTypes = {
    'Process Issues': [
      'LOOSE PART',
      'MISALIGNED PARTS',
      'EXCESS/LESS WORKING FLUIDS',
      'WRONG ROUTING',
      'POORLY FITTED PART',
      'MISSING INSPECTION MARKS',
      'MISSING DOCUMENTS',
      'INCOMPLETE PROCESS',
      'LESS PRESSURE',
      'TEMPORALY FITTED PART',
      'ABS LIGHT ON',
      'PART NOT FITTED',
      'ALTERNATIVE PART',
      'OVER TORQUE',
      'INCOMPLETE WELDS',
      'MISSING PART',
      'DAMAGED PART',
      'WARNING LIGHT',
      'WRONG PART FITTED',
      'LARGE GAPS',
      'WELD SPOTS',
      'WRONG DOCUMENTATION',
      'POROSITY',
      'UNDER TORQUE',
      'WELD UNDERCUTS',
      'POOR PUNCHING',
      'Jig Missing',
      'ROBBED',
      'FAULTY MACHINE',
    ],
    'Part Handling': [
      'SCRATCHES',
      'DENTS',
      'DIRT MARKS',
      'STRAY MARKS',
      'STAIN MARKS',
    ],
    'Paint Issues': [
      'DEBRIS',
      'OVERFLOW',
      'PINHOLES',
      'ORANGE PEELS',
      'COLOUR MISMATCH',
      'PAINT BLISS',
      'LESS PAINT',
      'PAINT BARE AREA',
      'PVC PEEL OFF',
      'PAINT OVERSPRAY',
      'DRY PAINT',
      'PAINT PEEL OFF',
      'POORLY PAINTED',
      'DAMAGED SEALER',
      'DAMAGED PVC',
      'PVC OVERSPRAY',
      'WET PAINT',
    ],
    'KDQR': [
      'PART QUALITY',
      'WS-WRONG SHIPMENT',
      'SS-SHORT SHIPMENT',
      'PROGRAMMING/SERVER',
      'FAULTY PART',
      'SCRATCHES',
      'DEBRIS',
      'ME-MANUFACTURER ERROR',
      'WRONG PART',
      'NS-NOT SUPPLIED',
    ],
    'MMO': [
      'LD-LINE DAMAGE',
      'LL-LINE LOSS',
      'RUST',
    ],
  };

  final List<String> _defectClassifications = [
    'A-Critical',
    'B- Major',
    'C-Minor',
    'D-Cosmetic',
  ];

  @override
  void initState() {
    super.initState();

    // Initialize with provided data
    _issueDescriptionController.text = widget.initialDescription ?? '';
    _partNoController.text = widget.initialPartNo ?? '';
    _selectedIssueCategory = widget.initialCategory;
    _selectedIssueType = widget.initialType;
    _selectedDefectClassification = widget.initialClassification;
    _imageFile = widget.initialImage;

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _partNoController.dispose();
    _issueDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
        onWillPop: () async {
          // Allow back button to work unless submitting
          return !_isSubmitting;
        },
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              elevation: 8,
              backgroundColor: Colors.white,
              contentPadding: EdgeInsets.zero,
              content: SingleChildScrollView(
                child: Container(
                  width: double.maxFinite,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Simple header
                      Container(
                        width: double.infinity,
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
                            Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Report Issue',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Content area
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildSimpleTextField(
                              controller: _issueDescriptionController,
                              label: 'Issue Description',
                              hint: 'Describe the issue',
                              maxLines: 3,
                            ),
                            SizedBox(height: 16),
                            _buildSimpleTextField(
                              controller: _partNoController,
                              label: 'Part Number',
                              hint: 'Enter part number',
                            ),
                            SizedBox(height: 16),
                            _buildSimpleDropdown(
                              label: 'Issue Category',
                              value: _selectedIssueCategory,
                              items: _issueCategories,
                              onChanged: (value) {
                                setState(() {
                                  _selectedIssueCategory = value;
                                  _selectedIssueType = null;
                                });
                              },
                            ),
                            if (_selectedIssueCategory != null) ...[
                              SizedBox(height: 16),
                              _buildSimpleDropdown(
                                label: 'Issue Type',
                                value: _selectedIssueType,
                                items: _issueCategoriesAndTypes[
                                        _selectedIssueCategory] ??
                                    [],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedIssueType = value;
                                  });
                                },
                              ),
                            ],
                            SizedBox(height: 16),
                            _buildSimpleDropdown(
                              label: 'Classification',
                              value: _selectedDefectClassification,
                              items: _defectClassifications,
                              onChanged: (value) {
                                setState(() {
                                  _selectedDefectClassification = value;
                                });
                              },
                            ),

                            SizedBox(height: 20),

                            // Camera button
                            Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: mycolor),
                              ),
                              child: TextButton.icon(
                                onPressed: _pickImage,
                                icon: Icon(Icons.camera_alt, color: mycolor),
                                label: Text(
                                  'Take Picture',
                                  style: TextStyle(
                                    color: mycolor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 12),
                                ),
                              ),
                            ),

                            // Image preview
                            if (_imageFile != null)
                              Container(
                                margin: const EdgeInsets.only(top: 12),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: Image.file(
                                    _imageFile!,
                                    height: 120,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),

                            const SizedBox(height: 24),

                            // Action buttons
                            Row(
                              children: [
                                Expanded(
                                  child: TextButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => Navigator.pop(context, null),
                                    style: TextButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        side: BorderSide(
                                            color: _isSubmitting
                                                ? Colors.grey.shade300
                                                : Colors.grey.shade400),
                                      ),
                                    ),
                                    child: Text(
                                      'Cancel',
                                      style: TextStyle(
                                        color: _isSubmitting
                                            ? Colors.grey.shade400
                                            : Colors.grey.shade600,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: _isSubmitting
                                        ? null
                                        : () => _submitForm(context),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor:
                                          _isSubmitting ? Colors.grey : mycolor,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    child: _isSubmitting
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Submit',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ));
  }

  Widget _buildSimpleTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: mycolor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildSimpleDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            hintText: 'Select $label',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: mycolor, width: 2),
            ),
            filled: true,
            fillColor: Colors.grey.shade50,
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => _imageFile = File(image.path));
    }
  }

  void _submitForm(BuildContext context) async {
    // Prevent multiple submissions
    if (_isSubmitting) return;

    // Basic validation
    if (_issueDescriptionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter issue description'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Set loading state
    setState(() {
      _isSubmitting = true;
    });

    try {
      // Simulate processing delay (you can remove this in production)
      await Future.delayed(Duration(milliseconds: 500));

      // Return claim data to indicate successful submission
      final claimData = {
        'description': _issueDescriptionController.text.trim(),
        'partNo': _partNoController.text.trim(),
        'category': _selectedIssueCategory,
        'type': _selectedIssueType,
        'classification': _selectedDefectClassification,
        'image': _imageFile,
      };

      Navigator.pop(context, claimData);
    } catch (e) {
      // Reset loading state on error
      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error submitting claim. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
