import 'dart:io';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/services/password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {


  var _signUpForm = GlobalKey<FormState>();
  var _passKey = GlobalKey<FormFieldState>();

  Teacher teacher = Teacher.blank();
  File _image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('SignUp'),
        ),
        body: Container(
            padding: EdgeInsets.all(5.0),
            child: Form(
              key: _signUpForm,
              child: Center(
                child: ListView(
                    children: <Widget>[
                      SizedBox(height: 20.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Align(
                            alignment: Alignment.center,
                            child: CircleAvatar(
                              radius: 100.0,
                              backgroundColor: Colors.blueAccent,
                              child: ClipOval(
                                child: SizedBox(
                                  width: 180.0,
                                  height: 180.0,
                                  child: (_image!=null)?
                                  Image.file(_image,fit: BoxFit.fill):
                                  Image.network(
                                    "https://www.google.co.in/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png",
                                    fit: BoxFit.fill,
                                  ),

                                ),
                              ),
                            ),

                          ),
                          Padding(
                            padding: EdgeInsets.only(top: 60.0),
                            child: IconButton(
                              icon: Icon(
                                Icons.edit,
                                size: 30.0,
                              ),
                              onPressed: () {
                                getImage();
                              },
                            ),
                          )
                        ],
                      ),

                      Padding(
                        padding: EdgeInsets.only(top: 10.0, left: 5.0, right: 5.0, bottom: 5.0),
                        child: TextFormField(
                          onSaved: (value) {
                            teacher.name = value;
                          },
                          validator: (String value) {
                            if (value.isEmpty) return 'Enter Name';
                          },
                          decoration: InputDecoration(
                              labelText: 'Name',
                              errorStyle: TextStyle(color: Colors.yellow),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: TextFormField(
                          obscureText: true,
                          key: _passKey,
                          onSaved: (value) {
                          },
                          validator: (String value) {
                            if (value.length<6) return 'Password too short';
                          },
                          decoration: InputDecoration(
                              labelText: 'Password',
                              errorStyle: TextStyle(color: Colors.yellow),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: TextFormField(
                          obscureText: true,
                          onSaved: (value) {
                            teacher.pass = Password.getHash(value);
                          },
                          validator: (String value) {
                            if (value.length<6 || _passKey.currentState.value != value )
                              return "Passwords doesn't match";
                          },
                          decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              errorStyle: TextStyle(color: Colors.yellow),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: TextFormField(
                          onSaved: (value) {
                            teacher.teacherId = value;
                          },
                          validator: (String value) {
                            if (value.length!=8) return "Enter Teacher's ID";
                          },
                          decoration: InputDecoration(
                              labelText: "Teacher's ID",
                              errorStyle: TextStyle(color: Colors.yellow),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: TextFormField(
                          onSaved: (value) {
                            teacher.email = value;
                          },
                          validator: (String value) {
                            if (!RegExp(r"^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value))
                              return 'Enter Correct Email';
                          },
                          decoration: InputDecoration(
                              labelText: 'Email',
                              errorStyle: TextStyle(color: Colors.yellow),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          onSaved: (value) {
                            teacher.mobile = value;
                          },
                          validator: (String value) {
                            if (!RegExp("[0-9]").hasMatch(value) || value.length!=10)
                              return 'Enter Mobile Number';
                          },
                          decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              errorStyle: TextStyle(color: Colors.yellow),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      Row(
                          children: <Widget>[
                            Expanded(
                              child: Container(
                                width: 50.0,
                              ),
                            ),
                            RaisedButton(
                              child: Text('Submit'),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)
                              ),
                              onPressed: () {
                                setState(() {
                                  if(_signUpForm.currentState.validate() ) {
                                    _signUpForm.currentState.save();
                                    uploadPic(context);

//                        Fluttertoast.showToast(
//                            msg: student.name+' '+student.regNo+' '+student.pass+' '
//                                +student.father+' '+student.gender+' '+student.category+' '
//                                +student.dob+' '+student.email+' '+student.mobile,
//                            toastLength: Toast.LENGTH_SHORT,
//                            gravity: ToastGravity.CENTER,
//                            timeInSecForIos: 1,
//                            backgroundColor: Colors.red,
//                            textColor: Colors.white,
//                            fontSize: 16.0
//                        );

                                    Firestore.instance.collection('teach').add(teacher.toMap());
                                    Navigator.of(context).pop();
                                  }
                                });
                              },
                            ),
                            Expanded(
                              child: Container(
                                width: 50.0,
                              ),
                            )
                          ]
                      ),
                    ]
                ),
              ),
            )
        )
    );
  }

  Future getImage() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery
    );

    setState(() {
      _image = image;
    });
  }

  Future uploadPic(BuildContext context) async {
    String fileName = teacher.teacherId;
    StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
    StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
    StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
    setState(() {
      Scaffold.of(context).showSnackBar(SnackBar(content: Text('Image Uploaded Successfully'),));
    });
  }

}
