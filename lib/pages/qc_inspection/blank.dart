import 'package:flutter/material.dart';

class Blank extends StatefulWidget {
  final res;

  const Blank({super.key, this.res});

  @override
  State<Blank> createState() => _BlankState();
}

class _BlankState extends State<Blank> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Text("${widget.res}"),
    );
  }
}
