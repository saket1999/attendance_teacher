import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Dashboard extends StatefulWidget {

  Teacher _teacher;

  Dashboard(this._teacher);

  @override
  _DashboardState createState() => _DashboardState(_teacher);
}

class _DashboardState extends State<Dashboard> {

  Teacher _teacher;

  _DashboardState(this._teacher);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxisScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                child: SliverSafeArea(
                  top: false,
                  sliver: SliverAppBar(
                    expandedHeight: 200.0,
                    floating: true,
                    pinned: true,
                    flexibleSpace: FlexibleSpaceBar(
                        centerTitle: true,

                        title: Text('Dashboard'),
                        background: Card(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: <Widget>[
                                Align(
                                  alignment: Alignment.center,
                                  child: CircleAvatar(
                                    radius: 50.0,
                                    backgroundColor: Colors.blueAccent,
                                    child: ClipOval(
                                      child: SizedBox(
                                        width: 100.0,
                                        height: 100.0,
                                        child: Image.network(
                                          "https://www.google.co.in/images/branding/googlelogo/1x/googlelogo_color_272x92dp.png",
                                          fit: BoxFit.fill,
                                        ),
                                      ),
                                    ),
                                  ),

                                ),
                                Container(
                                  child: Card(
                                    child: Text(
                                      _teacher.name,
                                      textScaleFactor: 1.5,
                                    ),
                                  ),
                                )
                              ]

                          ),
                        )
                    ),
                  ),
                ),
              )

            ];
          },
          body: getSubjects()
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () {

        },
        tooltip: 'Join New Class',
        backgroundColor: Colors.blueAccent,
      ),
    );
  }

  Widget getSubjects() {
    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('teach').document(_teacher.documentId).collection('subject').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData)
          return Text('Loading');
        return getSubjectList(snapshot);
      },
    );
  }

  getSubjectList(AsyncSnapshot<QuerySnapshot> snapshot) {

    var listView = ListView.builder(itemBuilder: (context, index) {
      if(index<snapshot.data.documents.length) {
        var doc = snapshot.data.documents[index];
        Teaching subject = Teaching.fromMapObject(doc);
        subject.documentId = doc.documentID;
        subject.teacherDocumentId = _teacher.documentId;
        return GestureDetector(
//          onTap: () {
//
//            Fluttertoast.showToast(
//                msg: subject.subjectId+' '+subject.teacherId+ ' '+ subject.subjectName+ ' '+ subject.documentId,
//                toastLength: Toast.LENGTH_SHORT,
//                gravity: ToastGravity.CENTER,
//                timeInSecForIos: 1,
//                backgroundColor: Colors.red,
//                textColor: Colors.white,
//                fontSize: 16.0
//            );
//
//            Navigator.push(context, MaterialPageRoute(builder: (context) {
//              return History(subject);
//            }));
//
//          },
          child: Card(
            child: ListTile(
              title: Text(subject.subjectId),
              subtitle: Text(subject.subjectName),
            ),
          ),
        );
      }
    });

//		List<ListTile> temp = snapshot.data.documents
//			.map((doc) {
//				ListTile(
//					title: Text(doc.data['subjectId']),
//					subtitle: Text(doc.data['teacherId']),
//			);
//				debugPrint(doc.data['subjectId']);
//				debugPrint(doc.documentID);
//			})
//			.toList();
    return listView;
  }
}
