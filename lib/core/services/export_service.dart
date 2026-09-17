import 'dart:io';
import 'dart:typed_data';
import 'package:excel/excel.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import 'package:pockettrack/features/expense/domain/entities/expense.dart';

class ExportService {
  // 1. PDF EXPORT
  static Future<void> exportToPdf(List<Expense> expenses, DateTime start, DateTime end) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        build: (context) => [
          pw.Header(level: 0, child: pw.Text("PocketTrack: Xarajatlar Hisoboti")),
          pw.Text("Muddat: ${DateFormat('dd.MM.yyyy').format(start)} - ${DateFormat('dd.MM.yyyy').format(end)}"),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Sana', 'Nomi', 'Kategoriya', 'Summa'],
            data: expenses.map((e) => [
              DateFormat('dd.MM.yyyy').format(e.date),
              e.title,
              e.category,
              "${e.amount.toStringAsFixed(0)} so'm"
            ]).toList(),
          ),
          pw.SizedBox(height: 20),
          pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              "Jami: ${expenses.fold(0.0, (sum, e) => sum + e.amount).toStringAsFixed(0)} so'm",
              style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
            ),
          ),
        ],
      ),
    );

    final bytes = await pdf.save();
    await _saveAndOpenFile(bytes, "pdf", "application/pdf");
  }

  // 2. EXCEL EXPORT
  static Future<void> exportToExcel(List<Expense> expenses, DateTime start, DateTime end) async {
    var excel = Excel.createExcel();
    
    // Standart 'Sheet1'ni o'chirib, o'zimiznikini yaratamiz
    excel.rename(excel.getDefaultSheet()!, 'Hisobot');
    Sheet sheetObject = excel['Hisobot'];

    // Sarlavhalar
    sheetObject.appendRow([
      TextCellValue('Sana'),
      TextCellValue('Nomi'),
      TextCellValue('Kategoriya'),
      TextCellValue('Summa (so\'m)'),
    ]);

    // Ma'lumotlar
    for (var e in expenses) {
      sheetObject.appendRow([
        TextCellValue(DateFormat('dd.MM.yyyy').format(e.date)),
        TextCellValue(e.title),
        TextCellValue(e.category),
        DoubleCellValue(e.amount),
      ]);
    }

    final fileBytes = excel.save();
    if (fileBytes != null) {
      await _saveAndOpenFile(
        Uint8List.fromList(fileBytes), 
        "xlsx", 
        "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
      );
    }
  }

  // 3. CSV EXPORT
  static Future<void> exportToCsv(List<Expense> expenses, DateTime start, DateTime end) async {
    // UTF-8 BOM qo'shish (Excel CSV-ni to'g'ri o'qishi uchun kerak)
    String csvData = "\uFEFFSana,Nomi,Kategoriya,Summa\n";
    
    for (var e in expenses) {
      csvData += "${DateFormat('dd.MM.yyyy').format(e.date)},${e.title},${e.category},${e.amount}\n";
    }

    final bytes = Uint8List.fromList(csvData.codeUnits);
    await _saveAndOpenFile(bytes, "csv", "text/csv");
  }

  // Yordamchi funksiya: Faylni saqlash va ochish
  static Future<void> _saveAndOpenFile(Uint8List bytes, String extension, String mimeType) async {
    // Temporary o'rniga Documents papkasidan foydalanamiz (ko'proq ruxsatlarga ega)
    final directory = await getApplicationDocumentsDirectory();
    final fileName = "pockettrack_${DateTime.now().millisecondsSinceEpoch}.$extension";
    final file = File("${directory.path}/$fileName");
    
    await file.writeAsBytes(bytes);
    
    // Faylni ochishda MIME turini aniq ko'rsatamiz
    await OpenFilex.open(file.path, type: mimeType);
  }
}
