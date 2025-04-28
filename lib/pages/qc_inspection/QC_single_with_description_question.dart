import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:isuze_pqcs/common/api.dart';


class QCSingleWithDescriptionQuestion extends StatefulWidget {
  final int id;
  final int index;
  final String question;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<File?> onImageChanged; // Allow null for deletion
  final ValueChanged<String> onRadioChanged;
  // final List<String> users; // List of users to notify
  final List<Map<String, String>> users; // List of users with name and email
  final ValueChanged<List<String>> onUsersSelected;
  final String? initialRadioValue;
  final String? initialDecripValue;
  final String? initialImage;
  final String? hasDescription;

  const QCSingleWithDescriptionQuestion({
    Key? key,
    required this.id,
    required this.index,
    required this.question,
    required this.onValueChanged,
    required this.onImageChanged,
    required this.onRadioChanged,
    required this.users,
    required this.onUsersSelected,
    this.initialRadioValue,
    this.hasDescription,
    this.initialDecripValue,
    required this.initialImage,
  }) : super(key: key);

  @override
  _QCSingleWithDescriptionQuestionState createState() =>
      _QCSingleWithDescriptionQuestionState();
}

class _QCSingleWithDescriptionQuestionState
    extends State<QCSingleWithDescriptionQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  List<String> selectedUsers = [];
  TextEditingController inputController = TextEditingController();
  File? _image; // Holds the captured image

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    inputController.text = widget.initialDecripValue ?? "";
    inputController.addListener(_handleValueChanged);
  }

  @override
  void dispose() {
    inputController.removeListener(_handleValueChanged);
    inputController.dispose();
    super.dispose();
  }

  void _handleValueChanged() {
    widget.onValueChanged(inputController.text);
  }

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

  /// Delete the captured image
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
  Widget build(BuildContext context) {
    super.build(context);
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(8),
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
                          fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ),
            Row(
              children: [
                Expanded(
                  child: Text(
                    widget.question,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Column(
                  children: [
                    Row(
                      children: [
                        Radio(
                          value: "ok",
                          groupValue: okay ?? widget.initialRadioValue,
                          onChanged: widget.initialRadioValue != null
                              ? null
                              : (value) {
                                  setState(() {
                                    okay = value as String;
                                  });
                                  widget.onRadioChanged(okay!);
                                },
                        ),
                        const Text('OK'),
                        const SizedBox(width: 16),
                        Radio(
                          value: "nok",
                          groupValue: okay ?? widget.initialRadioValue,
                          onChanged: widget.initialRadioValue != null
                              ? null
                              : (value) {
                                  setState(() {
                                    okay = value as String;
                                  });
                                  widget.onRadioChanged(okay!);
                                },
                        ),
                        const Text('NOK'),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 5),

            // Description Field
            widget.initialRadioValue != null
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(),
                    child: widget.initialDecripValue == null
                        ? Container()
                        : Text(
                            " ${widget.initialDecripValue}",
                            style: TextStyle(
                                // color: Colors.red[900],
                                ),
                          ),
                  )
                : (okay == "nok" ||
                        widget.hasDescription == 'Yes' ||
                        widget.initialRadioValue == 'nok')
                    ? Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              maxLines: null,
                              enabled: widget.initialDecripValue.runtimeType ==
                                          Null &&
                                      widget.initialRadioValue == null
                                  ? true
                                  : false,
                              controller: inputController,
                              decoration: const InputDecoration(
                                labelText: 'Description',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          if (okay == "nok" ||
                              widget.initialImage != null ||
                              okay == "ok")
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
                                          color: Colors.black,
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black26,
                                              blurRadius: 4,
                                              spreadRadius: 1,
                                            ),
                                          ],
                                        ),
                                        child: Center(
                                          child: Icon(
                                            Icons.camera_alt,
                                            color: Colors.white,
                                            size: 30,
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(),
                            )
                        ],
                      )
                    : Container(),

            const SizedBox(height: 10),

            // Capture Image & Display
            if (okay == "nok" || widget.initialImage != null || okay == "ok")
              Row(
                children: [
                  if (widget.initialImage == null)
                    // ElevatedButton.icon(
                    //   onPressed: _captureImage,
                    //   icon: const Icon(Icons.camera_alt),
                    //   label: const Text("Capture Image"),
                    // ),
                    const Spacer(),
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
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          onPressed: _deleteImage, // Delete image action
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
                            imageUrl: "${"Api.qc_image"}${widget.initialImage}",
                            width: 80, // Small image size
                            height: 80,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => Image.asset(
                              'assets/images/placeholder.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                      ],
                    ),
                ],
              ),

            const SizedBox(height: 10),
            // Notify Users Checkboxes
            if (okay == "nok")
              const Text(
                "Notify Users",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            if (okay == "nok")
              Column(
                children: widget.users.map((user) {
                  return CheckboxListTile(
                    title: Text(user['name']!), // Display user name
                    value: selectedUsers.contains(user['email']),
                    onChanged: (bool? value) {
                      setState(() {
                        if (value == true) {
                          selectedUsers.add(user['email']!); // Store email
                        } else {
                          selectedUsers.remove(user['email']!); // Remove email
                        }
                        widget.onUsersSelected(selectedUsers);
                      });
                    },
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}

Widget? Function(BuildContext, String) placeholderWidgetFn() =>
    (_, s) => placeholderWidget();
Widget placeholderWidget() =>
    Image.asset('assets/images/placeholder.jpg', fit: BoxFit.cover);
BoxDecoration boxDecoration(
    {double radius = 2,
    Color color = Colors.transparent,
    Color? bgColor,
    var showShadow = false}) {
  return BoxDecoration(
    color: bgColor,
    border: Border.all(color: color),
    borderRadius: BorderRadius.all(Radius.circular(radius)),
  );
}
