import 'package:flutter/material.dart';
import 'Screens/login.dart';
import 'home.dart';


void main() {
  runApp(MaterialApp(home: MyApp(),));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // home: (_loginStatus==1)?Home():LoginPage(),
      home: LoginPage(),
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (BuildContext context) => new LoginPage(),
        '/home': (BuildContext context) => new Home(),
      },
    );
  }
}