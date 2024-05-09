import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/widgets.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

class MultipleQuestion extends StatefulWidget {
  final int id;
  final options;
  // final List options;
  final String question;
  final ValueChanged<List<dynamic>> onValuesChanged;
  final ValueChanged<String> onRadioChanged;

  const MultipleQuestion({
    Key? key,
    required this.id,
    // required this.options,
    required this.question,
    required this.onValuesChanged,
    required this.onRadioChanged,
    this.options,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _MultipleQuestionState createState() => _MultipleQuestionState();
}

class _MultipleQuestionState extends State<MultipleQuestion>
    with AutomaticKeepAliveClientMixin {
  String? okay;
  List<dynamic> selectedValues = [];

  @override
  bool get wantKeepAlive => true;
  @override
  Widget build(BuildContext context) {
    List<String> indexedNames = [];
    for (int index = 0; index < widget.options.length; index++) {
      indexedNames.add("${widget.options[index]['option_value']}");
    }
    // print(indexedNames);
    // You can return your widget here

    super.build(context);
    // final defects = widget.options
    //     .map((option) => MultiSelectItem(option, option))
    //     .toList();
    // List<MultiSelectItem<dynamic>> items = widget.data.map((item) {
    //   return MultiSelectItem<dynamic>(item['option_value'], item);
    // }).toList();

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
                        groupValue: okay,
                        onChanged: (value) {
                          setState(() {
                            okay = value as String;
                            selectedValues =
                                []; // Clear selected values when changing the radio option

                            widget.onRadioChanged(okay!);
                          });
                        },
                        activeColor: Colors.green,
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
                        groupValue: okay,
                        onChanged: (value) {
                          setState(() {
                            okay = value as String;
                          });
                          widget.onRadioChanged(okay!);
                        },
                        activeColor: Colors.red,
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
          okay == "nok"
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
          const Divider()
        ],
      ),
    );
  }
}
