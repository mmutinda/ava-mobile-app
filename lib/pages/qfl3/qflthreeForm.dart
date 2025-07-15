import 'dart:convert';
import 'dart:developer';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:isuze_pqcs/pages/qfl3/qfl3_list.dart';

class AuditChecklistItem {
  final String sn;
  final String group;
  final String resp;
  final String description;
  int? rating;
  String? comment;

  AuditChecklistItem({
    required this.sn,
    required this.group,
    required this.resp,
    required this.description,
    this.rating,
    this.comment,
  });
}

class AuditChecklistPage extends StatefulWidget {
  const AuditChecklistPage({super.key});

  @override
  State<AuditChecklistPage> createState() => _AuditChecklistPageState();
}

class _AuditChecklistPageState extends State<AuditChecklistPage> {
  List<AuditChecklistItem> auditItems = [
    AuditChecklistItem(
        sn: '1.1',
        group: 'Man',
        resp: 'Prodn',
        description: 'Is the Operator Skill Level match the requirement'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description: 'Are the Self Check points known & confirmed by operator'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description: 'check station condition before & at the end of shift'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator aware of the torque parameter & torque tool set value'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator awares about the consequences of the keypoints in the operation'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator aware of the quality requirements/safety requirements'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator aware of the consequence of the failure.'),
    AuditChecklistItem(
        sn: '1.2',
        group: 'Man',
        resp: 'Prodn',
        description: 'Are standard work instructions followed by the Operator'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Are Specified Equipments / Tools used'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description:
            'Are they calibrated (in case of gauges) / Are they periodically checked (incase of Equip)'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'FM',
        description:
            'Are they calibrated (in case of gauges) / Are they periodically checked (incase of Equip)'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'QM',
        description:
            'Are they calibrated (in case of gauges) / Are they periodically checked (incase of Equip)'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Is the tool use procedure adhered to requirement'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: ' Is the Poka yoke working'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Is the boundary marking on each station visible'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Is the tool parking available and is it being utilized?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Machine',
        resp: 'ME',
        description: 'Is the tool parking available and is it being utilized?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Is the Process Flow update as on date available'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            'Are the SWI/JES/Assembly manual available in the station?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Are the operations sequence defined'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Is the Assembly procedure being followed?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Check station condition before & at the end of shift'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: ' Is DS/DZ characteristic monitoring Process done?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Are parts easily identified after shopping?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: 'Is there a safe ergonomics practiced in the station'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            'Is there 5S practice in the station during working hours?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            ' Is the station organized during production? 5S in process?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            ' Are defects properly tracked in History card / check  sheets'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description: '  Is the skill matrix available in the station?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            '  Is the product quality standard known to the operators?'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Method',
        resp: 'Prodn',
        description:
            'Is there a process in place to capture the lessons learnt in the respective stations'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Material',
        resp: 'Logistic',
        description: ' Is adequate traceability available for material'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Material',
        resp: 'Logistic',
        description: ' Is adequate traceability available for material'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Material',
        resp: 'Logistic',
        description: 'Are non-conformance parts handled as per procedure'),
    AuditChecklistItem(
        sn: '2.1',
        group: 'Material',
        resp: 'Logistic',
        description:
            'Is the work station is free of unwanted material to avoid wrong assembly'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description:
            'Is the lighting appropriate with respect to the station requirement'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description: 'Is there an identified waste bin in the station?'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description: 'Are the safety equipments available to operator'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description: 'Is Control of Hazardous materials adhered to standards'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Logistic',
        description: 'Is Control of Hazardous materials adhered to standards'),
    AuditChecklistItem(
        sn: '5.1',
        group: 'Milieu',
        resp: 'Prodn',
        description:
            'Is Safety instruction displayed in the workstation (PPE)?'),
  ];

  String? selectedResp = "Prodn";
  String? selectedGroup = "Man";

