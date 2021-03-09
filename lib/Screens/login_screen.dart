import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nfn_login/Api/api.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

ProgressDialog pr;
TextEditingController username = new TextEditingController();
TextEditingController password = new TextEditingController();

class LoginScreen2 extends StatefulWidget {
  @override
  _LoginScreen2State createState() => _LoginScreen2State();
}

class _LoginScreen2State extends State<LoginScreen2> {

  void startLogin() async {
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';

    Map<String, dynamic> values = {'username': username.text, 'password': password.text};
    pr.show();

    try{
      var response = await http.post(loginUrlWeb, body: values);
      print(response);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode('$response');
          if (jsonData["success"]) {
            await pr.hide();

            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('id', jsonData["uid"]);
            await prefs.setString('fullname', jsonData["fullname"]);
            await prefs.setString('username', jsonData["username"]);

            // Navigator.push(context, MaterialPageRoute(builder: (context) => Home()),);
            Navigator.pushReplacementNamed(context, '/home');
          } else {
            await pr.hide();
            _showDialog(jsonData["message"]);
          }
      } else {
        await pr.hide();
        _showDialog("Error during connecting to server.");
      }
    } catch (e){
      await pr.hide();
      _showDialog("error");
      Map<String, dynamic> result = jsonDecode('${e.response}');
      _showDialog(result["message"]);
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent
          //color set to transparent or set your own color
        ));
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
      body: SingleChildScrollView(
          child: Container(
            constraints: BoxConstraints(
              minHeight: MediaQuery
                  .of(context)
                  .size
                  .height,
            ),
            width: MediaQuery
                .of(context)
                .size
                .width,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.orange,
                  Colors.deepOrangeAccent,
                  Colors.red,
                  Colors.redAccent,
                ],
              ),
            ),
            //show linear gradient background of page

            padding: EdgeInsets.all(20),
            child: Column(children: <Widget>[
              headingText(),
              headingText2(),
              SizedBox(height: 30,),
              usernameField(),
              passwordField(),
              SizedBox(height: 30,),
              loginButton(),
            ]),
          )),
    );
  }

  Widget headingText() {
    return Column(children: <Widget>[
      Container(
        margin: EdgeInsets.only(top: 80),
        child: Text(
          "Sign Into System",
          style: TextStyle(
              color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold),
        ), //title text
      )
    ]);
  }

  Widget headingText2() {
    return Container(
      margin: EdgeInsets.only(top: 10),
      child: Text(
        "Sign In using Username and Password",
        style: TextStyle(color: Colors.white, fontSize: 15),
      ), //subtitle text
    );
  }

  Widget usernameField() {
    return Container(
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      margin: EdgeInsets.only(top: 10),
      child: TextField(
        controller: username,
        style: TextStyle(color: Colors.orange[100], fontSize: 20),
        decoration: myInputDecoration(
          label: "Username",
          icon: Icons.person,
        ),
      ),
    );
  }

  Widget passwordField() {
    return Container(
      padding: EdgeInsets.all(10),
      child: TextField(
        controller: password,
        style: TextStyle(color: Colors.orange[100], fontSize: 20),
        obscureText: true,
        decoration: myInputDecoration(
          label: "Password",
          icon: Icons.lock,
        ),
      ),
    );
  }

  Widget loginButton() {
    return Container(
      padding: EdgeInsets.all(10),
      margin: EdgeInsets.only(top: 20),
      child: SizedBox(
        height: 60,
        width: double.infinity,
        child: RaisedButton(
          onPressed: startLogin,
          child: Text(
            "LOGIN NOW",
            style: TextStyle(fontSize: 20),
          ),
          colorBrightness: Brightness.dark,
          color: Colors.orange,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30)),
        ),
      ),
    );
  }

  InputDecoration myInputDecoration({String label, IconData icon}) {
    return InputDecoration(
      hintText: label,
      //show label as placeholder
      hintStyle: TextStyle(color: Colors.orange[100], fontSize: 20),
      //hint text style
      prefixIcon: Padding(
          padding: EdgeInsets.only(left: 20, right: 10),
          child: Icon(
            icon,
            color: Colors.orange[100],
          )
        //padding and icon for prefix
      ),

      contentPadding: EdgeInsets.fromLTRB(30, 20, 30, 20),
      enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.orange[300], width: 1)),
      //default border of input

      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(30),
          borderSide: BorderSide(color: Colors.orange[200], width: 1)),
      //focus border

      fillColor: Color.fromRGBO(251, 140, 0, 0.5),
      filled: true, //set true if you want to show input background
    );
  }

  void _showDialog(String text) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return object of type Dialog
        return AlertDialog(
          title: new Text("Login Fail"),
          content: new Text(text),
          actions: <Widget>[
            // usually buttons at the bottom of the dialog
            new TextButton(
              child: new Text("Try Again."),
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
