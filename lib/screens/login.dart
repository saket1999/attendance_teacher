import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/screens/signup.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:flutter/material.dart';
import 'package:loading/loading.dart';

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {

  var _loginForm = GlobalKey<FormState>();

  Teacher teacher = Teacher.blank();
  String inputPass="";
  bool isLoading=false;


  @override
  Widget build(BuildContext context) {

    Teacher incoming = Teacher.blank();


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
                    },
                    decoration: InputDecoration(
                        labelText: "Teacher's ID",
                        errorStyle: TextStyle(color: Colors.yellow),
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
                    },
                    decoration: InputDecoration(
                        labelText: 'Password',
                        errorStyle: TextStyle(color: Colors.yellow),
                        border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0))),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(10.0),
                  child: RaisedButton(
                      child: isLoading?Loading():Text('Login'),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 20.0,
                      onPressed: () {
                        if (_loginForm.currentState.validate()) {
                          _loginForm.currentState.save();
                          setState(() {
                            isLoading=true;
                          });
                          FirestoreCRUD.login(context, incoming, teacher, inputPass).then((bool b){
                            print("See b is printed here  "+b.toString());
                            setState(() {
                              isLoading=b;
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
                    onPressed: () {
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
