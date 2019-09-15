import 'package:attendance_teacher/screens/adminDashboard.dart';
import 'package:attendance_teacher/screens/login.dart';
import 'package:attendance_teacher/screens/mailteachers.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher Attendance Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light
      ),
      home: Login(),
    );
  }
}
