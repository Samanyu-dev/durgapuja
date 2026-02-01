import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Persists and loads saved design concepts (My Concepts gallery).
/// Uses SharedPreferences; each concept is stored as a JSON map.
class ConceptsStoreService {
  static const String _keyConcepts = 'saved_design_concepts';

  /// Saves a concept to the store. Merges with existing; same [id] overwrites.
  Future<void> saveConcept({
    required String id,
    required String title,
    required String imageUrl,
    String theme = 'Custom',
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getConcepts();
    final dateStr = _formatDate(DateTime.now());
    final map = {
      'id': id,
      'title': title,
      'date': 'Created on $dateStr',
      'image': imageUrl,
      'theme': theme,
    };
    final index = list.indexWhere((c) => (c['id'] ?? c['title']) == id);
    if (index >= 0) {
      list[index] = map;
    } else {
      list.insert(0, map);
    }
    await prefs.setString(_keyConcepts, jsonEncode(list));
  }

  /// Returns all saved concepts (list of maps: id, title, date, image, theme).
  Future<List<Map<String, String>>> getConcepts() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_keyConcepts);
      if (raw == null || raw.isEmpty) return [];
      final list = jsonDecode(raw) as List<dynamic>?;
      if (list == null) return [];
      return list
          .map((e) => (e as Map<dynamic, dynamic>).map(
                (k, v) => MapEntry(k.toString(), v?.toString() ?? ''),
              ))
          .toList();
    } catch (e) {
      debugPrint('ConceptsStoreService getConcepts: $e');
      return [];
    }
  }

  /// Removes a concept by id.
  Future<void> removeConcept(String id) async {
    final list = await getConcepts();
    list.removeWhere((c) => (c['id'] ?? c['title']) == id);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyConcepts, jsonEncode(list));
  }

  static String _formatDate(DateTime d) {
    return '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
  }
}
