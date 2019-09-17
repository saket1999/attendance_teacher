/*This screen is called when Admin wants to see the short attendance list. Hence this screen lists all the available classes to the Admin*/
import 'package:attendance_teacher/screens/subjectavailable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class ClassAvailable extends StatefulWidget {
  @override
  _ClassAvailableState createState() => _ClassAvailableState();
}


/*UI Part:
* Appbar:
*    Text: Available Classes
* Body:
*   ListView of Classes*/
class _ClassAvailableState extends State<ClassAvailable> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          title: Text('Available Classes'),
        ),
        body: getClasses(),
      );
  }



  //Stream builder which gets the snapshot of all classes available
  Widget getClasses() {
    return StreamBuilder<QuerySnapshot> (
      stream: Firestore.instance.collection('classes').snapshots(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if(!snapshot.hasData)
          return Center(child:Loading(indicator: BallPulseIndicator(), size: 20.0));
        return getClassesList(snapshot);
      },
    );
  }

  //This method generates and returns a ListView of classes available to the user
  getClassesList(AsyncSnapshot<QuerySnapshot> snapshot) {

    var listView = ListView.builder(itemCount: snapshot.data.documents.length,itemBuilder: (context, index) {
      if(index<snapshot.data.documents.length) {
        var doc = snapshot.data.documents[index];
        var classId = doc.data['classId'].toString();
        String classDocId=doc.documentID.toString();

        return Card(
          child: ListTile(
            title: Text(classId),
            onTap: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) {
                return SubjectAvailable(classId,classDocId);
              }));
            },
          ),
        );
      }
      return GestureDetector();

    });
    return listView;
  }
}
