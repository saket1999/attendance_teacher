/*This screen generates a ListView of subjects available in a particular class.*/

import 'package:attendance_teacher/screens/studentavailable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class SubjectAvailable extends StatefulWidget {

  String classId;
  String classDocId;

  SubjectAvailable(this.classId,this.classDocId);
  @override
  _SubjectAvailableState createState() => _SubjectAvailableState(classId,classDocId);
}

class _SubjectAvailableState extends State<SubjectAvailable> {
  String classId;
  String classDocId;

  /*UI Part:
  * Appbar:
  *   Text: Subject in ClassId
  * Body:
  *   ListView of Subjects in that class*/

  _SubjectAvailableState(this.classId,this.classDocId);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: Text('Subjects in '+classId),
        ),
        body: getSubjects(),
      );
  }


  Widget getSubjects() {
    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('classes').document(classDocId).collection('subject').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData)
          return Center(child:Loading(indicator: BallPulseIndicator(), size: 20.0));
        return getSubjectsList(snapshot);
      },
    );
  }

  getSubjectsList(AsyncSnapshot<QuerySnapshot> snapshot) {

    var listView = ListView.builder(itemCount: snapshot.data.documents.length,itemBuilder: (context, index) {
      if(index<snapshot.data.documents.length) {
        var doc = snapshot.data.documents[index];
        var subjectId = doc.data['subjectId'].toString();
        var subjectName=doc.data['subjectName'].toString();

        return Card(
          child: ListTile(
            title: Text(subjectName),
            subtitle: Text(subjectId),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return StudentAvailable(classId,subjectId,subjectName);
              }));
            },
          ),
        );
      }
      return GestureDetector();

    });

//
    return listView;
  }
}
