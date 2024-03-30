import 'package:flutter/services.dart';

class CNICInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Only apply formatting to forward typing, not deletions.
    if (oldValue.text.length >= newValue.text.length) {
      return newValue;
    }

    String newText = newValue.text.replaceAll('-', '');
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < newText.length; i++) {
      buffer.write(newText[i]);
      if (i == 4 || i == 11) {
        buffer.write('-'); // Add dashes at the 5th and 12th positions
      }
    }

    String formattedText = buffer.toString();

    // Limit the length of the input to the size of a CNIC number
    if (formattedText.length > 15) {
      formattedText = formattedText.substring(0, 15);
    }

    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
