import 'package:en_time/database/models/note_model.dart';
import 'package:flutter/material.dart';

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
