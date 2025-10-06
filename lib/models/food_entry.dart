class FoodEntry {
  final String id;
  final String name;
  final int calories;
  final String time; // format like "08:30"

  FoodEntry({
    required this.id,
    required this.name,
    required this.calories,
    required this.time,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'calories': calories,
    'time': time,
  };

  static FoodEntry fromJson(Map<String, dynamic> json) => FoodEntry(
    id: json['id'],
    name: json['name'],
    calories: json['calories'],
    time: json['time'] ?? '',
  );
}
