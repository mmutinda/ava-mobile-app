import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class SingleQuestion extends StatefulWidget {
  final int id;
  final String question;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<String> onInputValueChanged;
  final ValueChanged<String> onValueChanged2;
  final String? initialRadioValue;
  final String? initialDecripValue;
  final String? hasDescription;
  final can_sign;
  final int index;
  final checkanswered;
  const SingleQuestion(
      {super.key,
      required this.id,
      required this.onValueChanged,
      required this.onInputValueChanged,
      required this.onValueChanged2,
      required this.question,
      this.initialRadioValue,
      this.can_sign,
      this.checkanswered,
      required this.index,
      this.initialDecripValue,
      this.hasDescription});

  @override
  State<SingleQuestion> createState() => _SingleQuestionState();
}

class _SingleQuestionState extends State<SingleQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  Uint8List? _signatureImage;
  late TextEditingController inputController;
  @override
  bool get wantKeepAlive => true;
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
    widget.onInputValueChanged(inputController.text);
  }

  @override
  Widget build(BuildContext context) {
    // print(widget.initialDecripValue);
    super.build(context);
    return Card(
      elevation: 2,
      color: Colors.white,
      child: Container(
        padding: const EdgeInsets.all(1),
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
                            // widget.initialRadioValue != null
                            //     ? Row(
                            //         children: [
                            //           Container(
                            //             decoration: BoxDecoration(
                            //                 borderRadius:
                            //                     BorderRadius.circular(10),
                            //                 color: widget.initialRadioValue ==
                            //                         'NOK'
                            //                     ? Colors.red
                            //                     : Colors.green),
                            //             padding: EdgeInsets.all(8),
                            //             child: Text(
                            //               "${widget.initialRadioValue}",
                            //               style: TextStyle(
                            //                 color: textWhite,
                            //               ),
                            //             ),
                            //           ),
                            //         ],
                            //       )
                            //     :
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
                                            widget.onValueChanged(okay!);
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
                                    width:
                                        16), // Add some spacing between the radio buttons
                                Radio(
                                  value: "NOK",
                                  groupValue: okay ?? widget.initialRadioValue,
                                  onChanged: widget.initialRadioValue != null
                                      ? null
                                      : (value) {
                                          setState(() {
                                            okay = value as String;
                                            widget.onValueChanged(okay!);
                                          });
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
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
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
                        : (widget.hasDescription == 'Yes')
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: TextFormField(
                                  maxLines: null,
                                  // enabled:
                                  //     widget.initialDecripValue.runtimeType ==
                                  //                 Null &&
                                  //             widget.initialRadioValue == null
                                  //         ? true
                                  //         : false,
                                  controller: inputController,
                                  decoration: InputDecoration(
                                    labelText: 'Description',
                                    isDense: true,
                                    hintText: '',
                                    floatingLabelBehavior:
                                        FloatingLabelBehavior.always,
                                    border: OutlineInputBorder(),
                                    // filled: true,
                                    // fillColor: mycolor.withOpacity(0.06),
                                  ),
                                ),
                              )
                            : Container(),

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
                                          // Do something with the signature
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
                    gap(),
                    // const Divider()
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
