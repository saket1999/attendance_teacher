/*Login page for the user. This page requires Id and password to login*/

import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/screens/signup.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class Login extends StatefulWidget {

  bool getHelp;
  Login(this.getHelp);

  @override
  _LoginState createState() => _LoginState(getHelp);
}

class _LoginState extends State<Login> {

  bool getHelp;
  _LoginState(this.getHelp);

  var _loginForm = GlobalKey<FormState>();

  Teacher teacher = Teacher.blank();
  String inputPass="";
  bool _isLoading=false;


  /*UI part of the login page.
* Appbar;
*     Text:Login
* Body:
*     TextField: ID
*     TextField: Password
*
*     Button: Login
*     Button: Sign Up*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: Form(
          key: _loginForm,
          child: Center(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    onSaved: (value) {
                      teacher.teacherId = value;
                    },
                    validator: (String value) {
                      if (value.length != 8)
                        return "Incorrect Teacher's ID";
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: "Teacher's ID",
                        errorStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: TextFormField(
                    obscureText: true,
                    onSaved: (value) {
                      inputPass = value;
                    },
                    validator: (String value) {
                      if (value.length < 6)
                        return 'Password too short';
                      return null;
                    },
                    decoration: InputDecoration(
                        labelText: 'Password',
                        errorStyle: TextStyle(color: Colors.red),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    color: Colors.black,
                      child: _isLoading?Loading(indicator: BallPulseIndicator(), size: 20.0):Text('Login', style: TextStyle(color: Colors.white)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 10.0,
                      onPressed: () {

                        /*Form is validated
                      * loading=true
                      * Login is attempted
                      * if login fails isLoading=false otherwise user is routed to Dashboard*/

                        if (_loginForm.currentState.validate()) {
                          _loginForm.currentState.save();
                          setState(() {
                            _isLoading=true;
                          });
                          FirestoreCRUD.login(context, teacher, inputPass, getHelp).then((bool value){
                            setState(() {
                              _isLoading=value;
                            });
                          });
                        }
                      }),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                    child: Text(
                      'New User? Sign Up',
                      style: TextStyle(color: Colors.black),
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    color: Colors.white,
                    onPressed: _isLoading?null:() {
                      Navigator.push(context, MaterialPageRoute(builder: (context) {
                        return SignUp();
                      }));
                    },
                  ),
                )
              ],
            ),
          ),
        ),
      ),
	);
  }
}
