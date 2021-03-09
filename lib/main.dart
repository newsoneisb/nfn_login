import 'package:flutter/material.dart';
import 'package:nfn_login/Screens/login_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home.dart';


void main() {
  runApp(MaterialApp(home: MyApp(),));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State {
  bool _loginStatus = false;
  void loginCheck() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if(prefs.getString('id') != null){
    setState(() {
      _loginStatus = true;
    });
  }
}
  @override
  void initState() {
    loginCheck();
    super.initState();
  }
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: (_loginStatus)?Home():LoginScreen2(),
      theme: ThemeData.light(),
      debugShowCheckedModeBanner: false,
      routes: {
        '/login': (BuildContext context) => new LoginScreen2(),
        '/home': (BuildContext context) => new Home(),
      },
    );
  }
}