
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_field.dart';

// Екран реєстрації нового користувача.
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Контролери для отримання введених даних.
  final TextEditingController _nameController =
      TextEditingController();

  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // Звільнення ресурсів після закриття екрана.
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  // Відображення повідомлення про помилку.
  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Помилка заповнення'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Зрозуміло'),
            ),
          ],
        );
      },
    );
  }

  // Демонстраційна обробка реєстрації.
  Future<void> _register() async {
    final String name = _nameController.text.trim();
    final String email = _emailController.text.trim();
    final String password = _passwordController.text;
    final String confirmPassword =
        _confirmPasswordController.text;

    // Перевірка заповнення обов'язкових полів.
    if (name.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showError('Будь ласка, заповніть усі поля.');
      return;
    }

    // Проста локальна перевірка формату email.
    final emailPattern =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      _showError(
        'Введіть правильну адресу електронної пошти.',
      );
      return;
    }

    // Мінімальна довжина пароля для демонстрації.
    if (password.length < 6) {
      _showError(
        'Пароль повинен містити щонайменше 6 символів.',
      );
      return;
    }

    // Перевірка збігу паролів.
    if (password != confirmPassword) {
      _showError(
        'Пароль і підтвердження пароля не збігаються.',
      );
      return;
    }

    // Реєстрація демонстраційна:
    // жодні дані не надсилаються на сервер.
    final bool? returnToLogin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Демонстраційна реєстрація'),
          content: const Text(
            'Усі поля заповнено правильно.\n\n'
            'У лабораторній роботі №3 створення '
            'реального акаунта не виконується, '
            'тому дані не збережено.\n\n'
            'Ви можете повернутися до екрана входу.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('До входу'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;

    if (returnToLogin == true) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Реєстрація',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 28,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок.
                  const Text(
                    'Створення акаунта',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Заповніть інформацію нижче, '
                    'щоб створити свій профіль '
                    'у Job Catalog.',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Поле імені користувача.
                  const Text(
                    'Ім’я користувача',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  AppTextField(
                    hintText: 'Введіть ваше ім’я',
                    controller: _nameController,
                    keyboardType: TextInputType.name,
                  ),

                  const SizedBox(height: 20),

                  // Поле електронної пошти.
                  const Text(
                    'Електронна пошта',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  AppTextField(
                    hintText: 'Введіть електронну пошту',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 20),

                  // Поле пароля.
                  const Text(
                    'Пароль',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  AppTextField(
                    hintText: 'Введіть пароль',
                    controller: _passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: 20),

                  // Підтвердження пароля.
                  const Text(
                    'Підтвердження пароля',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 8),

                  AppTextField(
                    hintText: 'Повторіть пароль',
                    controller: _confirmPasswordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: 14),

                  const Text(
                    'Пароль повинен містити '
                    'щонайменше 6 символів.',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Кнопка реєстрації.
                  AppPrimaryButton(
                    text: 'СТВОРИТИ АКАУНТ',
                    onPressed: _register,
                  ),

                  const SizedBox(height: 24),

                  // Повернення до авторизації.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Вже маєте акаунт?',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),

                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text(
                          'Увійти',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
