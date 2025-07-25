import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/api.dart';
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

class _LotIssueDialogReceivingState extends State<LotIssueDialogReceiving> {
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
