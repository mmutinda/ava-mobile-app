import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class MultipleQuestion extends StatefulWidget {
  final int id;
  final int index;
  final options;
  final intial_option;
  final can_sign;
  final checkanswered;
  final String? initialRadioValue;
  final String? initialImage;
  // final List options;
  final String question;
  final String? instruction; // Add instruction parameter
  final String? initialDecripValue; // Add description parameter
  final String? hasDescription; // Add hasDescription parameter
  final String? initialDefectCategory; // Add defect category parameter
  final ValueChanged<String>?
      onDefectCategoryChanged; // Add defect category callback
  final List<Map<String, String>> users; // List of users with name and email
  final ValueChanged<List<dynamic>> onValuesChanged;
  final ValueChanged<String> onRadioChanged;
  final ValueChanged<String> onInputValueChanged; // Add description callback
  final ValueChanged<String> onValueChanged2;
  final ValueChanged<File?> onImageChanged; // Allow null for deletion
  final ValueChanged<List<String>> onUsersSelected;
  final String? parts_to_scan; // Add parts scanning parameter
  final dynamic
      scandata; // Add scandata parameter for comparison (can be String or Map)
  const MultipleQuestion({
    Key? key,
    required this.id,
    required this.index,
    required this.onUsersSelected,
    // required this.options,
    required this.question,
    required this.onValuesChanged,
    required this.onRadioChanged,
    required this.onInputValueChanged, // Add description callback
    this.options,
    this.can_sign,
    this.checkanswered,
    required this.onValueChanged2,
    this.initialRadioValue,
    this.initialDecripValue, // Add description parameter
    this.hasDescription, // Add hasDescription parameter
    this.initialDefectCategory, // Add defect category parameter
    this.onDefectCategoryChanged, // Add defect category callback
    required this.users,
    required this.onImageChanged,
    required this.initialImage,
    required this.intial_option,
    this.instruction, // Add instruction parameter
    this.parts_to_scan, // Add parts scanning parameter
    this.scandata, // Add scandata parameter for comparison
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MultipleQuestionState createState() => _MultipleQuestionState();
}

class _MultipleQuestionState extends State<MultipleQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  File? _image; // Holds the captured image
  List<dynamic> selectedValues = [];
  late TextEditingController inputController; // Description input controller
  Uint8List? _signatureImage;
  bool _isInstructionExpanded = false; // Track instruction expansion state
  bool _isNotifyUsersExpanded = false; // Track notify users expansion state
  String? selectedDefectCategory; // Track selected defect category
  bool _isScanned = false; // Track if scanning is completed
  String? _scannedData; // Store scanned data
  bool _scanningRequired = false; // Track if scanning is required

  // Defect categories data
  final List<Map<String, String>> defectCategories = [
    {"name": "A-Critical", "classification": "A"},
    {"name": "B- Major", "classification": "B"},
    {"name": "C-Minor", "classification": "C"},
    {"name": "D-Cosmetic", "classification": "D"},
  ];

  @override
  void initState() {
    super.initState();
    inputController = TextEditingController(text: widget.initialDecripValue);
    inputController.addListener(_handleValueChanged);
    selectedDefectCategory =
        widget.initialDefectCategory; // Initialize defect category

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
            widget.onRadioChanged("OK");
          } else {
            okay = "NOK";
            widget.onRadioChanged("NOK");
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

  void _deleteImage() {
    print("Deleting image...");
    setState(() {
      _image = null; // Set image to null when deleting
    });

    // Pass null to onImageChanged to indicate deletion
    widget.onImageChanged(null);

    print("Image deleted, _image is now: $_image");
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    print(widget.intial_option);
    List<String> indexedNames = [];
    for (int index = 0; index < widget.options.length; index++) {
      indexedNames.add("${widget.options[index]}");
    }

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
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200, width: 1),
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
                            onPressed: _startScanning,
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
                                            .onRadioChanged(""); // Reset value
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
                                    widget.onRadioChanged(""); // Reset value
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
                  children: [
                    const Text(
                      'Answer:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(width: 12),
                    // OK Radio
                    Container(
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
                                      selectedValues =
                                          []; // Clear selected values when changing the radio option
                                      selectedDefectCategory = null;
                                      widget.onRadioChanged(okay!);
                                    });
                                  },
                            activeColor: Colors.green,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          Text(
                            'OK',
                            style: TextStyle(
                              fontSize: 14,
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
                    const SizedBox(width: 12),
                    // NOK Radio
                    Container(
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
                                : (value) {
                                    setState(() {
                                      okay = value!;
                                    });
                                    widget.onRadioChanged(okay!);
                                  },
                            activeColor: Colors.red,
                            materialTapTargetSize:
                                MaterialTapTargetSize.shrinkWrap,
                            visualDensity: VisualDensity.compact,
                          ),
                          Text(
                            'NOK',
                            style: TextStyle(
                              fontSize: 14,
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
                    const Spacer(),
                    // Camera button
                    if (widget.initialRadioValue == null &&
                        widget.initialImage == null &&
                        okay == "NOK")
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.blue.shade200),
                        ),
                        child: IconButton(
                          onPressed: _captureImage,
                          icon: Icon(
                            Icons.camera_alt,
                            color: Colors.blue.shade700,
                            size: 20,
                          ),
                          tooltip: 'Capture Photo',
                          padding: const EdgeInsets.all(8),
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                        ),
                      ),
                  ],
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

                const SizedBox(height: 12),

                // Defect category selection for NOK responses
                if (widget.initialRadioValue == null && okay == "NOK")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Defect Category *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: DropdownButtonFormField<String>(
                          value: selectedDefectCategory,
                          decoration: InputDecoration(
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 10,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(6),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.red.shade50,
                            hintText: 'Select defect category',
                            hintStyle: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 14,
                            ),
                          ),
                          items: defectCategories.map((category) {
                            return DropdownMenuItem<String>(
                              value: category['classification'],
                              child: Text(
                                category['name']!,
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDefectCategory = newValue;
                            });
                            if (newValue != null &&
                                widget.onDefectCategoryChanged != null) {
                              widget.onDefectCategoryChanged!(newValue);
                            }
                          },
                          dropdownColor: Colors.white,
                          icon: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.red.shade600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Display existing defect category for answered questions
                if (widget.initialRadioValue != null &&
                    widget.initialDefectCategory != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Defect Category:',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              defectCategories.firstWhere(
                                    (cat) =>
                                        cat['classification'] ==
                                        widget.initialDefectCategory,
                                    orElse: () => {
                                      'name': widget.initialDefectCategory ?? ''
                                    },
                                  )['name'] ??
                                  widget.initialDefectCategory ??
                                  '',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                    ],
                  ),

                // Defects selection for NOK responses
                if (okay == "NOK")
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: MultiSelectDialogField(
                      dialogHeight: 250,
                      items: indexedNames
                          .map((name) => MultiSelectItem<String>(name, name))
                          .toList(),
                      title: const Text(
                        "Select Defects",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      selectedColor: Colors.red.shade600,
                      checkColor: Colors.white,
                      buttonText: Text(
                        selectedValues.isEmpty
                            ? "Select Defects"
                            : "${selectedValues.length} Defect(s) Selected",
                        style: TextStyle(
                          color: selectedValues.isEmpty
                              ? Colors.grey.shade600
                              : Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.transparent),
                        color: Colors.red.shade50,
                      ),
                      searchable: true,
                      searchHint: "Search defects...",
                      buttonIcon: Icon(
                        Icons.arrow_drop_down,
                        color: Colors.red.shade600,
                      ),
                      onConfirm: (results) {
                        setState(() {
                          selectedValues = results;
                        });
                        widget.onValuesChanged(selectedValues);
                      },
                    ),
                  ),

                // Description field for existing answers
                if (widget.initialRadioValue != null &&
                    widget.initialDecripValue != null)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
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

                // Description field for NOK responses
                if (okay == "NOK")
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      TextFormField(
                        maxLines: null,
                        controller: inputController,
                        style: const TextStyle(fontSize: 14),
                        decoration: InputDecoration(
                          labelText: 'Issue Description *',
                          hintText: 'Describe the problem in detail...',
                          hintStyle: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                          ),
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.red.shade300),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.red.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: Colors.red.shade400, width: 2),
                          ),
                          filled: false,
                          fillColor: Colors.red.shade50,
                          labelStyle: TextStyle(
                            color: Colors.red.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),

                // Display initial options (existing answers)
                if (widget.intial_option.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Selected Defects:",
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Wrap(
                              children: List.generate(
                                widget.intial_option.length,
                                (index) => Container(
                                  margin: const EdgeInsets.only(
                                      right: 8, bottom: 4),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    borderRadius: BorderRadius.circular(12),
                                    border:
                                        Border.all(color: Colors.red.shade200),
                                  ),
                                  child: Text(
                                    "${index + 1}. ${widget.intial_option[index]}",
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.red.shade700,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
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
                                      "${"Api.qc_image"}${widget.initialImage}",
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
