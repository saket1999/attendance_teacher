import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class SubjectShortAttendancelist extends StatefulWidget {

  Teacher _teacher;
  Teaching _teaching;
  SubjectShortAttendancelist(this._teacher, this._teaching);

  @override
  _SubjectShortAttendancelistState createState() => _SubjectShortAttendancelistState(_teacher,_teaching);
}

class _SubjectShortAttendancelistState extends State<SubjectShortAttendancelist> {

  Teacher _teacher;
  Teaching _teaching;
  bool _isLoading=false;
  ListView shortAttendanceList=ListView();
  List<String> recipients=[];


  _SubjectShortAttendancelistState(this._teacher, this._teaching);


  void initState() {
    super.initState();
    shortAttendanceListGenerator();
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
          brightness: Brightness.dark
      ),
      home: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: (){
              Navigator.of(context).pop();
            },
          ),
          title: Text('Short Attendance List'),
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
        ),
        body: shortAttendanceList,
      ),
    );
  }

  Future<void> shortAttendanceListGenerator() async {
    setState(() {
      _isLoading=true;
    });
    shortAttendanceList=ListView();
    List<Widget> listArray=[];
    var studentDocumentIds=await Firestore.instance.collection('teach').document(_teacher.documentId).collection('subject').document(_teaching.documentId).collection('studentsEnrolled').getDocuments();
    print(studentDocumentIds.documents.length);
    for(int i=0;i<studentDocumentIds.documents.length;i++){
      var studentDocId=studentDocumentIds.documents[i].data['docId'];
      var student=await Firestore.instance.collection('stud').document(studentDocId).get();
      var subject=await Firestore.instance.collection('stud').document(studentDocId).collection('subject').where('subjectId',isEqualTo: _teaching.subjectId).where('subjectName',isEqualTo: _teaching.subjectName).where('teacherId',isEqualTo: _teacher.teacherId).getDocuments();
//      print(studentDocId+' '+_teaching.subjectName+'  '+_teaching.subjectId+' '+_teacher.teacherId+' '+'  '+subject.documents.length.toString());
      if(subject.documents.length==0)
        continue;

      var subjectDocData=subject.documents[0].data;

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
      percentage*=100.0;
      print(subjectDocData);
      print(percentage);
      if(percentage<75) {
        bool b=true;
        listArray.add(Card(
          child: ListTile(
            title: Text(student.data['name']),
            subtitle: Text(student.data['regNo']),
            trailing: RaisedButton(
              child: Text('Allow at '+percentage.toInt().toString()+' %'),
              onPressed: (){
                print(b.toString());
                if(b) {
                  toast('Allowed '+student.data['regNo']);
                  Firestore.instance.collection('allow').add({
                    'regNo': student.data['regNo'],
                    'teacherId': _teacher.teacherId,
                    'subjectId': _teaching.subjectId
                  });
                  b=false;
                }
              },
            ),
          ),
        ));
        recipients.add(student.data['email']);
      }
      setState(() {});
    }
    shortAttendanceList=ListView(children: listArray);
    _isLoading=false;
    setState(() {});
  }

  Future<void> sendMail() async {
    setState(() {
      _isLoading=true;
    });
    String subject='Notification regarding Short attendance in '+_teaching.subjectName;
    String body='As your current attendance is too low you are requested to attend classes regularly.\n\n Teacher incharge\n'+_teacher.name;
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
