/*This screen shows the list of timings available in a particular subject*/

import 'package:attendance_teacher/classes/student.dart';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:attendance_teacher/screens/create_extraclass.dart';
import 'package:attendance_teacher/screens/createtiming.dart';
import 'package:attendance_teacher/screens/editattendance.dart';
import 'package:attendance_teacher/screens/editextraclassattendance.dart';
import 'package:attendance_teacher/screens/qrscanner.dart';
import 'package:attendance_teacher/screens/swipe.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:attendance_teacher/services/functions.dart';
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

class _SubjectListState extends State<SubjectList> with SingleTickerProviderStateMixin {
	Teacher _teacher;
	Teaching _teaching;
	_SubjectListState(this._teacher, this._teaching);
	bool _isLoading = false;

	TabController _tabController;

	void initState() {
		super.initState();
		_tabController = TabController(length: 2, vsync: this, initialIndex: 0);
		_tabController.addListener(_handleTabIndex);
	}

	void dispose() {
		_tabController.removeListener(_handleTabIndex);
		_tabController.dispose();
		super.dispose();
	}

	void _handleTabIndex() {
		setState(() {});
	}

	/*UI:
	* 	Two Tabs:
	* 		Regular class
	* 		Extra Class
	* 	Each Tab has:
	* 		Expansion tiles:
	* 			Take attendance using swipe or qr method
	* 			Bunk
	* 			Edit attendance
	* 			Cancel Class
	* 	Floating action Buttons:
	* 			Add regular class
	* 			Add extra class*/

	@override
  Widget build(BuildContext context) {

		final _tabPages = <Widget>[
			regularClass(),
			extraClass()
		];
		final _tabs = <Tab>[
			Tab(icon: Icon(Icons.group), text: 'Class'),
			Tab(icon: Icon(Icons.group_add), text: 'Extra Class')
		];

		return DefaultTabController(
			length: _tabs.length,
			child: Scaffold(
				appBar: AppBar(
					title: Text('Timings'),
					bottom: TabBar(
						controller: _tabController,
						tabs: _tabs,
					),
				),
				body: TabBarView(
					controller: _tabController,
					children: _tabPages,
				),
				floatingActionButton: _bottomButtons(),
			),
		);
  }

	Widget regularClass() {
		return _isLoading ? Center(child: SpinKitRing(color: Colors.black)):getTimings();
	}

	Widget extraClass() {
		return _isLoading ? Center(child: SpinKitRing(color: Colors.black)):getExtraClassTimings();
	}

	//The floating buttons change action and icon when tabs are switched
	Widget _bottomButtons() {
		return _tabController.index == 0 ?
		FloatingActionButton(
			child: Icon(Icons.add),
			tooltip: 'Add new timing',
			onPressed: _isLoading ? () {} : () {
				Navigator.push(context, MaterialPageRoute(builder: (context) {
					return CreateTiming(_teaching);
				}));
			}
		):
		FloatingActionButton(
			child: Icon(Icons.add_comment),
			tooltip: 'Add new extra class',
			onPressed: () {
				Navigator.push(context, MaterialPageRoute(builder: (context) {
					return CreateExtraClass(_teaching);
				}));
			},
		);
	}

