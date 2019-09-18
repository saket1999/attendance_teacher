import 'package:attendance_teacher/classes/card.dart';
import 'package:attendance_teacher/classes/teacher.dart';
import 'package:attendance_teacher/classes/teaching.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart';
import 'package:printing/printing.dart';

exportToPdf(Teacher teacher,Teaching teaching,List<CardData> cardDataList) async {
  final Document pdf=Document();
  pdf.addPage(MultiPage(
      pageFormat: PdfPageFormat.a4,
      header: (Context context) {
        if (context.pageNumber == 1) {
          return null;
        }
        return Container(
            alignment: Alignment.centerRight,
            margin: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            padding: const EdgeInsets.only(bottom: 3.0 * PdfPageFormat.mm),
            decoration: const BoxDecoration(
                border:
                BoxBorder(bottom: true, width: 0.5, color: PdfColors.grey)),
            child: Text('Short Attendance List',
                style: Theme.of(context)
                    .defaultTextStyle
                    .copyWith(color: PdfColors.grey)));
      },
      build: (Context context) => <Widget>[
        Header(
          level: 0,
          child:Row(
            children: <Widget>[
              Center(child:Text('Short Attendance List',textScaleFactor: 2.0)),
            ]
          ),
        ),
        Center(child:Text('Students having attendance less than 75% in '+teaching.subjectName+' of Class: '+teaching.classId,textScaleFactor: 1.4)),
        Container(height: 20.0),
        Table.fromTextArray(context: context, data: returnList(cardDataList)),
        Container(height: 20.0),
        Text('Teacher Incharge: '+teacher.name),
        Text('Teacher Id: '+teacher.teacherId)
      ]));

  await Printing.sharePdf(bytes: pdf.save(), filename: 'my-document.pdf');



}

returnList(List<CardData> cardDataList) {
  List<List<String>> doc = [];
  doc.add(['Student Name', 'Registration Number', 'Attendance Percentage']);
  for(int i=0; i<cardDataList.length; i++) {
    List<String> temp = [cardDataList[i].title, cardDataList[i].subtitle, cardDataList[i].trailing.substring(9)];
    doc.add(temp);
  }
  return doc;

}