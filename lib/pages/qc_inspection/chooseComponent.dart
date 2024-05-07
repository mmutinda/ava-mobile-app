import 'package:flutter/material.dart';
import 'package:nb_utils/nb_utils.dart';

class ChooseComponent extends StatefulWidget {
  const ChooseComponent({Key? key}) : super(key: key);

  @override
  State<ChooseComponent> createState() => _ChooseComponentState();
}

class _ChooseComponentState extends State<ChooseComponent> {
  String? selectedComponent;

  final List<String> data = [
    'Cabin/Cockpit',
    'Chassis',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 300,
      width: double.infinity,
      child: Column(
        children: [
          Container(
            alignment: Alignment.center,
            width: double.infinity,
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.amber[900],
            ),
            child: Text(
              "CHOOSE COMPONENT",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          Column(
            children: data.map((String value) {
              return Column(
                children: [
                  RadioListTile(
                    activeColor: Colors.amber[900],
                    title: Text(value),
                    value: value,
                    groupValue: selectedComponent,
                    onChanged: (String? value) {
                      setState(() {
                        selectedComponent = value;
                      });
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Divider(),
                  ),
                ],
              );
            }).toList(),
          ),
          Spacer(),
          AppButton(
            text: "PUSH TO NEXT SHOP",
            onTap: () {
              if (selectedComponent != null) {
                showConfirmDialogCustom(
                  primaryColor: Colors.amber[900],
                  context,
                  title: "Do you want to Push this?",
                  dialogType: DialogType.CONFIRMATION,
                  onAccept: (val) {
                    snackBar(context, title: 'Pushed');
                    Navigator.pop(context);
                  },
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Please select a component.'),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
