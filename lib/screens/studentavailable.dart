/*This screen shows the list of students whose attendance is less than then the goal(75%). The students are listed according to the attendance in a particular subject of a particular class.
* The Admin can notify the students with email.*/

import 'package:attendance_teacher/classes/student.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class StudentAvailable extends StatefulWidget {

  String classId;
  String subjectName;
  String subjectId;

  StudentAvailable(this.classId,this.subjectId,this.subjectName);
  @override
  _StudentAvailableState createState() => _StudentAvailableState(classId,subjectId,subjectName);
}

class _StudentAvailableState extends State<StudentAvailable> {

  String classId;
  String subjectName;
  String subjectId;

  ListView students=ListView();
  List<String> recipients=[];
  bool _isLoading=false;

  _StudentAvailableState(this.classId,this.subjectId,this.subjectName);



  //shortAttendanceListGenerator is called before the activity is created
  void initState() {
    super.initState();
    shortAttendanceListGenerator();
  }

  /*UI Part:
  *   AppBar:
  *     Text: Subject of ClassId
  *     Button: Mail every student
  *   Body:
  *     ListView of Students with short attendance*/

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.cyan,
          bottom: PreferredSize(
            preferredSize: Size(100.0,40.0),
            child: RaisedButton(
                child: _isLoading?Loading(indicator: BallPulseIndicator(), size: 20.0):Text('Mail everyone'),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                elevation: 20.0,
                onPressed: () {
                  sendMail();
                }),
          ),
          title: Text(subjectName+' of '+classId),
        ),
        body: students,
      );

  }

  //An async method to create a ListView of Students with short attendance
  Future<void> shortAttendanceListGenerator() async {
    setState(() {
      _isLoading=true;
    });
    students=ListView();
    List<Widget> listArray=[];
    var studentDocuments=await Firestore.instance.collection('stud').where('classId',isEqualTo: classId).getDocuments();
    for(int i=0;i<studentDocuments.documents.length;i++){
      Student student=Student.fromMapObject(studentDocuments.documents[i].data);
      var subjectDocuments=await Firestore.instance.collection('stud').document(studentDocuments.documents[i].documentID).collection('subject').where('subjectId',isEqualTo: subjectId).where('subjectName',isEqualTo: subjectName).getDocuments();
      if(subjectDocuments.documents.length==0)
        continue;
      var subjectDocData=subjectDocuments.documents[0].data;

      int present=int.parse(subjectDocData['present']);
      int absent=int.parse(subjectDocData['absent']);
      if(present<0)
        present=0;
      if(absent<0)
        absent=0;
      int total=present+absent;

      double percentage;
      if(total!=0)
        percentage=present/total;
      else
        percentage=1.0;
      percentage*=100.0;//multiplying percentage by 100
      print(percentage);

      if(percentage<75.0){
        listArray.add(Card(
          child: ListTile(
            title: Text(student.name),
            subtitle: Text(student.regNo),
            trailing: Text(percentage.toInt().toString()+' %'),
          ),
        ));
        recipients.add(student.email);
      }
    }
    students=ListView(children: listArray);
    setState(() {_isLoading=false;});
  }

  //This method sends an email to all the listed students
  Future<void> sendMail() async {
    setState(() {
      _isLoading=true;
    });
    String subject='Notification regarding Short attendance in '+subjectName;
    String body='As your current attendance is too low you are requested to attend classes regularly.\n\nAdmin';
    final MailOptions mailOptions= MailOptions(
      body: body,
      subject: subject,
      bccRecipients: recipients,
    );
    await FlutterMailer.send(mailOptions);
    setState(() {
      _isLoading=false;
    });
    return;
  }




}
