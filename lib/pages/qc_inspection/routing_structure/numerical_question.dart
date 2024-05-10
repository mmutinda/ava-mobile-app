import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class NumericQuestion extends StatefulWidget {
  final int id;
  final String question;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<String> onValueChanged2;
  final String? initialDecripValue;
  final can_sign;
  final checkanswered;

  const NumericQuestion({
    Key? key,
    required this.id,
    required this.question,
    required this.onValueChanged,
    required this.onValueChanged2,
    this.can_sign,
    this.checkanswered,
    this.initialDecripValue,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NumericQuestionState createState() => _NumericQuestionState();
}

class _NumericQuestionState extends State<NumericQuestion>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController inputController;
  Uint8List? _signatureImage;

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    inputController = TextEditingController();
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
            ],
          ),
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: inputController,
            enabled: widget.initialDecripValue == null ? true : false,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              labelText: 'Input',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              isDense: true,
              hintText: 'Enter input Here',
              border: OutlineInputBorder(),
              suffixIcon: Padding(
                padding: EdgeInsets.all(8.0),
                child: widget.initialDecripValue == null
                    ? null
                    : Icon(
                        Icons.done,
                        color: mycolor,
                      ),
              ),
            ),
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
