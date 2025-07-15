import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ComplaintItem {
  final String id;
  final String unit;
  final String complaint;
  final String customer;
  final bool isResolved;

  ComplaintItem({
    required this.id,
    required this.unit,
    required this.complaint,
    required this.customer,
    this.isResolved = false,
  });
}

class QFLPage extends StatefulWidget {
  @override
  State<QFLPage> createState() => _QFLPageState();
}

class _QFLPageState extends State<QFLPage> {
  final List<ComplaintItem> complaints = [
    ComplaintItem(
      id: 'c1',
      unit: 'Toyota Hilux T312 DFG',
      complaint: 'Brake failure on downhill',
      customer: 'John Doe',
    ),
    ComplaintItem(
      id: 'c2',
      unit: 'Isuzu T245 DFG',
      complaint: 'Engine overheating after 30km',
      customer: 'Jane Smith',
    ),
  ];

  void openDetailPage(ComplaintItem complaint) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ComplaintDetailPage(complaint: complaint),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('QFL5/6 Complaints')),
      body: complaints.isEmpty
          ? const Center(child: Text("No complaints available."))
          : ListView.builder(
              itemCount: complaints.length,
              itemBuilder: (context, index) {
                final item = complaints[index];
                return Card(
                  color: Colors.white,
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  child: ListTile(
                    leading: const Icon(Icons.warning, color: Colors.orange),
                    title: Text(item.unit),
                    subtitle: Text(item.complaint),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () => openDetailPage(item),
                  ),
                );
              },
            ),
    );
  }
}

class ComplaintDetailPage extends StatefulWidget {
  final ComplaintItem complaint;

  const ComplaintDetailPage({super.key, required this.complaint});

  @override
  State<ComplaintDetailPage> createState() => _ComplaintDetailPageState();
}

class _ComplaintDetailPageState extends State<ComplaintDetailPage> {
  final TextEditingController _commentController = TextEditingController();
  File? _pickedImage;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Choose Image Source'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text("Camera"),
            onPressed: () => Navigator.pop(context, ImageSource.camera),
          ),
          TextButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text("Gallery"),
            onPressed: () => Navigator.pop(context, ImageSource.gallery),
          ),
        ],
      ),
    );

    if (source != null) {
      final picked = await picker.pickImage(source: source);
      if (picked != null) {
        setState(() => _pickedImage = File(picked.path));
      }
    }
  }

  void _submitResolution() {
    final comment = _commentController.text.trim();
    if (comment.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please add a comment before submitting")),
      );
      return;
    }

    // TODO: Save to backend (Firebase/REST)
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Complaint resolved successfully")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.complaint;

    return Scaffold(
      appBar: AppBar(title: Text('Resolve for ${c.unit}')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 4,
          color: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Customer: ${c.customer}",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Unit: ${c.unit}", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                Text("Complaint: ${c.complaint}",
                    style: const TextStyle(fontSize: 16)),
                const Divider(height: 30),
                TextFormField(
                  controller: _commentController,
                  decoration: const InputDecoration(
                    labelText: "Comment",
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text("Add Image"),
                    ),
                    const SizedBox(width: 10),
                    if (_pickedImage != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          _pickedImage!,
                          width: 80,
                          height: 80,
                          fit: BoxFit.cover,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 30),
                Center(
                  child: ElevatedButton.icon(
                    onPressed: _submitResolution,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 30, vertical: 12),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.check_circle),
                    label: const Text("Mark as Resolved"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
