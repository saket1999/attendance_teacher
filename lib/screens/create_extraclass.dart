/*This screen helps to schedule an extra class*/

import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class CreateExtraClass extends StatefulWidget {

	Teaching _teaching;
	CreateExtraClass(this._teaching);

	@override
	_CreateExtraClassState createState() => _CreateExtraClassState(_teaching);
}

class _CreateExtraClassState extends State<CreateExtraClass> {

	Teaching _teaching;
	_CreateExtraClassState(this._teaching);

	Timings _timings = Timings.blank();

	bool _isLoading = false;
	DateTime _dateTime = DateTime.now();
	final dateFormat = DateFormat("yyyy-MM-dd HH:mm");

	String date;

	var _createExtra = GlobalKey<FormState>();
	
	/*UI Part:
	* 	AppBar:
	* 		Text: Add Extra Class
	* 	Body: Form:*/

	@override
	Widget build(BuildContext context) {
		return Scaffold(
			appBar: AppBar(
				title: Text('Add Extra Class'),
			),
			body: Container(
				padding: EdgeInsets.all(10.0),
				child: Form(
					key: _createExtra,
					child: Center(
						child: Column(
							children: <Widget>[
								Padding(
									padding: EdgeInsets.all(10.0),
									child: DateTimeField(
										format: dateFormat,
										onShowPicker: (context, currentValue) async {
											final date = await showDatePicker(
												context: context,
												initialDate: _dateTime,
												firstDate: _dateTime.subtract(Duration(days: 1)),
												lastDate: DateTime(2050)
											);
											if(date != null) {
												final time = await showTimePicker(
													context: context,
													initialTime: TimeOfDay.now()
												);
												return DateTimeField.combine(date, time);
											} else
												return currentValue;
										},
										validator: (value) {
											if(value.toString().length == 0)
												return 'Enter Date and Time';
											else
												return null;
										},
										onSaved: (value) {
											_dateTime = value;
											date = _dateTime.year.toString()+'-'+_dateTime.month.toString()+'-'+_dateTime.day.toString();
											_timings.start = 'TimeOfDay('+_dateTime.hour.toString()+':'+_dateTime.minute.toString()+')';
											_timings.day = getWeekDay(_dateTime.weekday);
										},
										decoration: InputDecoration(
											labelText: 'Date and Time',
											errorStyle: TextStyle(color: Colors.red),
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(5.0))
										),
									),
								),
								Padding(
									padding: EdgeInsets.all(10.0),
									child: TextFormField(
										onSaved: (value) {
											_timings.duration = value;
										},
										keyboardType: TextInputType.number,
										validator: (String value) {
											if(value.length == 0)
												return "Enter Duration";
										},
										decoration: InputDecoration(
											labelText: 'Duration of Class',
											errorStyle: TextStyle(color: Colors.red),
											border: OutlineInputBorder(
												borderRadius: BorderRadius.circular(5.0))
										),
									),
								),
								Padding(
									padding: EdgeInsets.all(10.0),
									child: Row(
										children: <Widget>[
											Expanded(
												child: Container(
													width: 50.0,
												),
											),
											RaisedButton(
												child: _isLoading?Loading(indicator: BallPulseIndicator(), size: 20.0,):Text('Submit'),
												onPressed: () {
													if(_createExtra.currentState.validate() && _isLoading == false) {
														setState(() {
															_isLoading = true;
														});

														_createExtra.currentState.save();

														FirestoreCRUD.createExtraClass(_teaching, _timings , date).then((bool b) {
															if(b == true) {
																toast('Extra Class created successfully');
																Navigator.of(context).pop();
															}
															else
																setState(() {
																	_isLoading = false;
																});
														});
													}
												},
											),
											Expanded(
												child: Container(
													width: 50.0,
												),
											),
										],
									),

								)
							],
						),
					),
				),
			),
		);
	}

	String getWeekDay(int no) {
		switch(no) {
			case 1:
				return 'Monday';
			case 2:
				return 'Tuesday';
			case 3:
				return 'Wednesday';
			case 4:
				return 'Thursday';
			case 5:
				return 'Friday';
			case 6:
				return 'Saturday';
			case 7:
				return 'Sunday';
		}
	}
}
