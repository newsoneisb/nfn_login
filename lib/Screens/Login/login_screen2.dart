import 'package:flutter/material.dart';
import 'package:nfn_login/Screens/Login/components/buttons.dart';
import 'package:nfn_login/components/background.dart';

class LoginScreen2 extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Background(
        child: Column(
          children: <Widget>[
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
                "Sign In using Username and Password",
                style: TextStyle(color: Colors.white, fontSize: 15),
              ),
            ),
            SizedBox(
              height: 30,
            ),
            MyButtons(),
          ],
        ),
      ),
    );
  }


}
