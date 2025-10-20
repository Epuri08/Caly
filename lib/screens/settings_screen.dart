import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'calorie_calculator_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final TextEditingController usernameController =
  TextEditingController(text: "Username123");
  final TextEditingController passwordController =
  TextEditingController(text: "password123");

  bool _obscurePassword = true;
  bool _isDarkMode = false;
  int _dailyGoal = 2000; // default goal

  @override
  void initState() {
    super.initState();
    _loadGoal(); // Load saved goal
  }

  Future<void> _loadGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyGoal = prefs.getInt('dailyGoal') ?? 2000;
    });
  }

  Future<void> _saveGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('dailyGoal', goal);
  }

  void _updateGoal(int newGoal) {
    setState(() {
      _dailyGoal = newGoal;
    });
    _saveGoal(newGoal);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
        backgroundColor: const Color(0xFFFB009A),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Text(
                "Profile",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFB009A)),
              ),
              const SizedBox(height: 20),

              // Username
              TextField(
                controller: usernameController,
                decoration: InputDecoration(
                  labelText: "Username",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Password
              TextField(
                controller: passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "Password",
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Calorie Goal Section
              const Text(
                "Daily Calorie Goal",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFFB009A)),
              ),
              const SizedBox(height: 10),
              Text("$_dailyGoal kcal",
                  style: const TextStyle(fontSize: 18, color: Colors.black87)),
              const SizedBox(height: 10),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Change Goal manually
                  ElevatedButton(
                    onPressed: () async {
                      final newGoal = await showDialog<int>(
                        context: context,
                        builder: (context) {
                          final controller = TextEditingController(
                              text: _dailyGoal.toString());
                          return AlertDialog(
                            title: const Text("Change Calorie Goal"),
                            content: TextField(
                              controller: controller,
                              keyboardType: TextInputType.number,
                              decoration: const InputDecoration(
                                  labelText: "Enter new goal (kcal)"),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    final value =
                                    int.tryParse(controller.text);
                                    Navigator.pop(context, value);
                                  },
                                  child: const Text("Save")),
                            ],
                          );
                        },
                      );
                      if (newGoal != null) _updateGoal(newGoal);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFB009A),
                        foregroundColor: Colors.white),
                    child: const Text("Change Goal"),
                  ),
                  const SizedBox(width: 15),

                  // Figure It Out button
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                            const CalorieCalculatorScreen()),
                      );
                      if (result != null && result is int) {
                        _updateGoal(result);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: const Color(0xFFFB009A),
                        side: const BorderSide(color: Color(0xFFFB009A))),
                    child: const Text("Calculate It"),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              const SizedBox(height: 20),

              ListTile(
                leading: const Icon(Icons.dark_mode, color: Color(0xFFFB009A)),
                title: const Text("Dark Mode"),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (val) {
                    setState(() => _isDarkMode = val);
                  },
                  activeColor: const Color(0xFFFB085A),
                ),
              ),

              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFFB009A)),
                title: const Text("Log Out"),
                onTap: () {
                  // TODO: Add logout logic
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
