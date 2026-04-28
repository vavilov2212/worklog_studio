import 'package:flutter/material.dart';

class BadgeUtils {
  static const List<(Color bg, Color text)> _palette = [
    (Color(0xFFE3E8FC), Color(0xFF3B5BDB)),
    (Color(0xFFEBE4FF), Color(0xFF7048E8)),
    (Color(0xFFE5F5F0), Color(0xFF0CA678)),
    (Color(0xFFFFF0E6), Color(0xFFE8590C)),
    (Color(0xFFFFE3E3), Color(0xFFE03131)),
    (Color(0xFFF4FCE3), Color(0xFF5C940D)),
    (Color(0xFFE3FAF4), Color(0xFF089981)),
    (Color(0xFFFFF4E6), Color(0xFFD97706)),
    (Color(0xFFF3F0FF), Color(0xFF6741D9)),
    (Color(0xFFEDF2FF), Color(0xFF364FC7)),
    (Color(0xFFF8F0FC), Color(0xFF9C36B5)),
    (Color(0xFFE6FCF5), Color(0xFF099268)),
    (Color(0xFFEFE8E6), Color(0xFF785A52)),
    (Color(0xFFE8ECEF), Color(0xFF343A40)),
  ];

  static String getProjectInitials(String name) {
    if (name.trim().isEmpty) return '--';
    final words = name.trim().split(RegExp(r'\s+'));
    if (words.length == 1) {
      final word = words[0];
      if (word.length >= 2) return word.substring(0, 2).toUpperCase();
      return word.padRight(2, word).toUpperCase();
    }
    return (words[0][0] + words[1][0]).toUpperCase();
  }

  static String getTaskInitials(String taskName, String projectName) {
    final t = taskName.trim().isNotEmpty ? taskName.trim()[0] : '-';
    final p = projectName.trim().isNotEmpty ? projectName.trim()[0] : '-';
    return (t + p).toUpperCase();
  }

  static int _stringHash(String s) {
    var hash = 0;
    for (var i = 0; i < s.length; i++) {
      hash = s.codeUnitAt(i) + ((hash << 5) - hash);
    }
    return hash.abs();
  }

  static (Color, Color) getBadgeColor(String id) {
    final index = _stringHash(id) % _palette.length;
    return _palette[index];
  }
}