	//This stream builder fetches the timings of extra classes
	Widget getExtraClassTimings() {
		return StreamBuilder<QuerySnapshot> (
			stream: Firestore.instance.collection('teach').document(_teaching.teacherDocumentId).collection('subject').document(_teaching.documentId).collection('extraClass').orderBy("date", descending: true).snapshots(),
			builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
				if (!snapshot.hasData)
					return Center(child:Loading(indicator: BallPulseIndicator(), size: 20.0));
				return getExtraClassTimingsList(snapshot);
			}
		);
	}

	//This returns a list view according to the snapshots provided by the getExtraClassTimings stream builder
	getExtraClassTimingsList(AsyncSnapshot<QuerySnapshot> snapshot) {
		var listView = ListView.builder(itemCount: snapshot.data.documents.length, itemBuilder: (context, index) {
			if(index < snapshot.data.documents.length) {
				var doc = snapshot.data.documents[index];
				Timings timings = Timings.fromMapObject(doc);
				return Card(
					child: ExpansionTile(
						key: GlobalKey(),
						title: ListTile(
							title: Text(doc['date']),
							subtitle: Text('Time: '+timeConverter(doc['start'])+'  Duration: '+doc['duration']+' hours'),
						),
						children: <Widget>[
							Card(
								color: Colors.white70,
								child: Column(
									children: <Widget>[
										ListTile(
											title: Row(
												mainAxisAlignment: MainAxisAlignment.spaceBetween,
												children: <Widget>[
													Text('Take Attendance'),
													GestureDetector(
														child: Card(
															child: Padding(
																padding: const EdgeInsets.all(8.0),
																child: Text('Qr Scan'),
															),
														),
														onTap: () {
															Navigator.push(context, MaterialPageRoute(builder: (context) {
																return QrScanner.withDate(_teacher, _teaching, timings, doc['date']);
															}));
														},
													),
													GestureDetector(
														child: Card(
															child: Padding(
																padding: const EdgeInsets.all(8.0),
																child: Text('Swipe'),
															),
														),
														onTap: () {
															setState(() {
																_isLoading = true;
															});
															getDataSwipePageWithDate(timings, doc);
														},
													),
												],
											),
										),
										ListTile(
											title: Text('Edit Attendance'),
											onTap: () {
												Navigator.push(context, MaterialPageRoute(builder: (context) {
													return EditExtraClassAttendance(_teacher, _teaching, timings, doc['date']);
												}));

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

	//This stream builder fetches the timings of regular classes
	Widget getTimings() {
  	return StreamBuilder<QuerySnapshot> (
		stream: Firestore.instance.collection('teach').document(_teaching.teacherDocumentId).collection('subject').document(_teaching.documentId).collection('timings').snapshots(),
		builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
			if(!snapshot.hasData)
				return Center(child:Loading(indicator: BallPulseIndicator(), size: 20.0));
			return getTimingsList(snapshot);
		},
	);
  }
	//This returns a list view according to the snapshots provided by the getTimings stream builder
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
						subtitle: Text('Time: '+timeConverter(timings.start)+'  Duration: '+timings.duration+' hours'),
					),
				  	children: <Widget>[
				  		Card(
							color: Colors.white70,
							child: Column(
								children: <Widget>[
									ListTile(
										title: Row(
											mainAxisAlignment: MainAxisAlignment.spaceBetween,
											children: <Widget>[
												Text('Take Attendance'),
												GestureDetector(
													child: Card(
														child: Padding(
														  padding: const EdgeInsets.all(8.0),
														  child: Text('Qr Scan'),
														),
													),
													onTap: () {
														Navigator.push(context, MaterialPageRoute(builder: (context) {
															return QrScanner(_teacher, _teaching, timings);
														}));
													},
												),
												GestureDetector(
													child: Card(
														child: Padding(
															padding: const EdgeInsets.all(8.0),
															child: Text('Swipe'),
														),
													),
													onTap: () {
														setState(() {
															_isLoading = true;
														});
														getDataSwipePage(timings);
													},
												),
											],
										),
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
											FirestoreCRUD.cancelClass(_teacher,_teaching,timings);
											toast('Please Wait');
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

  //This method marks each student of that class absent and send them a mail.
  void markAllAbsent(Timings timings) async {
	  var now = DateTime.now();
	  var date = now.year.toString()+'-'+now.month.toString()+'-'+now.day.toString();
	  var time = timings.start;
		List<String> recipients=[];

	  Firestore.instance.collection('teach').document(_teacher.documentId).collection('subject').document(_teaching.documentId).collection('studentsEnrolled').getDocuments().then((snapshot) {
		  for(int i=0; i<snapshot.documents.length; i++) {
		  	//storing student docID in "var id"
			  var id = snapshot.documents[i].data['docId'];
				//adding email to recipient list
			  recipients.add(snapshot.documents[i].data['email']);
			  Firestore.instance.collection('stud').document(id).collection('subject').where('subjectId', isEqualTo: _teaching.subjectId).where('teacherId', isEqualTo: _teacher.teacherId).getDocuments().then((snapshot) {
				  if(snapshot.documents.length>0) {
					  Firestore.instance.collection('stud').document(id).collection('subject').document(snapshot.documents[0].documentID).collection('attendance').where('date', isEqualTo: date).where('time', isEqualTo: time).getDocuments().then((check) {
						  if(check.documents.length==0)
							  Firestore.instance.collection('stud').document(id).collection('subject').document(snapshot.documents[0].documentID).collection('attendance').add({'date': date, 'time': time, 'outcome': 'A', 'duration': timings.duration});
					  });

				  }
			  });
		  }
		  toast('Sending email to all students');
	  });

	  //This code sends email to all students to notify bunk
	  String subject='Mass Bunk in '+_teaching.subjectName;
	  String body='All students have been marked absent for the below mentioned class\n\nSubject: '+_teaching.subjectName+'\nDate: '+date+'\nTime: '+time+'\n\nStricter actions will be taken if mass bunk is attempted in future.\n\nTeacher incharge '+_teacher.name;
	  FirestoreCRUD.sendEmail(subject, body, recipients);
  }

  //This method collects information about students to mark their attendance using the swipe method for a regular class
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

	//This method collects information about students to mark their attendance using the swipe method for an extra class
	void getDataSwipePageWithDate(Timings timings, var doc) async {
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
			return Swipe.withDate(_teacher, _teaching, timings, students, url, doc['date']);
		}));

		setState(() {
			_isLoading = result;
		});
	}

}
