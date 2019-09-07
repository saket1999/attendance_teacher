
class Teaching {
	String _subjectId;
	String _className;
	String _subjectName;
	String _documentId;
	String _teacherDocumentId;
	String _joiningCode;

	String get joiningCode => _joiningCode;

	set joiningCode(String value) {
		_joiningCode = value;
	}

	Teaching.blank();

	String get subjectName => _subjectName;

	set subjectName(String value) {
		_subjectName = value;
	}

	String get className => _className;

	set className(String value) {
		_className = value;
	}

	String get subjectId => _subjectId;

	set subjectId(String value) {
		_subjectId = value;
	}


	String get documentId => _documentId;

	set documentId(String value) {
		_documentId = value;
	}

	Map<String, String> toMap() {
		var map = Map<String, String>();
		map['subjectId'] = _subjectId;
		map['className'] = _className;
		map['subjectName'] = _subjectName;
		map['joiningCode'] = _joiningCode;
		return map;
	}

	Teaching.fromMapObject(var doc) {
		this._subjectId = doc.data['subjectId'];
		this._className = doc.data['className'];
		this._subjectName = doc.data['subjectName'];
	}

	String get teacherDocumentId => _teacherDocumentId;

	set teacherDocumentId(String value) {
		_teacherDocumentId = value;
	}

}