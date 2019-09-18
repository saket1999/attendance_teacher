import 'dart:io';

import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/screens/login.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:attendance_teacher/services/password.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Profile extends StatefulWidget {

	Teacher _teacher;
	Profile(this._teacher);

	@override
	_ProfileState createState() => _ProfileState(_teacher);
}

class _ProfileState extends State<Profile> {

	var _profileForm = GlobalKey<FormState>();
	var _passKey = GlobalKey<FormFieldState>();

	Teacher _teacher;
	_ProfileState(this._teacher);

	File _image;

	String _url;

	bool _isLoading=false;

	String inputPass;

	@override
	void initState() {
		super.initState();
		getImageNetwork();
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('SignUp'),
			),
			body: Container(
				padding: EdgeInsets.all(5.0),
				child: Form(
					key: _profileForm,
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
														(_url==null? DecoratedBox(decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/default.png'))))
															: Image.network(
															_url,
															fit: BoxFit.fill,
														)),
													),
												),
											),

										),
										Padding(
											padding: EdgeInsets.only(top: 60.0),
											child: _teacher.verify==1?Icon(Icons.block):IconButton(
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
										readOnly: _teacher.verify==1,
										initialValue: _teacher.name,
										onSaved: (value) {
											_teacher.name = value;
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
										readOnly: _teacher.verify==1,
										obscureText: true,
										key: _passKey,
										onSaved: (value) {
										},
										validator: (String value) {
											if (value.length<6 && value.length>0) return 'Password too short';
										},
										decoration: InputDecoration(
											labelText: 'Password (Leave blank if not Using)',
											errorStyle: TextStyle(color: Colors.red),
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(5.0))),
									),
								),

								Padding(
									padding: EdgeInsets.all(5.0),
									child: TextFormField(
										readOnly: _teacher.verify==1,
										obscureText: true,
										onSaved: (value) {
											inputPass = value;
										},
										validator: (String value) {
											if ((value.length<6 && value.length>0) || _passKey.currentState.value != value )
												return "Passwords don't match";
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
										initialValue: _teacher.teacherId,
										readOnly: true,
										onSaved: (value) {
											_teacher.teacherId = value;
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
										readOnly: _teacher.verify==1,
										initialValue: _teacher.email,
										onSaved: (value) {
											_teacher.email = value;
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
										readOnly: _teacher.verify==1,
										initialValue: _teacher.mobile,
										keyboardType: TextInputType.number,
										onSaved: (value) {
											_teacher.mobile = value;
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
										_teacher.verify==1?Icon(Icons.block):RaisedButton(
											child: _isLoading?Loading(indicator: BallPulseIndicator(), size: 20.0):Text('Submit', style: TextStyle(color: Colors.white)),
											shape: RoundedRectangleBorder(
												borderRadius: BorderRadius.circular(30.0)
											),
											color: Colors.black,
											elevation: 10.0,
											onPressed: () {


												//The Sign Up button checks for below parameters
												if(_profileForm.currentState.validate() && _isLoading==false) {
													setState(() {
														_isLoading = true;
													});

													//forms state is saved
													_profileForm.currentState.save();
													_teacher.verify = 0;

													//Method made signUp if new user
													if(inputPass.length==0) {
														FirestoreCRUD.profileUpdate(_teacher,_image, false).then((bool b){
															if(b==true){
																toast('Updated successfully');
																Navigator.of(context).pop();
															}
															else
																setState(() {
																	_isLoading = false;
																});
														});
														inputPass = '';
													}
													else {
														compute(Password.getHash,inputPass).then((hash) {
															_teacher.pass = hash;
															FirestoreCRUD.profileUpdate(_teacher,_image ,true).then((bool b){
																if(b==true){
																	toast('Updated successfully');
																	clearSharedPrefs();
																	Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login(false)), (Route<dynamic> route) => false);
																}
																else
																	setState(() {
																		_isLoading = false;
																	});
															});
														});

													}



												}
												else if(_isLoading){
													toast("Please wait");
												}

											},
										),
										Expanded(
											child: Container(
												width: 50.0,
											),
										)
									],
								)
							],
						),
					),
				),
			),
		);
	}

	//fetches image from gallery
	Future getImage() async {
		var image = await ImagePicker.pickImage(
			source: ImageSource.gallery
		);

		setState(() {
			_image = image;
		});
	}

	void getImageNetwork() async {
		FirebaseStorage.instance.ref().child(_teacher.teacherId).getDownloadURL().then((storedUrl) {
			setState(() {
				_url = storedUrl;
			});
		});
	}

	void clearSharedPrefs() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		prefs.setString('storedObject', '');
		prefs.setString('storedId', '');
	}
}



