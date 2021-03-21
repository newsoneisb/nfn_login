import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:nfn_login/Api/api.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

var _loading = false;
ProgressDialog pr;
TextEditingController username = new TextEditingController();
TextEditingController password = new TextEditingController();


class MyButtons extends StatefulWidget {
  @override
  _MyButtonsState createState() => _MyButtonsState();
}

class _MyButtonsState extends State<MyButtons> {

  void startLogin() async {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    Map<String, dynamic> values = {'username': username.text, 'password': password.text};
    Map<String, String> header = {"Content-type": "application/json"};
    // pr.show();
    setState(() {
      _loading = true;
    });

    try{
      var response = await http.post(Uri.parse(loginUrlFun), headers: header, body: json.encode(values));
      // print(response.statusCode);
      // print(response.body);
      if (response.statusCode == 200) {
        var jsonData = jsonDecode('${response.body}');
        if (jsonData["success"]) {
          await pr.hide();
          setState(() {
            _loading = false;
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('id', jsonData["uid"]);
          await prefs.setString('fullname', jsonData["fullname"]);
          await prefs.setString('username', jsonData["username"]);

          // Navigator.push(context, MaterialPageRoute(builder: (context) => Home()),);
          Navigator.pushReplacementNamed(context, '/home');
        } else {
          setState(() {
            _loading = false;
          });
          await pr.hide();
          _showDialog(jsonData["message"]);
        }
      } else {
        await pr.hide();
        setState(() {
          _loading = false;
        });
        _showDialog("Error during connecting to server.");
      }
    } on Error catch (e){
      await pr.hide();
      setState(() {
        _loading = false;
      });
      _showDialog("error");
      Map<String, dynamic> result = jsonDecode('$e');
      _showDialog(result["message"]);
    } catch (e){
      await pr.hide();
      setState(() {
        _loading = false;
      });
      _showDialog("error");
      print(e);
    }
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
    return Column(
      children: <Widget>[
        usernameField(),
        passwordField(),
        SizedBox(
          height: 30,
        ),
        loginButton(),
      ],
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
        child: ElevatedButton(
          onPressed: _loading ? (){} : startLogin,
          child: _loading ? CircularProgressIndicator(): Text(
            "LOGIN NOW",
            style: TextStyle(fontSize: 20),
          ),
          style: ElevatedButton.styleFrom(
            primary: Colors.orange,
            shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          ),
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

    final snackBar = SnackBar(
      content: Text(text),
     backgroundColor: Colors.red,
      duration: new Duration(seconds: 2),
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);

    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     // return object of type Dialog
    //     return AlertDialog(
    //       title: new Text("Login Fail"),
    //       content: new Text(text),
    //       actions: <Widget>[
    //         // usually buttons at the bottom of the dialog
    //         new TextButton(
    //           child: new Text("Try Again."),
    //           onPressed: () {
    //             Navigator.of(context).pop();
    //           },
    //         ),
    //       ],
    //     );
    //   },
    // );
  }
}
