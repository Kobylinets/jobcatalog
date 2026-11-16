import 'package:flutter/material.dart';

import '../../core/auth_error_messages.dart';
import '../../core/auth_validators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui_messages.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../repositories/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AuthRepository();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _repository.signUp(
        name: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      await showAppMessage(
        context,
        title: 'Реєстрація успішна',
        message: 'Ваш акаунт створено у Firebase Authentication.',
      );
      if (!mounted) return;
      // Повертаємося до AuthGate, який сам відкриє DashboardScreen.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      await showAppMessage(
        context,
        title: 'Помилка реєстрації',
        message: authErrorMessage(error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _fieldLabel(String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        value,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Реєстрація',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                      'Заповніть інформацію нижче, щоб створити свій профіль у Job Catalog.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    _fieldLabel('Ім’я користувача'),
                    AppTextField(
                      hintText: 'Введіть ваше ім’я',
                      controller: _nameController,
                      keyboardType: TextInputType.name,
                      validator: AuthValidators.name,
                    ),
                    const SizedBox(height: 20),
                    _fieldLabel('Електронна пошта'),
                    AppTextField(
                      hintText: 'Введіть електронну пошту',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 20),
                    _fieldLabel('Пароль'),
                    AppTextField(
                      hintText: 'Введіть пароль',
                      controller: _passwordController,
                      isPassword: true,
                      validator: AuthValidators.newPassword,
                    ),
                    const SizedBox(height: 20),
                    _fieldLabel('Підтвердження пароля'),
                    AppTextField(
                      hintText: 'Повторіть пароль',
                      controller: _confirmController,
                      isPassword: true,
                      validator: (value) => AuthValidators.confirmation(
                        value,
                        _passwordController.text,
                      ),
                    ),
                    const SizedBox(height: 14),
                    const Text(
                      'Пароль повинен містити щонайменше 6 символів.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AppPrimaryButton(
                      text: _isLoading ? 'ЗАЧЕКАЙТЕ...' : 'СТВОРИТИ АКАУНТ',
                      onPressed: _isLoading ? null : _register,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
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
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).pop(),
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
      ),
    );
  }
}
