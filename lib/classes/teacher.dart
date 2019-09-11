
class Teacher {
	String _teacherId;
	String _pass;
	String _name;
	String _mobile;
	String _email;
	String _documentId;
	int _verify;

	Teacher.blank();


	int get verify => _verify;

	set verify(int value) {
		_verify = value;
	}

	String get documentId => _documentId;

	set documentId(String value) {
		_documentId = value;
	}

	String get email => _email;

	set email(String value) {
		_email = value;
	}

	String get mobile => _mobile;

	set mobile(String value) {
		_mobile = value;
	}

	String get name => _name;

	set name(String value) {
		_name = value;
	}

	String get pass => _pass;

	set pass(String value) {
		_pass = value;
	}

	String get teacherId => _teacherId;

	set teacherId(String value) {
		_teacherId = value;
	}

	Map<String, dynamic> toMap() {
		var map = Map<String, dynamic>();
		map['teacherId'] = _teacherId;
		map['pass'] = _pass;
		map['name'] = _name;
		map['mobile'] = _mobile;
		map['email'] = _email;
		map['verify'] = _verify;
		return map;
	}

	Teacher.fromMapObject(Map<String, dynamic> map) {
		this._teacherId = map['teacherId'];
		this._pass = map['pass'];
		this._name = map['name'];
		this._mobile = map['mobile'];
		this._email = map['email'];
		this._verify = map['verify'];
	}

}