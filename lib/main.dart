import 'package:flutter/material.dart';
import 'package:isuze_pqcs/common/constants.dart';
import 'package:isuze_pqcs/common/HomePage.dart';
import 'package:isuze_pqcs/pages/dashboard.dart';
import 'package:isuze_pqcs/pages/login/login.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences prefs = await SharedPreferences.getInstance();
  var userdata = prefs.getString('userdata');
  runApp(
    MyApp(
      userdata: userdata,
    ),
  );
}

class MyApp extends StatelessWidget {
  final userdata;

  const MyApp({super.key, this.userdata});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PQCS SYSTEM',
      theme: ThemeData(
        // scaffoldBackgroundColor: bgColor,
        scaffoldBackgroundColor: Colors.grey.shade100,
        appBarTheme: AppBarTheme(
          centerTitle: true,
          foregroundColor: Colors.white,
          backgroundColor: Color.fromARGB(255, 168, 88, 32),
        ),
        colorScheme: ColorScheme.fromSeed(seedColor: mycolor),
        useMaterial3: true,
        buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
        //
      ),
      // home: userdata == null ? Login() : Dashboard(),
      home: HomeScrean(),
    );
  }
}
