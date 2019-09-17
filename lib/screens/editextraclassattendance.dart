/*This screen allows teacher to edit attendance of an extra class*/
import 'package:attendance_teacher/classes/student.dart';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class EditExtraClassAttendance extends StatefulWidget {

  Teacher teacher;
  Teaching teaching;
  Timings timings;
  String date;

  EditExtraClassAttendance(this.teacher,this.teaching,this.timings,this.date);

  @override
  _EditExtraClassAttendanceState createState() => _EditExtraClassAttendanceState(teacher,teaching,timings,date);
}

class _EditExtraClassAttendanceState extends State<EditExtraClassAttendance> {

  Teacher teacher;
  Teaching teaching;
  Timings timings;
  String date;

  _EditExtraClassAttendanceState(this.teacher,this.teaching,this.timings,this.date);

  Widget studentPresentAbsent=Container();
  String regNo;
  bool _isLoading=false;
  var _editForm = GlobalKey<FormState>();

/*UI Part:
* AppBar:
*   Text Edit Attendance
* Body:
*   Form:
*     Enter Registration No.
*     Search Button
*   LisTile:
*     Displays info about the particular student to mark present/absent*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit attendance'),
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
                        errorStyle: TextStyle(color: Colors.redAccent),
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
      ),
    );
  }


  //This method searches for a particular student

  Future<void> searchStudentPresentAbsent() async {
    var student=await Firestore.instance.collection('stud').where('regNo',isEqualTo: regNo).getDocuments();
    if(student.documents.length==0){
      setState(() {_isLoading=false;});
      return;
    }
    var subject=await Firestore.instance.collection('stud').document(student.documents[0].documentID).collection('subject').where('subjectId',isEqualTo: teaching.subjectId).where('subjectName',isEqualTo: teaching.subjectName).where('teacherId',isEqualTo: teacher.teacherId).getDocuments();
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

  //This method returns a card containing details of the student
  Widget simpleCard(Student student,String subjectId,String attendanceId){
    return Card(
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
                Text('Date: '+date),
                Text('Time: '+timings.start),
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

  //This method refreshes the card
  void refreshSimpleCard(Student student){
    studentPresentAbsent=Card(
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
            Text('Date: '+date),
            Text('Time: '+timings.start),
            Icon(Icons.done),
          ]
      ),
    );
    setState(() {});
  }
}
