import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberFormatter extends TextInputFormatter {
  final NumberFormat _formatter = NumberFormat('#,##0.##');

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // If the new value is empty, return it as is
    if (newValue.text.isEmpty) {
      return newValue;
    }

    // Remove all non-digit and non-decimal characters
    String cleanedText = newValue.text.replaceAll(RegExp(r'[^\d.]'), '');
    
    // Handle multiple decimal points - keep only the first one
    List<String> parts = cleanedText.split('.');
    if (parts.length > 2) {
      cleanedText = '${parts[0]}.${parts.sublist(1).join('')}';
    }

    // Parse the cleaned text
    double? value = double.tryParse(cleanedText);
    if (value == null) {
      return oldValue;
    }

    // Format the number with commas
    String formattedText = _formatter.format(value);
    
    // Calculate the new cursor position
    int cursorPosition = formattedText.length;
    
    // If the user was typing at the end, keep cursor at the end
    if (newValue.selection.baseOffset == newValue.text.length) {
      cursorPosition = formattedText.length;
    } else {
      // Try to maintain relative cursor position
      int oldCursorPos = newValue.selection.baseOffset;
      int commasBeforeCursor = 0;
      
      for (int i = 0; i < oldCursorPos && i < newValue.text.length; i++) {
        if (newValue.text[i] == ',') {
          commasBeforeCursor++;
        }
      }
      
      // Adjust cursor position accounting for new commas
      cursorPosition = (oldCursorPos - commasBeforeCursor).clamp(0, formattedText.length);
      
      // Count commas in formatted text up to cursor position
      int newCommasBeforeCursor = 0;
      for (int i = 0; i < cursorPosition && i < formattedText.length; i++) {
        if (formattedText[i] == ',') {
          newCommasBeforeCursor++;
        }
      }
      
      cursorPosition = (cursorPosition + newCommasBeforeCursor).clamp(0, formattedText.length);
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: cursorPosition),
    );
  }

  /// Helper method to get the numeric value from formatted text
  static double? getNumericValue(String formattedText) {
    String cleanedText = formattedText.replaceAll(RegExp(r'[^\d.]'), '');
    return double.tryParse(cleanedText);
  }

  /// Helper method to format a number for display
  static String formatNumber(double number) {
    final formatter = NumberFormat('#,##0.##');
    return formatter.format(number);
  }
}