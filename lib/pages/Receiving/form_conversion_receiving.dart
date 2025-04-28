import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'dart:math';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader2.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';

class Conversion_receive_form extends StatefulWidget {
  @override
  State<Conversion_receive_form> createState() =>
      _Conversion_receive_formState();
}

class _Conversion_receive_formState extends State<Conversion_receive_form>
    with SingleTickerProviderStateMixin {
  var user = {};
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  late SingleValueDropDownController _carModel;
  late SingleValueDropDownController _customerModel;
  late TextEditingController _descriptionController;
  late TextEditingController NumberPlate;
  late TextEditingController VehicleChassis;
  late TextEditingController _enginrController;
  late TextEditingController _colorController;
  late TextEditingController _lotNo;
  var errorText = '';
  var selectedCustomerId;
  var modelId;
  var payd;
  // late List<dynamic> models = [];
  late List<dynamic> models = [];
  late List<dynamic> clients = [];
  List<Map<String, dynamic>> filteredModels = [];
  late List<dynamic> countries = [];
  bool isLoading = true;
  bool _isLoadingModels = false;
  String? error;
  String errorModel = '';
  FocusNode customerTextFieldFocusNode = FocusNode();
  FocusNode customerSearchFocusNode = FocusNode();
  FocusNode carModelTextFieldFocusNode = FocusNode();
  FocusNode carModelSearchFocusNode = FocusNode();
// Define your controllers
  final SingleValueDropDownController _routeController =
      SingleValueDropDownController();
  final SingleValueDropDownController _lineController =
      SingleValueDropDownController();
// Define your FocusNodes
  final FocusNode routeTextFieldFocusNode = FocusNode();
  final FocusNode routeSearchFocusNode = FocusNode();
  final FocusNode lineTextFieldFocusNode = FocusNode();
  final FocusNode lineSearchFocusNode = FocusNode();
// Sample color
  final Color mycolor = Colors.blue; // or whatever color you are using
  @override
  void initState() {
    _carModel = SingleValueDropDownController();
    _customerModel = SingleValueDropDownController();
    _descriptionController = TextEditingController();
    VehicleChassis = TextEditingController();
    _descriptionController = TextEditingController();
    _enginrController = TextEditingController();
    _colorController = TextEditingController();
    _lotNo = TextEditingController();
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
      _fetchData();
    });
    super.initState();
  }

  Future<void> _fetchData() async {
    setState(() {
      errorText = ''; // Initialize error text before fetching
      isLoading = true; // Show loading indicator
    });
    try {
      final results = await Future.wait([fetchClients()]);
      // Check if any result is null or missing expected keys
      if (results[0] == null || results[0]["data"] == null) {
        throw Exception("Failed to fetch data: Missing required information.");
      }
      setState(() {
        clients = results[0]["data"] as List;
        // filteredModels = List.from(models);
        // countries = results[1]["data"] as List;
        isLoading = false; // Stop loading indicator
      });
    } catch (e) {
      // Handle exceptions and update error text
      setState(() {
        errorText = e.toString(); // Display error message
        isLoading = false; // Stop loading indicator
      });
    }
  }

  @override
  void dispose() {
    _customerModel.dispose();
    _carModel.dispose();
    customerTextFieldFocusNode.dispose();
    customerSearchFocusNode.dispose();
    carModelTextFieldFocusNode.dispose();
    carModelSearchFocusNode.dispose();
    super.dispose();
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: Text(
          'Receiving  Form',
          // style: TextStyle(fontSize: 14),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(8.0),
              child: errorText.isNotEmpty
                  ? ErrorMessageWidget(
                      errorMessage: errorText,
                      onRetry: () {
                        _fetchData();
                      },
                    )
                  : SingleChildScrollView(
                      padding: const EdgeInsets.all(0),
                      child: Form(
                        key: _formKey,
                        child: Card(
                          color: Colors.white,
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (errorModel.isNotEmpty)
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Text(
                                      errorText,
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                DropDownTextField(
                                  controller: _customerModel,
                                  clearOption: false,
                                  dropDownIconProperty:
                                      IconProperty(color: mycolor, size: 30),
                                  textFieldDecoration: InputDecoration(
                                    labelText: 'Customer',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    // hintText: 'Choose Vehicle Model',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  textFieldFocusNode:
                                      customerTextFieldFocusNode,
                                  searchFocusNode: customerSearchFocusNode,
                                  dropDownItemCount: 5,
                                  enableSearch: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "*Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  // dropDownList: [],
                                  // dropDownList: clients.map((client) {
                                  //   return DropDownValueModel(
                                  //     name: "${client['name']}",
                                  //     value: client['id'],
                                  //   );
                                  // }).toList(),
                                  dropDownList: clients.map((client) {
                                    return DropDownValueModel(
                                      name: client['name']?.toString() ??
                                          'Unknown',
                                      value: client['id'],
                                    );
                                  }).toList(),
                                  onChanged: (val) async {
                                    if (val == null) {
                                      print('Error: Selected value is null.');
                                      return;
                                    }

                                    selectedCustomerId = val.value;
                                    setState(() {
                                      _isLoadingModels = true; // Start loading
                                    });

                                    try {
                                      final response = await fetchCarModel(
                                          selectedCustomerId);

                                      print(
                                          'FetchCarModel Response: $response');

                                      if (response != null &&
                                          response is Map<String, dynamic>) {
                                        if (response.containsKey('data') &&
                                            response['data'] is List) {
                                          models =
                                              List<Map<String, dynamic>>.from(
                                                  response['data']);
                                        } else {
                                          models = [];
                                          errorModel =
                                              'Error: "data" not found or is not a List.';

                                          print(
                                              '"data" not found or is not a List.');
                                        }
                                      } else {
                                        models = [];
                                        errorModel =
                                            ' Response is not a valid Map.';
                                        print('Response is not a valid Map.');
                                      }
                                    } on TimeoutException catch (_) {
                                      // Handle timeout error
                                      errorModel =
                                          'Fetching car models timed out.';
                                      print('Fetching car models timed out.');
                                      models = [];
                                    } on SocketException catch (_) {
                                      // Handle no internet connection error
                                      errorModel = 'No internet connection.';
                                      print('Error: No internet connection.');
                                      models = [];
                                    } catch (e) {
                                      // Handle other errors
                                      errorModel = '$e';
                                      print(
                                          'Exception caught while fetching car models: $e');
                                      models =
                                          []; // Clear models if error happens
                                    } finally {
                                      setState(() {
                                        _isLoadingModels =
                                            false; // Stop loading
                                        _carModel
                                            .clearDropDown(); // Clear previously selected car model
                                      });
                                    }
                                  },
                                ),
                                const SizedBox(height: 8),
                                _isLoadingModels
                                    ? Center(child: CircularProgressIndicator())
                                    : DropDownTextField(
                                        controller: _carModel,
                                        clearOption: false,
                                        dropDownIconProperty: IconProperty(
                                            color: mycolor, size: 30),
                                        textFieldFocusNode: textFieldFocusNode,
                                        textFieldDecoration: InputDecoration(
                                          labelText: 'Vehicle Model',
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0),
                                          ),
                                          filled: true,
                                          fillColor: Colors.grey.shade50,
                                        ),
                                        searchFocusNode: searchFocusNode,
                                        dropDownItemCount: 5,
                                        enableSearch: true,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "*Required";
                                          } else {
                                            return null;
                                          }
                                        },
                                        dropDownList: models.map((model) {
                                          return DropDownValueModel(
                                            name: "${model['model_name']}",
                                            value: model['id'],
                                          );
                                        }).toList(),
                                        onChanged: (val) {
                                          modelId = val.value;
                                        },
                                      ),
                                const SizedBox(height: 8),
                                CustomTextFormField(
                                  label: 'Chasis',
                                  hint: 'Enter Chasis No',
                                  controller: VehicleChassis,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '*Required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                CustomTextFormField(
                                  label: 'Engine No',
                                  hint: 'Enter engine number',
                                  controller: _enginrController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '*Required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                CustomTextFormField(
                                  // keyboardType: TextInputType.number,
                                  label: 'Lot No',
                                  hint: 'Enter Lot number',
                                  controller: _lotNo,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '*Required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                CustomTextFormField(
                                  label: 'Color',
                                  hint: 'write color',
                                  controller: _colorController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '*Required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                // Route Dropdown
                                DropDownTextField(
                                  controller: _routeController,
                                  clearOption: false,
                                  dropDownIconProperty:
                                      IconProperty(color: mycolor, size: 30),
                                  textFieldDecoration: InputDecoration(
                                    labelText: 'Route',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  textFieldFocusNode: routeTextFieldFocusNode,
                                  searchFocusNode: routeSearchFocusNode,
                                  dropDownItemCount: 5,
                                  enableSearch: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "*Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  dropDownList: [
                                    DropDownValueModel(
                                        name: "Route 1", value: "1"),
                                    DropDownValueModel(
                                        name: "Route 2", value: "2"),
                                    DropDownValueModel(
                                        name: "Route 3", value: "3"),
                                    DropDownValueModel(
                                        name: "Route 4", value: "4"),
                                    DropDownValueModel(
                                        name: "Route 5", value: "5"),
                                  ],
                                  onChanged: (val) {
                                    // Handle route change
                                  },
                                ),
                                SizedBox(height: 8), // space between dropdowns
                                // Line Dropdown
                                DropDownTextField(
                                  controller: _lineController,
                                  clearOption: false,
                                  dropDownIconProperty:
                                      IconProperty(color: mycolor, size: 30),
                                  textFieldDecoration: InputDecoration(
                                    labelText: 'Line',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
                                    ),
                                    filled: true,
                                    fillColor: Colors.grey.shade50,
                                  ),
                                  textFieldFocusNode: lineTextFieldFocusNode,
                                  searchFocusNode: lineSearchFocusNode,
                                  dropDownItemCount: 5,
                                  enableSearch: true,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "*Required";
                                    } else {
                                      return null;
                                    }
                                  },
                                  dropDownList: [
                                    DropDownValueModel(
                                        name: "Line 1", value: "line1"),
                                    DropDownValueModel(
                                        name: "Line 2", value: "line2"),
                                    DropDownValueModel(
                                        name: "Line 3", value: "line3"),
                                  ],
                                  onChanged: (val) {
                                    // Handle line change
                                  },
                                ),

                                const SizedBox(height: 24),
                                CustomButton(
                                  label: 'SAVE',
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Save the form data.
                                      if (_formKey.currentState!.validate()) {
                                        PostData();
                                      }
                                      print('Form submitted');
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
            ),
    );
  }

  void PostData() async {
    final dataToStore = {
      'lot_no': _lotNo.text.trim(),
      'vin_no': VehicleChassis.text.trim(),
      'engine_no': _enginrController.text.trim(),
      'model_id': modelId,
      'status': '0',
      'route': _routeController.dropDownValue?.value,
      'vehicle_line': _lineController.dropDownValue?.value,
      'color': _colorController.text.trim(),
      'client_id': selectedCustomerId,
    };

    final ProgressDialog progressDialog = ProgressDialog(context);
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
      // Defensive checks
      if (user == null ||
          user['data'] == null ||
          user['data']['token'] == null) {
        throw Exception('User token is missing!');
      }

      final response = await http
          .post(
            Uri.parse(Api.api_url + "postScheduledUnit"),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
              'Authorization': 'Bearer ${user['data']['token']}',
            },
            body: jsonEncode(dataToStore),
          )
          .timeout(const Duration(seconds: 30)); // timeout handling

      if (response.statusCode == 200) {
        var responseBody = jsonDecode(response.body);
        // log(jsonEncode(responseBody));

        if (responseBody['success'] == true) {
          // Success
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Record saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  'Failed: ${responseBody['msg'] ?? "Unknown server error"}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        // HTTP Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('HTTP Error: ${response.statusCode}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } on TimeoutException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request timed out. Please try again.'),
          backgroundColor: Colors.orange,
        ),
      );
    } on SocketException catch (_) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No Internet connection.'),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      print("Unexpected Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      progressDialog.hide();
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

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  const CustomTextFormField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
    this.keyboardType,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      keyboardType: keyboardType == null ? TextInputType.text : keyboardType,
      controller: controller,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        // hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}

class CustomDropdownField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final List<Map<String, String>> items;
  final Function(String?) onChanged;
  const CustomDropdownField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    required this.items,
    required this.onChanged,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8.0),
        ),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
      onChanged: onChanged,
      items: items
          .map((item) => DropdownMenuItem(
                value: item['value'],
                child: Text(item['name']!),
              ))
          .toList(),
    );
  }
}

class CustomDateField extends StatelessWidget {
  final String label;
  final DateTime selectedDate;
  final VoidCallback onTap;
  const CustomDateField({
    Key? key,
    required this.label,
    required this.selectedDate,
    required this.onTap,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: Colors.blue
                  .shade50, // Light blue background like Bootstrap alert-primary
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.blue, width: 1), // Blue border
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade900, // Darker blue for text
                    ),
                  ),
                ),
                Text(
                  DateFormat('dd-MM-yyyy').format(selectedDate),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.blue.shade800, // Matching text color
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const CustomButton({
    Key? key,
    required this.label,
    required this.onPressed,
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
        onPressed: onPressed,
        child: Text(label),
      ),
    );
  }
}
