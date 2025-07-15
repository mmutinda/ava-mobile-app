import 'dart:convert';
import 'dart:developer';
import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';

class QFL4_form extends StatefulWidget {
  final dynamic vehicleId;
  final dynamic modelId;
  final List<dynamic> shops;

  const QFL4_form(
      {super.key,
      required this.vehicleId,
      required this.modelId,
      required this.shops});

  @override
  State<QFL4_form> createState() => _QFL4_formState();
}

class _QFL4_formState extends State<QFL4_form> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SingleValueDropDownController _shopController =
      SingleValueDropDownController();
  final SingleValueDropDownController _vehicle =
      SingleValueDropDownController();
  bool isLoading2 = false;
  Map<String, dynamic> user = {};
  // List<dynamic> shops = [];
  List<dynamic> vehicles = [];
  List<String> issues = [""];
  bool isLoading = true;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    loadDataLists();
  }

  Future<Map<String, dynamic>?> fetchShops() async {
    String url = Api.api_url + "home";
    return await httpget(url, user['data']['token'], context);
  }

  Future<Map<String, dynamic>?> fetchScheduledVehicles() async {
    String url = Api.api_url + "sheduledunits"; // Replace with correct path
    return await httpget(url, user['data']['token'], context);
  }

  Future<void> loadDataLists() async {
    setState(() {
      isLoading = true;
      errorText = '';
    });

    try {
      final userData = await getuserdata();
      user = jsonDecode(userData);
    } catch (e) {
      setState(() {
        isLoading = false;
        errorText = "Failed to load user data: $e";
      });
      return;
    } finally {
      setState(() => isLoading = false);
    }
  }

  List<TextEditingController> issueControllers = [
    TextEditingController(),
  ];
  List<String?> issueClasses = [
    'A'
  ]; // initialize with default value for the first issue

  void _addIssue() {
    setState(() {
      issueControllers.add(TextEditingController());
      issueClasses.add('A'); // default to class A
    });
  }

  void _removeIssue(int index) {
    setState(() {
      issueControllers.removeAt(index);
      issueClasses.removeAt(index);
    });
  }

  @override
  void dispose() {
    for (var controller in issueControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QFL 4 Form'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(5),
              child: errorText.isNotEmpty
                  ? ErrorMessageWidget(
                      errorMessage: errorText, onRetry: loadDataLists)
                  : Form(
                      key: _formKey,
                      child: Card(
                        color: Colors.white,
                        elevation: 1,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(5),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: buildShopDropdown(),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 24),
                              if (_shopController.dropDownValue != null) ...[
                                const Text(
                                  'Record an issue',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                ...buildIssueFields(),
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: TextButton.icon(
                                    onPressed: _addIssue,
                                    icon: const Icon(Icons.add_circle,
                                        color: Colors.green),
                                    label: const Text("Add Issue"),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                isLoading2
                                    ? CustomLoader()
                                    : Container(
                                        width: double.infinity,
                                        child: ElevatedButton(
                                          child: const Text("SUBMIT"),
                                          style: ElevatedButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 14),
                                            backgroundColor: mycolor,
                                            foregroundColor: Colors.white,
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                          ),
                                          onPressed: () {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              final collectedIssues =
                                                  List.generate(
                                                      issueControllers.length,
                                                      (index) {
                                                return {
                                                  'issue':
                                                      issueControllers[index]
                                                          .text
                                                          .trim(),
                                                  'class': issueClasses[index],
                                                };
                                              });

                                              debugPrint(
                                                  "Selected Shop ID: ${_shopController.dropDownValue?.value}");
                                              debugPrint(
                                                  "Submitted Issues with Classes: $collectedIssues");
                                              _showConfirmDialog(context);
                                            }
                                          },
                                        ),
                                      ),
                              ] else ...[
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  margin: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.orange.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.orange),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: const [
                                      Icon(Icons.warning,
                                          color: Colors.orange, size: 36),
                                      SizedBox(height: 10),
                                      Text(
                                        "Please select a  Shop first.",
                                        style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.black87),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
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
      dropDownList: widget.shops
          .map((shop) => DropDownValueModel(
                name: shop['shop_name'] ?? 'Unknown',
                value: shop['id'],
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          issues = [""];
        });
      },
    );
  }

  Widget buildUnitDropdown() {
    return DropDownTextField(
      controller: _vehicle,
      enableSearch: true,
      clearOption: false,
      dropDownIconProperty: IconProperty(color: Colors.blue, size: 28),
      textFieldDecoration: InputDecoration(
        labelText: 'Select Unit',
        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
        filled: true,
        fillColor: Colors.grey.shade100,
      ),
      validator: (val) => val == null || val.isEmpty ? "*Required" : null,
      dropDownList: vehicles
          .map((unit) => DropDownValueModel(
                name: unit['vin_no'] ?? 'Unknown',
                value: unit['id'],
              ))
          .toList(),
      onChanged: (value) {
        setState(() {
          issues = [""];
        });
      },
    );
  }

  List<Widget> buildIssueFields() {
    return List.generate(issueControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: TextFormField(
                        controller: issueControllers[index],
                        maxLines: null,
                        // keyboardType: TextInputType.multiline,
                        decoration: InputDecoration(
                          labelText: issueControllers.length == 1
                              ? 'Issue'
                              : 'Issue No. ${index + 1}',
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.bold),
                          hintText: "Enter issue details here...",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Issue ${index + 1} is required";
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      // flex: 1,
                      child: DropdownButtonFormField<String>(
                        value: issueClasses[index],
                        decoration: InputDecoration(
                          labelText: 'Class',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: false,
                          fillColor: Colors.grey.shade100,
                        ),
                        items: ['A', 'B', 'C', 'D']
                            .map((classLabel) => DropdownMenuItem(
                                  value: classLabel,
                                  child: Text(classLabel),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            issueClasses[index] = value;
                          });
                        },
                        validator: (value) =>
                            value == null ? 'Class is required' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (issueControllers.length > 1)
                      IconButton(
                        icon: const Icon(Icons.delete_forever,
                            color: Colors.redAccent),
                        tooltip: "Delete this issue",
                        onPressed: () => _removeIssue(index),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void _showConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevents closing by tapping outside
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 8),
            Text('Confirm Submission'),
          ],
        ),
        content: const Text(
          'Are you sure you want to submit the data?',
          style: TextStyle(fontSize: 16),
        ),
        actionsPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        actions: [
          TextButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.cancel, color: Colors.red),
            label: const Text('Cancel', style: TextStyle(color: Colors.red)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              submitData(); // Then call the function
            },
            icon: const Icon(Icons.check),
            label: const Text('Yes, Submit'),
          ),
        ],
      ),
    );
  }

  void submitData() async {
// Validate only new entries
    final collectedIssues = List.generate(issueControllers.length, (index) {
      return {
        'issue': issueControllers[index].text.trim(),
        'classification': issueClasses[index],
      };
    });

    // ✅ Create payload for Laravel
    final payload = {
      "vehicle_id": widget.vehicleId,
      "shop_id": _shopController.dropDownValue!.value,
      "items": collectedIssues,
    };
    log(jsonEncode(payload));
    setState(() {
      isLoading2 = true;
    });

    try {
      final url = Api.api_url + "saveqfl4";
      final response = await httppostwithtoken(
        url,
        "${user['data']['token']}",
        payload,
        context,
      );

      setState(() {
        isLoading2 = false;
      });
      log(jsonEncode(response));
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

        Navigator.pop(context, "success");
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
      setState(() {
        isLoading2 = false;
      });
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
      // Remove or update this block if 'isLoading2' is not defined elsewhere
      // If you want to use a loading state, define 'isLoading2' as a bool in your state
      setState(() {
        isLoading2 = false;
      });
      setState(() {
        _shopController.setDropDown(null);
      });
    }
  }
}
