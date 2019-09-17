/*This screen helps in creating a particular timing of a particular regular class*/
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:attendance_teacher/classes/timings.dart';
import 'package:attendance_teacher/services/firestorecrud.dart';
import 'package:attendance_teacher/services/toast.dart';
import 'package:flutter/material.dart';
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
	TimeOfDay _time = TimeOfDay.now();

	var dayList = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
	var _currentDaySelected = '';


	//By default the initial day is set to dayList[0]
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
								child: RaisedButton(
									child: Text('Choose Time'),
									onPressed: () {
										selectTime(context);
									},
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

  //Time Selector
  Future<Null> selectTime(BuildContext context) async {
		final TimeOfDay picked = await showTimePicker(
			context: context,
			initialTime: _time
		);
		setState(() {
			if(picked!=null) {
				_time = picked;
				_timings.start = _time.toString();
			}
		});
  }
}