  List<AuditChecklistItem> get filteredItems {
    return auditItems.where((item) {
      final matchResp = selectedResp == null || item.resp == selectedResp;
      final matchGroup = selectedGroup == null || item.group == selectedGroup;
      return matchResp && matchGroup;
    }).toList();
  }

  Color getRatingColor(int value) {
    switch (value) {
      case 0:
        return Colors.redAccent;
      case 1:
        return Colors.orange;
      case 2:
        return Colors.green;
      case 3:
        return Colors.grey;
      default:
        return Colors.transparent;
    }
  }

  String getRatingLabel(int value) {
    switch (value) {
      case 0:
        return "Non-Conforming";
      case 1:
        return "Needs Improvement";
      case 2:
        return "OK";
      case 3:
        return "N/A";
      default:
        return "";
    }
  }

  bool showFilters = false;

  final TextEditingController _sectionController = TextEditingController();
  final TextEditingController _auditDepartmentController =
      TextEditingController();
  final TextEditingController _auditSectionController = TextEditingController();
  final TextEditingController _stationNumberController =
      TextEditingController();
  final TextEditingController _periodDurationController =
      TextEditingController();
  final SingleValueDropDownController _shopController =
      SingleValueDropDownController();
  Widget _buildHeaderField(
      IconData icon, String label, TextEditingController controller,
      {bool isDate = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextField(
        controller: controller,
        readOnly: isDate,
        onTap: isDate
            ? () async {
                final date = await showDatePicker(
                  context: context,
                  firstDate: DateTime(2000),
                  lastDate: DateTime(2100),
                  initialDate: DateTime.now(),
                );
                if (date != null) {
                  controller.text = date.toString().split(' ')[0];
                }
              }
            : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget buildShopDropdown() {
    return DropDownTextField(
      controller: _shopController,
      enableSearch: true,
      clearOption: false,
      dropDownIconProperty: IconProperty(color: Colors.blue, size: 28),
      textFieldDecoration: InputDecoration(
        labelText: 'Select Shop/Station',
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: (val) => val == null || val.isEmpty ? "*Required" : null,
      dropDownList: shops
          .map((shop) => DropDownValueModel(
                name: shop['shop_name'] ?? 'Unknown',
                value: shop['id'],
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          // issues = [""];
        });
      },
    );
  }

  String errorText = '';
  Map<String, dynamic> user = {};
  bool isLoading2 = false;
  List<dynamic> shops = [];
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      loadShops();
    });
  }

  Future<void> loadShops() async {
    setState(() => isLoading = true);
    try {
      final response = await fetchShops();

      if (response != null && response["data"]["shop"] != null) {
        shops = response["data"]["shop"];
      }
    } catch (e) {
      errorText = "Error loading shops: $e";
    } finally {
      setState(() => isLoading = false);
    }
  }

  Future<Map<String, dynamic>?> fetchShops() async {
    String url = Api.api_url + "home";
    return await httpget(url, user['data']['token'], context);
  }

