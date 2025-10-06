import 'package:flutter/material.dart';
import '../theme/colors.dart';
import 'settings_screen.dart';
import 'calendar_screen.dart';
import 'recipes_screen.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF5FC),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 80),

          // Logo
          Image.asset("assets/images/logo.png", height: 180),

          const SizedBox(height: 20),

          const Text(
            "Welcome",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.w500,
              color: Color(0xFFFE7AC1),
              fontFamily: 'cursive',
            ),
          ),

          const Spacer(),

          // Bottom navigation icons
          Padding(
            padding: const EdgeInsets.only(bottom: 30),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                IconButton(
                  icon: const Icon(Icons.settings, size: 30, color: Color(0xFFFE7AC1)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.calendar_month, size: 30, color: Color(0xFFFE7AC1)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const CalendarScreen()),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.book, size: 30, color: Color(0xFFFE7AC1)),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const RecipesScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
