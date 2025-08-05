import 'dart:async';
import 'dart:convert';
import 'dart:io';
// For logging
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_feather_icons/flutter_feather_icons.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:isuze_pqcs/common/ApiService.dart';
import 'package:isuze_pqcs/common/UIHelper.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/pages/planning/widget.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class ReceivingForm extends StatefulWidget {
  @override
  State<ReceivingForm> createState() => _ReceivingFormState();
}

class _ReceivingFormState extends State<ReceivingForm>
    with SingleTickerProviderStateMixin {
  late SingleValueDropDownController _carModel;
  late SingleValueDropDownController _customerModel;
  late TextEditingController _lotNo;
  late TextEditingController _lotQty;
  final TextEditingController _fileController = TextEditingController();
  final TextEditingController _fileController2 = TextEditingController();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<dynamic> clients = [];
  List<dynamic> models = [];
  String errorText = '';
  String errorModel = '';
  String selectedValue = 'NO';
  Map<String, dynamic>? issueData;

  void _showIssueDialog() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => IssueDialog(),
    );

    if (result != null) {
      setState(() {
        issueData = result;
      });
    } else {
      setState(() {
        selectedValue = 'NO';
      });
    }
  }

  bool isLoading = true;
  bool _isLoadingModels = false;
  dynamic selectedCustomerId;
  dynamic modelId;
  File? parkingFile;
  File? geologyFile;

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final Color mycolor = Colors.blue;
  var user = {};
  @override
  void initState() {
    _carModel = SingleValueDropDownController();
    _customerModel = SingleValueDropDownController();
    _lotNo = TextEditingController();
    _lotQty = TextEditingController();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      _fetchData();
      _animationController.forward();
    });
    super.initState();
  }

  @override
  void dispose() {
    _customerModel.dispose();
    _carModel.dispose();
    _lotNo.dispose();
    _lotQty.dispose();
    _fileController.dispose();
    _fileController2.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchData() async {
    await ApiHelper.fetchMultipleData(
      context: context,
      requests: [fetchClients()],
      setLoading: (val) => setState(() => isLoading = val),
      onSuccess: (results) {
        setState(() {
          clients = results[0]["data"] as List;
        });
      },
      onError: (message) {
        setState(() {
          errorText = message;
        });
      },
    );
  }

  Future<void> _pickFile(int type) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx', 'csv'],
    );
    if (result != null) {
      setState(() {
        if (type == 0) {
          parkingFile = File(result.files.single.path!);
          _fileController.text = result.files.single.name;
        } else {
          geologyFile = File(result.files.single.path!);
          _fileController2.text = result.files.single.name;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.primaryColor,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.primaryColor,
                theme.primaryColor.withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                FeatherIcons.truck,
                color: Colors.white,
                size: 20,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Receiving Form',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 22,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: EdgeInsets.only(right: 16),
            child: IconButton(
              icon: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  FeatherIcons.save,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              onPressed: () => _submitForm(context),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.grey.shade50,
              Colors.white,
            ],
          ),
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.all(20),
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
                      child: CircularProgressIndicator(
                        strokeWidth: 3,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(theme.primaryColor),
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Loading form data...',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: Column(
                  children: [
                    // Header Card
                    Container(
                      margin: EdgeInsets.all(16),
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            theme.primaryColor.withOpacity(0.1),
                            theme.primaryColor.withOpacity(0.05),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: theme.primaryColor.withOpacity(0.2)),
                        boxShadow: [
                          BoxShadow(
                            color: theme.primaryColor.withOpacity(0.1),
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color: theme.primaryColor,
                              borderRadius: BorderRadius.circular(15),
                              boxShadow: [
                                BoxShadow(
                                  color: theme.primaryColor.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: Offset(0, 3),
                                ),
                              ],
                            ),
                            child: Icon(
                              FeatherIcons.package,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                          SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Vehicle Receiving",
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: theme.primaryColor,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  "Register new lot & vehicle details",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[600],
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: Colors.blue.withOpacity(0.3)),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(FeatherIcons.edit3,
                                    color: Colors.blue, size: 14),
                                SizedBox(width: 6),
                                Text(
                                  "Form",
                                  style: TextStyle(
                                    color: Colors.blue[700],
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Form Content
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: errorText.isNotEmpty
                            ? _buildErrorWidget()
                            : _buildFormContent(theme),
                      ),
                    ),
                    // Submit Button
                    _buildSubmitButton(theme),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      margin: EdgeInsets.all(20),
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(FeatherIcons.alertCircle, color: Colors.red, size: 48),
          SizedBox(height: 16),
          Text(
            'Error Loading Data',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.red[800],
            ),
          ),
          SizedBox(height: 8),
          Text(
            errorText,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.red[600],
            ),
          ),
          SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _fetchData,
            icon: Icon(FeatherIcons.refreshCw, size: 18),
            label: Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormContent(ThemeData theme) {
    return SingleChildScrollView(
      physics: BouncingScrollPhysics(),
      child: Form(
        key: _formKey,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (errorModel.isNotEmpty)
                Container(
                  margin: EdgeInsets.only(bottom: 16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.red.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(FeatherIcons.alertTriangle,
                          color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          errorModel,
                          style: TextStyle(
                              color: Colors.red[700],
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              _buildStyledDropdown(
                controller: _customerModel,
                label: 'Customer',
                icon: FeatherIcons.users,
                items: clients.map((client) {
                  return DropDownValueModel(
                    name: client['name'] ?? 'Unknown',
                    value: client['id'],
                  );
                }).toList(),
                onChanged: (val) async {
                  selectedCustomerId = val.value;
                  setState(() => _isLoadingModels = true);
                  try {
                    final response = await fetchCarModel(selectedCustomerId);
                    models = response['data'] ?? [];
                  } catch (e) {
                    models = [];
                    errorModel = 'Failed to load models: $e';
                  } finally {
                    setState(() {
                      _isLoadingModels = false;
                      _carModel.clearDropDown();
                    });
                  }
                },
              ),
              const SizedBox(height: 20),
              _isLoadingModels
                  ? Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  theme.primaryColor),
                            ),
                          ),
                          SizedBox(width: 12),
                          Text(
                            'Loading vehicle models...',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  : _buildStyledDropdown(
                      controller: _carModel,
                      label: 'Vehicle Model',
                      icon: FeatherIcons.truck,
                      items: models.map((model) {
                        return DropDownValueModel(
                          name: model['model_name'] ?? '',
                          value: model['id'],
                        );
                      }).toList(),
                      onChanged: (val) {
                        modelId = val.value;
                      },
                    ),
              const SizedBox(height: 20),
              _buildStyledTextField(
                controller: _lotNo,
                label: 'Lot Number',
                hint: 'Enter lot number',
                icon: FeatherIcons.hash,
              ),
              const SizedBox(height: 20),
              _buildStyledTextField(
                controller: _lotQty,
                label: 'Lot Quantity',
                hint: 'Enter lot quantity',
                icon: FeatherIcons.layers,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 24),
              _buildFileUploadSection(theme),
              const SizedBox(height: 24),
              _buildPackagingIssueSection(theme),
              if (issueData != null) ...[
                SizedBox(height: 24),
                _buildIssueSummary(theme),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStyledDropdown({
    required SingleValueDropDownController controller,
    required String label,
    required IconData icon,
    required List<DropDownValueModel> items,
    required Function(DropDownValueModel) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: DropDownTextField(
            controller: controller,
            clearOption: false,
            dropDownIconProperty:
                IconProperty(color: Colors.grey[600], size: 24),
            textFieldDecoration: InputDecoration(
              hintText: 'Select $label',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            dropDownItemCount: 5,
            enableSearch: true,
            validator: (value) =>
                (value == null || value.isEmpty) ? "*Required" : null,
            dropDownList: items,
            onChanged: (value) => onChanged(value),
          ),
        ),
      ],
    );
  }

  Widget _buildStyledTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 8),
          child: Row(
            children: [
              Icon(icon, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide:
                    BorderSide(color: Theme.of(context).primaryColor, width: 2),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            validator: (value) =>
                (value == null || value.isEmpty) ? '*Required' : null,
          ),
        ),
      ],
    );
  }

  Widget _buildFileUploadSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 4, bottom: 16),
          child: Row(
            children: [
              Icon(FeatherIcons.upload, size: 18, color: Colors.grey[600]),
              SizedBox(width: 8),
              Text(
                'File Uploads',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey[700],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
        _buildFileUploadCard(
          label: 'Packing List (Excel)',
          controller: _fileController,
          onUpload: () => _pickFile(0),
          icon: FeatherIcons.fileText,
          color: Colors.green,
        ),
        SizedBox(height: 16),
        _buildFileUploadCard(
          label: 'Geology Data (Excel)',
          controller: _fileController2,
          onUpload: () => _pickFile(1),
          icon: FeatherIcons.database,
          color: Colors.blue,
        ),
      ],
    );
  }

  Widget _buildFileUploadCard({
    required String label,
    required TextEditingController controller,
    required VoidCallback onUpload,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: color.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.05),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        borderRadius: BorderRadius.circular(15),
        color: color.withOpacity(0.05),
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onUpload,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: Colors.white, size: 20),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[800],
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        controller.text.isEmpty
                            ? 'No file selected'
                            : controller.text,
                        style: TextStyle(
                          fontSize: 12,
                          color: controller.text.isEmpty
                              ? Colors.grey[500]
                              : color,
                          fontWeight: controller.text.isEmpty
                              ? FontWeight.normal
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(FeatherIcons.upload, color: color, size: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPackagingIssueSection(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FeatherIcons.alertTriangle, size: 18, color: Colors.orange),
              SizedBox(width: 8),
              Text(
                "Any Packaging Issue?",
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.grey[800],
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildChoiceChip(
                  label: 'YES',
                  isSelected: selectedValue == 'YES',
                  color: Colors.red,
                  onSelected: () {
                    setState(() {
                      selectedValue = 'YES';
                    });
                    _showIssueDialog();
                  },
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildChoiceChip(
                  label: 'NO',
                  isSelected: selectedValue == 'NO',
                  color: Colors.green,
                  onSelected: () {
                    setState(() {
                      selectedValue = 'NO';
                      issueData = null; // Clear issue data when NO is selected
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChoiceChip({
    required String label,
    required bool isSelected,
    required Color color,
    required VoidCallback onSelected,
  }) {
    return Material(
      borderRadius: BorderRadius.circular(12),
      color: isSelected ? color : Colors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onSelected,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? color : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIssueSummary(ThemeData theme) {
    return Container(
      padding: EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(FeatherIcons.alertCircle, color: Colors.red, size: 20),
              SizedBox(width: 8),
              Text(
                "Issue Summary",
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Colors.red[800],
                ),
              ),
            ],
          ),
          SizedBox(height: 12),
          _buildSummaryItem(
              "Process Description", issueData!['processDescription']),
          _buildSummaryItem("Part No", issueData!['partNo']),
          _buildSummaryItem(
              "Issue Description", issueData!['issueDescription']),
          _buildSummaryItem("Category", issueData!['category']),
          _buildSummaryItem("Issue Type", issueData!['issueType']),
          _buildSummaryItem("Reason Code", issueData!['reasonCode']),
          _buildSummaryItem("Classification", issueData!['classification']),
          if (issueData!['image'] != null) ...[
            SizedBox(height: 12),
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  issueData!['image'],
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              "$label:",
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.red[700],
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.red[600],
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.primaryColor,
              theme.primaryColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: theme.primaryColor.withOpacity(0.3),
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(15),
          child: InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () => _submitForm(context),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(FeatherIcons.send, color: Colors.white, size: 20),
                  SizedBox(width: 12),
                  Text(
                    'Submit Form',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm(BuildContext context) async {
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(builder: (context) => ReceivingFormClaim()),
    // );
    // return;
    if (!_formKey.currentState!.validate()) return;

    final uri = Uri.parse('${Api.api_url}postScheduledUnit');
    var request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      'Authorization': 'Bearer ${user['data']["token"]}',
    });

    // Add form fields
    request.fields['customer_id'] =
        _customerModel.dropDownValue!.value.toString();
    request.fields['unit_model_id'] = _carModel.dropDownValue!.value.toString();
    request.fields['lot_number'] = _lotNo.text;
    request.fields['lot_qty'] = _lotQty.text;
    request.fields['packing_list_issue'] = selectedValue;

    // Add issue-related fields only if there's a packaging issue
    if (selectedValue == 'YES' && issueData != null) {
      request.fields['process_description'] =
          issueData!['processDescription'] ?? '';
      request.fields['part_number'] = issueData!['partNo'] ?? '';
      request.fields['issue_description'] =
          issueData!['issueDescription'] ?? '';
      request.fields['category'] = issueData!['category'] ?? '';
      request.fields['issue_type'] = issueData!['issueType'] ?? '';
      request.fields['reason_code'] = issueData!['reasonCode'] ?? '';
      request.fields['classification'] = issueData!['classification'] ?? '';
    }

    // Add uploaded files
    if (parkingFile != null && parkingFile!.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'packing_list',
        parkingFile!.path,
      ));
    }

    if (geologyFile != null && geologyFile!.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'geology_data',
        geologyFile!.path,
      ));
    }

    // Add issue image only if there's a packaging issue and image exists
    if (selectedValue == 'YES' &&
        issueData != null &&
        issueData?['image'] != null &&
        issueData!['image']!.path.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath(
        'images',
        issueData!['image']!.path,
      ));
    }

    // Debug print for request fields
    request.fields.forEach((key, value) {
      print('Field: $key = $value');
    });

    final progressDialog = ProgressDialog(context);
    progressDialog.style(
      message: 'Submitting ..',
      child: CustomLoader(),
      borderRadius: 8,
      backgroundColor: Colors.white,
      messageTextStyle: TextStyle(
        color: Colors.black,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
      progressWidget: const SizedBox(
        width: 20,
        height: 20,
        child: Center(child: CircularProgressIndicator()),
      ),
      elevation: 10.0,
      insetAnimCurve: Curves.easeInOut,
    );

    progressDialog.show();

    try {
      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      var responseBody = jsonDecode(responseData);

      // Fixed: log expects a String, not a Map
      log(jsonDecode(responseData));
      log(jsonDecode(responseData));

      if (response.statusCode == 200 || responseBody['success'] == true) {
        progressDialog.hide();
        UIHelper.showSuccessMessage(
          context: context,
          message: "Submitted successfully",
        );
      } else {
        progressDialog.hide();

        String errorMessage = responseBody['msg'] ??
            responseBody['message'] ??
            "An error occurred";

        if (responseBody['errors'] != null) {
          final errors = responseBody['errors'];
          final errorDetails =
              errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
          errorMessage += '\n$errorDetails';
        }

        // Add a small delay to ensure progress dialog is fully hidden
        Future.delayed(Duration(milliseconds: 100), () {
          UIHelper.showErrorMessage(context: context, message: errorMessage);
        });
      }
    } on SocketException {
      progressDialog.hide();
      Future.delayed(Duration(milliseconds: 100), () {
        UIHelper.showErrorMessage(
          context: context,
          message: "No Internet connection.",
        );
      });
    } on TimeoutException {
      progressDialog.hide();
      Future.delayed(Duration(milliseconds: 100), () {
        UIHelper.showErrorMessage(
          context: context,
          message: "Request timed out. Please try again",
        );
      });
    } catch (e) {
      progressDialog.hide();
      print("Unexpected Error: $e");
      Future.delayed(Duration(milliseconds: 100), () {
        UIHelper.showErrorMessage(
          context: context,
          message: 'Failed: ${e.toString()}',
        );
      });
    }
  }

  Future fetchCarModel(customerId) async {
    setState(() {
      errorModel = ''; // Initialize error text before fetching
    });
    String url = Api.api_url + "loadClientModels/$customerId";
    print(url);
    var responsedata = await httpget(url, user['data']['token'], context);
    return responsedata;
  }

  Future fetchClients() async {
    String url = Api.api_url + "loadclients";
    var responsedata = await httpget(url, user['data']['token'], context);
    print(responsedata);
    return responsedata;
  }
}
