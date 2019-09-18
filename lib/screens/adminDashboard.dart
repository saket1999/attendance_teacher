/*This screen is the Admin Dashboard. It contains two tabs to verify new accounts of Teacher and Students.*/

import 'package:attendance_teacher/classes/student.dart';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/screens/allowprofilechange.dart';
import 'package:attendance_teacher/screens/classavailable.dart';
import 'package:attendance_teacher/screens/login.dart';
import 'package:attendance_teacher/screens/mailteachers.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/material.dart' as prefix0;
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminDashboard extends StatelessWidget{
  const AdminDashboard({Key key}):super(key :key);


  /*UI Part:
  * Drawer:
  *   Mail all teachers
  *   Allow profile change
  *   Attendance Short List
  *   Sign Out
  * Appbar:
  *   Two tabs:
  *      Teachers
  *      Students
  * Each Tab:
  *   Multiple expansion tiles to verify new users*/

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
        drawer: Drawer(
          child: ListView(
            children: <Widget>[
              DrawerHeader(
                child: Icon(Icons.account_circle),
                decoration: BoxDecoration(
                  color: Colors.cyan,
                ),
              ),
              ListTile(
                leading: Icon(Icons.email),
                title: Text('Mail',textScaleFactor: 1.1),
                subtitle: Text('All teachers will be sent the email'),
                onTap: (){
                  prefix0.Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return MailTeachers();
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.search),
                title: Text('Allow profile change',textScaleFactor: 1.1),
                subtitle: Text('All selected users will be allowed to update their profile'),
                onTap: (){

                  prefix0.Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return AllowProfileChange();
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.subject),
                title: Text('Attendance Short List',textScaleFactor: 1.1),
                subtitle: Text('See list of students with short attendance'),
                onTap: (){

                  prefix0.Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) {
                    return ClassAvailable();
                  }));
                },
              ),
              ListTile(
                leading: Icon(Icons.exit_to_app),
                title: Text('Sign Out',textScaleFactor: 1.1),
                onTap: (){
                  clearSharedPrefs();
                  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login(false)), (Route<dynamic> route) => false);
                  },
              ),
            ],
          )
        ),
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


  /*getUnverifiedTeachers returns a stream builder which creates a ListView with realtime updates. Stream is the Firestore reference to unverified teachers*/
  Widget getUnverifiedTeachers() {
    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('teach').where('verify', isEqualTo: 0).orderBy('name').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData)
          return Center(child: Loading(indicator: BallPulseIndicator(), size: 30.0));
        return getTeacherList(snapshot);
      },
    );
  }

  //getTeacherList creates a ListView of unverified teachers provided by the above stream builder.
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
//            color: Colors.black,
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
                              color: Colors.white,
                              onPressed: (){
                                Firestore.instance.collection('teach').document(teacher.documentId).updateData({'verify':1});
                              },
                            ),
                            RaisedButton(
                              child: Text('Reject'),
                              color: Colors.redAccent,
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



  /*getUnverifiedStudents returns a stream builder which creates a ListView with realtime updates. Stream is the Firestore reference to unverified teachers*/
  Widget getUnverifiedStudents() {
    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('stud').where('verify', isEqualTo: 0).orderBy('name').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData)
          return Center(child: Loading(indicator: BallPulseIndicator(), size: 30.0));
        return getStudentList(snapshot);
      },
    );
  }

  //getTeacherList creates a ListView of unverified students with their details provided by the above stream builder.
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
//            color: Colors.black,
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

  //Shared preferences are cleared on sign out
  void clearSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('storedObject', '');
    prefs.setString('storedId', '');
  }
}