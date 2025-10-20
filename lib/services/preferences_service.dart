import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  Future<void> saveCalorieGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('calorie_goal', goal);
  }

  Future<int?> getCalorieGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('calorie_goal');
  }
}
