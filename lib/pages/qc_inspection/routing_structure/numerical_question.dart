import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/widgets.dart';


class NumericQuestion extends StatefulWidget {
  final int id;
  final String question;
  final ValueChanged<String> onValueChanged;

  const NumericQuestion({
    Key? key,
    required this.id,
    required this.question,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _NumericQuestionState createState() => _NumericQuestionState();
}

class _NumericQuestionState extends State<NumericQuestion>
    with AutomaticKeepAliveClientMixin {
  late TextEditingController inputController;

  @override
  bool get wantKeepAlive => true;
  @override
  void initState() {
    super.initState();
    inputController = TextEditingController();
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some number';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Input',
              floatingLabelBehavior: FloatingLabelBehavior.always,
              isDense: true,
              hintText: 'Enter input Here',
              border: OutlineInputBorder(),
            ),
          ),
          gap(),
          const Divider()
        ],
      ),
    );
  }
}
