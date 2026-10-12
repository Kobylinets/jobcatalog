
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_text_field.dart';
import '../../core/widgets/app_primary_button.dart';

// Екран демонстраційної зміни пароля.
class ChangePasswordScreen extends StatelessWidget {
  const ChangePasswordScreen({super.key});

  // Повідомлення про демонстраційний режим.
  void _showMessage(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Зміна пароля'),
          content: const Text(
            'Це демонстраційна форма зміни пароля.\n\n'
            'У лабораторній роботі №3 пароль '
            'фактично не змінюється, оскільки '
            'серверну авторизацію ще не підключено.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Зрозуміло'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Зміна пароля'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),

                  // Іконка безпеки.
                  Center(
                    child: Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9DFFF),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(
                        Icons.lock_outline,
                        color: AppColors.primary,
                        size: 50,
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  const Center(
                    child: Text(
                      'Захист акаунта',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  const Center(
                    child: Text(
                      'Введіть поточний пароль, '
                      'а потім новий пароль '
                      'та його підтвердження.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 35),

                  // Поточний пароль.
                  const Text(
                    'Поточний пароль',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const AppTextField(
                    hintText: 'Введіть поточний пароль',
                    isPassword: true,
                  ),

                  const SizedBox(height: 22),

                  // Новий пароль.
                  const Text(
                    'Новий пароль',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const AppTextField(
                    hintText: 'Введіть новий пароль',
                    isPassword: true,
                  ),

                  const SizedBox(height: 22),

                  // Підтвердження нового пароля.
                  const Text(
                    'Підтвердження нового пароля',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const AppTextField(
                    hintText: 'Повторіть новий пароль',
                    isPassword: true,
                  ),

                  const SizedBox(height: 35),

                  // Демонстраційна кнопка.
                  AppPrimaryButton(
                    text: 'ЗМІНИТИ ПАРОЛЬ',
                    icon: Icons.lock_reset,
                    onPressed: () {
                      _showMessage(context);
                    },
                  ),

                  const SizedBox(height: 20),

                  // Повернення до профілю.
                  Center(
                    child: TextButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 18,
                      ),
                      label: const Text(
                        'Повернутися до профілю',
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.primary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Інформаційне пояснення.
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                        color: AppColors.border,
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: AppColors.primary,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Зміна пароля представлена '
                            'лише графічним інтерфейсом. '
                            'Дані не передаються на сервер '
                            'та не зберігаються.',
                            style: TextStyle(
                              fontSize: 12,
                              height: 1.5,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
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
