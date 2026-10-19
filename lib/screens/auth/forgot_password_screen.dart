import 'package:flutter/material.dart';

import '../../core/auth_error_messages.dart';
import '../../core/auth_validators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui_messages.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _repository = AuthRepository();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _resetPassword() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _repository.resetPassword(email: _emailController.text);
      if (!mounted) return;
      await showAppMessage(
        context,
        title: 'Відновлення пароля',
        message: 'Якщо для цієї пошти існує акаунт, '
            'ви отримаєте лист із посиланням для скидання пароля. '
            'Перевірте також папку «Спам».',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      await showAppMessage(
        context,
        title: 'Помилка відновлення',
        message: authErrorMessage(error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Відновлення пароля'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.white,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE9DFFF),
                        borderRadius: BorderRadius.circular(50),
                      ),
                      child: const Icon(Icons.mark_email_read_outlined, size: 48, color: AppColors.primary),
                    ),
                    const SizedBox(height: 30),
                    const Text('Забули пароль?',
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    const SizedBox(height: 14),
                    const Text(
                      'Введіть електронну пошту, пов’язану з вашим акаунтом, '
                      'щоб отримати лист для відновлення пароля.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 36),
                    const Align(
                      alignment: Alignment.centerLeft,
                      child: Text('Електронна пошта', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    ),
                    const SizedBox(height: 10),
                    AppTextField(
                      hintText: 'Введіть електронну пошту',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email_outlined,
                      validator: AuthValidators.email,
                    ),
                    const SizedBox(height: 30),
                    AppPrimaryButton(
                      text: _isLoading ? 'НАДСИЛАННЯ...' : 'ВІДНОВИТИ ПАРОЛЬ',
                      onPressed: _isLoading ? null : _resetPassword,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 14),
                      const CircularProgressIndicator(color: AppColors.primary),
                    ],
                    const SizedBox(height: 24),
                    TextButton.icon(
                      onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back, size: 18),
                      label: const Text('Повернутися до входу'),
                    ),
                    const SizedBox(height: 25),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Лист надсилається через Firebase Authentication. '
                              'Для отримання посилання потрібен доступ до поштової скриньки.',
                              style: TextStyle(fontSize: 12, height: 1.5, color: AppColors.textSecondary),
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
      ),
    );
  }
}
