
class Teaching {
	String _subjectId;
	String _classId;
	String _subjectName;
	String _documentId;
	String _teacherDocumentId;

	Teaching.blank();

	String get subjectName => _subjectName;

	set subjectName(String value) {
		_subjectName = value;
	}

	String get classId => _classId;

	set classId(String value) {
		_classId = value;
	}

	String get subjectId => _subjectId;

	set subjectId(String value) {
		_subjectId = value;
	}


	String get documentId => _documentId;

	set documentId(String value) {
		_documentId = value;
	}

	String get teacherDocumentId => _teacherDocumentId;

	set teacherDocumentId(String value) {
		_teacherDocumentId = value;
	}

	Map<String, String> toMap() {
		var map = Map<String, String>();
		map['subjectId'] = _subjectId;
		map['classId'] = _classId;
		map['subjectName'] = _subjectName;
		return map;
	}

	Teaching.fromMapObject(var doc) {
		this._subjectId = doc.data['subjectId'];
		this._classId = doc.data['classId'];
		this._subjectName = doc.data['subjectName'];
	}


}