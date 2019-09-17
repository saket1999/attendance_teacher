import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/screens/createclass.dart';
import 'package:attendance_teacher/screens/login.dart';
import 'package:attendance_teacher/screens/mailclass.dart';
import 'package:attendance_teacher/screens/profile.dart';
import 'package:attendance_teacher/screens/shortatendancelist.dart';
import 'package:attendance_teacher/screens/subjectlist.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcase.dart';
import 'package:showcaseview/showcase_widget.dart';

class Dashboard extends StatefulWidget {

  Teacher _teacher;
  bool getHelp;

  Dashboard(this._teacher, this.getHelp);

  @override
  DashboardState createState() => DashboardState(_teacher, getHelp);
}

class DashboardState extends State<Dashboard> {

  Teacher _teacher;
  bool getHelp;
  String _url;

  DashboardState(this._teacher, this.getHelp);

  void initState() {
    super.initState();
    getURL();
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  GlobalKey _one = GlobalKey();
  GlobalKey _two = GlobalKey();
  GlobalKey _three = GlobalKey();

  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if(ModalRoute.of(context).isCurrent&& getHelp) {
        getHelp = false;
        return ShowCaseWidget.startShowCase(context, [_one, _two, _three]);
      }
    });

    var top = 0.0;
    return Scaffold(
      key: _scaffoldKey,
      body: NestedScrollView(
          headerSliverBuilder: (BuildContext context, bool innerBoxisScrolled) {
            return <Widget>[
              SliverOverlapAbsorber(
                handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                child: SliverSafeArea(
                  top: false,
                  sliver: SliverAppBar(
                    expandedHeight: 170.0,
                    floating: true,
                    pinned: true,
                    leading: Showcase(
                      key: _two,
                      description: 'Press to open additional settings',
                      shapeBorder: CircleBorder(),
                      child: IconButton(
                        icon: Icon(Icons.dehaze),
                        onPressed: () {
                          _scaffoldKey.currentState.openDrawer();
                        },
                      ),
                    ),
                    flexibleSpace: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constraints) {
                        top = constraints.biggest.height;
                        return FlexibleSpaceBar(
                            centerTitle: true,

                            title: AnimatedOpacity(
                              duration: Duration(milliseconds: 300),
                              opacity: top < 90.0 ? 1.0: 0.0,
                              child: Text('Dashboard'),
                            ),
                            background: Card(
                              elevation: 20.0,
                              color: Colors.blue,
                              child: Showcase(
                                key: _three,
                                description: "Teacher's Profile",
                                shapeBorder: CircleBorder(),
                                child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: <Widget>[
                                      Align(
                                        alignment: Alignment.center,
                                        child: CircleAvatar(
                                          radius: 50.0,
                                          backgroundColor: Colors.blue,
                                          child: ClipOval(
                                            child: SizedBox(
                                              width: 100.0,
                                              height: 100.0,
                                              child: _url!=null?Image.network(_url):DecoratedBox(decoration: BoxDecoration(image: DecorationImage(image: AssetImage('assets/default.png')))),
                                            ),
                                          ),
                                        ),

                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Container(
                                              child: Text(
                                                _teacher.name,
                                                textScaleFactor: 2,
                                                style: TextStyle(
                                                  color: Colors.white
                                                ),
                                              ),
                                            ),
                                          ),
                                          Padding(
                                            padding: const EdgeInsets.all(6.0),
                                            child: Container(
                                              child: Text(
                                                _teacher.teacherId,
                                                textScaleFactor: 1.25,
                                                style: TextStyle(
                                                    color: Colors.white
                                                ),
                                              ),
                                            ),
                                          ),

                                        ],
                                      )
                                    ]

                                ),
                              ),
                            )
                        );
                      },
                    )
                  ),
                ),
              )

            ];
          },
          body: getSubjects()
      ),
      floatingActionButton: Showcase(
        key: _one,
        description: 'Tap to create new class',
        shapeBorder: CircleBorder(),
        child: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            if(_teacher.verify==0)
              toast('Your profile is not yet verified.');
            else if(_teacher.verify==-1)
              toast('Please correct and update profile');
            else
			Navigator.push(context, MaterialPageRoute(builder: (context) {
				return CreateClass(_teacher);
			}));
          },
          tooltip: 'Create new class',
          backgroundColor: Colors.blueAccent,
        ),
      ),
      drawer: Drawer(
        child: ListView(
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.blue
              ),
                child: Icon(Icons.account_circle)
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) {
                  return Profile(_teacher);
                }));
              },
            ),
            ListTile(
              title: Text('Sign Out'),
              onTap: () {
                clearSharedPrefs();
                Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (BuildContext context) => Login(false)), (Route<dynamic> route) => false);
              },
            )
          ],
        ),
      ),
    );
  }

  Widget getSubjects() {
    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('teach').document(_teacher.documentId).collection('subject').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData)
          return Center(child:Loading(indicator: BallPulseIndicator(), size: 20.0));
        return getSubjectList(snapshot);
      },
    );
  }

  getSubjectList(AsyncSnapshot<QuerySnapshot> snapshot) {

    var listView = ListView.builder(itemCount: snapshot.data.documents.length,itemBuilder: (context, index) {
      if(index<snapshot.data.documents.length) {
        var doc = snapshot.data.documents[index];
        Teaching subject = Teaching.fromMapObject(doc);
        subject.documentId = doc.documentID;
        subject.teacherDocumentId = _teacher.documentId;
//        return GestureDetector(
//          onTap: () {
//
//            Navigator.push(context, MaterialPageRoute(builder: (context) {
//              return SubjectList(_teacher, subject);
//            }));
////            Navigator.push(context, MaterialPageRoute(builder: (context) {
////              return MailClass(subject,_teacher);
////            }));
//
//          },
//          child: Card(
//            child: ListTile(
//              title: Text(subject.subjectId),
//              subtitle: Text(subject.subjectName),
//            ),
//          ),
//        );
        return Card(
//          color: Colors.black12,
          child: ExpansionTile(
              title: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Text(
                      subject.subjectName,
                      textScaleFactor: 1.2,
                    ),
                    Text(
                      subject.classId,
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
                    ListTile(
                      title: Text('Attendance'),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return SubjectList(_teacher, subject);
                        }));
                      },
                    ),
                    ListTile(
                      title: Text('Short Attendance List'),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return SubjectShortAttendancelist(_teacher, subject);
                        }));
                      },
                    ),
                    ListTile(
                      title: Text('Email CLass'),
                      onTap: (){
                        Navigator.push(context, MaterialPageRoute(builder: (context) {
                          return MailClass(_teacher, subject);
                        }));
                      },
                    ),
                  ],
                )
              ]
          ),
        );
      }
      return GestureDetector();

    });

//
    return listView;
  }

  void getURL() async{
    String url;
    StorageReference ref = FirebaseStorage.instance.ref().child(_teacher.teacherId);
    url = (await ref.getDownloadURL()).toString();
    print(url);

    setState(() {
      _url = url;
    });

  }

  void clearSharedPrefs() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('storedObject', '');
    prefs.setString('storedId', '');
  }
}
