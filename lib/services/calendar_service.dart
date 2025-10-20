import 'package:shared_preferences/shared_preferences.dart';
import '../models/food_entry.dart';

class CalendarService {
  final Map<String, List<FoodEntry>> _entriesByDate = {};

  // ✅ Fetch all entries for a specific date
  Future<List<FoodEntry>> getEntriesFor(DateTime date) async {
    final key = _dateKey(date);
    return _entriesByDate[key] ?? [];
  }

  // ✅ Add a new entry
  Future<void> addEntry(DateTime date, FoodEntry entry) async {
    final key = _dateKey(date);
    final list = _entriesByDate[key] ?? [];
    list.add(entry);
    _entriesByDate[key] = list;
  }

  // ✅ Update existing entry
  Future<void> updateEntry(DateTime date, FoodEntry entry) async {
    final key = _dateKey(date);
    final list = _entriesByDate[key];
    if (list != null) {
      final index = list.indexWhere((e) => e.id == entry.id);
      if (index != -1) list[index] = entry;
    }
  }

  // ✅ Delete an entry
  Future<void> removeEntry(DateTime date, String id) async {
    final key = _dateKey(date);
    _entriesByDate[key]?.removeWhere((e) => e.id == id);
  }

  // ✅ Get daily goal from SharedPreferences
  Future<int> getDailyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('dailyGoal') ?? 2000;
  }

  // ✅ Set daily goal and sync it globally
  Future<void> setDailyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', goal);
  }

  String _dateKey(DateTime date) =>
      "${date.year}-${date.month}-${date.day}";
}
