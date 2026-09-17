import 'dart:io';
import 'package:excel_plus/excel_plus.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:intl/intl.dart';
import '../../features/expense/domain/entities/expense.dart';

class ExportService {
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

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/pockettrack_report_${DateTime.now().millisecondsSinceEpoch}.pdf");
    await file.writeAsBytes(await pdf.save());
    await OpenFilex.open(file.path);
  }

  static Future<void> exportToExcel(List<Expense> expenses, DateTime start, DateTime end) async {
    final excel = Excel.createExcel();
    final Sheet sheetObject = excel['Sheet1'];

    sheetObject.appendRow([
      TextCellValue('Sana'),
      TextCellValue('Nomi'),
      TextCellValue('Kategoriya'),
      TextCellValue('Summa'),
    ]);

    for (var e in expenses) {
      sheetObject.appendRow([
        TextCellValue(DateFormat('dd.MM.yyyy').format(e.date)),
        TextCellValue(e.title),
        TextCellValue(e.category),
        DoubleCellValue(e.amount),
      ]);
    }

    final output = await getTemporaryDirectory();
    final fileBytes = excel.save();
    final file = File("${output.path}/pockettrack_report_${DateTime.now().millisecondsSinceEpoch}.xlsx");
    
    if (fileBytes != null) {
      await file.writeAsBytes(fileBytes);
      await OpenFilex.open(file.path);
    }
  }

  static Future<void> exportToCsv(List<Expense> expenses, DateTime start, DateTime end) async {
    String csvData = "Sana,Nomi,Kategoriya,Summa\n";
    
    for (var e in expenses) {
      csvData += "${DateFormat('dd.MM.yyyy').format(e.date)},${e.title},${e.category},${e.amount}\n";
    }

    final output = await getTemporaryDirectory();
    final file = File("${output.path}/pockettrack_report_${DateTime.now().millisecondsSinceEpoch}.csv");
    await file.writeAsString(csvData);
    await OpenFilex.open(file.path);
  }
}
