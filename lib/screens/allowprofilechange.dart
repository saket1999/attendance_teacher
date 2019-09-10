import 'package:attendance_teacher/classes/student.dart';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class AllowProfileChange extends StatefulWidget {
  @override
  _AllowProfileChangeState createState() => _AllowProfileChangeState();
}

class _AllowProfileChangeState extends State<AllowProfileChange> {
  var _profileChange = GlobalKey<FormState>();
  var uniqueId='';
  Widget teacherStudent=Container();
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allow profile change',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark
      ),
      home: Scaffold(
        appBar: AppBar(
          title: Text('Allow profile change'),
        ),
        body: ListView(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(10.0),
            ),
            Form(
              key: _profileChange,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      onSaved: (value) {
                        uniqueId = value;
                      },
                      decoration: InputDecoration(
                          labelText: "Unique Id",
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(5.0))),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.search),
                    onPressed: (){
                      _profileChange.currentState.save();
                      refreshTeacherStudent();
                    },
                  )
                ],
              ),
            ),
            teacherStudent,//This is the main widget which allows unlocking profile
          ],
        ),
      ),
    );
  }


  //This function checks whether it is teacher id or student id and makes a tile accordingly
  Future<void> refreshTeacherStudent()async{
    var snapshot=await Firestore.instance.collection('teach').where('teacherId', isEqualTo: uniqueId).getDocuments();
    if(snapshot.documents.length!=0) {
      Teacher teacher = Teacher.fromMapObject(snapshot.documents[0].data);
      teacher.documentId = snapshot.documents[0].documentID;
      bool enable=(snapshot.documents[0].data['verify']==1)?true:false;
      teacherStudent = Card(
        color: Colors.black,
        child: ExpansionTile(
            title: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Text(
                    teacher.name,
                    style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    teacher.teacherId,
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
                  Text(
                    'Email: ' + teacher.email,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    'Mobile no: ' + teacher.mobile,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: enable?RaisedButton(
                      child: Text('Accept'),
                      onPressed: () {
                        Firestore.instance.collection('teach').document(teacher.documentId).updateData({'verify': 0});
                        refreshTeacherStudent();
                      },
                    ):Icon(Icons.done),
                  )
                ],
              )
            ]
        ),
      );
    }
    var snapshot2= await Firestore.instance.collection('stud').where('regNo', isEqualTo: uniqueId).getDocuments();
    if(snapshot2.documents.length!=0) {
      Student student = Student.fromMapObject(snapshot2.documents[0].data);
      student.documentId = snapshot2.documents[0].documentID;
      bool enable = (snapshot2.documents[0].data['verify'] == 1) ? true : false;
      teacherStudent = Card(
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
                  Text(
                    'Email: ' + student.email,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    'Mobile no: ' + student.mobile,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    'Gender: ' + student.gender,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    'Class ID: ' + student.classId,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    'Category: ' + student.category,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Text(
                    'Date of Birth: ' + student.dob,
                    style: TextStyle(
                      fontSize: 15.0,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: enable ? RaisedButton(
                      child: Text('Accept'),
                      onPressed: () {
                        Firestore.instance.collection('stud').document(student.documentId).updateData({'verify': 0});
                        refreshTeacherStudent();
                      },
                    ) : Icon(Icons.done),
                  )
                ],
              )
            ]
        ),
      );
    }
    setState((){});
    return;
  }
}
