
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,

      // Початковий екран застосунку.
      home: Builder(
        builder: (context) {
          return LoginScreen(
            onLogin: () {
              // Демонстраційний перехід після входу.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      const HomeScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Початковий головний екран із лабораторної №1.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Трекер пошуку роботи'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/job.jpg',
              width: 320,
              height: 320,
            ),

            const SizedBox(height: 20),

            const Text(
              'Вакансії та мої заявки',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 10),

            const Text(
              'Збережені вакансії та відповіді',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
