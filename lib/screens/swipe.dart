import 'package:attendance_teacher/classes/student.dart';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_tindercard/flutter_tindercard.dart';

class Swipe extends StatefulWidget {

	Teacher teacher;
	Teaching teaching;
	Timings timings;
	List<Student> students;
	List<String> url;
	String _extraDate;

	Swipe.withDate(this.teacher, this.teaching, this.timings, this.students, this.url, this._extraDate);
	Swipe(this.teacher, this.teaching, this.timings, this.students, this.url);

	@override
	_SwipeState createState() {
		if(_extraDate == null)
			return _SwipeState(teacher, teaching, timings, students, url);
		else
			return _SwipeState.withDate(teacher, teaching, timings, students, url, _extraDate);
	}
}

class _SwipeState extends State<Swipe> {

	Teacher teacher;
	Teaching teaching;
	Timings timings;
	List<Student> students;
	List<String> url;
	String _extraDate;

	_SwipeState(this.teacher, this.teaching, this.timings, this.students, this.url);
	_SwipeState.withDate(this.teacher, this.teaching, this.timings, this.students, this.url, this._extraDate);

	var now = DateTime.now();
	var date,time;
	bool swipeDirection = true;		//true for right, false for left

	int total = 0;
	int present = 0;

	bool _isLoading = false;

	@override
	void initState() {
		super.initState();

		if(_extraDate == null)
			date = now.year.toString()+'-'+now.month.toString()+'-'+now.day.toString();
		else
			date = _extraDate;
		time = timings.start;

		Firestore.instance.collection('teach').document(teacher.documentId).collection('subject').document(teaching.documentId).collection('studentsEnrolled').getDocuments().then((snapshot) {
			for(int i=0; i<snapshot.documents.length; i++) {
				var id = snapshot.documents[i].data['docId'];
				Firestore.instance.collection('stud').document(id).collection('subject').where('subjectId', isEqualTo: teaching.subjectId).where('teacherId', isEqualTo: teacher.teacherId).getDocuments().then((snapshot) {
					if(snapshot.documents.length>0) {
						Firestore.instance.collection('stud').document(id).collection('subject').document(snapshot.documents[0].documentID).collection('attendance').where('date', isEqualTo: date).where('time', isEqualTo: time).getDocuments().then((check) {
							if(check.documents.length==0)
								Firestore.instance.collection('stud').document(id).collection('subject').document(snapshot.documents[0].documentID).collection('attendance').add({'date': date, 'time': time, 'outcome': 'A', 'duration': timings.duration});
						});

					}
				});
			}
		});
	}

