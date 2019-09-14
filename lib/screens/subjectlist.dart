import 'package:attendance_teacher/classes/student.dart';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:attendance_teacher/screens/createtiming.dart';
import 'package:attendance_teacher/screens/editattendance.dart';
import 'package:attendance_teacher/screens/qrscanner.dart';
import 'package:attendance_teacher/screens/swipe.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class SubjectList extends StatefulWidget {

	Teacher _teacher;
	Teaching _teaching;
	SubjectList(this._teacher, this._teaching);

	@override
  _SubjectListState createState() => _SubjectListState(_teacher, _teaching);
}

class _SubjectListState extends State<SubjectList> {

	Teacher _teacher;
	Teaching _teaching;

	_SubjectListState(this._teacher, this._teaching);

	String barcode = "";
	bool _isLoading = false;

	@override
  Widget build(BuildContext context) {
    return Scaffold(
		appBar: AppBar(
			title: Text('Timings'),
		),
		body: _isLoading ? Center(child: SpinKitRing(color: Colors.white)):getTimings(),
		floatingActionButton: FloatingActionButton(
			child: Icon(Icons.add),
			onPressed: _isLoading ? () {} : () {
				Navigator.push(context, MaterialPageRoute(builder: (context) {
					return CreateTiming(_teaching);
				}));
			},
		),
	);
  }

  Widget getTimings() {
  	return StreamBuilder<QuerySnapshot> (
		stream: Firestore.instance.collection('teach').document(_teaching.teacherDocumentId).collection('subject').document(_teaching.documentId).collection('timings').snapshots(),
		builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
			if(!snapshot.hasData)
				return Text('Loading');
			return getTimingsList(snapshot);
		},
	);
  }

  getTimingsList(AsyncSnapshot<QuerySnapshot> snapshot) {
		var listView = ListView.builder(itemCount:snapshot.data.documents.length,itemBuilder: (context, index) {
			if(index<snapshot.data.documents.length) {
				var doc = snapshot.data.documents[index];
				Timings timings = Timings.fromMapObject(doc);
				timings.documentId = doc.documentID;
				return Card(
				  child: ExpansionTile(
					  key: GlobalKey(),
				  	title: ListTile(
						title: Text(timings.day),
						subtitle: Text(timings.start+' : '+timings.duration+' hours'),
					),
				  	children: <Widget>[
				  		Card(
							color: Colors.black12,
							child: Column(
								children: <Widget>[
									ListTile(
										title: Text('Take Attendance'),
										onTap: () {
											Navigator.push(context, MaterialPageRoute(builder: (context) {
												return QrScanner(_teacher, _teaching, timings);
											}));
										},
									),
									ListTile(
										title: Text('Bunk'),
										onTap: () {
											markAllAbsent(timings);
										},
									),
									ListTile(
										title: Text('Edit Attendance'),
										onTap: () {
											Navigator.push(context, MaterialPageRoute(builder: (context) {
												return EditAttendance(_teacher, _teaching, timings);
											}));

										},
									),
									ListTile(
										title: Text('Cancel Class'),
										onTap: () {
											setState(() {
											  _isLoading = true;
											});
											getDataSwipePage(timings);

										},
									)
								],
							),
						)
				  	],
				  ),
				);
			}
			return Container();
		});
		return listView;
  }

  void markAllAbsent(Timings timings) async {
	  var now = DateTime.now();
	  var date = now.year.toString()+'-'+now.month.toString()+'-'+now.day.toString();
	  var day = timings.day;
	  var time = timings.start;

	  Firestore.instance.collection('teach').document(_teacher.documentId).collection('subject').document(_teaching.documentId).collection('studentsEnrolled').getDocuments().then((snapshot) {
		  for(int i=0; i<snapshot.documents.length; i++) {
			  var id = snapshot.documents[i].data['docId'];
			  Firestore.instance.collection('stud').document(id).collection('subject').where('subjectId', isEqualTo: _teaching.subjectId).where('teacherId', isEqualTo: _teacher.teacherId).getDocuments().then((snapshot) {
				  if(snapshot.documents.length>0) {
					  Firestore.instance.collection('stud').document(id).collection('subject').document(snapshot.documents[0].documentID).collection('attendance').where('date', isEqualTo: date).where('time', isEqualTo: time).getDocuments().then((check) {
						  if(check.documents.length==0)
							  Firestore.instance.collection('stud').document(id).collection('subject').document(snapshot.documents[0].documentID).collection('attendance').add({'date': date, 'day': day, 'time': time, 'outcome': 'A'});
					  });

				  }
			  });
		  }
		  toast('Task Completed Successfully');
	  });
  }

	void getDataSwipePage(Timings timings) async {
		List<Student> students = List<Student>();
		List<String> url = List<String>();

		QuerySnapshot snapshot = await Firestore.instance.collection('teach').document(_teacher.documentId).collection('subject').document(_teaching.documentId).collection('studentsEnrolled').getDocuments();
		for(int i=0; i<snapshot.documents.length; i++) {
			var id = snapshot.documents[i].data['docId'];

			DocumentSnapshot studentSnapshot = await Firestore.instance.collection('stud').document(id).get();
			students.add(Student.fromMapObject(studentSnapshot.data));
			students[students.length-1].documentId = id;
			String singleUrl = await FirebaseStorage.instance.ref().child(students[i].regNo).getDownloadURL();
			url.add(singleUrl);
		}
		bool result = await Navigator.push(context, MaterialPageRoute(builder: (context) {
			return Swipe(_teacher, _teaching, timings, students, url);
		}));

		setState(() {
		  _isLoading = result;
		});
	}

}
