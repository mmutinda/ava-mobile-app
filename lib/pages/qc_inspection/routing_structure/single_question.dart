import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:nb_utils/nb_utils.dart';

class SingleQuestion extends StatefulWidget {
  final int id;
  final String question;
  final ValueChanged<String> onValueChanged;
  final String? initialRadioValue;
  final can_sign;
  final checkanswered;
  const SingleQuestion(
      {super.key,
      required this.id,
      required this.onValueChanged,
      required this.question,
      this.initialRadioValue,
      this.can_sign,
      this.checkanswered});

  @override
  State<SingleQuestion> createState() => _SingleQuestionState();
}

class _SingleQuestionState extends State<SingleQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  Uint8List? _signatureImage;
  @override
  bool get wantKeepAlive => true;
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
                                  widget.onValueChanged(okay!);
                                });
                              },
                        activeColor: Colors.green,
                        materialTapTargetSize: widget.initialRadioValue != null
                            ? MaterialTapTargetSize.shrinkWrap
                            : MaterialTapTargetSize.padded,
                      ),
                      Text(
                        'OK',
                        style: TextStyle(
                          color: okay == "ok" ? Colors.green : Colors.black,
                        ),
                      ),
                      const SizedBox(
                          width:
                              16), // Add some spacing between the radio buttons
                      Radio(
                        value: "nok",
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
                        materialTapTargetSize: widget.initialRadioValue != null
                            ? MaterialTapTargetSize.shrinkWrap
                            : MaterialTapTargetSize.padded,
                      ),
                      Text(
                        'NOK',
                        style: TextStyle(
                          color: okay == "nok" ? Colors.red : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
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
          gap(),
          const Divider()
        ],
      ),
    );
  }
}
