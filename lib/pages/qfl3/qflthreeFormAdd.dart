import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
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
  // final String sn;
  final String category;
  final String resp;
  final String description;
  int? rating;
  String? comment;

  AuditChecklistItem({
    // required this.sn,
    required this.category,
    required this.resp,
    required this.description,
    this.rating,
    this.comment,
  });
}

class Item {
  final category;
  final resp;
  final query_name;
  final rating;

  final comment;

  Item({
    required this.category,
    required this.query_name,
    required this.rating,
    required this.resp,
    required this.comment,
  });

  factory Item.fromJson(Map<String, dynamic> json) {
    return Item(
      category: json['category'],
      query_name: json['query_name'],
      rating: json['rating'],
      resp: json['resp'],
      comment: json['comment'],
    );
  }
}

class AuditChecklistPageAdd extends StatefulWidget {
  final id;

  const AuditChecklistPageAdd({super.key, required this.id});
  // final List<AuditChecklistItem> previouslyAnsweredItems;

  // const AuditChecklistPageAdd(
  //     {super.key, required this.previouslyAnsweredItems});

  @override
  State<AuditChecklistPageAdd> createState() => _AuditChecklistPageAddState();
}

class _AuditChecklistPageAddState extends State<AuditChecklistPageAdd> {
  List<AuditChecklistItem> auditItems = [
    AuditChecklistItem(
        category: 'Man',
        resp: 'Prodn',
        description: 'Is the Operator Skill Level match the requirement'),
    AuditChecklistItem(
        category: 'Man',
        resp: 'Prodn',
        description: 'Are the Self Check points known & confirmed by operator'),
    AuditChecklistItem(
        category: 'Man',
        resp: 'Prodn',
        description: 'check station condition before & at the end of shift'),
    AuditChecklistItem(
        category: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator aware of the torque parameter & torque tool set value'),
    AuditChecklistItem(
        category: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator awares about the consequences of the keypoints in the operation'),
    AuditChecklistItem(
        category: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator aware of the quality requirements/safety requirements'),
    AuditChecklistItem(
        category: 'Man',
        resp: 'Prodn',
        description:
            'Is the operator aware of the consequence of the failure.'),
    AuditChecklistItem(
        category: 'Man',
        resp: 'Prodn',
        description: 'Are standard work instructions followed by the Operator'),
    AuditChecklistItem(
        category: 'Machine',
        resp: 'ME',
        description: 'Are Specified Equipments / Tools used'),
    AuditChecklistItem(
        category: 'Machine',
        resp: 'ME',
        description:
            'Are they calibrated (in case of gauges) / Are they periodically checked (incase of Equip)'),
    AuditChecklistItem(
        category: 'Machine',
        resp: 'FM',
        description:
            'Are they calibrated (in case of gauges) / Are they periodically checked (incase of Equip)'),
    AuditChecklistItem(
        category: 'Machine',
        resp: 'QM',
        description:
            'Are they calibrated (in case of gauges) / Are they periodically checked (incase of Equip)'),
    AuditChecklistItem(
        category: 'Machine',
        resp: 'ME',
        description: 'Is the tool use procedure adhered to requirement'),
    AuditChecklistItem(
        category: 'Machine',
        resp: 'ME',
        description: ' Is the Poka yoke working'),
    AuditChecklistItem(
        category: 'Machine',
        resp: 'ME',
        description: 'Is the boundary marking on each station visible'),
    AuditChecklistItem(
        category: 'Machine',
        resp: 'ME',
        description: 'Is the tool parking available and is it being utilized?'),
    AuditChecklistItem(
        category: 'Machine',
        resp: 'ME',
        description: 'Is the tool parking available and is it being utilized?'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description: 'Is the Process Flow update as on date available'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description:
            'Are the SWI/JES/Assembly manual available in the station?'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description: 'Are the operations sequence defined'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description: 'Is the Assembly procedure being followed?'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description: 'Check station condition before & at the end of shift'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description: ' Is DS/DZ characteristic monitoring Process done?'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description: 'Are parts easily identified after shopping?'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description: 'Is there a safe ergonomics practiced in the station'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description:
            'Is there 5S practice in the station during working hours?'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description:
            ' Is the station organized during production? 5S in process?'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description:
            ' Are defects properly tracked in History card / check  sheets'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description: '  Is the skill matrix available in the station?'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description:
            '  Is the product quality standard known to the operators?'),
    AuditChecklistItem(
        category: 'Method',
        resp: 'Prodn',
        description:
            'Is there a process in place to capture the lessons learnt in the respective stations'),
    AuditChecklistItem(
        category: 'Material',
        resp: 'Logistic',
        description: ' Is adequate traceability available for material'),
    AuditChecklistItem(
        category: 'Material',
        resp: 'Logistic',
        description: ' Is adequate traceability available for material'),
    AuditChecklistItem(
        category: 'Material',
        resp: 'Logistic',
        description: 'Are non-conformance parts handled as per procedure'),
    AuditChecklistItem(
        category: 'Material',
        resp: 'Logistic',
        description:
            'Is the work station is free of unwanted material to avoid wrong assembly'),
    AuditChecklistItem(
        category: 'Milieu',
        resp: 'Prodn',
        description:
            'Is the lighting appropriate with respect to the station requirement'),
    AuditChecklistItem(
        category: 'Milieu',
        resp: 'Prodn',
        description: 'Is there an identified waste bin in the station?'),
    AuditChecklistItem(
        category: 'Milieu',
        resp: 'Prodn',
        description: 'Are the safety equipments available to operator'),
    AuditChecklistItem(
        category: 'Milieu',
        resp: 'Prodn',
        description: 'Is Control of Hazardous materials adhered to standards'),
    AuditChecklistItem(
        category: 'Milieu',
        resp: 'Logistic',
        description: 'Is Control of Hazardous materials adhered to standards'),
    AuditChecklistItem(
        category: 'Milieu',
        resp: 'Prodn',
        description:
            'Is Safety instruction displayed in the workstation (PPE)?'),
  ];

  String? selectedResp = "Prodn";
  String? selectedcategory = "Man";

  List<AuditChecklistItem> get filteredItems {
    return auditItems.where((item) {
      final matchResp = selectedResp == null || item.resp == selectedResp;
      final matchcategory =
          selectedcategory == null || item.category == selectedcategory;
      return matchResp && matchcategory;
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
  bool isItemPreviouslyAnswered(AuditChecklistItem item) {
    return items.any((prev) =>
        prev.category == item.category &&
        prev.resp == item.resp &&
        prev.query_name == item.description &&
        prev.rating != null);
  }

  final SingleValueDropDownController _shopController =
      SingleValueDropDownController();

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
      // loadShops();
      initializeFormData();
    }).catchError((error) {
      print(error);
    });
  }

  List<Item> items = [];

  Future<void> initializeFormData() async {
    print('Fetching previous data from: ${Api.api_url}editqfl3/${widget.id}');
    setState(() => isLoading = true);

    try {
      // Load Shops
      final shopResponse = await fetchShops();
      if (shopResponse != null && shopResponse["data"]["shop"] != null) {
        shops = shopResponse["data"]["shop"];
      }

      // Load Previous Data
      final response = await http.get(
        Uri.parse('${Api.api_url}editqfl3/${widget.id}'),
        headers: {
          'Authorization': 'Bearer ${user['data']['token']}',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final Map<String, dynamic> record = data['data'];

        if (record['items'] != null && record['items'] is List) {
          items = (record['items'] as List)
              .map((itemJson) => Item.fromJson(itemJson))
              .toList();
        }
      } else {
        throw Exception(
            'Failed to load records. Status code: ${response.statusCode}');
      }
    } catch (e) {
      errorText = "Error during initialization: $e";
    } finally {
      setState(() => isLoading = false);
    }
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
    final uniquecategorys = auditItems.map((e) => e.category).toSet().toList();

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
                Text("Group: ${selectedcategory}",
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
              ? ErrorMessageWidget(
                  errorMessage: errorText, onRetry: initializeFormData)
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
                                              value:
                                                  selectedcategory!.isNotEmpty
                                                      ? selectedcategory
                                                      : null,
                                              hint:
                                                  const Text("Select category"),
                                              items: uniquecategorys
                                                  .map((category) {
                                                return DropdownMenuItem<String>(
                                                  value: category,
                                                  child: Text(category),
                                                );
                                              }).toList(),
                                              onChanged: (value) => setState(
                                                  () => selectedcategory =
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
                                          size: 48,
                                          color: Colors.grey.shade500),
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
                                  final alreadyFilled =
                                      isItemPreviouslyAnswered(item);

                                  return Card(
                                    color: Colors.white,
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    margin:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    child: Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          /// Row with title and badge
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Expanded(
                                                child: Text(
                                                  "${index + 1}. ${item.description}",
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              if (alreadyFilled)
                                                Container(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  decoration: BoxDecoration(
                                                    color:
                                                        Colors.green.shade100,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            20),
                                                    border: Border.all(
                                                        color: Colors
                                                            .green.shade600),
                                                  ),
                                                  child: const Text(
                                                    "Already Filled",
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.green,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ),
                                            ],
                                          ),

                                          const SizedBox(height: 10),

                                          /// Rating chips
                                          /// if
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
                                                onSelected: alreadyFilled
                                                    ? null
                                                    : (_) {
                                                        setState(() {
                                                          item.rating = value;
                                                        });
                                                      },
                                              );
                                            }),
                                          ),

                                          const SizedBox(height: 10),

                                          /// Comment field
                                          TextFormField(
                                            initialValue: item.comment,
                                            enabled: !alreadyFilled,
                                            decoration: InputDecoration(
                                              hintText:
                                                  'Add comment (optional)',
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
                              )),
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
                          '📄Confirm to Add',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
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
                                  onPressed: () async {
                                    Navigator.pop(
                                        context); // ✅ Close the dialog first

                                    // ✅ Wait for dialog to close, then call submission outside using Future
                                    Future.delayed(Duration.zero, () {
                                      submitChecklistData(); // Call function in parent or parent context
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size(120, 50),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8)),
                                    backgroundColor: mycolor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text("Confirm"),
                                ),
                              ),
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

    // Build payload array from answered items
    final answered = auditItems
        .where((item) => item.rating != null)
        .map((item) => {
              'category': item.category,
              'resp': item.resp,
              'query_name': item.description,
              'rating': item.rating,
              'comment': item.comment ?? '',
            })
        .toList();
    var payload = {
      "qfl3_id": widget.id,
      "items": answered,
    };

    try {
      String url = Api.api_url + "qfl3add";
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
          MaterialPageRoute(builder: (context) => QFLThreeList()),
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
