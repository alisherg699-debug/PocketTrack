import 'package:flutter/services.dart';

class PhoneNumberInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String text = newValue.text.replaceAll(RegExp(r'\D'), '');

    if (text.startsWith('998')) {
      text = text.substring(3);
    }

    if (text.length > 9) {
      text = text.substring(0, 9);
    }

    String buffer = '+998';
    if (text.isNotEmpty) {
      buffer += ' ${text.substring(0, text.length >= 2 ? 2 : text.length)}';
    }
    if (text.length > 2) {
      buffer += ' ${text.substring(2, text.length >= 5 ? 5 : text.length)}';
    }
    if (text.length > 5) {
      buffer += ' ${text.substring(5, text.length >= 7 ? 7 : text.length)}';
    }
    if (text.length > 7) {
      buffer += ' ${text.substring(7, text.length)}';
    }

    return TextEditingValue(
      text: buffer,
      selection: TextSelection.collapsed(offset: buffer.length),
    );
  }
}
