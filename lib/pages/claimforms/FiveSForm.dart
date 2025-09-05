import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class FiveSAuditPage extends StatefulWidget {
  @override
  _FiveSAuditPageState createState() => _FiveSAuditPageState();
}

class _FiveSAuditPageState extends State<FiveSAuditPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, int?> scores = {};
  final Map<String, TextEditingController> comments = {};
  final Map<String, List<File>> questionImages =
      {}; // Store images for each question
  final ImagePicker _picker = ImagePicker();
  final _sectionController = TextEditingController();
  final _authorController = TextEditingController();
  final _dateController = TextEditingController();
  final _creationDateController = TextEditingController();
  final _documentRefController = TextEditingController();
  final _revisionController = TextEditingController();

  // Predefined sections list
  final List<String> predefinedSections = [
    'TRAINING ACADEMY',
    'AVA DISPENSARY',
    'LOGISTICS BAY 1',
    'MAIN GATE AND PARKING',
    'MEN\'S CHANGING ROOM',
    'END OF LINE',
    'LOGISTICS BAY 3',
    'ADMIN OFFICE, CANTEEN & SURROUNDING AREA',
    'CONSUMABLES STORE & PAINT STORE',
    'TOOLS STORE',
    'OPERATIONS OFFICE',
    'SPRAY BOOTH 2, OVEN AND WETDECK',
    'CARPENTRY',
    'LADIES\' CHANGING ROOM',
    'MV TRAINING ROOM',
    'PAINTSHOP: PRECLEANING + UNDERBODY BOOTH 1',
    'MAINTENANCE, ENGINEERING, GENERATOR & COMPRESSOR AREA',
    'CONFERENCE ROOM',
    'LINE 3',
    'BODY CONVERSION AREA',
    'LOGISTICS BAY 2',
    'CAB TRIM LINE 2 AND BURNTWOOD',
    'CAB TRIM LINE 1 & BATTERY STORAGE',
    'COOLANT STORAGE AND SHOWER TEST AREA',
    'LINE 1',
    'LINE 2',
    'CAB TRIM LINE 3 & PILOT AREA',
    'BUS PROJECT AREA',
    'GAS STORAGE AREA',
    'BODYSHOP - JIGSHOP AND METAL LINE',
    'CHASSIS RIVET BAY 1, 2 & 3',
    'SPRAY BOOTH 4 AND SURROUNDING',
    'NEW LOGISTICS YARD',
    'TUKTUK ASSEMBLY',
    'JIG AND TROLLEY AREA',
    'CHASSIS AND TIPPER PAINTING AREA',
    'BODYSHOP - TIPPER',
    'OTHER',
  ];

  String? selectedSection;

  Map<String, bool> _questionDescriptionExpanded = {};
  Map<String, bool> _questionCommentExpanded = {};
  List<dynamic> dynamicSections = [];
  Map<String, List<dynamic>> dynamicQuestions = {};
  bool isLoading = true;
  String errorMessage = '';
  var user = {};
  bool _documentInfoCompleted = false;

  @override
  void initState() {
    super.initState();
    //getting user data from shared preferences
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      // Load 5S settings after getting user data
      _loadFiveSSettings().then((_) {
        // Show document information dialog after data is loaded
        if (!errorMessage.isNotEmpty && !isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _showDocumentInformationDialog();
          });
        }
      });
    });
  }

  Future<void> _loadFiveSSettings() async {
    try {
      setState(() {
        isLoading = true;
        errorMessage = '';
      });

      final response = await http.get(
        Uri.parse('${Api.api_url}loadFiveSSettings'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${user['data']['token']}',
        },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body);

        if (responseBody['success'] == true) {
          final List<dynamic> sections = responseBody['data'];

          setState(() {
            dynamicSections = sections;
            dynamicQuestions.clear();
            scores.clear();
            comments.clear();
            _questionDescriptionExpanded.clear();
            _questionCommentExpanded.clear();

            // Initialize scores and comments for each question
            for (var section in sections) {
              String sectionName = section['name'];
              List<dynamic> items = section['items'] ?? [];

              dynamicQuestions[sectionName] = items;

              for (var item in items) {
                String questionText = item['item_name'];
                scores[questionText] = null;
                comments[questionText] = TextEditingController();
                questionImages[questionText] =
                    []; // Initialize empty image list
                _questionDescriptionExpanded[questionText] = false;
                _questionCommentExpanded[questionText] = false;
              }
            }

            isLoading = false;
          });
        } else {
          setState(() {
            errorMessage = responseBody['msg'] ?? 'Failed to load 5S settings';
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to load 5S settings';
          isLoading = false;
        });
      }
    } on SocketException {
      setState(() {
        errorMessage = 'No Internet connection';
        isLoading = false;
      });
    } on TimeoutException {
      setState(() {
        errorMessage = 'Request timed out';
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        errorMessage = 'Error: ${e.toString()}';
        isLoading = false;
      });
    }
  }

  Future<void> _showDocumentInformationDialog() async {
    // Add a small delay to ensure everything is loaded
    await Future.delayed(Duration(milliseconds: 500));

    // Pre-fill some default values
    final now = DateTime.now();
    _dateController.text =
        "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
    _creationDateController.text = '15/09/2023';
    _documentRefController.text = 'AVA.SHE.D.013';
    _revisionController.text = '1';

    // Pre-fill auditor name from user data if available
    // if (user['data'] != null && user['data']['name'] != null) {
    //   _authorController.text = user['data']['name'];
    // }

    if (!context.mounted) return;

    // Show document information dialog
    bool? result = await showDialog<bool>(
      context: context,
      barrierDismissible: true, // Allow dismissing the dialog
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
            builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                Icon(Icons.description, color: mycolor),
                SizedBox(width: 8),
                Expanded(child: Text('Document Information')),
                IconButton(
                  onPressed: () => Navigator.of(dialogContext).pop(false),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            content: Container(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildDialogHeaderField(
                      Icons.calendar_today,
                      'Document Creation Date',
                      _creationDateController,
                      isDate: true,
                    ),
                    _buildDialogHeaderField(
                      Icons.description,
                      'Document Ref',
                      _documentRefController,
                    ),
                    _buildDialogHeaderField(
                      Icons.history_edu,
                      'Revision',
                      _revisionController,
                    ),
                    SizedBox(height: 12),
                    _buildSectionDropdown(),
                    _buildDialogHeaderField(
                      Icons.person,
                      'Auditee',
                      _authorController,
                    ),
                    _buildDialogHeaderField(
                      Icons.date_range,
                      'Date',
                      _dateController,
                      isDate: true,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(false),
                child: Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  // Validate the form
                  if (_validateDocumentForm()) {
                    Navigator.of(dialogContext).pop(true);
                  }
                },
                style: ElevatedButton.styleFrom(backgroundColor: mycolor),
                child: Text('Continue', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        });
      },
    );

    if (result == true) {
      setState(() {
        _documentInfoCompleted = true;
      });
      _showSuccessMessage();
    }
  }

  bool _validateDocumentForm() {
    List<String> missingFields = [];

    if (selectedSection == null || selectedSection!.trim().isEmpty)
      missingFields.add('Section');
    if (_authorController.text.trim().isEmpty) missingFields.add('Auditor');
    if (_dateController.text.trim().isEmpty) missingFields.add('Date');
    if (_creationDateController.text.trim().isEmpty)
      missingFields.add('Document Creation Date');
    if (_documentRefController.text.trim().isEmpty)
      missingFields.add('Document Ref');
    if (_revisionController.text.trim().isEmpty) missingFields.add('Revision');

    if (missingFields.isNotEmpty) {
      showError(
          'Please fill in all required fields:\n${missingFields.join('\n')}');
      return false;
    }

    return true;
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white, size: 20),
            SizedBox(width: 8),
            Text(
                'Document Information completed! You can now proceed with the audit checklist.'),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.all(16),
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Image capture methods
  Future<void> _captureImageFromCamera(String question) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        File imageFile = File(image.path);
        setState(() {
          // Replace existing image with new one (only one photo allowed)
          questionImages[question] = [imageFile];
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Image added successfully!'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to capture image: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildDialogHeaderField(
    IconData icon,
    String label,
    TextEditingController controller, {
    bool isDate = false,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        enabled: controller == _creationDateController ||
                controller == _documentRefController
            ? false
            : true,
        controller: controller,
        readOnly: isDate,
        onTap: isDate
            ? () async {
                DateTime? picked = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                );
                if (picked != null) {
                  controller.text =
                      "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
                }
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: mycolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: mycolor, size: 18),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mycolor, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildSectionDropdown() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: selectedSection,
        decoration: InputDecoration(
          labelText: 'Section',
          prefixIcon: Container(
            margin: EdgeInsets.all(8),
            padding: EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: mycolor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(Icons.article, color: mycolor, size: 18),
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: mycolor, width: 2),
            borderRadius: BorderRadius.circular(10),
          ),
          labelStyle: TextStyle(
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
        items: predefinedSections.map((String section) {
          return DropdownMenuItem<String>(
            value: section,
            child: Text(
              section,
              style: TextStyle(fontSize: 14),
            ),
          );
        }).toList(),
        onChanged: (String? value) {
          setState(() {
            selectedSection = value;
            _sectionController.text = value ?? '';
          });
        },
        validator: (value) =>
            value == null || value.isEmpty ? 'Please select a section' : null,
        isExpanded: true,
        icon: Icon(Icons.keyboard_arrow_down, color: mycolor),
        dropdownColor: Colors.white,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 14,
        ),
        menuMaxHeight: 300,
      ),
    );
  }

  Widget _buildQuestion(String question, {String description = ''}) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.white, Colors.white.withOpacity(0.5)],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: mycolor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(Icons.help_outline, color: mycolor, size: 16),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    question,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                      fontSize: 15,
                    ),
                  ),
                ),
              ],
            ),

            if (description.isNotEmpty)
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
                          _questionDescriptionExpanded[question] =
                              !(_questionDescriptionExpanded[question] ??
                                  false);
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
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Instructions',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade700,
                                    ),
                                  ),
                                  if (!(_questionDescriptionExpanded[
                                              question] ??
                                          false) &&
                                      description.length > 50)
                                    Text(
                                      '${description.substring(0, 50)}...',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.blue.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            const Spacer(),
                            Icon(
                              (_questionDescriptionExpanded[question] ?? false)
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
                    if (_questionDescriptionExpanded[question] ?? false)
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
                            // Regular text instruction
                            Text(
                              description,
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
            SizedBox(height: 16),
            // Radio buttons for OK/NOK selection
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Text(
                        'Answer:',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 12),
                      // OK Radio
                      Container(
                        decoration: BoxDecoration(
                          color: scores[question] == 1
                              ? Colors.green.shade50
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: scores[question] == 1
                                ? Colors.green.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<int>(
                              value: 1,
                              groupValue: scores[question],
                              onChanged: (value) {
                                setState(() {
                                  scores[question] = value!;
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
                                fontWeight: FontWeight.w500,
                                color: scores[question] == 1
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
                          color: scores[question] == 0
                              ? Colors.red.shade50
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: scores[question] == 0
                                ? Colors.red.shade300
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Radio<int>(
                              value: 0,
                              groupValue: scores[question],
                              onChanged: (value) {
                                setState(() {
                                  scores[question] = value!;
                                });
                              },
                              activeColor: Colors.red,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              visualDensity: VisualDensity.compact,
                            ),
                            Text(
                              'NOK',
                              style: TextStyle(
                                fontWeight: FontWeight.w500,
                                color: scores[question] == 0
                                    ? Colors.red.shade700
                                    : Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                          ],
                        ),
                      ),
                      const Spacer(),
                      if (scores[question] == 0) ...[
                        if (questionImages[question] == null ||
                            questionImages[question]!.isEmpty)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: Colors.blue.shade200),
                            ),
                            child: IconButton(
                              onPressed: () =>
                                  _captureImageFromCamera(question),
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
                        if (questionImages[question] != null &&
                            questionImages[question]!.isNotEmpty)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                  color: Colors.green.shade300, width: 2),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: InkWell(
                              onTap: () => _captureImageFromCamera(question),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: Image.file(
                                  questionImages[question]![0],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          ),
                      ]
                    ],
                  ),
                ],
              ),
            ),

            // Image capture section for NOK selections

            SizedBox(height: 12),
            // Expandable comment section
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Comment header - always visible
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border:
                          Border.all(color: Colors.orange.shade200, width: 1),
                    ),
                    child: InkWell(
                      onTap: () {
                        setState(() {
                          _questionCommentExpanded[question] =
                              !(_questionCommentExpanded[question] ?? false);
                        });
                      },
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        child: Row(
                          children: [
                            Icon(
                              Icons.comment_outlined,
                              // color: Colors.orange.shade700,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Comments',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      // color: Colors.orange.shade700,
                                    ),
                                  ),
                                  if (!(_questionCommentExpanded[question] ??
                                          false) &&
                                      comments[question]?.text.isNotEmpty ==
                                          true &&
                                      comments[question]!.text.length > 30)
                                    Text(
                                      '${comments[question]!.text.substring(0, 30)}...',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.orange.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (comments[question]?.text.isNotEmpty == true)
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                padding: EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.orange.shade200,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Has comment',
                                  style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.orange.shade800,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            const Spacer(),
                            Icon(
                              (_questionCommentExpanded[question] ?? false)
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              color: Colors.orange.shade600,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Expandable comment field
                  if (_questionCommentExpanded[question] ?? false)
                    AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                      margin: EdgeInsets.only(top: 8),
                      child: TextFormField(
                        controller: comments[question],
                        decoration: InputDecoration(
                          labelText: 'Comments (Optional)',
                          prefixIcon: Icon(Icons.comment, color: mycolor),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: scores[question] == 0
                                    ? Colors.orange.shade300
                                    : Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                                color: scores[question] == 0
                                    ? Colors.orange
                                    : mycolor,
                                width: 2),
                          ),
                          alignLabelWithHint: true,
                        ),
                        maxLines: null, // Makes it expandable
                        minLines: 3, // Start with multiple lines when expanded
                        keyboardType: TextInputType.multiline,
                        textInputAction: TextInputAction.newline,
                        onChanged: (value) {
                          // Trigger rebuild to show/hide indicator
                          setState(() {});
                        },
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

  Widget _buildSection(String title, List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 24),
        Container(
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Icon(Icons.checklist, size: 18),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    // color: Colors.white,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${items.length} items',
                  style: TextStyle(
                    // color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 3),
        for (var item in items)
          _buildQuestion(item['item_name'] ?? '',
              description: item['description'] ?? ''),
      ],
    );
  }

  void handleSuccess() {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        content: Text('Record saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
  }

  void showError(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: color,
      ),
    );
  }

  void _submitForm() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Validate radio button selections and NOK comments
    List<String> unselectedQuestions = [];
    List<String> nokWithoutComments = [];
    List<String> nokWithoutImages = [];

    dynamicQuestions.forEach((section, items) {
      for (var item in items) {
        final question = item['item_name'];
        if (scores[question] == null) {
          unselectedQuestions.add(question);
        } else if (scores[question] == 0) {
          // Check if NOK items have comments
          final comment = comments[question]?.text.trim() ?? '';
          if (comment.isEmpty) {
            nokWithoutComments.add(question);
          }
          // Check if NOK items have images
          final images = questionImages[question] ?? [];
          if (images.isEmpty) {
            nokWithoutImages.add(question);
          }
        }
      }
    });

    if (unselectedQuestions.isNotEmpty) {
      showError('Please answer all questions');
      return;
    }

    final progressDialog = ProgressDialog(context);
    progressDialog.style(
      message: 'Submitting ..',
      child: CustomLoader(),
      borderRadius: 8,
      backgroundColor: Colors.white,
      progressWidget: const SizedBox(
          width: 20,
          height: 20,
          child: Center(child: CircularProgressIndicator())),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );
    progressDialog.show();
    try {
      // Create multipart request for file uploads
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(Api.api_url + "fives"),
      );

      // Add headers
      request.headers.addAll({
        'Accept': 'application/json',
        'Authorization': 'Bearer ${user['data']['token']}',
      });

      // Add form fields
      request.fields['section'] = selectedSection ?? '';
      request.fields['revision'] = _revisionController.text.trim();
      request.fields['author'] = _authorController.text.trim();
      // Convert date from dd/MM/yyyy to yyyy-MM-dd format
      try {
        final parts = _dateController.text.trim().split('/');
        if (parts.length == 3) {
          final formattedDate =
              '${parts[2]}-${parts[1].padLeft(2, '0')}-${parts[0].padLeft(2, '0')}';
          request.fields['date'] = formattedDate;
        } else {
          request.fields['date'] = _dateController.text.trim();
        }
      } catch (e) {
        request.fields['date'] = _dateController.text.trim();
      }
      request.fields['document_creation_date'] =
          _creationDateController.text.trim();
      request.fields['document_ref'] = _documentRefController.text.trim();

      // Add items data
      int itemIndex = 0;

      for (var sectionEntry in dynamicQuestions.entries) {
        List<dynamic> items = sectionEntry.value;

        for (var item in items) {
          final question = item['item_name'];

          // Add each item as individual form fields
          request.fields['items[$itemIndex][five_s_setting_id]'] =
              (item['five_s_setting_id'] ?? 0).toString();
          request.fields['items[$itemIndex][five_s_items_setting_id]'] =
              (item['id'] ?? 0).toString();
          request.fields['items[$itemIndex][score]'] =
              (scores[question] ?? 0).toString();
          request.fields['items[$itemIndex][comments]'] =
              comments[question]?.text.trim() ?? '';

          // Add images for this question
          final images = questionImages[question] ?? [];
          int imageSubIndex = 0;
          for (File image in images) {
            String fieldName = 'items[${itemIndex}][images][$imageSubIndex]';
            String fileName = path.basename(image.path);

            request.files.add(await http.MultipartFile.fromPath(
              fieldName,
              image.path,
              filename: fileName,
            ));
            imageSubIndex++;
          }

          itemIndex++;
        }
      }

      // Send request
      final streamedResponse =
          await request.send().timeout(const Duration(seconds: 60));
      final response = await http.Response.fromStream(streamedResponse);

      var responseBody = jsonDecode(response.body);
      log(jsonEncode(responseBody));

      if (response.statusCode == 200 || responseBody['success'] == true) {
        handleSuccess();
      } else {
        String errorMessage = responseBody['msg'] ??
            responseBody['message'] ??
            "An error occurred";
        if (responseBody['errors'] != null) {
          final errors = responseBody['errors'] as Map<String, dynamic>;
          final errorDetails =
              errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
          errorMessage += '\n$errorDetails';
        }
        showError(errorMessage);
      }
    } on SocketException {
      showError('No Internet connection.');
    } on TimeoutException {
      showError('Request timed out. Please try again.', color: Colors.orange);
    } catch (e) {
      print("Unexpected Error: $e");
      showError('Failed: ${e.toString()}');
    } finally {
      progressDialog.hide();
    }
  }

  // Calculate progress
  int get totalQuestions {
    int total = 0;
    dynamicQuestions.forEach((section, items) {
      total += items.length;
    });
    return total;
  }

  int get answeredQuestions {
    int answered = 0;
    dynamicQuestions.forEach((section, items) {
      for (var item in items) {
        final question = item['item_name'];
        if (scores[question] != null) {
          answered++;
        }
      }
    });
    return answered;
  }

  double get progressPercentage {
    if (totalQuestions == 0) return 0.0;
    return answeredQuestions / totalQuestions;
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: EdgeInsets.fromLTRB(12, 8, 12, 8),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.checklist_rtl, color: mycolor, size: 18),
                  SizedBox(width: 8),
                  Text(
                    'Progress',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: mycolor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '$answeredQuestions / $totalQuestions',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: mycolor,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progressPercentage,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                progressPercentage == 1.0 ? Colors.green : mycolor,
              ),
              minHeight: 6,
            ),
          ),
          SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${(progressPercentage * 100).toInt()}% Complete',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (progressPercentage == 1.0)
                Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green, size: 14),
                    SizedBox(width: 4),
                    Text(
                      'Ready to Submit!',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.assignment_turned_in,
                  color: Colors.white, size: 20),
            ),
            SizedBox(width: 12),
            Text('5S Audit Checklist',
                style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        backgroundColor: mycolor,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: isLoading
          ? Container(
              decoration: BoxDecoration(),
              child: Center(
                child: CustomLoader(),
              ))
          : errorMessage.isNotEmpty
              ? Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.red.shade50, Colors.orange.shade50],
                    ),
                  ),
                  child: Center(
                    child: Container(
                      margin: EdgeInsets.all(20),
                      padding: EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 20,
                            offset: Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.red.shade50,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.error_outline,
                                size: 48, color: Colors.red.shade400),
                          ),
                          SizedBox(height: 20),
                          Text(
                            'Error Loading Data',
                            style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800]),
                          ),
                          SizedBox(height: 12),
                          Text(
                            errorMessage,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 14),
                          ),
                          SizedBox(height: 20),
                          ElevatedButton.icon(
                            onPressed: _loadFiveSSettings,
                            icon: Icon(Icons.refresh),
                            label: Text('Retry'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: mycolor,
                              foregroundColor: Colors.white,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 24, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : !_documentInfoCompleted
                  ? Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue.shade50, Colors.indigo.shade50],
                        ),
                      ),
                      child: Center(
                        child: Container(
                          margin: EdgeInsets.all(20),
                          padding: EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: mycolor.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.description,
                                    size: 48, color: mycolor),
                              ),
                              SizedBox(height: 20),
                              Text(
                                'Document Information Required',
                                style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[800]),
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Please complete the document information form to proceed with the audit checklist.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color: Colors.grey[600], fontSize: 14),
                              ),
                              SizedBox(height: 20),
                              ElevatedButton.icon(
                                onPressed: _showDocumentInformationDialog,
                                icon: Icon(Icons.description),
                                label: Text('Fill Document Information'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: mycolor,
                                  foregroundColor: Colors.white,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 24, vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      decoration: BoxDecoration(),
                      child: Column(
                        children: [
                          // === Fixed Progress Indicator ===
                          _buildProgressIndicator(),

                          // === Scrollable Content ===
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Form(
                                key: _formKey,
                                child: ListView(
                                  children: [
                                    // === Audit Sections ===

                                    ...dynamicSections
                                        .map((section) => _buildSection(
                                            section['name'],
                                            dynamicQuestions[section['name']] ??
                                                []))
                                        .toList(),

                                    const SizedBox(height: 30),

                                    // === Submit Button ===
                                    Container(
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(16),
                                        gradient: LinearGradient(
                                          colors: [
                                            mycolor,
                                            mycolor.withOpacity(0.8)
                                          ],
                                          begin: Alignment.centerLeft,
                                          end: Alignment.centerRight,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: mycolor.withOpacity(0.4),
                                            blurRadius: 15,
                                            offset: Offset(0, 6),
                                          ),
                                        ],
                                      ),
                                      child: ElevatedButton.icon(
                                        onPressed: _submitForm,
                                        icon: Icon(Icons.send,
                                            color: Colors.white),
                                        label: Text(
                                          'Submit Audit',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          foregroundColor: Colors.white,
                                          shadowColor: Colors.transparent,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(16),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 20),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
