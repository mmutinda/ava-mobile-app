import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/widgets.dart';

class OpenTextQuestion extends StatefulWidget {
  final int id;
  final String question;
  final ValueChanged<String> onValueChanged;

  const OpenTextQuestion({
    Key? key,
    required this.id,
    required this.question,
    required this.onValueChanged,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _OpenTextQuestionState createState() => _OpenTextQuestionState();
}

class _OpenTextQuestionState extends State<OpenTextQuestion>
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
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
            decoration: const InputDecoration(
              labelText: 'Input',
              isDense: true,
              hintText: 'Enter input Here',
              floatingLabelBehavior: FloatingLabelBehavior.always,
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
