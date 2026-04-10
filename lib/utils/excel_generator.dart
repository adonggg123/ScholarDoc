import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';
import 'package:intl/intl.dart';

class ExcelGenerator {
  static Future<void> exportStudentsData({
    required List<Map<String, dynamic>> students,
    required String title,
  }) async {
    var excel = Excel.createExcel();
    Sheet sheetObject = excel['Students Profile Database'];
    excel.setDefaultSheet('Students Profile Database');

    // Headers
    List<String> headers = [
      "Full Name", "Student ID", "Email", "Contact Number", 
      "Course Display", "Year", "Section", "Scholarship Name", 
      "Account Status", "Father's Name", "Mother's Name", 
      "Yearly Income", "Religion", "Tribe"
    ];
    
    sheetObject.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Rows
    for (var student in students) {
      final familyDetails = student['familyDetails'] as Map<String, dynamic>? ?? {};

      List<CellValue> row = [
        TextCellValue(student['fullName']?.toString() ?? ''),
        TextCellValue(student['studentId']?.toString() ?? ''),
        TextCellValue(student['email']?.toString() ?? ''),
        TextCellValue(student['contactNumber']?.toString() ?? ''),
        TextCellValue(student['courseDisplay']?.toString() ?? ''),
        TextCellValue(student['year']?.toString() ?? ''),
        TextCellValue(student['section']?.toString() ?? ''),
        TextCellValue(student['scholarshipName']?.toString() ?? ''),
        TextCellValue(student['status']?.toString() ?? ''),
        TextCellValue(familyDetails['fatherName']?.toString() ?? ''),
        TextCellValue(familyDetails['motherName']?.toString() ?? ''),
        TextCellValue(familyDetails['yearlyIncome']?.toString() ?? ''),
        TextCellValue(familyDetails['religion']?.toString() ?? ''),
        TextCellValue(familyDetails['tribe']?.toString() ?? ''),
      ];
      sheetObject.appendRow(row);
    }

    var fileBytes = excel.save();
    if (fileBytes != null) {
      final date = DateFormat('yyyy_MM_dd_HH_mm_ss').format(DateTime.now());
      await FileSaver.instance.saveFile(
        name: '${title.replaceAll(' ', '_')}_$date.xlsx',
        bytes: Uint8List.fromList(fileBytes),
      );
    }
  }
}
