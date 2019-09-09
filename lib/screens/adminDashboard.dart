import 'package:attendance_teacher/classes/student.dart';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class AdminDashboard extends StatelessWidget{
  const AdminDashboard({Key key}):super(key :key);


  @override
  Widget build(BuildContext context) {
    final _tabPages=<Widget>[
      getUnverifiedTeachers(),
      getUnverifiedStudents()
    ];
    final _tabs=<Tab>[
      Tab(icon: Icon(Icons.account_circle),text: 'Teacher'),
      Tab(icon: Icon(Icons.face),text: 'Student')
    ];

    return DefaultTabController(
      length: _tabs.length,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Admin Dashboard'),
          backgroundColor: Colors.cyan,
          bottom: TabBar(
            tabs: _tabs
          ),
        ),
        body: TabBarView(
          children: _tabPages,
        ),
      ),
    );

  }



  Widget getUnverifiedTeachers() {
    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('teach').where('verify', isEqualTo: 0).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData)
          return Center(child: Loading(indicator: BallPulseIndicator(), size: 30.0));
        return getTeacherList(snapshot);
      },
    );
  }

  getTeacherList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if(snapshot.data.documents.length==0)
      return Center(child: Icon(Icons.cloud,size: 64.0,color: Colors.teal));

    var listView = ListView.builder(itemCount: snapshot.data.documents.length,itemBuilder: (context, index) {

      if(index<snapshot.data.documents.length) {
        var doc = snapshot.data.documents[index];
        Teacher teacher = Teacher.fromMapObject(doc.data);
        teacher.documentId = doc.documentID;
        return GestureDetector(
          onTap: () {},
          child: Card(
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
                        'Email: '+teacher.email,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      Text(
                        'Mobile no: '+teacher.mobile,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                              child: Text('Accept'),
                              onPressed: (){
                                Firestore.instance.collection('teach').document(teacher.documentId).updateData({'verify':1});
                              },
                            ),
                            RaisedButton(
                              child: Text('Reject'),
                              onPressed: (){
                                Firestore.instance.collection('teach').document(teacher.documentId).updateData({'verify':-1});
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ]
            ),
          ),
        );
      }
      return GestureDetector(
        onTap: (){},
      );
    });
    return listView;
  }


  Widget getUnverifiedStudents() {
    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('stud').where('verify', isEqualTo: 0).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData)
          return Center(child: Loading(indicator: BallPulseIndicator(), size: 30.0));
        return getStudentList(snapshot);
      },
    );
  }

  getStudentList(AsyncSnapshot<QuerySnapshot> snapshot) {
    if(snapshot.data.documents.length==0)
      return Center(child: Icon(Icons.cloud,size: 64.0,color: Colors.teal));

    var listView = ListView.builder(itemCount: snapshot.data.documents.length,itemBuilder: (context, index) {

      if(index<snapshot.data.documents.length) {
        var doc = snapshot.data.documents[index];
        Student student = Student.fromMapObject(doc.data);
        student.documentId = doc.documentID;
        return GestureDetector(
          onTap: () {},
          child: Card(
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
                        'Email: '+student.email,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      Text(
                        'Mobile no: '+student.mobile,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      Text(
                        'Gender: '+student.gender,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      Text(
                        'Class ID: '+student.classId,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      Text(
                        'Category: '+student.category,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),
                      Text(
                        'Date of Birth: '+student.dob,
                        style: TextStyle(
                          fontSize: 15.0,
                        ),
                      ),

                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            RaisedButton(
                              child: Text('Accept',style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
                              color: Colors.white,
                              onPressed: (){
                                Firestore.instance.collection('stud').document(student.documentId).updateData({'verify':1});
                              },
                            ),
                            RaisedButton(
                              child: Text('Reject',style: TextStyle(color: Colors.black),),
                              color: Colors.redAccent,
                              onPressed: (){
                                Firestore.instance.collection('stud').document(student.documentId).updateData({'verify':-1});
                              },
                            ),
                          ],
                        ),
                      )
                    ],
                  )
                ]
            ),
          ),
        );
      }
      return GestureDetector(
        onTap: (){},
      );
    });
    return listView;
  }
}