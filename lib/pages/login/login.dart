import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/logo.dart';
import 'form_content.dart';

class Login extends StatelessWidget {
  static const routeName = 'login';
  const Login({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
        body: Center(
            child: isSmallScreen
                ? const SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Logo(),
                        FormContent(),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    child: Container(
                      padding: const EdgeInsets.all(32.0),
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: const Row(
                        children: [
                          // Expanded(child: Logo()),
                          Expanded(
                            child: Center(child: FormContent()),
                          ),
                        ],
                      ),
                    ),
                  )));
  }
}
