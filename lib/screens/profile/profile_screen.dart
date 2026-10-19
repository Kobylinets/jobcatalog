import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/auth_error_messages.dart';
import '../../core/auth_validators.dart';
import '../../core/theme/app_theme.dart';
import '../../core/ui_messages.dart';
import '../../core/widgets/app_primary_button.dart';
import '../../repositories/auth_repository.dart';
import 'change_password_screen.dart';

// Збережено дизайн ЛР №3: обкладинка, аватар, контакти, резюме, навички,
// нижня панель навігації. Додано редагування профілю та вихід через Firebase.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _repository = AuthRepository();
  bool _isLoading = false;

  static const List<String> _avatarUrls = [
    'https://i.pravatar.cc/300?img=12',
    'https://i.pravatar.cc/300?img=47',
    'https://i.pravatar.cc/300?img=5',
    'https://i.pravatar.cc/300?img=32',
  ];

  User? get _user => _repository.currentUser;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    try {
      await _repository.reloadUser();
      if (mounted) setState(() {});
    } catch (_) {
      // Кешовані дані профілю залишаються доступними без мережі.
    }
  }

  Future<void> _performAction(Future<void> Function() action, String success) async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      await action();
      if (!mounted) return;
      setState(() {});
      await showAppMessage(context, title: 'Готово', message: success);
    } catch (error) {
      if (!mounted) return;
      await showAppMessage(
        context,
        title: 'Помилка',
        message: authErrorMessage(error),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _editName() async {
    final formKey = GlobalKey<FormState>();
    String enteredName = _user?.displayName ?? '';
    final name = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Змінити ім’я'),
        content: Form(
          key: formKey,
          child: TextFormField(
            initialValue: enteredName,
            onChanged: (text) => enteredName = text,
            autofocus: true,
            decoration: const InputDecoration(labelText: 'Ваше ім’я'),
            validator: AuthValidators.name,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(dialogContext).pop(enteredName.trim());
              }
            },
            child: const Text('Зберегти'),
          ),
        ],
      ),
    );
    if (!mounted || name == null) return;
    await _performAction(
      () => _repository.updateName(name),
      'Ім’я користувача оновлено у Firebase.',
    );
  }

  Future<void> _selectAvatar() async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Оберіть аватар',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              const Text('Фото з готових HTTPS-посилань (за методичкою ЛР №4).',
                  textAlign: TextAlign.center),
              const SizedBox(height: 18),
              Wrap(
                spacing: 16,
                runSpacing: 16,
                alignment: WrapAlignment.center,
                children: _avatarUrls.map((url) {
                  return InkWell(
                    onTap: () => Navigator.of(sheetContext).pop(url),
                    borderRadius: BorderRadius.circular(45),
                    child: CircleAvatar(
                      radius: 38,
                      backgroundColor: const Color(0xFFE8DEFF),
                      child: ClipOval(
                        child: Image.network(
                          url,
                          width: 76,
                          height: 76,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.person, size: 42, color: AppColors.primary),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
            ],
          ),
        ),
      ),
    );
    if (!mounted || selected == null) return;
    await _performAction(
      () => _repository.updatePhoto(selected),
      'Аватар успішно збережено у Firebase.',
    );
  }

  Future<void> _signOut() async {
    if (_isLoading) return;
    final approved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Вийти з акаунта?'),
        content: const Text('Після виходу для доступу до профілю потрібно буде увійти знову.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Скасувати'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );
    if (!mounted || approved != true) return;
    setState(() => _isLoading = true);
    try {
      await _repository.signOut();
      if (!mounted) return;
      // Прибираємо ProfileScreen з історії переходів.
      // AuthGate на кореневому екрані вже показує LoginScreen.
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (error) {
      if (!mounted) return;
      await showAppMessage(context, title: 'Помилка виходу', message: authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Лише для захисту лабораторної: без аварійного завершення застосунку.
  Future<void> _sendTestCrash() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      FirebaseCrashlytics.instance.crash();
      await FirebaseCrashlytics.instance.sendUnsentReports();
      if (!mounted) return;
      await showAppMessage(
        context,
        title: 'Тестову помилку зареєстровано',
        message: 'Перевірте Firebase Console → Crashlytics → Issues. '
            'Звіт може з’явитися з затримкою; іноді потрібен перезапуск застосунку.',
      );
    } catch (error) {
      if (!mounted) return;
      await showAppMessage(context, title: 'Помилка Crashlytics', message: authErrorMessage(error));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _openChangePassword() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ChangePasswordScreen()),
    );
  }

  Widget _contactIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E9FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(icon, color: AppColors.primary),
    );
  }

  Widget _skill(String name, int percent, Color color) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          SizedBox(
            width: 65,
            height: 65,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 60,
                  height: 60,
                  child: CircularProgressIndicator(
                    value: percent / 100,
                    strokeWidth: 6,
                    backgroundColor: AppColors.border,
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text('$percent%',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              ],
            ),
          ),
          const SizedBox(height: 7),
          Text(name, textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: AppColors.textPrimary)),
        ],
      ),
    );
  }

  Widget _avatar() {
    final photoUrl = _user?.photoURL;
    return CircleAvatar(
      radius: 49,
      backgroundColor: Colors.white,
      child: CircleAvatar(
        radius: 44,
        backgroundColor: const Color(0xFFE8DEFF),
        child: photoUrl == null || photoUrl.isEmpty
            ? const Icon(Icons.person, color: AppColors.primary, size: 57)
            : ClipOval(
                child: Image.network(
                  photoUrl,
                  width: 88,
                  height: 88,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) =>
                      const Icon(Icons.person, color: AppColors.primary, size: 57),
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = (_user?.displayName?.trim().isNotEmpty ?? false)
        ? _user!.displayName!
        : 'Користувач Job Catalog';
    final email = _user?.email ?? 'Email не вказано';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Акаунт'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Вийти з акаунта',
            onPressed: _isLoading ? null : _signOut,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.only(bottom: 24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Column(
              children: [
                SizedBox(
                  height: 170,
                  child: Stack(
                    children: [
                      Container(
                        height: 115,
                        decoration: const BoxDecoration(
                          color: Color(0xFF25212F),
                          borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
                        ),
                        child: const Center(
                          child: Icon(Icons.code, size: 65, color: AppColors.primaryLight),
                        ),
                      ),
                      Positioned(
                        top: 73,
                        left: 0,
                        right: 0,
                        child: Center(child: _avatar()),
                      ),
                    ],
                  ),
                ),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 5),
                Text(email, textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
                const SizedBox(height: 8),
                const Text('Програміст',
                    style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Студент спеціальності «Інженерія програмного забезпечення». '
                    'Цікавлюся розробкою програмного забезпечення та сучасними '
                    'технологіями програмування.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, height: 1.5, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 22),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _contactIcon(Icons.phone_outlined),
                    _contactIcon(Icons.email_outlined),
                    _contactIcon(Icons.location_on_outlined),
                  ],
                ),
                const SizedBox(height: 20),
                // Невеликий блок керування реальними Firebase-даними.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    alignment: WrapAlignment.center,
                    children: [
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _editName,
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: const Text('Змінити ім’я'),
                      ),
                      OutlinedButton.icon(
                        onPressed: _isLoading ? null : _selectAvatar,
                        icon: const Icon(Icons.photo_camera_outlined, size: 18),
                        label: const Text('Змінити фото'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 22),
                // Демонстраційне резюме з попередньої лабораторної.
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: InkWell(
                    onTap: () => showAppMessage(
                      context,
                      title: 'Job Catalog',
                      message: 'Перегляд резюме буде реалізовано в наступній лабораторній.',
                    ),
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.description_outlined, color: Colors.white, size: 30),
                          SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Моє резюме', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                                SizedBox(height: 4),
                                Text('Файл: Resume.pdf', style: TextStyle(color: Colors.white70, fontSize: 12)),
                              ],
                            ),
                          ),
                          Icon(Icons.chevron_right, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Навички',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
                  ),
                ),
                const SizedBox(height: 18),
                // Демонстраційна статистика навичок, поки без Firestore.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7,
                  runSpacing: 18,
                  children: [
                    _skill('PHP', 86, const Color(0xFFFF873D)),
                    _skill('Java', 48, const Color(0xFF4DBB77)),
                    _skill('MySQL', 55, const Color(0xFF42A5F5)),
                    _skill('React Native', 34, const Color(0xFFDD5FBE)),
                    _skill('CSS', 82, AppColors.primary),
                  ],
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: AppPrimaryButton(
                    text: 'ЗМІНИТИ ПАРОЛЬ',
                    icon: Icons.lock_outline,
                    onPressed: _isLoading ? null : _openChangePassword,
                  ),
                ),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('ВИЙТИ З АКАУНТА'),
                      style: OutlinedButton.styleFrom(foregroundColor: AppColors.error),
                    ),
                  ),
                ),
                if (_isLoading) ...[
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(color: AppColors.primary),
                ],
                if (kDebugMode) ...[
                  const SizedBox(height: 18),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: TextButton.icon(
                      onPressed: _isLoading ? null : _sendTestCrash,
                      icon: const Icon(Icons.bug_report_outlined),
                      label: const Text('Надіслати тестову помилку (ЛР №4)'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8DFFF),
        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.of(context).pop();
          } else if (index != 3) {
            showAppMessage(
              context,
              title: 'Job Catalog',
              message: 'Цей розділ буде реалізовано пізніше.',
            );
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Дім'),
          NavigationDestination(icon: Icon(Icons.calendar_month_outlined), label: 'Інтерв’ю'),
          NavigationDestination(icon: Icon(Icons.mail_outline), label: 'Сповіщення'),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person, color: AppColors.primary),
            label: 'Акаунт',
          ),
        ],
      ),
    );
  }
}
