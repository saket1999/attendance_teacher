import 'dart:io';

import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/screens/dashboard.dart';
import 'package:attendance_teacher/services/password.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class FirestoreCRUD{
	//  This function looks for the document for login
	static Future<QuerySnapshot> getDocsForLogin(Teacher teacher,String inputPass) async {
		return await Firestore.instance.collection('teach')
			.where('teacherId', isEqualTo: teacher.teacherId)
			.where('pass', isEqualTo: await compute(Password.getHash,inputPass)).getDocuments();
	}


	//This function is called for login
	static Future<bool> login(BuildContext context,Teacher teacher,inputPass) async {

		Teacher incoming = Teacher.blank();
		bool value=false;

		await FirestoreCRUD.getDocsForLogin(teacher,inputPass)
			.then((QuerySnapshot docs) {
			try {
				incoming = Teacher.fromMapObject(docs.documents[0].data);
				incoming.documentId = docs.documents[0].documentID;
				teacher = incoming;
				value = true;
				Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Dashboard(teacher)), (Route<dynamic> route) => false);

			}
			catch(e){
				toast('Wrong credentials');
				print(e);
				value=false;
			}
		});
		return false;
	}

	//This function is for sign up
	static Future<bool> signUp(Teacher teacher,File _image) async {
		int length=0;

		//checking if user already exists
		await Firestore.instance.collection('teach').where('teacherId',isEqualTo: teacher.teacherId).getDocuments().then((QuerySnapshot docs){
			length=docs.documents.length;
		});
		if(length>0) {
			toast('User already exists. Please login');
			return false;
		}
		teacher.pass=await compute(Password.getHash,teacher.pass);
		await uploadPic(teacher,_image);
		await Firestore.instance.collection('stud').add(teacher.toMap());
		return true;
	}

	static Future uploadPic(Teacher student,File _image) async {
		String fileName = student.teacherId;
		StorageReference firebaseStorageRef = FirebaseStorage.instance.ref().child(fileName);
		StorageUploadTask uploadTask = firebaseStorageRef.putFile(_image);
		StorageTaskSnapshot taskSnapshot = await uploadTask.onComplete;
	}

}