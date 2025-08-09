import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/constants.dart';

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
  final TextEditingController _searchController = TextEditingController();
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

  List<ComplaintItem> filteredComplaints = [];

  @override
  void initState() {
    super.initState();
    filteredComplaints = complaints;
    _searchController.addListener(_filterComplaints);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterComplaints() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      if (query.isEmpty) {
        filteredComplaints = complaints;
      } else {
        filteredComplaints = complaints.where((complaint) {
          return complaint.unit.toLowerCase().contains(query) ||
              complaint.complaint.toLowerCase().contains(query) ||
              complaint.customer.toLowerCase().contains(query);
        }).toList();
      }
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      filteredComplaints = complaints;
    });
  }

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
      appBar: AppBar(
        title: const Text(
          'QFL5/6 Complaints',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: mycolor,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: Column(
          children: [
            // Search Filter Section
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.grey.shade200,
                  width: 1,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.search_rounded, color: mycolor, size: 24),
                        const SizedBox(width: 8),
                        const Text(
                          'Search Complaints',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF212529),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8F9FA),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: StatefulBuilder(
                        builder: (context, setSearchState) {
                          return TextField(
                            controller: _searchController,
                            decoration: InputDecoration(
                              hintText:
                                  "Search by unit, complaint, or customer...",
                              hintStyle: TextStyle(
                                color: Colors.grey.shade500,
                                fontSize: 14,
                              ),
                              border: InputBorder.none,
                              contentPadding: const EdgeInsets.all(16),
                              prefixIcon: Icon(
                                Icons.search_outlined,
                                color: Colors.grey.shade500,
                              ),
                              suffixIcon: _searchController.text.isNotEmpty
                                  ? IconButton(
                                      onPressed: () {
                                        _clearSearch();
                                        setSearchState(() {});
                                      },
                                      icon: Icon(
                                        Icons.clear_rounded,
                                        color: Colors.grey.shade500,
                                      ),
                                    )
                                  : null,
                            ),
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF212529),
                            ),
                            onChanged: (value) {
                              setSearchState(() {});
                            },
                          );
                        },
                      ),
                    ),
                    if (_searchController.text.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        '${filteredComplaints.length} result${filteredComplaints.length != 1 ? 's' : ''} found',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Complaints List
            Expanded(
              child: filteredComplaints.isEmpty
                  ? Center(
                      child: Container(
                        padding: const EdgeInsets.all(24),
                        margin: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.grey.shade200,
                            width: 1,
                          ),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: _searchController.text.isNotEmpty
                                    ? Colors.orange.shade500
                                    : mycolor,
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: Icon(
                                _searchController.text.isNotEmpty
                                    ? Icons.search_off_rounded
                                    : Icons.inbox_outlined,
                                size: 48,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isNotEmpty
                                  ? "No complaints match your search."
                                  : "No complaints available.",
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF495057),
                              ),
                            ),
                            if (_searchController.text.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(
                                "Try adjusting your search terms",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextButton.icon(
                                onPressed: _clearSearch,
                                icon: const Icon(Icons.clear_all_rounded),
                                label: const Text("Clear Search"),
                                style: TextButton.styleFrom(
                                  foregroundColor: mycolor,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: filteredComplaints.length,
                      itemBuilder: (context, index) {
                        final item = filteredComplaints[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: Colors.orange.shade200,
                              width: 1,
                            ),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.orange.shade500,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.warning_rounded,
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            title: Text(
                              item.unit,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Color(0xFF212529),
                              ),
                            ),
                            subtitle: Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                item.complaint,
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 14,
                                  height: 1.3,
                                ),
                              ),
                            ),
                            trailing: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: mycolor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                            onTap: () => openDetailPage(item),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
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

    // Show bottom sheet instead of dialog for better mobile UX
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle indicator
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Add Photo Evidence',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212529),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Choose how you want to add photo evidence',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Camera Option
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, ImageSource.camera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: mycolor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.camera_alt_rounded, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Take Photo',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Gallery Option
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ElevatedButton(
                    onPressed: () =>
                        Navigator.pop(context, ImageSource.gallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: mycolor,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: mycolor, width: 2),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.photo_library_rounded, size: 24),
                        const SizedBox(width: 12),
                        const Text(
                          'Choose from Gallery',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Cancel Option
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (source != null) {
      try {
        final picked = await picker.pickImage(
          source: source,
          imageQuality: 80, // Compress image for better performance
          maxWidth: 1024, // Limit image size
          maxHeight: 1024,
        );
        if (picked != null) {
          setState(() => _pickedImage = File(picked.path));
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error picking image: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
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
      appBar: AppBar(
        title: Text(
          'Resolve Complaint',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: mycolor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        color: const Color(0xFFF8F9FA),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Complaint Info Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Column(
                  children: [
                    // Header with gradient background
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: mycolor),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Complaint Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              // color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 16),
                          _buildInfoRow(
                              Icons.person_rounded, 'Customer', c.customer),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                              Icons.directions_car_rounded, 'Unit', c.unit),
                          const SizedBox(height: 12),
                          _buildInfoRow(
                              Icons.warning_rounded, 'Issue', c.complaint),
                        ],
                      ),
                    ),

                    // Status Badge
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.orange.shade50,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.orange.shade200),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.pending_actions,
                                color: Colors.orange.shade600, size: 16),
                            const SizedBox(width: 8),
                            Text(
                              'Pending Resolution',
                              style: TextStyle(
                                color: Colors.orange.shade700,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Resolution Form Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.grey.shade200,
                    width: 1,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.edit_note_rounded,
                              color: mycolor, size: 24),
                          const SizedBox(width: 8),
                          const Text(
                            'Resolution Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF212529),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Comment Section
                      const Text(
                        'Resolution Comment *',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF8F9FA),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: TextFormField(
                          controller: _commentController,
                          decoration: const InputDecoration(
                            hintText: "Describe the resolution steps taken...",
                            hintStyle: TextStyle(
                              color: Color(0xFF6C757D),
                              fontSize: 14,
                            ),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(16),
                            prefixIcon: Icon(
                              Icons.comment_outlined,
                              color: Color(0xFF6C757D),
                            ),
                          ),
                          maxLines: 4,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF212529),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Photo Evidence Section
                      const Text(
                        'Photo Evidence',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF495057),
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (_pickedImage == null)
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 120,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF8F9FA),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: Colors.grey.shade300,
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.add_a_photo_outlined,
                                  size: 32,
                                  color: Colors.grey.shade500,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Tap to add photo evidence',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Optional',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                          child: Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(12),
                                  topRight: Radius.circular(12),
                                ),
                                child: Image.file(
                                  _pickedImage!,
                                  width: double.infinity,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade50,
                                  borderRadius: const BorderRadius.only(
                                    bottomLeft: Radius.circular(12),
                                    bottomRight: Radius.circular(12),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.check_circle,
                                        color: Colors.green.shade600, size: 16),
                                    const SizedBox(width: 8),
                                    const Text(
                                      'Photo evidence added',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: Color(0xFF495057),
                                      ),
                                    ),
                                    const Spacer(),
                                    TextButton(
                                      onPressed: _pickImage,
                                      child: Text(
                                        'Change',
                                        style: TextStyle(
                                          color: mycolor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Submit Button
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitResolution,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.check_circle_rounded, size: 24),
                      const SizedBox(width: 12),
                      const Text(
                        "Mark as Resolved",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  // color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
