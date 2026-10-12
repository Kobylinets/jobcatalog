
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_field.dart';

// Екран відновлення пароля користувача.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState
    extends State<ForgotPasswordScreen> {

  // Контролер для введення електронної пошти.
  final TextEditingController _emailController =
      TextEditingController();

  // Звільнення ресурсів контролера.
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  // Відображення повідомлення про помилку.
  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Помилка'),
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

  // Демонстраційна обробка запиту відновлення пароля.
  void _recoverPassword() {
    final String email = _emailController.text.trim();

    // Перевірка на порожнє поле.
    if (email.isEmpty) {
      _showError(
        'Будь ласка, введіть електронну пошту.',
      );
      return;
    }

    // Базова перевірка формату email.
    final RegExp emailPattern =
        RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

    if (!emailPattern.hasMatch(email)) {
      _showError(
        'Введіть коректну адресу електронної пошти.',
      );
      return;
    }

    // Демонстраційне повідомлення.
    // Реальний лист не надсилається.
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text(
            'Відновлення пароля',
          ),
          content: Text(
            'Адреса $email має правильний формат.\n\n'
            'Запит на відновлення пароля '
            'успішно перевірено в демонстраційному '
            'режимі.\n\n'
            'Лист не було надіслано, оскільки '
            'серверна авторизація не входить '
            'до завдання лабораторної роботи №3.',
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text(
          'Відновлення пароля',
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
            vertical: 32,
          ),

          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [

                  // Декоративна іконка електронної пошти.
                  Container(
                    width: 100,
                    height: 100,

                    decoration: BoxDecoration(
                      color: const Color(0xFFE9DFFF),
                      borderRadius: BorderRadius.circular(50),
                    ),

                    child: const Icon(
                      Icons.mark_email_read_outlined,
                      size: 48,
                      color: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Основний заголовок.
                  const Text(
                    'Забули пароль?',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 14),

                  // Пояснення призначення екрана.
                  const Text(
                    'Введіть електронну пошту, '
                    'пов’язану з вашим акаунтом, '
                    'щоб сформувати запит '
                    'на відновлення пароля.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Підпис текстового поля.
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Електронна пошта',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Повторно використовуване текстове поле.
                  AppTextField(
                    hintText: 'Введіть електронну пошту',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                  ),

                  const SizedBox(height: 30),

                  // Кнопка демонстраційного відновлення.
                  AppPrimaryButton(
                    text: 'ВІДНОВИТИ ПАРОЛЬ',
                    onPressed: _recoverPassword,
                  ),

                  const SizedBox(height: 24),

                  // Повернення на сторінку авторизації.
                  TextButton.icon(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },

                    icon: const Icon(
                      Icons.arrow_back,
                      size: 18,
                    ),

                    label: const Text(
                      'Повернутися до входу',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),

                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Інформаційний блок.
                  Container(
                    width: double.infinity,

                    padding: const EdgeInsets.all(18),

                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
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
                          size: 22,
                          color: AppColors.primary,
                        ),

                        SizedBox(width: 12),

                        Expanded(
                          child: Text(
                            'У цій лабораторній роботі '
                            'відновлення пароля працює '
                            'в демонстраційному режимі '
                            'без надсилання листів.',
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
