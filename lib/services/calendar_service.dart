import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';

class CalendarService {
  static const _key = 'cal_entries';
  static const _goalKey = 'daily_goal';

  Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  // Helper date string: "yyyy-mm-dd"
  String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4,'0')}-${d.month.toString().padLeft(2,'0')}-${d.day.toString().padLeft(2,'0')}';

  Future<Map<String, List<FoodEntry>>> _loadMap() async {
    final p = await _prefs;
    final raw = p.getString(_key);
    if (raw == null) return {};
    final Map<String, dynamic> decoded = jsonDecode(raw);
    return decoded.map((k, v) {
      final list = (v as List).map((e) => FoodEntry.fromJson(e)).toList();
      return MapEntry(k, list);
    });
  }

  Future<void> _saveMap(Map<String, List<FoodEntry>> map) async {
    final p = await _prefs;
    final out = map.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList()));
    await p.setString(_key, jsonEncode(out));
  }

  Future<List<FoodEntry>> getEntriesFor(DateTime date) async {
    final m = await _loadMap();
    return m[dateKey(date)] ?? [];
  }

  Future<void> addEntry(DateTime date, FoodEntry entry) async {
    final m = await _loadMap();
    final k = dateKey(date);
    final list = m[k] ?? [];
    list.add(entry);
    m[k] = list;
    await _saveMap(m);
  }

  Future<void> updateEntry(DateTime date, FoodEntry entry) async {
    final m = await _loadMap();
    final k = dateKey(date);
    final list = m[k] ?? [];
    final idx = list.indexWhere((e) => e.id == entry.id);
    if (idx != -1) {
      list[idx] = entry;
      m[k] = list;
      await _saveMap(m);
    }
  }

  Future<void> removeEntry(DateTime date, String entryId) async {
    final m = await _loadMap();
    final k = dateKey(date);
    final list = m[k] ?? [];
    list.removeWhere((e) => e.id == entryId);
    m[k] = list;
    await _saveMap(m);
  }

  Future<int> getDailyGoal() async {
    final p = await _prefs;
    return p.getInt(_goalKey) ?? 2000; // default goal
  }

  Future<void> setDailyGoal(int goal) async {
    final p = await _prefs;
    await p.setInt(_goalKey, goal);
  }

  // Convenience: total calories for date
  Future<double> totalCaloriesFor(DateTime date) async {
    final entries = await getEntriesFor(date);
    return entries.fold<double>(0.0, (s, e) => s + e.calories);
  }
}
