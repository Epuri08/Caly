import 'package:flutter/material.dart';

class CalorieCalculatorScreen extends StatefulWidget {
  const CalorieCalculatorScreen({super.key});

  @override
  State<CalorieCalculatorScreen> createState() =>
      _CalorieCalculatorScreenState();
}

class _CalorieCalculatorScreenState extends State<CalorieCalculatorScreen> {
  String _gender = "Male";
  double _weight = 0; // in kg
  double _height = 0; // in cm
  int _age = 0;
  String _activity = "Sedentary";
  double _calculatedCalories = 0;

  void _calculate() {
    double bmr;

    // ✅ Correct Mifflin-St Jeor formula
    if (_gender == "Male") {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age + 5;
    } else {
      bmr = 10 * _weight + 6.25 * _height - 5 * _age - 161;
    }

    double multiplier;
    switch (_activity) {
      case "Lightly Active":
        multiplier = 1.375;
        break;
      case "Moderately Active":
        multiplier = 1.55;
        break;
      case "Very Active":
        multiplier = 1.725;
        break;
      case "Extremely Active":
        multiplier = 1.9;
        break;
      default:
        multiplier = 1.2;
    }

    setState(() {
      _calculatedCalories = bmr * multiplier;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Figure Out Calorie Goal"),
        backgroundColor: const Color(0xFFFB009A),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: SingleChildScrollView( // ✅ Prevent overflow on small screens
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DropdownButtonFormField<String>(
                value: _gender,
                decoration: const InputDecoration(labelText: "Gender"),
                items: const [
                  DropdownMenuItem(value: "Male", child: Text("Male")),
                  DropdownMenuItem(value: "Female", child: Text("Female")),
                ],
                onChanged: (val) => setState(() => _gender = val!),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Weight (kg)"),
                keyboardType: TextInputType.number,
                onChanged: (val) =>
                    setState(() => _weight = double.tryParse(val) ?? 0),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Height (cm)"),
                keyboardType: TextInputType.number,
                onChanged: (val) =>
                    setState(() => _height = double.tryParse(val) ?? 0),
              ),
              TextField(
                decoration: const InputDecoration(labelText: "Age (years)"),
                keyboardType: TextInputType.number,
                onChanged: (val) =>
                    setState(() => _age = int.tryParse(val) ?? 0),
              ),
              DropdownButtonFormField<String>(
                value: _activity,
                decoration: const InputDecoration(labelText: "Activity Level"),
                items: const [
                  DropdownMenuItem(value: "Sedentary", child: Text("Sedentary")),
                  DropdownMenuItem(
                      value: "Lightly Active", child: Text("Lightly Active")),
                  DropdownMenuItem(
                      value: "Moderately Active",
                      child: Text("Moderately Active")),
                  DropdownMenuItem(
                      value: "Very Active", child: Text("Very Active")),
                  DropdownMenuItem(
                      value: "Extremely Active", child: Text("Extremely Active")),
                ],
                onChanged: (val) => setState(() => _activity = val!),
              ),
              const SizedBox(height: 25),
              Center(
                child: ElevatedButton(
                  onPressed: _calculate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFB009A),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 12),
                  ),
                  child: const Text("Calculate"),
                ),
              ),
              const SizedBox(height: 25),

              // ✅ Always show calculated calories
              Center(
                child: Text(
                  _calculatedCalories > 0
                      ? "Estimated Calorie Goal: ${_calculatedCalories.toStringAsFixed(0)} kcal"
                      : "Enter your info and press Calculate",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: _calculatedCalories > 0
                        ? Colors.black
                        : Colors.grey.shade600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              if (_calculatedCalories > 0) ...[
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _calculatedCalories.toInt());
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFFFB009A),
                      side: const BorderSide(color: Color(0xFFFB009A)),
                    ),
                    child: const Text("Use This Goal"),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
