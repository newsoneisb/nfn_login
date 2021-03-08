import 'package:flutter/material.dart';
import 'Screens/login.dart';
import 'home.dart';
import 'login_talha.dart';


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
      home: LoginScreen(),
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (BuildContext context) => new LoginScreen(),
        '/home': (BuildContext context) => new Home(),
      },
    );
  }
}