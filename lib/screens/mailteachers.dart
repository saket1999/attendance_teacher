import 'package:attendance_teacher/services/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mailer/flutter_mailer.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class MailTeachers extends StatefulWidget {
  @override
  _MailTeachersState createState() => _MailTeachersState();
}

class _MailTeachersState extends State<MailTeachers> {
  var _mailForm = GlobalKey<FormState>();
  var subject;
  var body;
  List<String> recipients=[];
  bool _isLoading=true;
  bool _sendingMail=false;

  _MailTeachersState();

  void initState() {
    super.initState();
    getRecipients();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Attendance Manager',
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
          title: Text('Send Mail'),
          backgroundColor: Colors.cyan,
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
                            child: _sendingMail?Loading(indicator: BallPulseIndicator(), size: 20.0):Text('Send Email'),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30.0),
                            ),
                            elevation: 40.0,
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
      ),
    );
  }

  Future<void> func() async {
    setState(() {
      _sendingMail=true;
    });
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
    QuerySnapshot docs=await Firestore.instance.collection('teach').getDocuments();
    toast(docs.documents.length.toString()+" teachers will be sent email");
    for(int i=0;i<docs.documents.length;i++)
      recipients.add(docs.documents[i].data['email'].toString());
    setState(() {
      _isLoading=false;
    });
    return;
  }
}
