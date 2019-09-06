import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/screens/dashboard.dart';
import 'package:attendance_teacher/services/password.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class FirestoreCRUD{
	//  This function looks for the document for login
	static Future<QuerySnapshot> getDocsForLogin(Teacher teacher,String inputPass) async {
		return await Firestore.instance.collection('teach')
			.where('teacherId', isEqualTo: teacher.teacherId)
			.where('pass', isEqualTo: await compute(Password.getHash,inputPass)).getDocuments();
	}


	//This function is called for login
	static Future<bool> login(BuildContext context,Teacher incoming,Teacher teacher,inputPass) async {
		FirestoreCRUD.getDocsForLogin(teacher,inputPass)
			.then((QuerySnapshot docs) {
			try {
				incoming = Teacher.fromMapObject(docs.documents[0].data);
				incoming.documentId = docs.documents[0].documentID;
				teacher = incoming;
				Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Dashboard(teacher)), (Route<dynamic> route) => false);

			}
			catch(e){
				Fluttertoast.showToast(
					msg: 'Wrong Credentials',
					toastLength: Toast.LENGTH_SHORT,
					gravity: ToastGravity.BOTTOM,
					timeInSecForIos: 1,
					backgroundColor: Colors.black,
					textColor: Colors.white,
					fontSize: 10.0
				);
				print(e);
			}
		});
		return false;
	}

}