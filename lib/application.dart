import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import '../pages/login_page.dart';
import 'themes.dart';

// class Application extends StatefulWidget {
//   static const ROUTE_NAME = 'Application';
//   @override
//   _ApplicationState createState() => _ApplicationState();
// }
//
// class _ApplicationState extends State<Application> {
//   static const TAG = 'Application';
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: "Simple Chat App",
//       theme: light(context),
//       darkTheme: dark(context),
//       home: LoginScreen(title: "Chat App"),
//       debugShowCheckedModeBanner: false,
//     );
//   }
// }

class Application extends StatelessWidget {
  // const Application({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Simple Chat App",
      theme: light(context),
      darkTheme: dark(context),
      home: LoginScreen(title: "Chat App"),
      debugShowCheckedModeBanner: false,
    );
  }
}
