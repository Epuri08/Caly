import 'package:flutter/material.dart';
import 'package:percent_indicator/percent_indicator.dart';
import '../services/calendar_service.dart';
import '../models/food_entry.dart';

class DayDetailScreen extends StatefulWidget {
  final DateTime date;
  const DayDetailScreen({required this.date, super.key});

  @override
  State<DayDetailScreen> createState() => _DayDetailScreenState();
}

class _DayDetailScreenState extends State<DayDetailScreen> {
  final CalendarService _service = CalendarService();
  List<FoodEntry> _entries = [];
  int _dailyGoal = 2000;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final entries = await _service.getEntriesFor(widget.date);
    final goal = await _service.getDailyGoal();
    setState(() {
      _entries = entries;
      _dailyGoal = goal;
    });
  }

  int get _consumed => _entries.fold(0, (s, e) => s + e.calories);
  int get _left => (_dailyGoal - _consumed).clamp(0, _dailyGoal);

  Future<void> _openAddDialog({FoodEntry? existing}) async {
    final nameCtrl = TextEditingController(text: existing?.name ?? '');
    final calCtrl = TextEditingController(
      text: existing != null ? '${existing.calories}' : '',
    );

    // --- Add time support ---
    TimeOfDay chosen = TimeOfDay.now();
    if (existing != null && existing.time.isNotEmpty) {
      final parts = existing.time.split(':');
      if (parts.length == 2) {
        chosen = TimeOfDay(
          hour: int.tryParse(parts[0]) ?? 0,
          minute: int.tryParse(parts[1]) ?? 0,
        );
      }
    }

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setInnerState) => AlertDialog(
          title: Text(existing == null ? 'Add Entry' : 'Edit Entry'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: calCtrl,
                decoration: const InputDecoration(labelText: 'Calories'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text('Time: ${chosen.format(context)}'),
                  const Spacer(),
                  TextButton(
                    onPressed: () async {
                      final t = await showTimePicker(
                        context: context,
                        initialTime: chosen,
                      );
                      if (t != null) {
                        setInnerState(() => chosen = t);
                      }
                    },
                    child: const Text('Pick time'),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final name = nameCtrl.text.trim();
                final cal = int.tryParse(calCtrl.text.trim()) ?? 0;
                final time =
                    '${chosen.hour.toString().padLeft(2, '0')}:${chosen.minute.toString().padLeft(2, '0')}';

                if (name.isEmpty || cal <= 0) return;

                if (existing == null) {
                  final newEntry = FoodEntry(
                    id: DateTime.now()
                        .millisecondsSinceEpoch
                        .toString(),
                    name: name,
                    calories: cal,
                    time: time,
                  );
                  await _service.addEntry(widget.date, newEntry);
                } else {
                  final updated = FoodEntry(
                    id: existing.id,
                    name: name,
                    calories: cal,
                    time: time,
                  );
                  await _service.updateEntry(widget.date, updated);
                }

                await _load();
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _deleteEntry(String id) async {
    await _service.removeEntry(widget.date, id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final percent = (_consumed / _dailyGoal).clamp(0.0, 1.0);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFFFF5FC),
        iconTheme: const IconThemeData(color: Color(0xFFFE7AC1)),
        title: Text(
          '${widget.date.month}/${widget.date.day}/${widget.date.year}',
          style: const TextStyle(
            color: Color(0xFFFE7AC1),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      backgroundColor: const Color(0xFFFFF5FC),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            // Add / Edit buttons row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => _openAddDialog(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC0E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    fixedSize: const Size(120, 120),
                  ),
                  child: const Icon(Icons.add,
                      size: 40, color: Colors.black87),
                ),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text('Tap an entry below to edit'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFFC0E6),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    fixedSize: const Size(120, 120),
                  ),
                  child: const Icon(Icons.edit,
                      size: 40, color: Colors.black87),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Circular calories progress
            CircularPercentIndicator(
              radius: 120.0,
              lineWidth: 16.0,
              percent: percent,
              center: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$_left',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Text('cal left'),
                ],
              ),
              progressColor: const Color(0xFFFF77C0),
              backgroundColor: const Color(0xFFFEDDF0),
              animation: true,
            ),

            const SizedBox(height: 20),

            // Entry list
            Expanded(
              child: _entries.isEmpty
                  ? const Center(
                child: Text('No entries for this day'),
              )
                  : ListView.separated(
                itemCount: _entries.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, i) {
                  final e = _entries[i];
                  return ListTile(
                    title: Text(
                        '${e.calories} cal  —  ${e.name}'),
                    subtitle: Text(e.time.isNotEmpty
                        ? 'Time: ${e.time}'
                        : 'Time: --:--'),
                    onTap: () => _openAddDialog(existing: e),
                    onLongPress: () => showDialog(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete entry?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context),
                              child: const Text('Cancel')),
                          TextButton(
                            onPressed: () async {
                              await _deleteEntry(e.id);
                              Navigator.pop(context);
                            },
                            child: const Text('Delete',
                                style: TextStyle(
                                    color: Colors.red)),
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
