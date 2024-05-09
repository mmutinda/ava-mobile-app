import 'package:flutter/material.dart';

class ChooseComponent extends StatefulWidget {
  const ChooseComponent({Key? key}) : super(key: key);

  @override
  State<ChooseComponent> createState() => _ChooseComponentState();
}

class _ChooseComponentState extends State<ChooseComponent> {
  String? selectedComponent;

 

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
              "Current Position",
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(height: 20),
          
        ],
      ),
    );
  }
}
