import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';

class SingleWithDescriptionQuestion extends StatefulWidget {
  final int id;

  final String question;
  final ValueChanged<String> onValueChanged;
  final ValueChanged<String> onRadioChanged;
  final String? initialRadioValue;
  final String? initialDecripValue;
  final String? hasDescription;

  const SingleWithDescriptionQuestion({
    Key? key,
    required this.id,
    required this.question,
    required this.onValueChanged,
    required this.onRadioChanged,
    this.initialRadioValue,
    this.hasDescription,
    this.initialDecripValue,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _SingleWithDescriptionQuestionState createState() =>
      _SingleWithDescriptionQuestionState();
}

class _SingleWithDescriptionQuestionState
    extends State<SingleWithDescriptionQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  List<dynamic> selectedValues = [];
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
                                  selectedValues =
                                      []; // Clear selected values when changing the radio option

                                  widget.onRadioChanged(okay!);
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
                        width: 16,
                      ), // Add some spacing between the radio buttons
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
          const SizedBox(
            height: 5,
          ),
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
          const Divider()
        ],
      ),
    );
  }
}
