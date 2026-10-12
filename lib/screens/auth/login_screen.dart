
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_field.dart';

import 'register_screen.dart';
import 'forgot_password_screen.dart';

// Екран авторизації користувача.
class LoginScreen extends StatefulWidget {
  final VoidCallback onLogin;

  const LoginScreen({
    super.key,
    required this.onLogin,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {

  // Контролери полів авторизації.
  final TextEditingController _emailController =
      TextEditingController();

  final TextEditingController _passwordController =
      TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Повідомлення для демонстраційних функцій.
  void _showInfo(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(title),
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

  // Демонстраційні кнопки Google та Facebook.
  Widget _buildSocialButton({
    required String symbol,
    required Color color,
    required String provider,
  }) {
    return SizedBox(
      width: 84,
      height: 48,

      child: OutlinedButton(
        onPressed: () {
          _showInfo(
            provider,
            'Авторизацію через $provider буде реалізовано '
            'на наступних етапах розроблення.',
          );
        },

        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,

          side: const BorderSide(
            color: AppColors.border,
          ),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),

        child: Text(
          symbol,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

  // Відкриття екрана реєстрації.
  void _openRegisterScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) => const RegisterScreen(),
      ),
    );
  }

  // Відкриття екрана відновлення пароля.
  void _openForgotPasswordScreen() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (context) =>
            const ForgotPasswordScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: true,

        title: const Text(
          'Job Catalog',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
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
                    'Вхід',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    'Будь ласка, увійдіть у ваш '
                    'зареєстрований акаунт',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Електронна пошта.
                  AppTextField(
                    hintText: 'Електронна пошта',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),

                  const SizedBox(height: 16),

                  // Пароль.
                  AppTextField(
                    hintText: 'Пароль',
                    controller: _passwordController,
                    isPassword: true,
                  ),

                  const SizedBox(height: 24),

                  // Вхід на головний екран.
                  AppPrimaryButton(
                    text: 'ВХІД',
                    onPressed: widget.onLogin,
                  ),

                  const SizedBox(height: 20),

                  // Відновлення пароля.
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Забули ваш пароль?',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      TextButton(
                        onPressed: _openForgotPasswordScreen,

                        child: const Text(
                          'Скинути пароль',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Роздільник соціальної авторизації.
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(),
                      ),

                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12,
                        ),
                        child: Text(
                          'Увійти за допомогою',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),

                      Expanded(
                        child: Divider(),
                      ),
                    ],
                  ),

                  const SizedBox(height: 22),

                  // Google та Facebook.
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton(
                        symbol: 'G',
                        color: const Color(0xFF4285F4),
                        provider: 'Google',
                      ),

                      const SizedBox(width: 20),

                      _buildSocialButton(
                        symbol: 'f',
                        color: const Color(0xFF1877F2),
                        provider: 'Facebook',
                      ),
                    ],
                  ),

                  const SizedBox(height: 38),

                  // Створення нового акаунта.
                  SizedBox(
                    width: double.infinity,
                    height: 50,

                    child: ElevatedButton(
                      onPressed: _openRegisterScreen,

                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFFE5D9FF),
                        foregroundColor: AppColors.primary,
                        elevation: 0,

                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(25),
                        ),
                      ),

                      child: const Text(
                        'СТВОРИТИ АКАУНТ',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
