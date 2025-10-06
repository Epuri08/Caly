import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../services/calendar_service.dart';
import 'day_detail_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  final CalendarService _service = CalendarService();

  late DateTime _focusedDay;
  DateTime? _selectedDay;
  Map<DateTime, List<String>> _events = {};

  @override
  void initState() {
    super.initState();
    _focusedDay = DateTime.now();
    _loadEvents();
  }

  /// ✅ Loads all saved calorie entries and converts them into event markers
  Future<void> _loadEvents() async {
    final today = DateTime.now();

    // We'll simulate events for all days that have entries
    final allDates = <DateTime, List<String>>{};

    // Loop through past ~90 days and see which have data
    for (int i = 0; i < 90; i++) {
      final date = today.subtract(Duration(days: i));
      final entries = await _service.getEntriesFor(date);
      if (entries.isNotEmpty) {
        allDates[DateTime(date.year, date.month, date.day)] =
            entries.map((e) => e.name).toList();
      }
    }

    setState(() {
      _events = allDates;
    });
  }

  List<String> _getEventsForDay(DateTime day) {
    final normalized = DateTime(day.year, day.month, day.day);
    return _events[normalized] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5FC),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "ANALYTICS",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFFFE7AC1),
          ),
        ),
      ),
      body: Column(
        children: [
          TableCalendar(
            firstDay: DateTime.utc(2020, 1, 1),
            lastDay: DateTime.utc(2030, 12, 31),
            focusedDay: _focusedDay,
            calendarFormat: CalendarFormat.month,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedDay) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedDay = focusedDay;
              });

              // ✅ Navigate to Day Detail screen (calorie tracker)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DayDetailScreen(date: selectedDay),
                ),
              );
            },
            eventLoader: _getEventsForDay,
            headerStyle: const HeaderStyle(
              formatButtonVisible: false,
              titleCentered: true,
              titleTextStyle: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFFFE7AC1),
              ),
            ),
            calendarStyle: const CalendarStyle(
              todayDecoration: BoxDecoration(
                color: Color(0xFFFE7AC1),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              weekendTextStyle: TextStyle(color: Colors.red),
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView(
              children: _getEventsForDay(_selectedDay ?? DateTime.now())
                  .map((e) => ListTile(title: Text(e)))
                  .toList(),
            ),
          )
        ],
      ),
    );
  }
}