	@override
	Widget build(BuildContext context) {

		CardController controller;
		return WillPopScope(
			onWillPop: _isLoading ? () {} : () {
				setState(() {
				  _isLoading = true;
				});
				getAttendanceData();
			},
			child: Scaffold(
				backgroundColor: Colors.white70,
				appBar: AppBar(
					title: Text('Attendance'),
				),
				body: Center(
					child: _isLoading ? Center(child: SpinKitRing(color: Colors.black)):Container(
						height: MediaQuery.of(context).size.height * 0.6,
						child: TinderSwapCard(
							orientation: AmassOrientation.BOTTOM,
							totalNum: students.length,
							stackNum: 3,
							swipeEdge: 4.0,
							maxWidth: MediaQuery.of(context).size.width * 0.9,
							maxHeight: MediaQuery.of(context).size.width * 0.9,
							minWidth: MediaQuery.of(context).size.width * 0.8,
							minHeight: MediaQuery.of(context).size.width * 0.8,
							cardBuilder: (context, index) {
								return Card(
									child: Container(
										height: 380.0,
										width: 50.0,
										child: Column(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												CircleAvatar(
													radius: 100.0,
													child: ClipOval(
														child: SizedBox(
															width: 200.0,
															height: 200.0,
															child: Image
																.network(url[index])
														),
													),
												),
												Padding(
													padding: const EdgeInsets.all(5.0),
													child: Text(
														students[index].name,
														style: TextStyle(
															fontSize: 22.0,
															fontWeight: FontWeight.w600,
														),
													),
												),
												Padding(
													padding: const EdgeInsets.all(5.0),
													child: Text(
														"Reg no: "+students[index].regNo,
														style: TextStyle(
															fontSize: 22.0,
															fontWeight: FontWeight.w600
														),
													),
												),
											],
										),
									),
								);
							},
							cardController: controller,
							swipeUpdateCallback: (DragUpdateDetails details, Alignment align) {
								if(align.x < 0) {
									swipeDirection = false;
								}
								else if(align.x > 0) {
									swipeDirection = true;
								}
							},
							swipeCompleteCallback: (CardSwipeOrientation orientation, int index) {
								if(swipeDirection)
									setAttendance(index, 'P');
								else
									setAttendance(index, 'A');
							},
						),
					),
				)
			),
		);
	}

	void setAttendance(int index, String outcome) async {
		var snapshot = await Firestore.instance.collection('stud').document(students[index].documentId).collection('subject').where('subjectId', isEqualTo: teaching.subjectId).where('teacherId', isEqualTo: teacher.teacherId).getDocuments();
		if(snapshot.documents.length>0) {
			var docId = snapshot.documents[0].documentID;
			Firestore.instance.collection('stud').document(students[index].documentId).collection('subject').document(docId).collection('attendance').where('date', isEqualTo: date).where('time', isEqualTo: time).getDocuments().then((snapshot) {
				if(snapshot.documents.length==0)
					Firestore.instance.collection('stud').document(students[index].documentId).collection('subject').document(docId).collection('attendance').add({'date': date, 'time': time,'outcome': outcome, 'duration': timings.duration});
				else {
					Firestore.instance.collection('stud').document(students[index].documentId).collection('subject').document(docId).collection('attendance').document(snapshot.documents[0].documentID).updateData({'outcome': outcome});
				}
			});
		}
	}

	void getAttendanceData() async {
		var snapshot = await Firestore.instance.collection('teach').document(teacher.documentId).collection('subject').document(teaching.documentId).collection('studentsEnrolled').getDocuments();
		total = snapshot.documents.length;

		for(int i=0; i<snapshot.documents.length; i++) {

//			toast(snapshot.documents[i].data['docId']);
			var subSnapshot = await Firestore.instance.collection('stud').document(snapshot.documents[i].data['docId']).collection('subject').where('subjectId', isEqualTo: teaching.subjectId).where('teacherId', isEqualTo: teacher.teacherId).getDocuments();

//			toast(subSnapshot.documents.length.toString());
			if(subSnapshot.documents.length>0) {
				var attenSnapshot = await Firestore.instance.collection('stud').document(snapshot.documents[i].data['docId']).collection('subject').document(subSnapshot.documents[0].documentID).collection('attendance').where('date', isEqualTo: date).where('time', isEqualTo: time).getDocuments();

//				toast(attenSnapshot.documents[0].data['outcome']);
				if(attenSnapshot.documents.length>0 && attenSnapshot.documents[0].data['outcome'] == 'P')
					present++;
			}
		}
//		toast(present.toString());
		attendanceDialog();
	}

	void attendanceDialog(){
		showDialog(
			context: context,
			builder: (_) {
				return WillPopScope(
					onWillPop: () {
						Navigator.pop(context);
						Navigator.pop(context, false);
					},
					child: Dialog(
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(12.0)
						),
						child: Container(
							height: 300.0,
							width: 300.0,
							child: Column(
								mainAxisAlignment: MainAxisAlignment.center,
								children: <Widget>[
									Card(
										child: Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												Text(
													'Date',
													textScaleFactor: 1.5,
												),
												Container(width: 10),
												Text(
													date,
													textScaleFactor: 1.5,
												)
											],
										),
									),
									Card(
										child: Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												Text(
													'Time',
													textScaleFactor: 1.5,
												),
												Container(width: 10),
												Text(
													time,
													textScaleFactor: 1.5,
												)
											],
										),
									),
									Card(
										child: Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												Text(
													'Total Strength',
													textScaleFactor: 1.5,
												),
												Container(width: 10),
												Text(
													total.toString(),
													textScaleFactor: 1.5,
												)
											],
										),
									),
									Card(
										child: Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												Text(
													'Present',
													textScaleFactor: 1.5,
												),
												Container(width: 10),
												Text(
													present.toString(),
													textScaleFactor: 1.5,
												)
											],
										),
									),
									Card(
										child: Row(
											mainAxisAlignment: MainAxisAlignment.center,
											children: <Widget>[
												Text(
													'Absent',
													textScaleFactor: 1.5,
												),
												Container(width: 10),
												Text(
													(total-present).toString(),
													textScaleFactor: 1.5,
												)
											],
										),
									),

								],
							),
						),
					),
				);
			}
		);
	}

}
