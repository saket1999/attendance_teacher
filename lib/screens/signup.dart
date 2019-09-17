import 'dart:io';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:attendance_teacher/services/password.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading/loading.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';

class SignUp extends StatefulWidget {
  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {


  var _signUpForm = GlobalKey<FormState>();
  var _passKey = GlobalKey<FormFieldState>();

  Teacher teacher = Teacher.blank();
  File _image;

  bool _isLoading = false;

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
                                  DecoratedBox(decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/default.png')))),

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
                              onPressed: _isLoading?null:() {
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
                              errorStyle: TextStyle(color: Colors.red),
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
                              errorStyle: TextStyle(color: Colors.red),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),

                      Padding(
                        padding: EdgeInsets.all(5.0),
                        child: TextFormField(
                          obscureText: true,
                          onSaved: (value) {
                            teacher.pass = value;
                          },
                          validator: (String value) {
                            if (value.length<6 || _passKey.currentState.value != value )
                              return "Passwords doesn't match";
                          },
                          decoration: InputDecoration(
                              labelText: 'Confirm Password',
                              errorStyle: TextStyle(color: Colors.red),
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
                              errorStyle: TextStyle(color: Colors.red),
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
                              errorStyle: TextStyle(color: Colors.red),
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
                              errorStyle: TextStyle(color: Colors.red),
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
                              child: _isLoading?Loading(indicator: BallPulseIndicator(), size: 20.0):Text('Submit'),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0)
                              ),
                              onPressed: () {
                                  if(_image!=null  && _signUpForm.currentState.validate() && _isLoading==false) {
                                    setState(() {
                                      _isLoading = true;
                                    });
                                    _signUpForm.currentState.save();
                                    teacher.verify = 0;
                                    uploadPic(context);

                                    //Method made signUp if new user
                                    FirestoreCRUD.signUp(teacher,_image).then((bool b){
                                      if(b==true){
                                        toast('Registered successfully');
                                        Navigator.of(context).pop();
                                      }
                                      else
                                        setState(() {
                                          _isLoading = false;
                                        });
                                    });
                                  }
                                  else if(_image==null){
                                    toast('Select an image');
                                  }
                                  else if(_isLoading){
                                    toast("Please wait");
                                  }

                              }
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
