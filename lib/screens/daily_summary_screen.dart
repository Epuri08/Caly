import 'package:flutter/material.dart';
import '../models/food_entry.dart';
import '../services/calendar_service.dart';
import 'food_entry_dialog.dart';

class DailySummaryScreen extends StatefulWidget {
  final DateTime date;
  const DailySummaryScreen({super.key, required this.date});

  @override
  State<DailySummaryScreen> createState() => _DailySummaryScreenState();
}

class _DailySummaryScreenState extends State<DailySummaryScreen> {
  final _service = CalendarService();
  List<FoodEntry> _entries = [];
  int _goal = 2000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final entries = await _service.getEntriesFor(widget.date);
    final goal = await _service.getDailyGoal();
    setState(() {
      _entries = entries;
      _goal = goal;
    });
  }

  Future<void> _addOrEditEntry([FoodEntry? existing]) async {
    final newEntry = await showDialog<FoodEntry>(
      context: context,
      builder: (context) => FoodEntryDialog(existing: existing),
    );
    if (newEntry != null) {
      if (existing == null) {
        await _service.addEntry(widget.date, newEntry);
      } else {
        await _service.updateEntry(widget.date, newEntry);
      }
      await _loadData();
    }
  }

  Future<void> _deleteEntry(String id) async {
    await _service.removeEntry(widget.date, id);
    await _loadData();
  }

  int get _totalCalories =>
      _entries.fold(0, (sum, e) => sum + (e.calories ?? 0));

  @override
  Widget build(BuildContext context) {
    final dateStr =
        "${widget.date.year}-${widget.date.month}-${widget.date.day}";
    final remaining = _goal - _totalCalories;

    return Scaffold(
      appBar: AppBar(
        title: Text("Daily Summary - $dateStr"),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addOrEditEntry(),
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Calorie Goal: $_goal", style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 10),
            LinearProgressIndicator(
              value: _totalCalories / _goal,
              backgroundColor: Colors.grey.shade300,
              color: Colors.green,
              minHeight: 10,
            ),
            const SizedBox(height: 8),
            Text(
              "$_totalCalories / $_goal kcal",
              style: const TextStyle(fontSize: 16),
            ),
            Text(
              remaining >= 0
                  ? "Remaining: $remaining kcal"
                  : "Over by ${-remaining} kcal",
              style: TextStyle(
                fontSize: 16,
                color: remaining >= 0 ? Colors.black : Colors.red,
              ),
            ),
            const Divider(height: 30),
            Expanded(
              child: _entries.isEmpty
                  ? const Center(child: Text("No entries yet!"))
                  : ListView.builder(
                itemCount: _entries.length,
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  return Card(
                    child: ListTile(
                      title: Text(e.name),
                      subtitle: Text("${e.calories} kcal — ${e.time}"),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _addOrEditEntry(e),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteEntry(e.id),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
