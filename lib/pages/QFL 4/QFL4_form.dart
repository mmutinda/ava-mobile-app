import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/widgets.dart';

class QFL4_form extends StatefulWidget {
  final dynamic vehicleId;
  final dynamic modelId;

  const QFL4_form({super.key, required this.vehicleId, required this.modelId});

  @override
  State<QFL4_form> createState() => _QFL4_formState();
}

class _QFL4_formState extends State<QFL4_form> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final SingleValueDropDownController _shopController =
      SingleValueDropDownController();

  Map<String, dynamic> user = {};
  List<dynamic> shops = [];
  List<String> issues = [""];
  bool isLoading = true;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    loadUserAndShops();
  }

  Future<void> loadUserAndShops() async {
    setState(() => isLoading = true);
    try {
      final userData = await getuserdata();
      user = jsonDecode(userData);
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

  List<TextEditingController> issueControllers = [
    TextEditingController(),
  ];

  void _addIssue() {
    setState(() {
      issueControllers.add(TextEditingController());
    });
  }

  void _removeIssue(int index) {
    setState(() {
      issueControllers.removeAt(index);
    });
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      List<String> issues =
          issueControllers.map((controller) => controller.text.trim()).toList();

      // Print or send to server
      debugPrint("Collected issues: $issues");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Issues submitted successfully!")),
      );
    }
  }

  Future<Map<String, dynamic>?> fetchShops() async {
    String url = Api.api_url + "home";
    return await httpget(url, user['data']['token'], context);
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
        title: const Text('QFL 3 Form'),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(5),
              child: errorText.isNotEmpty
                  ? ErrorMessageWidget(
                      errorMessage: errorText, onRetry: loadUserAndShops)
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
                          child: ListView(
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: buildShopDropdown(),
                              ),
                              const SizedBox(height: 24),
                              if (_shopController.dropDownValue != null) ...[
                                const Text(
                                  'Issues',
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
                                ElevatedButton(
                                  child: const Text("SUBMIT"),
                                  style: ElevatedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    backgroundColor: mycolor,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: handleSubmit,
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
      dropDownList: shops
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

  List<Widget> buildIssueFields() {
    return List.generate(issueControllers.length, (index) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 12.0),
        child: Card(
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.only(right: 8.0, top: 12),
                  child:
                      Icon(Icons.warning_amber_rounded, color: Colors.orange),
                ),
                Expanded(
                  child: TextFormField(
                    controller: issueControllers[index],
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: InputDecoration(
                      labelText: 'Issue ${index + 1}',
                      labelStyle: const TextStyle(fontWeight: FontWeight.bold),
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
                if (issueControllers.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.red),
                    tooltip: "Delete this issue",
                    onPressed: () => _removeIssue(index),
                  ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void handleSubmit() {
    if (_formKey.currentState!.validate()) {
      print("Selected Shop ID: ${_shopController.dropDownValue?.value}");
      print("Issues: $issues");

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Form Submitted Successfully"),
          backgroundColor: Colors.green,
        ),
      );
    }
  }
}
