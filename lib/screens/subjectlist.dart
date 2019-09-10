import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:attendance_teacher/screens/createtiming.dart';
import 'package:attendance_teacher/screens/qrscanner.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

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

	@override
  Widget build(BuildContext context) {
    return Scaffold(
		appBar: AppBar(
			title: Text('Subjects List'),
		),
		body: getTimings(),
		floatingActionButton: FloatingActionButton(
			child: Icon(Icons.add),
			onPressed: () {
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
		var listView = ListView.builder(itemBuilder: (context, index) {
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

										},
									),
									ListTile(
										title: Text('Cancel Class'),
										onTap: () {

										},
									)
								],
							),
						)
				  	],
				  ),
				);
			}
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

}
