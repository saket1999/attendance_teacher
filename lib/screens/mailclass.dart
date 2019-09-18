import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class MailClass extends StatefulWidget {

  Teacher _teacher;
  Teaching _teaching;

  MailClass(this._teacher,this._teaching);

  @override
  _MailClassState createState() => _MailClassState(_teacher,_teaching);
}

class _MailClassState extends State<MailClass> {

  Teacher _teacher;
  Teaching _teaching;
  var _mailForm = GlobalKey<FormState>();
  var subject;
  var body;
  List<String> recipients=[];
  bool _isLoading=true;
  bool _sendingMail=false;

  _MailClassState(this._teacher,this._teaching);

  void initState() {
    super.initState();
    getRecipients();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Send Mail'),
        ),
        body: ListView(
          children: <Widget>[
            Container(
              padding: EdgeInsets.all(10.0),
              child: Form(
                key: _mailForm,
                child: Center(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextFormField(
                          onSaved: (value) {
                            subject = value;
                          },
                          decoration: InputDecoration(
                              labelText: "Subject",
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: TextFormField(
                          keyboardType: TextInputType.multiline,
                          maxLines: null,
                          onSaved: (value) {
                            body=value;
                          },
                          decoration: InputDecoration(
                              labelText: 'Body',
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(5.0))),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                        child: RaisedButton(
                          color: Colors.black,
                            child: (_sendingMail || _isLoading)?Loading(indicator: BallPulseIndicator(), size: 20.0):Text('Send Email', style: TextStyle(color: Colors.white)),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 10.0,
                            onPressed: () {
                              if(_isLoading==true)
                                toast('Please wait recipients are being fetched');
                              else{
                                _mailForm.currentState.save();
                                func();
                              }
                            }),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      );
  }

  Future<void> func() async {
    setState(() {
      _sendingMail=true;
    });
    
    body=body+'\n\n'+_teacher.name;//adding from message to email
    final MailOptions mailOptions= MailOptions(
      body: body,
      subject: subject,
      bccRecipients: recipients,
    );
    await FlutterMailer.send(mailOptions);
    setState(() {
      _sendingMail=false;
    });
    return;
  }
  Future<void> getRecipients() async {
    QuerySnapshot docs=await Firestore.instance.collection('teach').document(_teacher.documentId).collection('subject').document(_teaching.documentId).collection('studentsEnrolled').getDocuments();

    for(int i=0;i<docs.documents.length;i++) {
      DocumentSnapshot studentDocs = await Firestore.instance.collection('stud').document(docs.documents[i].data['docId']).get();
      recipients.add(studentDocs.data['email'].toString());
    }
    setState(() {
      _isLoading=false;
    });
    return;
  }
}
