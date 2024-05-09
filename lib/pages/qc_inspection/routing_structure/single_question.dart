import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/widgets.dart';


class SingleQuestion extends StatefulWidget {
  final int id;
  final String question;
  final ValueChanged<String> onValueChanged;
  final String? initialRadioValue;

  const SingleQuestion(
      {super.key,
      required this.id,
      required this.onValueChanged,
      required this.question,
      this.initialRadioValue});

  @override
  State<SingleQuestion> createState() => _SingleQuestionState();
}

class _SingleQuestionState extends State<SingleQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
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
          gap(),
          const Divider()
        ],
      ),
    );
  }
}
