import 'dart:async';
import 'dart:convert';
import 'dart:io';
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
  late TextEditingController NumberPlate;
  late TextEditingController VehicleChassis;
  late TextEditingController _enginrController;
  late TextEditingController _partNoController;
  late TextEditingController _colorController;
  late TextEditingController _lotNo;
  var errorText = '';
  var selectedCustomerId;
  var modelId;
  var payd;
  // late List<dynamic> models = [];
  late List<dynamic> models = [];
  // var checklistData;
  late List<dynamic> clients = [];
  late List<dynamic> checklist = [];
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
    VehicleChassis = TextEditingController();
    _enginrController = TextEditingController();
    _partNoController = TextEditingController();
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
      final results = await Future.wait([fetchClients(), fetchChecklist()]);
      // Check if any result is null or missing expected keys
      if (results[0] == null ||
          results[1] == null ||
          results[0]["data"] == null ||
          results[1]["data"] == null) {
        throw Exception("Failed to fetch data: Missing required information.");
      }
      setState(() {
        clients = results[0]["data"] as List;
        checklist = results[1]["data"] as List;
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

  List<List<dynamic>> checklistData = [];
  void storeChecklist() {
    try {
      checklistData = checklist.where((query) {
        return query['checked'] == 'OK' || query['checked'] == 'NOK';
      }).map((query) {
        return [query['id'], query['checked']];
      }).toList();
    } catch (e) {
      print('Error storing checklist: $e');
    }
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    // print(checklistData);
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
                                  label: 'Part No',
                                  hint: 'Enter part number',
                                  controller: _partNoController,
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
                                const SizedBox(height: 16),
                                Text(
                                  'Checklist',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  children: checklist.map((query) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          query['query_name']?.toString() ??
                                              'Unknown',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Row(
                                          children: [
                                            Text('OK'),
                                            Radio(
                                              value: 'OK',
                                              groupValue: query['checked'],
                                              onChanged: (value) {
                                                setState(() {
                                                  query['checked'] = value;
                                                  storeChecklist();
                                                });
                                              },
                                            ),
                                            Text('NOK'),
                                            Radio(
                                              value: 'NOK',
                                              groupValue: query['checked'],
                                              onChanged: (value) {
                                                setState(() {
                                                  query['checked'] = value;
                                                  storeChecklist();
                                                });
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    );
                                  }).toList(),
                                ),
                                const SizedBox(height: 24),
                                CustomButton(
                                  label: 'SAVE',
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Save the form data.
                                      if (_formKey.currentState!.validate()) {
                                        if (checklist.length !=
                                            (checklistData.length)) {
                                          ScaffoldMessenger.of(context)
                                              .showSnackBar(
                                            const SnackBar(
                                              margin: const EdgeInsets.all(50),
                                              padding: const EdgeInsets.all(10),
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              content: Text(
                                                  'Please fill all checklist items!'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                          return;
                                        }
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
      'part_no': _partNoController.text.trim(),
      'engine_no': _enginrController.text.trim(),
      'model_id': modelId,
      'status': '0',
      'route': _routeController.dropDownValue?.value,
      'vehicle_line': _lineController.dropDownValue?.value,
      'color': _colorController.text.trim(),
      'client_id': selectedCustomerId,
      'answers': checklistData,
    };
    // print(dataToStore);
    final progressDialog = ProgressDialog(context);
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
          .timeout(const Duration(seconds: 30));
      var responseBody = jsonDecode(response.body);
      print(responseBody);
      if (response.statusCode == 200 || responseBody['success'] == true) {
        handleSuccess();
      } else {
        // Check for 'errors' key
        String errorMessage = responseBody['msg'] ??
            responseBody['message'] ??
            "An error occurred";
        if (responseBody['errors'] != null) {
          final errors = responseBody['errors'] as Map<String, dynamic>;
          final errorDetails =
              errors.entries.map((e) => '${e.key}: ${e.value[0]}').join('\n');
          errorMessage += '\n$errorDetails';
        }
        showError(errorMessage);
      }
    } on TimeoutException {
      showError('Request timed out. Please try again.', color: Colors.orange);
    } on SocketException {
      showError('No Internet connection.');
    } catch (e) {
      print("Unexpected Error: $e");
      showError('Failed: ${e.toString()}');
    } finally {
      progressDialog.hide();
    }
  }

  void handleSuccess() {
    if (!context.mounted) return; // ✅ Add this check
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        content: Text('Record saved successfully!'),
        backgroundColor: Colors.green,
      ),
    );
    // Optional: Clear form fields if necessary
    _lotNo.clear();
    VehicleChassis.clear();
    _partNoController.clear();
    _enginrController.clear();
    _colorController.clear();
    Navigator.pop(context); // ✅ Now safely navigates back
  }

  void showError(String message, {Color color = Colors.red}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        margin: const EdgeInsets.all(50),
        padding: const EdgeInsets.all(10),
        behavior: SnackBarBehavior.floating,
        content: Text(message),
        backgroundColor: color,
      ),
    );
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

  Future fetchChecklist() async {
    String url = Api.api_url + "loadVehicleReceiving";
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
