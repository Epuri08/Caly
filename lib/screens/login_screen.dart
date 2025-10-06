import 'package:flutter/material.dart';
import '../theme/colors.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.pinkPrimary,
                shape: BoxShape.circle, // makes it circular
              ),
              padding: const EdgeInsets.all(8),
              child: Image.asset(
                "assets/images/back_icon.png", // 👈 put your uploaded image here
                //color: Colors.white, // makes image white-ish (remove if not needed)
              ),
            ),
          ),
        ),
        title: const Text(
          "Login",
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: Text(
          "This is the Login Page",
          style: TextStyle(fontSize: 22, color: AppColors.pinkPrimary),
        ),
      ),
    );
  }
}
