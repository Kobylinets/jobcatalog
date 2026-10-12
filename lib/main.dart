
import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/dashboard/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      // Загальна тема застосунку.
      theme: AppTheme.lightTheme,

      // Початковий екран авторизації.
      home: Builder(
        builder: (context) {
          return LoginScreen(
            onLogin: () {
              // Демонстраційний перехід
              // на новий дашборд після входу.
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (context) =>
                      const DashboardScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// Початковий екран з лабораторної роботи №1.
// Залишаємо для збереження попередньої реалізації.
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
