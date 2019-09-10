import 'package:attendance_teacher/services/toast.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:validators/validators.dart';

class EditAttendance extends StatefulWidget {
  @override
  _EditAttendanceState createState() => _EditAttendanceState();
}

class _EditAttendanceState extends State<EditAttendance> {

	var _editForm = GlobalKey<FormState>();

	final dateFormat = DateFormat("yyyy-MM-dd");
	String regNo;
	String date;
	DateTime dateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
		appBar: AppBar(
			title: Text('Edit Attendance'),
		),
		body: Container(
			padding: EdgeInsets.all(10.0),
			child: Form(
				key: _editForm,
				child: Center(
					child: ListView(
						children: <Widget>[
							Padding(
								padding: EdgeInsets.all(10.0),
								child: TextFormField(
									onSaved: (value) {
										regNo = value;
									},
									validator: (String value) {
										if(value.length != 8)
											return 'Enter valid Registeration Number';
									},
									decoration: InputDecoration(
										labelText: 'Registeration Number',
										errorStyle: TextStyle(color: Colors.yellow),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(5.0))
									),
								),
							),
							Padding(
								padding: EdgeInsets.all(10.0),
								child: DateTimeField(
									format: dateFormat,
									onShowPicker: (context, currentValue) {
										return showDatePicker(
											context: context,
											initialDate: dateTime,
											firstDate: DateTime(2000),
											lastDate: DateTime(2050));
									},
									onSaved: (value) {
										dateTime = value;
										date = dateTime.year.toString()+'-'+dateTime.month.toString()+'-'+dateTime.day.toString();
									},
									validator: (DateTime value) {
										if(!isDate(value.toString()) || value == null)
											return 'Enter valid Date';
									},
									decoration: InputDecoration(
										labelText: 'Date',
										errorStyle: TextStyle(color: Colors.yellow),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(5.0))
									),
								),
							),
							Row(
								children: <Widget>[
									Expanded(
									  child: Container(
									  	width: 50.0,
									  ),
									),
									Card(
									  child: IconButton(
									  	iconSize: 30.0,
									  	icon: Icon(Icons.search),
									  	onPressed: () {
									  		if(_editForm.currentState.validate()) {
									  			_editForm.currentState.save();
									  			toast(date);
									  		}
									  	},
									  ),
									),
									Expanded(
										child: Container(
											width: 50.0,
										),
									),
								],
							)

						],
					),
				),
			),
		)
	);
  }



}
