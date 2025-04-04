import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  // final List options;
  final String question;
  final ValueChanged<List<dynamic>> onValuesChanged;
  final ValueChanged<String> onRadioChanged;
  final ValueChanged<String> onValueChanged2;
  const MultipleQuestion({
    Key? key,
    required this.id,
    required this.index,
    // required this.options,
    required this.question,
    required this.onValuesChanged,
    required this.onRadioChanged,
    this.options,
    this.can_sign,
    this.checkanswered,
    required this.onValueChanged2,
    this.initialRadioValue,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MultipleQuestionState createState() => _MultipleQuestionState();
}

class _MultipleQuestionState extends State<MultipleQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  List<dynamic> selectedValues = [];
  late TextEditingController inputController;
  Uint8List? _signatureImage;

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

    return Container(
      padding: const EdgeInsets.all(5),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                      : Row(
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
                                color:
                                    okay == "OK" ? Colors.green : Colors.black,
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
                                color:
                                    okay == "NOK" ? Colors.red : Colors.black,
                              ),
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
                  items: indexedNames
                      .map((name) => MultiSelectItem<String>(name, name))
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
                                String base64Image = 'data:image/png;base64,' +
                                    base64Encode(_signatureImage!);

                                widget.onValueChanged2(base64Image);
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
