import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class CreateClass extends StatefulWidget {

	Teacher _teacher;

	CreateClass(this._teacher);

	@override
  _CreateClassState createState() => _CreateClassState(_teacher);
}

class _CreateClassState extends State<CreateClass> {

	Teacher _teacher;

	_CreateClassState(this._teacher);


	var _createForm = GlobalKey<FormState>();

	Teaching _subject = Teaching.blank();

	bool _isLoading = false;

	/*UI Part:
	* Appbar:
	* 	Text: Create Class
	* Body: Form:
	* 	Subject ID
	* 	Subject Name
	* 	Class ID
	* 	Create Class Button*/

  @override
  Widget build(BuildContext context) {

    return Scaffold(
		appBar: AppBar(
			title: Text('Create Class'),
		),
		body: Container(
			padding: EdgeInsets.all(10.0),
			child: Form(
				key: _createForm,
				child: Center(
					child: Column(
						children: <Widget>[
							Padding(
								padding: EdgeInsets.all(10.0),
								child: TextFormField(
									onSaved: (value) {
										_subject.subjectId = value;
									},
									validator: (String value) {
										if (value.length != 6)
											return "Length should be 6";
									},
									decoration: InputDecoration(
										labelText: "Subject ID",
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(5.0))),
								),
							),

							Padding(
								padding: EdgeInsets.all(10.0),
								child: TextFormField(
									onSaved: (value) {
										_subject.subjectName = value;
									},
									validator: (String value) {
										if (value.length ==0)
											return "Enter Subject name";
									},
									decoration: InputDecoration(
										labelText: "Subject Name",
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(5.0))),
								),
							),

							Padding(
								padding: EdgeInsets.all(10.0),
								child: TextFormField(
									onSaved: (value) {
										_subject.classId = value;
									},
									validator: (String value) {
										if (value.length != 5)
											return "Length should be 5";
									},
									decoration: InputDecoration(
										labelText: "Class Id",
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(5.0))),
								),
							),

							Padding(
								padding: EdgeInsets.all(10.0),
								child: RaisedButton(
									color: Colors.black,
									child: _isLoading?Loading(indicator: BallPulseIndicator(), size: 20.0):Text('Create', style: TextStyle(color: Colors.white)),
									shape: RoundedRectangleBorder(
										borderRadius: BorderRadius.circular(30.0),
									),
									elevation: 10.0,
									onPressed: () {

										//If validated class is created by the method FirestoreCRUD.createNewClass
										if (_createForm.currentState.validate()) {
											_createForm.currentState.save();
											_subject.teacherDocumentId = _teacher.documentId;
											setState(() {
												_isLoading=true;
											});

											FirestoreCRUD.createNewClass(_subject).then((bool b){
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
									}),
							),
						],
					),
				),
			),
		),
	);
  }
}
