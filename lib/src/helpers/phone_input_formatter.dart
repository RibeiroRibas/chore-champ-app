import 'package:flutter/services.dart';

class PhoneInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (text.length > 11) return oldValue;
    String formatted = '';
    for (int i = 0; i < text.length; i++) {
      if (i == 0) {
        formatted += '(${text[i]}';
      } else if (i == 1) {
        formatted += '${text[i]}) ';
      }
      else if (i == 6) {
        formatted += '-${text[i]}';
      }
      else {
        formatted += text[i];
      }
    }
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
