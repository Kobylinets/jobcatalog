import 'package:flutter/material.dart';

import '../../core/auth_error_messages.dart';
import '../../core/auth_validators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui_messages.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../repositories/auth_repository.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  // Необов'язковий параметр збережено для сумісності з кодом ЛР №3.
  final VoidCallback? onLogin;
  const LoginScreen({super.key, this.onLogin});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _repository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _repository.signIn(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) return;
      // AuthGate автоматично покаже DashboardScreen після успішного входу.
      widget.onLogin?.call();
    } catch (error) {
      if (!mounted) return;
      await showAppMessage(
        context,
        title: 'Помилка входу',
        message: authErrorMessage(error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _socialButton({
    required String text,
    required Color color,
    required String provider,
  }) {
    return SizedBox(
      width: 84,
      height: 48,
      child: OutlinedButton(
        onPressed: _isLoading
            ? null
            : () => showAppMessage(
                context,
                title: provider,
                message:
                    'Соціальний вхід поки демонстраційний. '
                    'Для лабораторної №4 реалізовано Email/Password.',
              ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: AppColors.border),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: color,
          ),
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
          'Job Catalog',
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
                      'Вхід',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Будь ласка, увійдіть у ваш зареєстрований акаунт',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 30),
                    AppTextField(
                      hintText: 'Електронна пошта',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 16),
                    AppTextField(
                      hintText: 'Пароль',
                      controller: _passwordController,
                      isPassword: true,
                      validator: AuthValidators.loginPassword,
                    ),
                    const SizedBox(height: 24),
                    AppPrimaryButton(
                      text: _isLoading ? 'ЗАЧЕКАЙТЕ...' : 'ВХІД',
                      onPressed: _isLoading ? null : _signIn,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                          onPressed: _isLoading
                              ? null
                              : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) =>
                                        const ForgotPasswordScreen(),
                                  ),
                                ),
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
                    const Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Увійти за допомогою',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                        Expanded(child: Divider()),
                      ],
                    ),
                    const SizedBox(height: 22),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _socialButton(
                          text: 'G',
                          color: const Color(0xFF4285F4),
                          provider: 'Google',
                        ),
                        const SizedBox(width: 20),
                        _socialButton(
                          text: 'f',
                          color: const Color(0xFF1877F2),
                          provider: 'Facebook',
                        ),
                      ],
                    ),
                    const SizedBox(height: 38),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () => Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5D9FF),
                          foregroundColor: AppColors.primary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
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
      ),
    );
  }
}
