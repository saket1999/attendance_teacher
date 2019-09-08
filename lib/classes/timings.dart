
class Timings {
	String _day;
	String _start;
	String _duration;
	String _documentId;


	Timings(this._day, this._start, this._duration);

	Timings.blank();

	String get duration => _duration;

	set duration(String value) {
		_duration = value;
	}

	String get start => _start;

	set start(String value) {
		_start = value;
	}

	String get day => _day;

	set day(String value) {
		_day = value;
	}

	String get documentId => _documentId;

	set documentId(String value) {
		_documentId = value;
	}

	Map<String, String> toMap() {
		var map = Map<String, String>();
		map['day'] = _day;
		map['start'] = _start;
		map['duration'] = _duration;
		return map;
	}

	Timings.fromMapObject(var doc) {
		this._day = doc.data['day'];
		this._start = doc.data['start'];
		this._duration = doc.data['duration'];
	}


}