import 'package:attendance_teacher/classes/student.dart';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:validators/validators.dart';

class EditAttendance extends StatefulWidget {

	Teacher _teacher;
	Teaching teaching;
	Timings timings;
	EditAttendance(this._teacher, this.teaching, this.timings);

  @override
  _EditAttendanceState createState() => _EditAttendanceState(_teacher,teaching,timings);
}

class _EditAttendanceState extends State<EditAttendance> {


	Teacher _teacher;
	Teaching teaching;
	Timings timings;
	_EditAttendanceState(this._teacher, this.teaching, this.timings);


	var _editForm = GlobalKey<FormState>();
	final dateFormat = DateFormat("yyyy-MM-dd");
	String regNo;
	String date;
	DateTime dateTime = DateTime.now();
	bool _isLoading=false;
	Widget studentPresentAbsent=Container();//This widget allows you to mark absent or present

  @override
  Widget build(BuildContext context) {
    return Scaffold(
		appBar: AppBar(
			title: Text('Edit Attendance'),
		),
		body: Container(
			padding: EdgeInsets.all(10.0),
			child: Form(
				key: _editForm,
				child: Center(
					child: ListView(
						children: <Widget>[
							Padding(
								padding: EdgeInsets.all(10.0),
								child: TextFormField(
									onSaved: (value) {
										regNo = value;
									},
									validator: (String value) {
										if(value.length != 8)
											return 'Enter valid Registration Number';
									},
									decoration: InputDecoration(
										labelText: 'Registration Number',
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(5.0))
									),
								),
							),
							Padding(
								padding: EdgeInsets.all(10.0),
								child: DateTimeField(
									format: dateFormat,
									onShowPicker: (context, currentValue) {
										return showDatePicker(
											context: context,
											initialDate: dateTime,
											firstDate: DateTime(2000),
											lastDate: DateTime(2050));
									},
									onSaved: (value) {
										dateTime = value;
										date = dateTime.year.toString()+'-'+dateTime.month.toString()+'-'+dateTime.day.toString();
									},
									validator: (DateTime value) {
										if(!isDate(value.toString()) || value == null)
											return 'Enter valid Date';
									},
									decoration: InputDecoration(
										labelText: 'Date',
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(5.0))
									),
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
										child: _isLoading?Loading(indicator: BallPulseIndicator(), size: 20.0):Text(
											'Search',
											style: TextStyle(color: Colors.white),
										),
										shape: RoundedRectangleBorder(
											borderRadius: BorderRadius.circular(30.0),
										),
										color: Colors.black,
										onPressed: () {
											if (!_editForm.currentState.validate())
												return;
											_editForm.currentState.save();
											setState(() {
											  _isLoading=true;
											});
											searchStudentPresentAbsent();
										},
									),
									Expanded(
										child: Container(
											width: 50.0,
										),
									),
								],
							),
							studentPresentAbsent,//The widget which comes after searching for a student
						],
					),
				),
			),
		)
	);
  }

  Future<void> searchStudentPresentAbsent() async {
  	var student=await Firestore.instance.collection('stud').where('regNo',isEqualTo: regNo).getDocuments();
  	if(student.documents.length==0){
  		setState(() {_isLoading=false;});
  		return;
		}
  	var subject=await Firestore.instance.collection('stud').document(student.documents[0].documentID).collection('subject').where('subjectId',isEqualTo: teaching.subjectId).where('subjectName',isEqualTo: teaching.subjectName).where('teacherId',isEqualTo: _teacher.teacherId).getDocuments();
  	if(subject.documents.length==0){
			setState(() {_isLoading=false;});
			return;
		}
  	var attendance=await Firestore.instance.collection('stud').document(student.documents[0].documentID).collection('subject').document(subject.documents[0].documentID).collection('attendance').where('date',isEqualTo: date).where('time',isEqualTo: timings.start).getDocuments();
		if(attendance.documents.length==0){
			setState(() {_isLoading=false;});
			return;
		}
		Student s=Student.fromMapObject(student.documents[0].data);
		s.documentId=student.documents[0].documentID;
		String subjectId=subject.documents[0].documentID.toString();
		String attendanceId=attendance.documents[0].documentID.toString();
		setState(() {
			studentPresentAbsent=simpleCard(s,subjectId,attendanceId);
			_isLoading=false;
		});
  	return;
  	
	}

	Widget simpleCard(Student student,String subjectId,String attendanceId){
  	return Card(
			color: Colors.black,
			child: ExpansionTile(
					title: Padding(
						padding: const EdgeInsets.all(10.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: <Widget>[
								Text(
									student.name,
									style: TextStyle(
										fontSize: 20.0,
										fontWeight: FontWeight.bold,
									),
								),
								Text(
									student.regNo,
									style: TextStyle(
										fontSize: 15.0,
									),
								),
							],
						),
					),
					children: <Widget>[
						Column(
							children: <Widget>[
								Padding(
									padding: const EdgeInsets.all(10.0),
									child: Row(
										mainAxisAlignment: MainAxisAlignment.spaceEvenly,
										children: <Widget>[
											RaisedButton(
												child: Text('Present'),
												onPressed: () {
													Firestore.instance.collection('stud').document(student.documentId).collection('subject').document(subjectId).collection('attendance').document(attendanceId).updateData({'outcome': 'P'});
													refreshSimpleCard(student);
												},
											),
											RaisedButton(
												child: Text('Absent'),
												onPressed: () {
													Firestore.instance.collection('stud').document(student.documentId).collection('subject').document(subjectId).collection('attendance').document(attendanceId).updateData({'outcome': 'A'});
													refreshSimpleCard(student);
												},
											)
										],
									)
								)
							],
						)
					]
			),
		);
	}
	void refreshSimpleCard(Student student){
  	studentPresentAbsent=Card(
			color: Colors.black,
			child: ExpansionTile(
					title: Padding(
						padding: const EdgeInsets.all(10.0),
						child: Column(
							crossAxisAlignment: CrossAxisAlignment.start,
							mainAxisAlignment: MainAxisAlignment.spaceEvenly,
							children: <Widget>[
								Text(
									student.name,
									style: TextStyle(
										fontSize: 20.0,
										fontWeight: FontWeight.bold,
									),
								),
								Text(
									student.regNo,
									style: TextStyle(
										fontSize: 15.0,
									),
								),
							],
						),
					),
					children: <Widget>[
						Icon(Icons.done),
					]
			),
		);
  	setState(() {});
	}

}
