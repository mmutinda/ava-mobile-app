import 'dart:async';
import 'dart:convert';

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
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
  late SingleValueDropDownController _country;
  late TextEditingController _descriptionController;
  late TextEditingController NumberPlate;
  late TextEditingController VehicleChassis;
  late TextEditingController _enginrController;
  late TextEditingController _ownerController;
  var errorText = '';
  var val;
  var jobcard;
  var stageid;
  late List<dynamic> models = [];
  late List<dynamic> countries = [];
  bool isLoading = true;
  String? error;
  DateTime _toBePickedOn = DateTime.now();
  DateTime _receivedOn = DateTime.now();
  @override
  void initState() {
  
    _carModel = SingleValueDropDownController();
    _descriptionController = TextEditingController();
    VehicleChassis = TextEditingController();
    _descriptionController = TextEditingController();
    _ownerController = TextEditingController();
    _enginrController = TextEditingController();

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
      final results = await Future.wait([fetchCarModel(), fetchcountry()]);

      // Check if any result is null or missing expected keys
      if (results[0] == null ||
          results[1] == null ||
          results[0]["data"] == null ||
          results[1]["data"] == null) {
        throw Exception("Failed to fetch data: Missing required information.");
      }

      setState(() {
        // models = results[0]["data"] as List;
        countries = results[1]["data"] as List;
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

  Future<void> _selectDate(BuildContext context, String field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: field == 'To be Picked On' ? _toBePickedOn : _receivedOn,
      firstDate: DateTime(2022),
      lastDate: DateTime(2025),
    );
    if (picked != null) {
      setState(() {
        if (field == 'To be Picked On') {
          _toBePickedOn = picked;
        } else {
          _receivedOn = picked;
        }
      });
    }
  }

  @override
  void dispose() {
   
    _country.dispose();
    _country.dispose();
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
                                CustomDateField(
                                  label: 'Received On',
                                  selectedDate: _receivedOn,
                                  onTap: () =>
                                      _selectDate(context, 'Received On'),
                                ),
                                const SizedBox(height: 8),
                                CustomTextFormField(
                                  label: 'Customer ',
                                  hint: 'Customer name',
                                  controller: _ownerController,
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
                                DropDownTextField(
                                  controller: _carModel,
                                  clearOption: false,
                                  dropDownIconProperty:
                                      IconProperty(color: mycolor, size: 30),
                                  textFieldFocusNode: textFieldFocusNode,
                                  textFieldDecoration: InputDecoration(
                                    labelText: 'Vehicle Model',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    // hintText: 'Choose Vehicle Model',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8.0),
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
                                  // dropDownList: [],
                                  dropDownList: models.map((model) {
                                    return DropDownValueModel(
                                      name:
                                          "${model['name']} - ${model['brand']['name']} ${model['model']['name']}",
                                      value: model['id'],
                                    );
                                  }).toList(),
                                  onChanged: (val) {
                                    stageid = val.value;
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
                                  label: 'Lot No',
                                  hint: 'Enter Lot number',
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
                                  label: 'Color',
                                  hint: 'write color',
                                  controller: _enginrController,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return '*Required';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  controller: _descriptionController,
                                  keyboardType: TextInputType.multiline,
                                  minLines: 2,
                                  maxLines:
                                      null, // Allows the text area to expand as needed

                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    // hintText: 'Enter description',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(5.0),
                                      borderSide:
                                          BorderSide(color: Colors.grey),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),
                                CustomButton(
                                  label: 'SAVE',
                                  onPressed: () {
                                    if (_formKey.currentState!.validate()) {
                                      // Save the form data.
                                      if (_formKey.currentState!.validate()) {
                                        PostData(
                                            // _vehicle.dropDownValue!.value,
                                            DateFormat('dd-MM-yyyy')
                                                .format(_receivedOn),
                                            _ownerController.text,
                                            VehicleChassis.text,
                                            NumberPlate.text,
                                            _carModel.dropDownValue!.value,
                                            _enginrController.text,
                                            _descriptionController.text);
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

  void PostData(
    Received_on,
    owner,
    vehicle_chassis,
    plate_number,
    country,
    engNo,
    desc,
  ) async {
    final dataToStore = {
      'product_id': null,
      'origin': country,
      'sku': vehicle_chassis,
      'receiving_date': Received_on,
      'notes': desc,
      'engineno': engNo,
      'owner': owner
    };
    // print(widget.userToken);
    print('Data to store: $dataToStore');
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
      final response = await http.post(
        Uri.parse(Api.api_url + "ApiCreateReceiveVehicle"),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer ${user['token']}',
        },
        body: jsonEncode(dataToStore),
      );
      // print(response.body);
      var responseBody = jsonDecode(response.body);
      if (response.statusCode == 200) {
        // Success

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Record saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context); // Navigate back or to another screen
      } else {
        // API Error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed: ${responseBody['msg'] ?? "Something went wrong"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print("==================");
      // ScaffoldMessenger.of(context)
      //     .showSnackBar(snackBar("Failed ${e}", Colors.red));
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

  Future fetchCarModel() async {
    // String assemblyurl = Api.api_url + "getApiVehicleModel";
    String assemblyurl = "https://countriesnow.space/api/v0.1/countries";

    var responsedata = await httpget(assemblyurl, user["token"], context);
    // print(responsedata);
    return responsedata;
  }

  Future fetchcountry() async {
    String assemblyurl = "https://countriesnow.space/api/v0.1/countries";

    var responsedata = await httpget(assemblyurl, user["token"], context);
    // print(responsedata['data'][1]['country']);
    return responsedata;
  }
}

class CustomTextFormField extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const CustomTextFormField({
    Key? key,
    required this.label,
    required this.hint,
    required this.controller,
    this.validator,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
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
