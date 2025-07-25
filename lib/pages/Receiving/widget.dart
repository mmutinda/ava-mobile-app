import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';

class ChecklistItemCard extends StatelessWidget {
  final Map<String, dynamic> checklistItem;
  final int? index;

  const ChecklistItemCard({
    Key? key,
    required this.checklistItem,
    this.index,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    bool isOK = checklistItem['query_answer'] == 'OK';

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isOK
              ? [Colors.green.shade50, Colors.green.shade100]
              : [Colors.red.shade50, Colors.red.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOK ? Colors.green.shade300 : Colors.red.shade300,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: isOK
                ? Colors.green.withOpacity(0.1)
                : Colors.red.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // Index number with gradient
            if (index != null)
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOK
                        ? [Colors.green.shade400, Colors.green.shade600]
                        : [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color:
                          (isOK ? Colors.green : Colors.red).withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    '${(index ?? 0) + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),

            if (index != null) const SizedBox(width: 16),

            // Question text
            Expanded(
              flex: 2,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Question',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    checklistItem['query_name'] ?? 'Unknown Question',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade800,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 16),

            // Answer badge
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: isOK
                      ? [Colors.green.shade400, Colors.green.shade600]
                      : [Colors.red.shade400, Colors.red.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (isOK ? Colors.green : Colors.red).withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isOK ? Icons.check_circle : Icons.cancel,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    checklistItem['query_answer'] ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
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

//// LotIssueDialog.dart

class LotIssueDialogReceiving extends StatefulWidget {
  final lotId;
  final lotNumber;
  final user;
  const LotIssueDialogReceiving(
      {Key? key,
      required this.lotId,
      required this.user,
      required this.lotNumber})
      : super(key: key);

  @override
  State<LotIssueDialogReceiving> createState() =>
      _LotIssueDialogReceivingState();
}

class _LotIssueDialogReceivingState extends State<LotIssueDialogReceiving>
    with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hasIssue = false;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  final TextEditingController issueDetailController = TextEditingController();
  String? issueClassification;
  String? issueCategory;
  XFile? pickedImage;

  final List<String> classificationOptions = ['Minor', 'Major', 'Critical'];
  final List<String> categoryOptions = ['Mechanical', 'Electrical', 'Other'];

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 10,
          backgroundColor: Colors.white,
          contentPadding: EdgeInsets.zero,
          content: Container(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Modern header with gradient
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [mycolor.withOpacity(0.8), mycolor],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.report_problem,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Lot Issue Confirmation',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Content area
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Is there any lot issue?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Modern choice chips
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => hasIssue = true),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: hasIssue
                                      ? LinearGradient(
                                          colors: [
                                            Colors.red.shade400,
                                            Colors.red.shade600
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color: hasIssue ? null : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: hasIssue
                                        ? Colors.red.shade600
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: hasIssue
                                      ? [
                                          BoxShadow(
                                            color: Colors.red.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.warning,
                                      color: hasIssue
                                          ? Colors.white
                                          : Colors.red.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Yes',
                                      style: TextStyle(
                                        color: hasIssue
                                            ? Colors.white
                                            : Colors.red.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => setState(() => hasIssue = false),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding:
                                    const EdgeInsets.symmetric(vertical: 12),
                                decoration: BoxDecoration(
                                  gradient: !hasIssue
                                      ? LinearGradient(
                                          colors: [
                                            Colors.green.shade400,
                                            Colors.green.shade600
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        )
                                      : null,
                                  color:
                                      !hasIssue ? null : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: !hasIssue
                                        ? Colors.green.shade600
                                        : Colors.grey.shade300,
                                    width: 2,
                                  ),
                                  boxShadow: !hasIssue
                                      ? [
                                          BoxShadow(
                                            color:
                                                Colors.green.withOpacity(0.3),
                                            blurRadius: 8,
                                            offset: const Offset(0, 4),
                                          ),
                                        ]
                                      : [],
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: !hasIssue
                                          ? Colors.white
                                          : Colors.green.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'No',
                                      style: TextStyle(
                                        color: !hasIssue
                                            ? Colors.white
                                            : Colors.green.shade600,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      // Issue details section
                      if (hasIssue) ...[
                        const SizedBox(height: 24),
                        _buildModernTextField(
                          controller: issueDetailController,
                          label: 'Part Number',
                          icon: Icons.inventory,
                        ),
                        const SizedBox(height: 16),
                        _buildModernDropdown(
                          value: issueClassification,
                          label: 'Issue Classification',
                          icon: Icons.priority_high,
                          options: classificationOptions,
                          onChanged: (val) =>
                              setState(() => issueClassification = val),
                        ),
                        const SizedBox(height: 16),
                        _buildModernDropdown(
                          value: issueCategory,
                          label: 'Issue Category',
                          icon: Icons.category,
                          options: categoryOptions,
                          onChanged: (val) =>
                              setState(() => issueCategory = val),
                        ),
                        const SizedBox(height: 20),

                        // Camera button
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: mycolor, width: 2),
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),

                        // Image preview
                        if (pickedImage != null)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                File(pickedImage!.path),
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                      ],

                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                    color: Colors.red.shade300, width: 2),
                              ),
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                child: Text(
                                  'Cancel',
                                  style: TextStyle(
                                    color: Colors.red.shade600,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [mycolor.withOpacity(0.8), mycolor],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                boxShadow: [
                                  BoxShadow(
                                    color: mycolor.withOpacity(0.3),
                                    blurRadius: 8,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: () => _submitForm(context),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text(
                                  'Submit',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
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
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => pickedImage = image);
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    // if (!_formKey.currentState!.validate()) return;

    final fields = {
      'any_lot_issue': hasIssue ? 'YES' : 'NO',
      'vehicle_receiving_id': widget.lotId.toString(), // ✅ fix
      'lot_number': widget.lotNumber.toString(), // ✅ fix
      'part_number': issueDetailController.text.trim(),
      'classification': issueClassification ?? '',
      'category': issueCategory ?? '',
    };

    // Example dynamic files
    final files = pickedImage != null
        ? {
            'images': File(pickedImage!.path),
          }
        : {};

    print("Submit...");
    await submitMultipartForm(
      context: context,
      url: '${Api.api_url}pushToPlanning',
      fields: fields, // Now guaranteed strings
      files: files,
      token: widget.user,
    );

    Navigator.pop(context);
  }

  Widget _buildModernTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        color: Colors.grey.shade50,
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: mycolor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
      ),
    );
  }

  Widget _buildModernDropdown({
    required String? value,
    required String label,
    required IconData icon,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300, width: 1.5),
        color: Colors.grey.shade50,
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: mycolor),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          labelStyle: TextStyle(color: Colors.grey.shade600),
        ),
        items: options
            .map((e) => DropdownMenuItem(
                  value: e,
                  child: Text(e, style: TextStyle(color: Colors.grey.shade800)),
                ))
            .toList(),
        onChanged: onChanged,
        dropdownColor: Colors.white,
      ),
    );
  }
}

/// LotIssueDialog.dart

class LotIssueDialogFinishRacking extends StatefulWidget {
  final lotId;
  final lotNumber;
  final user;
  const LotIssueDialogFinishRacking(
      {Key? key,
      required this.lotId,
      required this.user,
      required this.lotNumber})
      : super(key: key);

  @override
  State<LotIssueDialogFinishRacking> createState() =>
      _LotIssueDialogFinishRackingState();
}

class _LotIssueDialogFinishRackingState
    extends State<LotIssueDialogFinishRacking> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool hasIssue = false;

  final TextEditingController issueDetailController = TextEditingController();
  String? issueClassification;
  String? issueCategory;
  XFile? pickedImage;

  final List<String> classificationOptions = ['Minor', 'Major', 'Critical'];
  final List<String> categoryOptions = ['Mechanical', 'Electrical', 'Other'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: Row(
        children: [
          Icon(Icons.report_problem, color: Colors.amber.shade700),
          const SizedBox(width: 8),
          Text(
            'Lot Issue Confirmation',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Divider(thickness: 1, color: Colors.grey.shade300),
            const SizedBox(height: 10),
            Text(
              'Is there any lot issue?',
              style: theme.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Center(
              child: Wrap(
                spacing: 12,
                children: [
                  ChoiceChip(
                    label: Text('Yes',
                        style: TextStyle(
                            color: hasIssue ? Colors.white : Colors.black)),
                    selected: hasIssue,
                    selectedColor: Colors.redAccent,
                    onSelected: (_) => setState(() => hasIssue = true),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  ChoiceChip(
                    label: Text('No',
                        style: TextStyle(
                            color: !hasIssue ? Colors.white : Colors.black)),
                    selected: !hasIssue,
                    selectedColor: Colors.green,
                    onSelected: (_) => setState(() => hasIssue = false),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                ],
              ),
            ),
            if (hasIssue) ...[
              const SizedBox(height: 24),
              _buildTextField(
                controller: issueDetailController,
                label: 'Part Number',
                maxLines: 1,
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: issueClassification,
                label: 'Issue Classification',
                options: classificationOptions,
                onChanged: (val) => setState(() => issueClassification = val),
              ),
              const SizedBox(height: 16),
              _buildDropdown(
                value: issueCategory,
                label: 'Issue Category',
                options: categoryOptions,
                onChanged: (val) => setState(() => issueCategory = val),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text('Take Picture'),
                  onPressed: _pickImage,
                ),
              ),
              if (pickedImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      File(pickedImage!.path),
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
      actionsPadding: const EdgeInsets.all(16),
      actions: [
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.red,
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _submitForm(context),
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      maxLines: maxLines,
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<String> options,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: options
          .map((e) => DropdownMenuItem(value: e, child: Text(e)))
          .toList(),
      onChanged: onChanged,
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() => pickedImage = image);
    }
  }

  Future<void> _submitForm(BuildContext context) async {
    // if (!_formKey.currentState!.validate()) return;

    final fields = {
      'any_lot_issue': hasIssue ? 'YES' : 'NO',
      'vehicle_receiving_id': widget.lotId.toString(), // ✅ fix
      'lot_number': widget.lotNumber.toString(), // ✅ fix
      'part_number': issueDetailController.text.trim(),
      'classification': issueClassification ?? '',
      'category': issueCategory ?? '',
    };

    // Example dynamic files
    final files = pickedImage != null
        ? {
            'images': File(pickedImage!.path),
          }
        : {};

    await submitMultipartForm(
      context: context,
      url: '${Api.api_url}completeUnboxing',
      fields: fields, // Now guaranteed strings
      files: files,
      token: widget.user,
    );

    Navigator.pop(context);
  }
}
