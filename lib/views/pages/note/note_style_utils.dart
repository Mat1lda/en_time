import 'package:en_time/database/models/note_model.dart';
import 'package:flutter/material.dart';

class NoteStyleUtils {
  static Color getContrastingTextColor(Color backgroundColor) {
    // Tính toán độ sáng của màu nền
    final luminance = backgroundColor.computeLuminance();
    // Nếu độ sáng > 0.5 thì dùng màu đen, ngược lại dùng màu trắng
    return luminance > 0.5 ? Colors.black : Colors.white;
  }

  static Color parseColor(String? hexColor, {Color fallback = Colors.white}) {
    if (hexColor == null || hexColor.isEmpty) return fallback;

    try {
      if (hexColor.length == 6) {
        hexColor = 'FF$hexColor';
      }
      if (hexColor.startsWith('#')) {
        hexColor = hexColor.replaceFirst('#', '');
      }
      return Color(int.parse(hexColor, radix: 16));
    } catch (e) {
      return fallback;
    }
  }

  static String colorToHex(Color color) {
    return '#${color.value.toRadixString(16).substring(2)}';
  }
}

Color getNoteBackgroundColor(Note note) {
  final colorStr = note.themeColor?.startsWith('0x') == true
      ? note.themeColor!
      : '0x${note.themeColor ?? '000000'}';
  return Color(int.parse(colorStr));
}

Color getNoteFontColor(Note note) {
  final colorStr = note.fontColor?.startsWith('0x') == true
      ? note.fontColor!
      : '0x${note.fontColor ?? '000000'}';
  return Color(int.parse(colorStr));
}

double getNoteFontSize(Note note, {bool isTitle = false}) {
  final baseSize = note.fontSize?.toDouble() ?? 14.0;
  return isTitle ? baseSize + 2 : baseSize;
}
