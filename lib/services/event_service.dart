import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class EventService {
  static const String _storageKey = "events_data";

  /// Save events to local storage
  Future<void> saveEvents(Map<DateTime, List<String>> events) async {
    final prefs = await SharedPreferences.getInstance();

    // Convert DateTime keys to string
    final data = events.map((key, value) =>
        MapEntry(key.toIso8601String(), value));

    await prefs.setString(_storageKey, jsonEncode(data));
  }

  /// Load events from local storage
  Future<Map<DateTime, List<String>>> loadEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_storageKey);

    if (jsonString == null) {
      return {};
    }

    final Map<String, dynamic> decoded = jsonDecode(jsonString);

    // Convert back to DateTime
    final events = decoded.map(
          (key, value) => MapEntry(
        DateTime.parse(key),
        List<String>.from(value),
      ),
    );

    return events;
  }

  /// Add a single event
  Future<void> addEvent(DateTime day, String event) async {
    final events = await loadEvents();
    final normalized = DateTime(day.year, day.month, day.day);

    if (!events.containsKey(normalized)) {
      events[normalized] = [];
    }
    events[normalized]!.add(event);

    await saveEvents(events);
  }

  /// Remove an event
  Future<void> removeEvent(DateTime day, String event) async {
    final events = await loadEvents();
    final normalized = DateTime(day.year, day.month, day.day);

    events[normalized]?.remove(event);

    if (events[normalized]?.isEmpty ?? false) {
      events.remove(normalized);
    }

    await saveEvents(events);
  }
}