  @override
  Widget build(BuildContext context) {
    final uniqueResps = auditItems.map((e) => e.resp).toSet().toList();
    final uniqueGroups = auditItems.map((e) => e.group).toSet().toList();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            const Text("Audit Checklist",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text("Responsible: ${selectedResp}",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text("Group: ${selectedGroup}",
                    style:
                        TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              showFilters ? Icons.filter_alt_off : Icons.filter_alt,
              color: Colors.white,
            ),
            onPressed: () {
              setState(() {
                showFilters = !showFilters;
              });
            },
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorText.isNotEmpty
              ? ErrorMessageWidget(errorMessage: errorText, onRetry: loadShops)
              : Column(
                  children: [
                    // Filters
                    AnimatedCrossFade(
                      crossFadeState: showFilters
                          ? CrossFadeState.showFirst
                          : CrossFadeState.showSecond,
                      duration: showFilters
                          ? const Duration(milliseconds: 500)
                          : const Duration(milliseconds: 0),
                      firstChild: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Card(
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("RESP",
                                              style: TextStyle(fontSize: 14)),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey.shade100,
                                            ),
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              value: selectedResp,
                                              hint: const Text("Select RESP"),
                                              items: uniqueResps.map((resp) {
                                                return DropdownMenuItem<String>(
                                                  value: resp,
                                                  child: Text(resp),
                                                );
                                              }).toList(),
                                              onChanged: (value) => setState(
                                                  () => selectedResp = value),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const Text("Group",
                                              style: TextStyle(fontSize: 14)),
                                          const SizedBox(height: 6),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 12),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                  color: Colors.grey.shade300),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              color: Colors.grey.shade100,
                                            ),
                                            child: DropdownButton<String>(
                                              isExpanded: true,
                                              underline: const SizedBox(),
                                              value: selectedGroup!.isNotEmpty
                                                  ? selectedGroup
                                                  : null,
                                              hint: const Text("Select Group"),
                                              items: uniqueGroups.map((group) {
                                                return DropdownMenuItem<String>(
                                                  value: group,
                                                  child: Text(group),
                                                );
                                              }).toList(),
                                              onChanged: (value) => setState(
                                                  () => selectedGroup =
                                                      value ?? ''),
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
                        ),
                      ),
                      secondChild: const SizedBox.shrink(),
                    ),

                    // Checklist
                    Expanded(
                      child: filteredItems.isEmpty
                          ? Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 30),
                                margin: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                  border:
                                      Border.all(color: Colors.grey.shade300),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.inbox,
                                        size: 48, color: Colors.grey.shade500),
                                    const SizedBox(height: 12),
                                    Text(
                                      "No items found",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.grey.shade700,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      "Try adjusting your filters or search.",
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              itemCount: filteredItems.length,
                              itemBuilder: (context, index) {
                                final item = filteredItems[index];
                                return Card(
                                  color: Colors.white,
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  margin:
                                      const EdgeInsets.symmetric(vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(12),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "${index + 1}. ${item.description}",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        const SizedBox(height: 10),
                                        Wrap(
                                          spacing: 10,
                                          children: List.generate(4, (value) {
                                            final isSelected =
                                                item.rating == value;
                                            return ChoiceChip(
                                              label: Text(
                                                getRatingLabel(value),
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  color: isSelected
                                                      ? Colors.white
                                                      : Colors.black,
                                                ),
                                              ),
                                              selected: isSelected,
                                              selectedColor:
                                                  getRatingColor(value),
                                              onSelected: (_) {
                                                setState(() {
                                                  item.rating = value;
                                                });
                                              },
                                            );
                                          }),
                                        ),
                                        const SizedBox(height: 10),
                                        TextFormField(
                                          initialValue: item.comment,
                                          decoration: InputDecoration(
                                            hintText: 'Add comment (optional)',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 12,
                                                    vertical: 10),
                                          ),
                                          onChanged: (val) {
                                            item.comment = val;
                                          },
                                          maxLines: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                    ),
                    // Submit Button
                    filteredItems.isEmpty
                        ? Container()
                        : isLoading2
                            ? CustomLoader()
                            : SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(12.0),
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      minimumSize:
                                          const Size(double.infinity, 50),
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(8)),
                                      backgroundColor: mycolor,
                                      foregroundColor: Colors.white,
                                    ),
                                    icon: const Icon(Icons.send),
                                    label: const Text("Submit"),
                                    onPressed: () {
                                      final answered = auditItems
                                          .where((item) => item.rating != null)
                                          .toList();
                                      if (answered.isEmpty) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                "Please answer at least one checklist item before submitting."),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                        return;
                                      }
                                      _showDocumentDialog();
                                    },

                                    // onPressed: _showDocumentDialog,
                                  ),
                                ),
                              )
                  ],
                ),
    );
  }

  void _showDocumentDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              content: SingleChildScrollView(
                child: Card(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  elevation: 3,
                  // margin: const EdgeInsets.all(16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '📄 Document Information',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 12),
                        buildShopDropdown(),
                        _buildHeaderField(Icons.article,
                            'Project Model & Variant', _sectionController),
                        _buildHeaderField(Icons.person, 'Audit department',
                            _auditDepartmentController),
                        _buildHeaderField(Icons.person, 'Audit section/ Line',
                            _auditSectionController),
                        _buildHeaderField(Icons.person, 'Period/ Duration',
                            _periodDurationController),
                        const SizedBox(height: 20),
                        Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => Navigator.pop(context),
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(120, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    backgroundColor: Colors.grey.shade300,
                                    foregroundColor: Colors.black,
                                  ),
                                  child: const Text("Cancel"),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                  child: ElevatedButton(
                                onPressed: () {
                                  if (_sectionController.text.trim().isEmpty ||
                                      _auditDepartmentController.text
                                          .trim()
                                          .isEmpty ||
                                      _auditSectionController.text
                                          .trim()
                                          .isEmpty ||
                                      _periodDurationController.text
                                          .trim()
                                          .isEmpty ||
                                      _shopController.dropDownValue == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please fill in all fields before submitting."),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }
                                  Navigator.pop(
                                      context); // ✅ Close the dialog first

                                  // ✅ Wait for dialog to close, then call submission outside using Future
                                  Future.delayed(Duration.zero, () {
                                    submitChecklistData(); // Call function in parent or parent context
                                  });
                                },
                                child: const Text("Submit"),
                              )),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void submitChecklistData() async {
    // if (_sectionController.text.trim().isEmpty ||
    //     _auditDepartmentController.text.trim().isEmpty ||
    //     _auditSectionController.text.trim().isEmpty ||
    //     _periodDurationController.text.trim().isEmpty ||
    //     _shopController.dropDownValue == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     const SnackBar(
    //       content: Text("Please fill in all fields before submitting."),
    //       backgroundColor: Colors.red,
    //     ),
    //   );
    //   return;
    // }

    setState(() {
      isLoading2 = true;
    });

    final answered = auditItems
        .where((item) => item.rating != null)
        .map((item) => {
              'category': item.group,
              'resp': item.resp,
              'query_name': item.description,
              'rating': item.rating,
              'comment': item.comment ?? '',
            })
        .toList();

    final payload = {
      "project_model_variant": _sectionController.text,
      "audit_department": _auditDepartmentController.text,
      "audit_line": _auditSectionController.text,
      "station_number": _shopController.dropDownValue!.name.toString(),
      "period": _periodDurationController.text,
      "document_ref": "AVA.QM.D.021",
      "original_date": "19.03.2019",
      "revision": "4",
      "items": answered,
    };

    try {
      final url = Api.api_url + "qfl3";
      final response = await httppostwithtoken(
        url,
        "${user['data']['token']}",
        payload,
        context,
      );

      if (!mounted) return;

      if (response != null && response['success'] == true) {
        awesomeTopSnackbar(
          context,
          "${response["msg"]}",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.green,
        );

        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (
            context,
          ) =>
                  QFLThreeList()),
          (route) => route.isFirst,
        );
      } else {
        awesomeTopSnackbar(
          context,
          "${response?["msg"] ?? "Failed to submit data."}",
          iconWithDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(),
            color: Colors.white,
          ),
          backgroundColor: Colors.red,
        );
      }
    } catch (e) {
      if (!mounted) return;
      debugPrint("❌ Error during saveData: $e");
      awesomeTopSnackbar(
        context,
        "Something went wrong. Please try again.",
        iconWithDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(),
          color: Colors.white,
        ),
        backgroundColor: Colors.red,
      );
    } finally {
      if (mounted) {
        setState(() {
          isLoading2 = false;
        });
      }
    }
  }
}
