import 'package:flutter/services.dart';

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // Faqat raqamlar va nuqtani qoldiramiz
    String text = newValue.text.replaceAll(' ', '');
    
    // Nuqtalar sonini tekshiramiz (faqat bitta bo'lishi kerak)
    if ('.'.allMatches(text).length > 1) {
      return oldValue;
    }

    List<String> parts = text.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    // Mingliklarga ajratish
    final chars = integerPart.runes.toList();
    String formattedInteger = '';
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) {
        formattedInteger += ' ';
      }
      formattedInteger += String.fromCharCode(chars[i]);
    }

    String finalSelectionText = formattedInteger;
    if (decimalPart != null) {
      finalSelectionText += '.$decimalPart';
    }

    return TextEditingValue(
      text: finalSelectionText,
      selection: TextSelection.collapsed(offset: finalSelectionText.length),
    );
  }
  
  static String format(double amount) {
    String text = amount.toStringAsFixed(amount.truncateToDouble() == amount ? 0 : 2);
    List<String> parts = text.split('.');
    String integerPart = parts[0];
    String? decimalPart = parts.length > 1 ? parts[1] : null;

    final chars = integerPart.runes.toList();
    String formattedInteger = '';
    for (int i = 0; i < chars.length; i++) {
      if (i > 0 && (chars.length - i) % 3 == 0) {
        formattedInteger += ' ';
      }
      formattedInteger += String.fromCharCode(chars[i]);
    }

    if (decimalPart != null && decimalPart != '00') {
      return '$formattedInteger.$decimalPart';
    }
    return formattedInteger;
  }
}
