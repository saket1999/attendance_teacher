/*This code is the Teacher/Admin part of the 'Present for Future' attendance management system. This app supports teacher and admin login.
* Teacher part facilitates:
*      Creating new class
*      Listing timings for each class
*      Creating an extra class
*      Taking attendance
*      Generating Short attendance list
*      Send notice/assignment/message to a particular class
* Admin part facilitates:
*      Verify teacher and student login
*      Mail all teachers
*      Unlock profile of teachers and students for editing
*      See short list of students in each subject of each class.
*
*
* Language: Dart
* IDE: Android Studio
* Database: Firebase Firestore*/

/*Note: Method description is provided just BEFORE method declaration/definition*/
/*Note:  Firebase server currently has 8 (eight) cloud functions triggered on different activities of the app which helps in reducing load of client side app and keeps data consistent in all cases*/
/*Note: isLoading and sendingMail are standard boolean variable used throughout project to set particular screen to loading mode*/
/*Note: Each screen's UI is briefly described before the build method*/

import 'dart:convert';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/screens/adminDashboard.dart';
import 'package:attendance_teacher/screens/dashboard.dart';
import 'package:attendance_teacher/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:showcaseview/showcaseview.dart';

/*Checking if a user is already logged int o the app. If logged in user is shown the dashboard.*/

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
/*Admin has the verify flag 404*/
/*This routes the user to Login or the dashboard*/
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
