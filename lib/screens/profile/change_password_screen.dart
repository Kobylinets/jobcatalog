import 'package:flutter/material.dart';

import '../../core/auth_error_messages.dart';
import '../../core/auth_validators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui_messages.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../core/widgets/app_text_field.dart';
import '../../repositories/auth_repository.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _repository = AuthRepository();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _changePassword() async {
    if (_isLoading || !_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await _repository.changePassword(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
      );
      if (!mounted) return;
      await showAppMessage(
        context,
        title: 'Пароль змінено',
        message: 'Новий пароль успішно збережено у Firebase Authentication.',
      );
      if (!mounted) return;
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      await showAppMessage(
        context,
        title: 'Помилка зміни пароля',
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
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9DFFF),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: const Icon(Icons.lock_outline, color: AppColors.primary, size: 50),
                      ),
                    ),
                    const SizedBox(height: 28),
                    const Center(
                      child: Text('Захист акаунта',
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 12),
                    const Center(
                      child: Text(
                        'Введіть поточний пароль, а потім новий пароль та його підтвердження.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textSecondary),
                      ),
                    ),
                    const SizedBox(height: 35),
                    const Text('Поточний пароль', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    AppTextField(
                      hintText: 'Введіть поточний пароль',
                      controller: _currentController,
                      isPassword: true,
                      validator: AuthValidators.loginPassword,
                    ),
                    const SizedBox(height: 22),
                    const Text('Новий пароль', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    AppTextField(
                      hintText: 'Введіть новий пароль',
                      controller: _newController,
                      isPassword: true,
                      validator: AuthValidators.newPassword,
                    ),
                    const SizedBox(height: 22),
                    const Text('Підтвердження нового пароля', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    const SizedBox(height: 10),
                    AppTextField(
                      hintText: 'Повторіть новий пароль',
                      controller: _confirmController,
                      isPassword: true,
                      validator: (value) => AuthValidators.confirmation(value, _newController.text),
                    ),
                    const SizedBox(height: 35),
                    AppPrimaryButton(
                      text: _isLoading ? 'ЗАЧЕКАЙТЕ...' : 'ЗМІНИТИ ПАРОЛЬ',
                      icon: Icons.lock_reset,
                      onPressed: _isLoading ? null : _changePassword,
                    ),
                    if (_isLoading) ...[
                      const SizedBox(height: 16),
                      const Center(child: CircularProgressIndicator(color: AppColors.primary)),
                    ],
                    const SizedBox(height: 20),
                    Center(
                      child: TextButton.icon(
                        onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back, size: 18),
                        label: const Text('Повернутися до профілю'),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primary),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Firebase перевіряє поточний пароль, повторно підтверджує особу '
                              'та лише після цього змінює пароль.',
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
