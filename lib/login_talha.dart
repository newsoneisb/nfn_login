import 'dart:async';
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:nfn_login/Api/api.dart';
import 'package:nfn_login/home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

ProgressDialog pr;
TextEditingController email = new TextEditingController();
TextEditingController pass = new TextEditingController();

class LoginScreen extends StatefulWidget {
  LoginScreen({Key key, this.title}) : super(key: key);
  final String title;

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String _result = '';
  String _uname = '';
  String _uemail = '';
  String _uimage = '';
  String _counter = '';
  int open = 0;

  List users = [];

  Future<String> fetchData() async {
    setState(() {
      _result = '';
    });
    var dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    var emailStr = email.text;
    var passStr = pass.text;

    Map<String, dynamic> values = {"username": emailStr, "password": passStr};
    await pr.show();

    try {
      print(loginUrlWeb);
      print(values);
      var response = await dio.post(loginUrlWeb, data: values);
      Map<String, dynamic> result = jsonDecode('$response');

      // Insert
      if (response.statusCode == 200) {
        var jsondata = json.decode('$response');
        if (jsondata["error"]) {
          pr.hide();
          _result = jsondata["message"];
          _showDialog();
        } else {
          if (jsondata["success"]) {
            await pr.hide();

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('id', jsondata["s_id"]);
            await prefs.setString('name', jsondata["s_fullname"]);
            await prefs.setString('email', jsondata["s_username"]);

            print("Pref Added");

            // Navigator.push(context, MaterialPageRoute(builder: (context) => Home()),);
            // Navigator.pushNamed(context, '/home');
            Navigator.pushReplacementNamed(context, '/home');
            //user shared preference to save data
          } else {
            await pr.hide();
            _result = jsondata["message"];
            _showDialog();
          }
        }
      } else {
        await pr.hide();
        _result = "Error during connecting to server.";
        _showDialog();
      }
    } catch (e) {
      await pr.hide();
      Map<String, dynamic> result = jsonDecode('${e.response}');
      setState(() {
        _result = result['message'];
        _showDialog();
      });
    }
  }

  Future<String> _checker() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('id') != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (BuildContext context) {
            return Home();
          },
        ),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _checker();
    print('kr na check');
  }

  @override
  Widget build(BuildContext context) {
    pr = ProgressDialog(
      context,
      type: ProgressDialogType.Normal,
      textDirection: TextDirection.ltr,
      isDismissible: true,
    );
    pr.style(
      message: "Processing",
      borderRadius: 10.0,
      backgroundColor: Colors.white,
      elevation: 8.0,
      insetAnimCurve: Curves.easeInOut,
      progressWidgetAlignment: Alignment.center,
      progressTextStyle: TextStyle(
          color: Colors.black, fontSize: 13.0, fontWeight: FontWeight.w400),
      messageTextStyle: TextStyle(
          color: Colors.black, fontSize: 19.0, fontWeight: FontWeight.w600),
    );
    return Scaffold(
      body: Center(
        child: ListView(
          scrollDirection: Axis.vertical,
          primary: false,
          children: <Widget>[
            SizedBox(
              height: 20.0,
            ),
            Align(
              alignment: Alignment.center,
              child: logo(),
            ),
            Align(
              alignment: Alignment.center,
              child: buildEmail(),
            ),
            Align(
              alignment: Alignment.center,
              child: buildPassword(),
            ),
            Align(
              alignment: Alignment.center,
              child: buildLoginButton(),
            ),
            FlatButton(
              onPressed: () {},
              child: Text('Logout'),
            ),
            Text(
              '$_counter',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget logo() {
    return Container(
      height: 250.0,
      width: 250.0,
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            blurRadius: 5,
            offset: Offset(0, 3),
          )
        ],
        shape: BoxShape.circle,
        image: DecorationImage(
            image: ExactAssetImage('assets/logo_nfn.png'),
            fit: BoxFit.fitWidth),
      ),
      child: Container(
        height: 20.0,
        width: 20.0,
        margin: EdgeInsets.only(left: 150.0, top: 140.0),
        decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                blurRadius: 5,
                offset: Offset(0, 3),
              )
            ]),
        child: Container(
          margin: EdgeInsets.all(20.0),
          child: Text("W",
              style: TextStyle(
                  color: Colors.blue,
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  Widget buildEmail() {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      child: TextFormField(
        controller: email,
        decoration: InputDecoration(
          hintText: "Username",
        ),
      ),
    );
  }

  Widget buildPassword() {
    return Container(
      margin: EdgeInsets.all(10.0),
      padding: EdgeInsets.all(10.0),
      child: TextFormField(
        controller: pass,
        obscureText: true,
        decoration: InputDecoration(
          hintText: "Password",
        ),
      ),
    );
  }

  Widget buildLoginButton() {
    return Container(
      child: SignInButtonBuilder(
        text: 'Login',
        icon: Icons.email,
        onPressed: fetchData,
        backgroundColor: Colors.blueAccent,
        padding: EdgeInsets.all(10.0),
      ),
    );
  }

  void _showDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Login Fail"),
          content: new Text(_result),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new FlatButton(
              child: new Text("Try Again"),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
