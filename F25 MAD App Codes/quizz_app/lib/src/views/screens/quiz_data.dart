import 'package:flutter/material.dart';

// Global list for Quizzes
List<Map<String, dynamic>> globalQuizzes = [
  {
    'title': 'Statistics Math Quiz',
    'subtitle': 'Math • 12 Quizzes',
    'icon': Icons.bar_chart,
    'iconColor': const Color(0xFF4169E1),
    'bgColor': const Color(0xFFE0E7FF),
  },
  {
    'title': 'Integers Quiz',
    'subtitle': 'Math • 10 Quizzes',
    'icon': Icons.functions,
    'iconColor': const Color(0xFF3CB371),
    'bgColor': const Color(0xFFE0F8E0),
  },
];

// --- NEW: Global list for Categories ---
List<Map<String, dynamic>> globalCategories = [
  {
    'title': 'Html',
    'icon': Icons.code,
    'iconColor': const Color(0xFFE57373), // Red-ish
    'bgColor': const Color(0xFFFFEBEE),
  },
  {
    'title': 'Flutter',
    'icon': Icons.grid_view_outlined,
    'iconColor': const Color(0xFFD982A3), // Pink
    'bgColor': const Color(0xFFFCE8EF),
  },
  {
    'title': 'Mathematics',
    'icon': Icons.bar_chart,
    'iconColor': const Color(0xFF4169E1), // Royal Blue
    'bgColor': const Color(0xFFE0E7FF),
  },
  {
    'title': 'Java',
    'icon': Icons.coffee,
    'iconColor': const Color(0xFF81C784), // Green-ish
    'bgColor': const Color(0xFFE8F5E9),
  },
  {
    'title': 'Python',
    'icon': Icons.terminal,
    'iconColor': const Color(0xFF64B5F6), // Blue-ish
    'bgColor': const Color(0xFFE3F2FD),
  },
];