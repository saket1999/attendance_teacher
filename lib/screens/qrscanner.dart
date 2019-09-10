import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:qr_code_scanner/qr_scanner_overlay_shape.dart';

class QrScanner extends StatefulWidget {

	Teacher _teacher;
	Teaching teaching;
	Timings timings;
	QrScanner(this._teacher, this.teaching, this.timings);

	@override
  _QrScannerState createState() => _QrScannerState(_teacher, teaching, timings);
}

class _QrScannerState extends State<QrScanner> {

	Teacher _teacher;
	Teaching teaching;
	Timings timings;
	_QrScannerState(this._teacher, this.teaching, this.timings);

	GlobalKey qrKey = GlobalKey();
	var qrText = "";
	QRViewController controller;

	Map<String, dynamic> student = Map<String, dynamic>();

	bool _doScan = true;


	var now = DateTime.now();
	var date,day,time;
	
	void initState() {
		super.initState();


		date = now.year.toString()+'-'+now.month.toString()+'-'+now.day.toString();
		day = timings.day;
		time = timings.start;

		Firestore.instance.collection('teach').document(_teacher.documentId).collection('subject').document(teaching.documentId).collection('studentsEnrolled').getDocuments().then((snapshot) {
			for(int i=0; i<snapshot.documents.length; i++) {
				var id = snapshot.documents[i].data['docId'];
				Firestore.instance.collection('stud').document(id).collection('subject').where('subjectId', isEqualTo: teaching.subjectId).where('teacherId', isEqualTo: _teacher.teacherId).getDocuments().then((snapshot) {
					if(snapshot.documents.length>0) {
						Firestore.instance.collection('stud').document(id).collection('subject').document(snapshot.documents[0].documentID).collection('attendance').where('date', isEqualTo: date).where('time', isEqualTo: time).getDocuments().then((check) {
							if(check.documents.length==0)
								Firestore.instance.collection('stud').document(id).collection('subject').document(snapshot.documents[0].documentID).collection('attendance').add({'date': date, 'day': day, 'time': time, 'outcome': 'A'});
						});

					}
				});
			}
		});
	}

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			body: Column(
				children: <Widget>[
					Expanded(
						flex: 5,
						child: QRView(
							key: qrKey,
							overlay: QrScannerOverlayShape(
								borderRadius: 10.0,
								borderColor: Colors.red,
								borderLength: 30.0,
								borderWidth: 10.0,
								cutOutSize: 300.0
							),
							onQRViewCreated: _onQRViewCreate,
						),
					),
					Expanded(
						child: Center(
							child: Text(qrText),
						),
					),
//				RaisedButton(
//					child: Text('~'),
//					onPressed: () {
//						giffyDialogue();
//					}
//				)
				],
			),
		);
	}

	@override
	void dispose() {
		controller?.dispose();
		super.dispose();
	}


	void _onQRViewCreate(QRViewController controller) {
		this.controller = controller;
		controller.scannedDataStream.listen((scanData) {
			setState(() {
				if (_doScan) {
					qrText = scanData;
					_doScan = false;
//					confirmDialogue();
					getData();
				}
			});
		});
	}

	void confirmDialogue() async {
		var _imageUrl = await FirebaseStorage.instance.ref().child(student['regNo']).getDownloadURL();
		_imageUrl = _imageUrl.toString();
		showDialog(
			barrierDismissible: false,
			context: context,
			builder: (_) {
				return WillPopScope(
					onWillPop: () {},
					child: Dialog(
						shape: RoundedRectangleBorder(
							borderRadius: BorderRadius.circular(12.0)
						),
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
													.network(_imageUrl)
											),
										),
									),
									Padding(
										padding: const EdgeInsets.all(5.0),
										child: Text(
											student['name'],
											style: TextStyle(
												fontSize: 22.0,
												fontWeight: FontWeight.w600,
											),
										),
									),
									Padding(
										padding: const EdgeInsets.all(5.0),
										child: Text(
											"Reg no: "+student['regNo'],
											style: TextStyle(
												fontSize: 22.0,
												fontWeight: FontWeight.w600
											),
										),
									),
									Row(
										children: <Widget>[
											Expanded(
												child: Container(width: 20.0),
											),
											RaisedButton(
												child: Text('Absent'),
												color: Colors.red,
												onPressed: () {
													setAttendance('A');
													_doScan = true;
													Navigator.of(context).pop();
												},
											),
											Expanded(
												child: Container(width: 20.0),
											),
											RaisedButton(
												child: Text('Present'),
												color: Colors.green,
												onPressed: () {
													setAttendance('P');
													_doScan = true;
													Navigator.of(context).pop();
												},
											),
											Expanded(
												child: Container(width: 20.0),
											),
										],
									)
								],
							),
						),
					),
				);
			}
		);
	}

	void getData() async {
		var snapshot = await Firestore.instance.collection('stud').document(qrText).get();
//  	snapshot.then((doc) {
//		student = doc.data;
//		toast(student['regNo']);
//		setState(() {
//
//		});
//	});
//  }
		var doc = snapshot.data;
		student = doc;
		confirmDialogue();
	}

	void setAttendance(String outcome) async {
		var snapshot = await Firestore.instance.collection('stud').document(qrText).collection('subject').where('subjectId', isEqualTo: teaching.subjectId).where('teacherId', isEqualTo: _teacher.teacherId).getDocuments();
		if(snapshot.documents.length>0) {
			var docId = snapshot.documents[0].documentID;
			Firestore.instance.collection('stud').document(qrText).collection('subject').document(docId).collection('attendance').where('date', isEqualTo: date).where('day', isEqualTo: day).where('time', isEqualTo: time).getDocuments().then((snapshot) {
				if(snapshot.documents.length==0)
					Firestore.instance.collection('stud').document(qrText).collection('subject').document(docId).collection('attendance').add({'date': date, 'day': day, 'time': time,'outcome': outcome});
				else {
					Firestore.instance.collection('stud').document(qrText).collection('subject').document(docId).collection('attendance').document(snapshot.documents[0].documentID).updateData({'outcome': outcome});
				}
			});
		}
	}
}
