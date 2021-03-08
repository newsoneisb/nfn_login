import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:nfn_login/Api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../home.dart';

class LoginPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    return _LoginPage();
  }
}

class _LoginPage extends State<LoginPage> {
  String errormsg;
  bool error, showprogress;
  String username, password;

  var _username = TextEditingController();
  var _password = TextEditingController();
  bool checkRemember = false;
  SharedPreferences sharedPreferences;

  startLogin() async {
    Dio dio = new Dio();
    dio.options.headers['content-Type'] = 'application/json';
    Map<String, dynamic> values = {'username': username, 'password': password};

    try {
      var response = await dio.post(LOGIN, data: values);

      if (response.statusCode == 200) {
        var jsondata = json.decode('$response');
        if (jsondata["error"]) {
          setState(() {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = jsondata["message"];
          });
        } else {
          if (jsondata["success"]) {
            setState(() {
              error = false;
              showprogress = false;
            });
            //save the data returned from server
            //and navigate to home page
            String uid = jsondata["uid"];
            String fullname = jsondata["fullname"];
            String address = jsondata["address"];
            print(fullname);
            
            // Navigator.push(context, MaterialPageRoute(builder: (context) => Home()),);
            // Navigator.pushNamed(context, '/home');
            Navigator.pushReplacementNamed(context, '/home');
            //user shared preference to save data
          } else {
            showprogress = false; //don't show progress indicator
            error = true;
            errormsg = "Something went wrong.";
          }
        }
      } else {
        setState(() {
          showprogress = false; //don't show progress indicator
          error = true;
          errormsg = "Error during connecting to server.";
        });
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        showprogress = false; //don't show progress indicator
        error = true;
        errormsg = "Connection timeout.";
      });
    }
  }

  _onChanged(bool value) async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      checkRemember = value;
      sharedPreferences.setBool("check", checkRemember);
      sharedPreferences.setString("username", username);
      sharedPreferences.setString("password", password);
      sharedPreferences.commit();
      getCredential();
    });
  }

  getCredential() async {
    sharedPreferences = await SharedPreferences.getInstance();
    setState(() {
      checkRemember = sharedPreferences.getBool("check");
      if (checkRemember != null) {
        if (checkRemember) {
          _username.text = sharedPreferences.getString("username");
          _password.text = sharedPreferences.getString("password");
        } else {
          _username.clear();
          _password.clear();
          sharedPreferences.clear();
        }
      } else {
        checkRemember = false;
      }
    });
  }

  @override
  void initState() {
    username = "";
    password = "";
    errormsg = "";
    error = false;
    showprogress = false;

    super.initState();

    getCredential();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
        SystemUiOverlayStyle(statusBarColor: Colors.transparent
            //color set to transperent or set your own color
            ));

    return Scaffold(
      body: SingleChildScrollView(
          child: Container(
        constraints:
            BoxConstraints(minHeight: MediaQuery.of(context).size.height
                //set minimum height equal to 100% of VH
                ),
        width: MediaQuery.of(context).size.width,
        //make width of outer wrapper to 100%
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
          Container(
            margin: EdgeInsets.only(top: 80),
            child: Text(
              "Sign Into System",
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ), //title text
          ),
          Container(
            margin: EdgeInsets.only(top: 10),
            child: Text(
              "Sign In using Email and Password",
              style: TextStyle(color: Colors.white, fontSize: 15),
            ), //subtitle text
          ),
          Container(
            //show error message here
            margin: EdgeInsets.only(top: 30),
            padding: EdgeInsets.all(10),
            child: error ? errmsg(errormsg) : Container(),
            //if error == true then show error message
            //else set empty container as child
          ),
          Container(
            padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
            margin: EdgeInsets.only(top: 10),
            child: TextField(
              controller: _username, //set username controller
              style: TextStyle(color: Colors.orange[100], fontSize: 20),
              decoration: myInputDecoration(
                label: "Username",
                icon: Icons.person,
              ),
              onChanged: (value) {
                //set username  text on change
                username = value;
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            child: TextField(
              controller: _password,
              //set password controller
              style: TextStyle(color: Colors.orange[100], fontSize: 20),
              obscureText: true,
              decoration: myInputDecoration(
                label: "Password",
                icon: Icons.lock,
              ),
              onChanged: (value) {
                // change password text
                password = value;
              },
            ),
          ),
          Container(
            child: new CheckboxListTile(
              value: checkRemember,
              onChanged: _onChanged,
              title: new Text("Remember me"),
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 20),
            child: SizedBox(
              height: 60,
              width: double.infinity,
              child: RaisedButton(
                onPressed: () {
                  setState(() {
                    //show progress indicator on click
                    showprogress = true;
                  });
                  startLogin();
                },
                child: showprogress
                    ? SizedBox(
                        height: 30,
                        width: 30,
                        child: CircularProgressIndicator(
                          backgroundColor: Colors.orange[100],
                          valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.deepOrangeAccent),
                        ),
                      )
                    : Text(
                        "LOGIN NOW",
                        style: TextStyle(fontSize: 20),
                      ),
                // if showprogress == true then show progress indicator
                // else show "LOGIN NOW" text
                colorBrightness: Brightness.dark,
                color: Colors.orange,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)
                    //button corner radius
                    ),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.only(top: 20),
            child: InkResponse(
                onTap: () {
                  //action on tap
                },
                child: Text(
                  "Forgot Password? Troubleshoot",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                )),
          )
        ]),
      )),
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

  Widget errmsg(String text) {
    //error message widget.
    return Container(
      padding: EdgeInsets.all(15.00),
      margin: EdgeInsets.only(bottom: 10.00),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          color: Colors.red,
          border: Border.all(color: Colors.red[300], width: 2)),
      child: Row(children: <Widget>[
        Container(
          margin: EdgeInsets.only(right: 6.00),
          child: Icon(Icons.info, color: Colors.white),
        ), // icon for error message

        Text(text, style: TextStyle(color: Colors.white, fontSize: 18)),
        //show error message text
      ]),
    );
  }
}
