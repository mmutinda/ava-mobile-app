import 'package:dropdown_textfield/dropdown_textfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class Others extends StatefulWidget {
  final int id;
  final options;
  final String question;
  final ValueChanged<String> onValueChanged;
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
    required this.onRadioChanged,
    this.initialRadioValue,
    this.hasDescription,
    this.options,
    this.initialDecripValue, this.can_sign, this.checkanswered,
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
    print(indexedNames);
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
              Expanded(
                flex: 3,
                child: Column(
                  children: [
                    // Row(
                    //   children: [
                    //     Radio(
                    //       value: "ok",
                    //       groupValue: okay ?? widget.initialRadioValue,
                    //       onChanged: widget.initialRadioValue != null
                    //           ? null
                    //           : (value) {
                    //               setState(() {
                    //                 okay = value as String;
                    //                 selectedValues =
                    //                     []; // Clear selected values when changing the radio option

                    //                 widget.onRadioChanged(okay!);
                    //               });
                    //             },
                    //       activeColor: Colors.green,
                    //       materialTapTargetSize: widget.initialRadioValue != null
                    //           ? MaterialTapTargetSize.shrinkWrap
                    //           : MaterialTapTargetSize.padded,
                    //     ),
                    //     Text(
                    //       'OK',
                    //       style: TextStyle(
                    //         color: okay == "ok" ? Colors.green : Colors.black,
                    //       ),
                    //     ),
                    //     const SizedBox(
                    //       width: 16,
                    //     ), // Add some spacing between the radio buttons
                    //     Radio(
                    //       value: "nok",
                    //       groupValue: okay ?? widget.initialRadioValue,
                    //       onChanged: widget.initialRadioValue != null
                    //           ? null
                    //           : (value) {
                    //               setState(() {
                    //                 okay = value as String;
                    //               });
                    //               widget.onRadioChanged(okay!);
                    //             },
                    //       activeColor: Colors.red,
                    //       materialTapTargetSize: widget.initialRadioValue != null
                    //           ? MaterialTapTargetSize.shrinkWrap
                    //           : MaterialTapTargetSize.padded,
                    //     ),
                    //     Text(
                    //       'NOK',
                    //       style: TextStyle(
                    //         color: okay == "nok" ? Colors.red : Colors.black,
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    TextFormField(
                      maxLines: null,
                      enabled: widget.initialDecripValue.runtimeType == Null
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
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: mycolor.withOpacity(0.06),
                      ),
                    ),
                    // MultiSelectDialogField(
                    //   decoration: BoxDecoration(
                    //       border: Border(bottom: BorderSide.none)),
                    //   items: indexedNames
                    //       .map((name) => MultiSelectItem<String>(name, name))
                    //       .toList(),
                    //   title: const Text("Categories"),
                    //   selectedColor: mycolor,
                    //   checkColor: textWhite,
                    //   buttonText: const Text(
                    //     "Category",
                    //     style: TextStyle(
                    //       color: textBlack,
                    //       fontSize: 16,
                    //     ),
                    //   ),
                    //   searchable: true,
                    //   buttonIcon: const Icon(Icons.arrow_drop_down),
                    //   onConfirm: (results) {
                    //     setState(() {
                    //       selectedValues = results;
                    //     });
                    //     // widget.onValuesChanged(selectedValues);
                    //   },
                    // ),
                    SizedBox(height: 5),
                    DropDownTextField(
                      clearOption: false,
                      dropDownIconProperty:
                          IconProperty(color: mycolor, size: 30),
                      textFieldFocusNode: textFieldFocusNode,
                      textFieldDecoration: InputDecoration(
                        labelText: 'Category',
                        floatingLabelBehavior: FloatingLabelBehavior.always,
                        hintText: 'Choose ',
                        border: InputBorder.none,
                        filled: true,
                        fillColor: Colors.grey.shade200,
                      ),
                      searchFocusNode: searchFocusNode,
                      dropDownItemCount: 5,
                      enableSearch: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Required field";
                        } else {
                          return null;
                        }
                      },
                      dropDownList: indexedNames.map((stage) {
                        return DropDownValueModel(name: stage, value: stage);
                      }).toList(),
                      onChanged: (val) {
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
          // if (widget.initialDecripValue != null)
          //   Container(
          //     width: double.infinity,
          //     padding: EdgeInsets.all(10),
          //     decoration: BoxDecoration(color: mycolor.withOpacity(0.06)),
          //     child: Text(
          //       " ${widget.initialDecripValue}",
          //       style: TextStyle(color: Colors.red[900]),
          //     ),
          //   ),
          okay == "nok" || widget.hasDescription == 'Yes'
              ? TextFormField(
                  maxLines: null,
                  enabled: widget.initialDecripValue.runtimeType == Null
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
                    floatingLabelBehavior: FloatingLabelBehavior.always,
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: mycolor.withOpacity(0.06),
                  ),
                )
              : Container(),
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
                              onSignatureChanged: (signature) {
                                // Do something with the signature
                                setState(() {
                                  _signatureImage = signature;
                                });
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
