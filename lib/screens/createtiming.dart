/*This screen helps in creating a particular timing of a particular regular class*/
import 'dart:math';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading/indicator/ball_pulse_indicator.dart';
import 'package:loading/loading.dart';

class CreateTiming extends StatefulWidget {

	Teaching _teaching;
	CreateTiming(this._teaching);

	@override
  _CreateTimingState createState() => _CreateTimingState(_teaching);
}

class _CreateTimingState extends State<CreateTiming> {

	Teaching _teaching;
	_CreateTimingState(this._teaching);

	Timings _timings = Timings.blank();

	bool _isLoading = false;

	var _createForm = GlobalKey<FormState>();
	String _time;
	final format = DateFormat("HH:mm");

	var dayList = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
	var _currentDaySelected = '';

	void initState() {
		super.initState();
		_currentDaySelected = dayList[0];
	}

	/*UI Part:
	* Appbar:
	* 	Text: Add Timings
	* Body:
	* 	Select Day
	* 	Select Time
	* 	Enter Duration
	* 	Submit Button*/

	@override
  Widget build(BuildContext context) {
    return Scaffold(
		appBar: AppBar(
			title: Text('Add Timings'),
		),
		body: Container(
			padding: EdgeInsets.all(10.0),
			child: Form(
				key: _createForm,
				child: Center(
					child: Column(
						children: <Widget>[

							Padding(
								padding: EdgeInsets.all(10.0),
								child: Row(
									children: <Widget>[
										Text(
											'Day',
											textScaleFactor: 1.5,
										),
										Container(
											width: 30.0,
										),
										DropdownButton<String> (
											items: dayList.map((String value) {
												return DropdownMenuItem<String>(
													value: value,
													child: Text(value),
												);
											}).toList(),
											value: _currentDaySelected,
											onChanged: (String newValue) {
												setState(() {
												  this._currentDaySelected = newValue;
												  _timings.day = newValue;
												});
											},
										)
									],
								),
							),

							Padding(
								padding: EdgeInsets.all(10.0),
								child: DateTimeField(
									onSaved: (value) {
										_time = 'TimeOfDay('+value.hour.toString().padLeft(2, '0')+':'+value.minute.toString().padLeft(2, '0')+')';
									},
									validator: (value) {
										if (value == null)
										  return 'Enter Time';
										else
											return null;
									},
									format: format,
									decoration: InputDecoration(
										labelText: 'Time',
										errorStyle: TextStyle(color: Colors.red),
										border: OutlineInputBorder(
											borderRadius: BorderRadius.circular(5.0))
									),
									onShowPicker: (context, currentValue) async {
										final time = await showTimePicker(
											context: context,
											initialTime: TimeOfDay.fromDateTime(currentValue ?? DateTime.now()),
										);
										return DateTimeField.convert(time);
									},
								)
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
										else
											return null;
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
								padding: const EdgeInsets.all(10.0),
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
												if(_createForm.currentState.validate() && _isLoading == false) {
													setState(() {
														_isLoading = true;
													});

													_createForm.currentState.save();
													_timings.start = _time;

													FirestoreCRUD.createTime(_teaching, _timings ).then((bool b) {
														if(b == true) {
															toast('Timing created successfully');
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
}
