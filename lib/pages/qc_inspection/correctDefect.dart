import 'dart:convert';
import 'dart:io';

import 'package:awesome_top_snackbar/awesome_top_snackbar.dart';
import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/api.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/functions.dart';
import 'package:isuze_pqcs/common/loader.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:progress_dialog_null_safe/progress_dialog_null_safe.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CorrectDefect extends StatefulWidget {
  final vehicle_id;
  final route_id;
  final job_no;

  const CorrectDefect({Key? key, this.vehicle_id, this.route_id, this.job_no})
      : super(key: key);

  @override
  State<CorrectDefect> createState() => _CorrectDefectState();
}

class _CorrectDefectState extends State<CorrectDefect> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String? selectedComponent;
  late TextEditingController correctedByController;
  late TextEditingController remarksController;
  String? ans;
  File? selectedImages;

  var user = {};
  @override
  void initState() {
    super.initState();
    correctedByController = TextEditingController(text: '');
    remarksController = TextEditingController(text: '');
    getuserdata().then((value) {
      setState(() {
        user = jsonDecode(value);
      });
    });
  }

  final ImagePicker _picker = ImagePicker();

  Future<void> captureImage() async {
    final XFile? pickedFile = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
      maxHeight: 1000,
      maxWidth: 1000,
    );

    setState(() {
      if (pickedFile != null) {
        selectedImages = File(pickedFile.path);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No image captured')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 192, 85, 3),
            ),
            child: Text(
              "CORRECT DEFECT",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          gap(),
          DropDownTextField(
            clearOption: false,
            listSpace: 20,
            listPadding: ListPadding(top: 20),
            enableSearch: false,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Required field";
              }
              return null;
            },
            textFieldDecoration: InputDecoration(
              labelText: 'Answer',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              hintText: 'Choose Answer',
              border: InputBorder.none,
              filled: true,
              fillColor: Colors.grey.shade200,
            ),
            dropDownList: const [
              DropDownValueModel(name: 'OK', value: "OK"),
              DropDownValueModel(name: 'NOK', value: "NOK"),
            ],
            onChanged: (val) {
              ans = val.value;
            },
          ),
          gap(),
          TextFormField(
            // maxLines: null,
            controller: correctedByController,
            validator: (value) =>
                value == null || value.trim().isEmpty ? 'Required field' : null,
            decoration: InputDecoration(
                labelText: 'corrected By',
                isDense: true,
                hintText: 'Write Name',
                border: InputBorder.none,
                filled: true,
                fillColor: mycolor.withOpacity(0.1)),
          ),
          gap(),
          // gap(),
          TextFormField(
            maxLines: null,
            controller: remarksController,
            decoration: InputDecoration(
                labelText: 'Remarks',
                isDense: true,
                hintText: 'Write text',
                border: InputBorder.none,
                filled: true,
                fillColor: mycolor.withOpacity(0.1)),
          ),
          if (selectedImages == null)
            ElevatedButton.icon(
              icon: Icon(Icons.camera),
              style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5))),
              label: Text('Capture Image'),
              onPressed: () async {
                await captureImage();
              },
            ),
          // Text('${selectedImages}'),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: selectedImages != null
                ? SizedBox(
                    height: 150,
                    width: double.infinity,
                    child: Center(
                      child: Stack(
                        children: [
                          Image.file(
                            selectedImages!,
                            fit: BoxFit.contain,
                          ),
                          InkWell(
                            onTap: () {
                              print("ok");
                              setState(() {
                                selectedImages = null;
                              });
                            },
                            child: Container(
                              // alignment: Alignment.topRight,

                              child: CircleAvatar(
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 30,
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ))
                : Container(), // or any other placeholder widget
          ),
          // Spacer(),
          AppButton(
            text: "SAVE",
            onTap: () async {
              if (_formKey.currentState!.validate()) {
                showConfirmDialogCustom(
                  primaryColor: Colors.amber[900],
                  context,
                  title: "Do you want to Save?",
                  onAccept: (val) async {
                    final ProgressDialog progressDialog =
                        ProgressDialog(context);
                    progressDialog.style(
                      message: 'loading...',
                      child: CustomLoader(),
                      progressWidget: CircularProgressIndicator(),
                    );
                    await progressDialog.show();

                    try {
                      String url = Api.api_url + "correctdefect";
                      var request =
                          http.MultipartRequest('POST', Uri.parse(url));

                      request.headers.addAll({
                        'Accept': 'application/json',
                        'Authorization': 'Bearer ${user['data']['token']}',
                      });
                      // var answer2 = {"name":ans};
                      request.fields['defect_id'] =
                          widget.vehicle_id.toString();
                      request.fields['answer'] = ans.toString();
                      request.fields['remarks'] = remarksController.text;
                      request.fields['defect_corrected_by'] =
                          correctedByController.text;
                      if (selectedImages != null) {
                        var imageFile = await http.MultipartFile.fromPath(
                          'icon',
                          selectedImages!.path,
                        );
                        request.files.add(imageFile);
                      }
                      // request.files.add(imageFile);
                      print(request.files);
                      var response = await request.send();
                      // Get response
                      var response2 = await http.Response.fromStream(response);
                      var responseData = jsonDecode(response2.body);
                      print('Request URL: $url');
                      print('Request Fields: ${request.fields}');
                      if (request.files.isNotEmpty) {
                        print('Request Files:');
                        request.files.forEach((file) {
                          print('${file.field}: ${file.filename}');
                        });
                      }
                      log(jsonEncode(responseData));
                      if (responseData['success']) {
                        await progressDialog.hide();
                        awesomeTopSnackbar(
                          context,
                          "${responseData['msg']}",
                          iconWithDecoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(),
                              color: Colors.white),
                          icon: Icon(
                            Icons.done,
                            color: Colors.green[900],
                          ),
                        );
                        Navigator.pop(context);
                      } else {
                        await progressDialog.hide();

                        awesomeTopSnackbar(context, "${responseData['msg']}",
                            iconWithDecoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(),
                                color: Colors.white),
                            icon: Icon(
                              Icons.close,
                              color: Colors.red,
                            ),
                            backgroundColor: Colors.red[900]);
                        Navigator.pop(context);
                      }
                      return response;
                    } catch (e) {
                      await progressDialog.hide();
                      print("error : $e");
                    } finally {
                      await progressDialog.hide();
                    }

                    // Navigator.pop(context);
                  },
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
