import 'dart:io';

import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';
import 'package:path_provider/path_provider.dart';

class Others extends StatefulWidget {
  final int id;
  final options;
  final String question;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<String> onValueChanged2;
  final ValueChanged<String> onRadioChanged;
  final String? initialRadioValue;
  final String? initialDecripValue;
  final String? hasDescription;
  final can_sign;
  final checkanswered;

  const Others({
    Key? key,
    required this.id,
    required this.question,
    required this.onValueChanged,
    required this.onValueChanged2,
    required this.onRadioChanged,
    this.initialRadioValue,
    this.hasDescription,
    this.options,
    this.initialDecripValue,
    this.can_sign,
    this.checkanswered,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OthersState createState() => _OthersState();
}

class _OthersState extends State<Others> with AutomaticKeepAliveClientMixin {
  String? okay;
  var selectedValues = '';
  late TextEditingController inputController;
  Uint8List? _signatureImage;
  @override
  bool get wantKeepAlive => true;
  FocusNode searchFocusNode = FocusNode();
  FocusNode textFieldFocusNode = FocusNode();
  @override
  void initState() {
    super.initState();
    inputController = TextEditingController(text: widget.initialDecripValue);
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

  @override
  Widget build(BuildContext context) {
    List<String> indexedNames = [];
    for (int index = 0; index < widget.options.length; index++) {
      indexedNames.add("${widget.options[index]['option_value']}");
    }
    // print(indexedNames);
    super.build(context);
    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  widget.question,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              widget.initialRadioValue != null
                  ? Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: widget.initialRadioValue == 'NOK'
                                  ? Colors.red
                                  : Colors.green),
                          padding: EdgeInsets.all(8),
                          child: Text(
                            "${widget.initialRadioValue}",
                            style: TextStyle(
                              color: textWhite,
                            ),
                          ),
                        ),
                      ],
                    )
                  : Expanded(
                      flex: 3,
                      child: Column(
                        children: [
                          TextFormField(
                            maxLines: null,
                            enabled:
                                widget.initialDecripValue.runtimeType == Null
                                    ? true
                                    : false,
                            controller: inputController,
                            validator: okay != null
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter some text';
                                    }
                                    return null;
                                  }
                                : null,
                            decoration: InputDecoration(
                              labelText: 'Description',
                              isDense: true,
                              hintText: 'Enter Description Here',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              border: OutlineInputBorder(),
                              filled: true,
                              fillColor: mycolor.withOpacity(0.06),
                            ),
                          ),
                          SizedBox(height: 5),
                          DropDownTextField(
                            clearOption: false,
                            dropDownIconProperty:
                                IconProperty(color: mycolor, size: 30),
                            textFieldFocusNode: textFieldFocusNode,
                            textFieldDecoration: InputDecoration(
                              labelText: 'Category',
                              floatingLabelBehavior:
                                  FloatingLabelBehavior.always,
                              hintText: 'Choose ',
                              border: InputBorder.none,
                              filled: true,
                              fillColor: Colors.grey.shade200,
                            ),
                            searchFocusNode: searchFocusNode,
                            dropDownItemCount: 5,
                            enableSearch: true,
                            dropDownList: indexedNames.map((stage) {
                              return DropDownValueModel(
                                  name: stage, value: stage);
                            }).toList(),
                            onChanged: (val) {
                              setState(() {
                                selectedValues = val.name;
                              });
                              widget.onRadioChanged(selectedValues);
                              selectedValues = val.name;
                            },
                          ),
                        ],
                      ),
                    ),
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          gap(),
          if (widget.can_sign == 'Yes' && widget.checkanswered == false) ...[
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
                      padding: const EdgeInsets.symmetric(vertical: 0),
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
                                final directory =
                                    await getApplicationDocumentsDirectory();
                                final imagePath =
                                    '${directory.path}/signature.png';
                                print(imagePath);
                                final imageFile = File(imagePath);
                                await imageFile.writeAsBytes(_signatureImage!);

                                // Pass the file path to the callback
                                widget.onValueChanged2(imagePath);
                                // print('Signature saved');
                                Navigator.pop(context);
                              },
                            ),
                        dialogAnimation: DialogAnimation.SLIDE_TOP_BOTTOM);
                  },
                  icon: Icon(Icons.edit),
                  label: Text("Sign Here")),
            ]
          ],
          const Divider()
        ],
      ),
    );
  }
}
