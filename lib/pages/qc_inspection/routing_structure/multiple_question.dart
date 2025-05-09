import 'dart:convert';
import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:nb_utils/nb_utils.dart';

class MultipleQuestion extends StatefulWidget {
  final int id;
  final int index;
  final options;
  final can_sign;
  final checkanswered;
  final String? initialRadioValue;
  final String? initialImage;
  // final List options;
  final String question;
  final List<Map<String, String>> users; // List of users with name and email
  final ValueChanged<List<dynamic>> onValuesChanged;
  final ValueChanged<String> onRadioChanged;
  final ValueChanged<String> onValueChanged2;
  final ValueChanged<File?> onImageChanged; // Allow null for deletion
  final ValueChanged<List<String>> onUsersSelected;
  const MultipleQuestion({
    Key? key,
    required this.id,
    required this.index,
    required this.onUsersSelected,
    // required this.options,
    required this.question,
    required this.onValuesChanged,
    required this.onRadioChanged,
    this.options,
    this.can_sign,
    this.checkanswered,
    required this.onValueChanged2,
    this.initialRadioValue,
    required this.users,
    required this.onImageChanged,
    required this.initialImage,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MultipleQuestionState createState() => _MultipleQuestionState();
}

class _MultipleQuestionState extends State<MultipleQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  File? _image; // Holds the captured image
  List<dynamic> selectedValues = [];
  late TextEditingController inputController;
  Uint8List? _signatureImage;
  void _handleImageChanged() {
    widget.onImageChanged(_image!);
  }

  /// Capture image from camera
  Future<void> _captureImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);
    if (image != null) {
      setState(() {
        _image = File(image.path);
        _handleImageChanged(); // Notify parent
      });
    }
  }

  List<String> selectedUsers = [];
  void _deleteImage() {
    print("Deleting image...");
    setState(() {
      _image = null; // Set image to null when deleting
    });

    // Pass null to onImageChanged to indicate deletion
    widget.onImageChanged(null);

    print("Image deleted, _image is now: $_image");
  }

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    // print(selectedValues);
    List<String> indexedNames = [];
    for (int index = 0; index < widget.options.length; index++) {
      indexedNames.add("${widget.options[index]['option_value']}");
    }

    super.build(context);

    return Card(
      elevation: 1,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(0),
        child: Row(
          children: [
            SizedBox(width: 5),
            //vertocal line
            Container(
              width: 4,
              height: 35,
              // height: double.infinity,
              margin: EdgeInsets.only(top: 16),
              color: widget.index % 2 == 0 ? mycolor : Colors.amber,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.initialRadioValue == null
                        ? Container()
                        : Container(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              "Answered",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          ),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.question,
                            style: const TextStyle(fontSize: 18),
                          ),
                        ),
                        Column(
                          children: [
                            Row(
                              children: [
                                Radio(
                                  value: "OK",
                                  groupValue: okay ?? widget.initialRadioValue,
                                  onChanged: widget.initialRadioValue != null
                                      ? null
                                      : (value) {
                                          setState(() {
                                            okay = value as String;
                                            selectedValues =
                                                []; // Clear selected values when changing the radio option

                                            widget.onRadioChanged(okay!);
                                          });
                                        },
                                  activeColor: Colors.green,
                                  materialTapTargetSize:
                                      widget.initialRadioValue != null
                                          ? MaterialTapTargetSize.shrinkWrap
                                          : MaterialTapTargetSize.padded,
                                ),
                                Text(
                                  'OK',
                                  style: TextStyle(
                                    color: okay == "OK"
                                        ? Colors.green
                                        : Colors.black,
                                  ),
                                ),
                                const SizedBox(
                                  width: 16,
                                ), // Add some spacing between the radio buttons
                                Radio(
                                  value: "NOK",
                                  groupValue: okay ?? widget.initialRadioValue,
                                  onChanged: widget.initialRadioValue != null
                                      ? null
                                      : (value) {
                                          setState(() {
                                            okay = value as String;
                                          });
                                          widget.onRadioChanged(okay!);
                                        },
                                  activeColor: Colors.red,
                                  materialTapTargetSize:
                                      widget.initialRadioValue != null
                                          ? MaterialTapTargetSize.shrinkWrap
                                          : MaterialTapTargetSize.padded,
                                ),
                                Text(
                                  'NOK',
                                  style: TextStyle(
                                    color: okay == "NOK"
                                        ? Colors.red
                                        : Colors.black,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: widget.initialImage == null
                                      ? GestureDetector(
                                          onTap: _captureImage,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            // width: 80,
                                            // height: 80,
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              // color: Colors.black,
                                              // boxShadow: [
                                              //   BoxShadow(
                                              //     color: Colors.black26,
                                              //     blurRadius: 2,
                                              //     spreadRadius: 1,
                                              //   ),
                                              // ],
                                            ),
                                            child: Center(
                                              child: Icon(
                                                Icons.camera_alt,
                                                // color: Colors.white,
                                                color: Colors.teal,
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                        )
                                      : Container(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    okay == "NOK"
                        ? MultiSelectDialogField(
                            dialogHeight: 200,
                            items: indexedNames
                                .map((name) =>
                                    MultiSelectItem<String>(name, name))
                                .toList(),
                            title: const Text("Defects"),
                            selectedColor: mycolor,
                            checkColor: textWhite,
                            buttonText: const Text(
                              "Defects",
                              style: TextStyle(
                                color: textBlack,
                                fontSize: 16,
                              ),
                            ),
                            searchable: true,
                            buttonIcon: const Icon(Icons.arrow_drop_down),
                            onConfirm: (results) {
                              setState(() {
                                selectedValues = results;
                              });
                              widget.onValuesChanged(selectedValues);
                            },
                          )
                        : Container(),

                    gap(),
                    if (widget.can_sign == 'Yes' &&
                        widget.checkanswered == false) ...[
                      if (_signatureImage != null) ...[
                        Container(
                          height: 80,
                          width: 100,
                          // decoration: BoxDecoration(
                          //   border: Border.all(color: Colors.grey),
                          // ),
                          // child: Image.memory(_signatureImage!),
                          child: Stack(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 0),
                                child: SizedBox(
                                  child: Image.memory(
                                    _signatureImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 70,
                                child: InkWell(
                                  onTap: () {
                                    print("tapped");
                                    setState(() {
                                      _signatureImage = null;
                                    });
                                  },
                                  child: Container(
                                    child: CircleAvatar(
                                      backgroundColor: app_colorPrimary,
                                      radius: 15,
                                      child: Icon(
                                        Icons.close,
                                        color: textWhite,
                                        size: 15,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ] else ...[
                        TextButton.icon(
                            onPressed: () {
                              showInDialog(context,
                                  builder: (context) => SignatureField(
                                        onSignatureChanged: (signature) async {
                                          setState(() {
                                            _signatureImage = signature;
                                          });
                                          String base64Image =
                                              'data:image/png;base64,' +
                                                  base64Encode(
                                                      _signatureImage!);

                                          widget.onValueChanged2(base64Image);
                                          // print('Signature saved');
                                          Navigator.pop(context);
                                        },
                                      ),
                                  dialogAnimation:
                                      DialogAnimation.SLIDE_TOP_BOTTOM);
                            },
                            icon: Icon(Icons.edit),
                            label: Text("Sign Here")),
                      ]
                    ],
                    // Capture Image & Display
                    if (okay == "NOK" ||
                        widget.initialImage != null ||
                        okay == "OK")
                      Row(
                        children: [
                          if (widget.initialImage == null) const Spacer(),
                          if (_image != null)
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.file(
                                  _image!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                                IconButton(
                                  icon: const Icon(Icons.cancel,
                                      color: Colors.red),
                                  onPressed:
                                      _deleteImage, // Delete image action
                                ),
                              ],
                            ),
                          if (widget.initialImage != null)
                            Stack(
                              alignment: Alignment.topRight,
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: CachedNetworkImage(
                                    imageUrl:
                                        "${"Api.qc_image"}${widget.initialImage}",
                                    width: 80, // Small image size
                                    height: 80,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                    errorWidget: (context, url, error) =>
                                        Image.asset(
                                      'assets/images/placeholder.jpg',
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                )
                              ],
                            ),
                        ],
                      ),
                    // const Divider()
                    const SizedBox(height: 10),
                    // Notify Users Checkboxes
                    if (okay == "NOK")
                      const Text(
                        "Notify Users",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    if (okay == "NOK")
                      Column(
                        children: widget.users.map((user) {
                          return CheckboxListTile(
                            title: Text(user['name']!), // Display user name
                            value: selectedUsers.contains(user['email']),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  selectedUsers
                                      .add(user['email']!); // Store email
                                } else {
                                  selectedUsers
                                      .remove(user['email']!); // Remove email
                                }
                                widget.onUsersSelected(selectedUsers);
                              });
                            },
                          );
                        }).toList(),
                      )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
