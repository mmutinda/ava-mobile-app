import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/widgets.dart';

class Logo extends StatelessWidget {
  const Logo({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // FlutterLogo(size: isSmallScreen ? 100 : 200),
        Image.asset(
          "images/logo.png",
          width: isSmallScreen ? 200 : 300,
        ),
        gap()
        // Padding(
        //   padding: const EdgeInsets.all(16.0),
        //   child: Text(
        //     "Welcome to PQCS!",
        //     textAlign: TextAlign.center,
        //     style: isSmallScreen
        //         ? Theme.of(context).textTheme.headlineSmall
        //         : Theme.of(context)
        //             .textTheme
        //             .headlineMedium
        //             ?.copyWith(color: Colors.black),
        //   ),
        // )
      ],
    );
  }
}
