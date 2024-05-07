import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';


class CustomLoader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10),
      child: Center(
        child: SizedBox(
          child: LoadingAnimationWidget.discreteCircle(
            color: mycolor,
            size: 50,
          ),
        ),
      ),
    );
  }
}
