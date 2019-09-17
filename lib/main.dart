import 'dart:convert';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/screens/adminDashboard.dart';
import 'package:attendance_teacher/screens/dashboard.dart';
import 'package:attendance_teacher/screens/login.dart';
import 'package:attendance_teacher/screens/mailteachers.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

void main() {

  SharedPreferences.getInstance().then((prefs) {
    final String jsonObject = prefs.getString('storedObject');
    final String jsonId = prefs.getString('storedId');
    final String firstTime = prefs.getString('firstTime');
    prefs.setString('firstTime', 'false');
    bool getHelp;
    if(firstTime == null)
      getHelp = true;
    else
      getHelp = false;

    if(jsonObject != null && jsonObject.isNotEmpty) {
      Teacher student = Teacher.fromMapObject(json.decode(jsonObject));
      student.documentId = jsonId;
      return runApp(MyApp(true, student, getHelp));
    }
    else
      return runApp(MyApp(false, Teacher.blank(), getHelp));
  });

}

class MyApp extends StatelessWidget {

  bool check;
  Teacher teacher;
  bool getHelp;
  MyApp(this.check, this.teacher, this.getHelp);

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      title: 'Teacher Attendance Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light
      ),
      home: check? (teacher.verify==404? AdminDashboard(): ShowCaseWidget(child: Dashboard(teacher, getHelp))): Login(getHelp)
    );
  }
}
