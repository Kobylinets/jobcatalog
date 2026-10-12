
import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import '../../core/widgets/app_primary_button.dart';
import 'change_password_screen.dart';

// Екран профілю користувача.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  // Демонстраційне інформаційне повідомлення.
  void _showInfo(BuildContext context, String message) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Job Catalog'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
            },
            child: const Text('Зрозуміло'),
          ),
        ],
      ),
    );
  }

  // Перехід до екрана зміни пароля.
  void _openChangePassword(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ChangePasswordScreen(),
      ),
    );
  }

  // Піктограма контактної інформації.
  Widget _contactIcon(IconData icon) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: const Color(0xFFF0E9FF),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Icon(
        icon,
        color: AppColors.primary,
      ),
    );
  }

  // Круговий індикатор навички.
  Widget _skill(
    String name,
    int percent,
    Color color,
  ) {
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
                    valueColor:
                        AlwaysStoppedAnimation<Color>(color),
                  ),
                ),
                Text(
                  '$percent%',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 7),

          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        title: const Text('Акаунт'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
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
                // Верхня обкладинка та аватар.
                SizedBox(
                  height: 170,
                  child: Stack(
                    children: [
                      Container(
                        height: 115,
                        decoration: const BoxDecoration(
                          color: Color(0xFF25212F),
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(22),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.code,
                            size: 65,
                            color: AppColors.primaryLight,
                          ),
                        ),
                      ),

                      const Positioned(
                        top: 73,
                        left: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 49,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 44,
                            backgroundColor: Color(0xFFE8DEFF),
                            child: Icon(
                              Icons.person,
                              color: AppColors.primary,
                              size: 57,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Ім'я користувача.
                const Text(
                  'Іван Кобилінець',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),

                const SizedBox(height: 5),

                // Професія.
                const Text(
                  'Програміст',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),

                const SizedBox(height: 16),

                // Інформація про користувача.
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24,
                  ),
                  child: Text(
                    'Студент спеціальності '
                    '«Інженерія програмного забезпечення». '
                    'Цікавлюся розробкою програмного '
                    'забезпечення та сучасними '
                    'технологіями програмування.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),

                const SizedBox(height: 22),

                // Контактні піктограми.
                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceEvenly,
                  children: [
                    _contactIcon(Icons.phone_outlined),
                    _contactIcon(Icons.email_outlined),
                    _contactIcon(Icons.location_on_outlined),
                  ],
                ),

                const SizedBox(height: 25),

                // Демонстраційна картка резюме.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: InkWell(
                    onTap: () {
                      _showInfo(
                        context,
                        'Перегляд резюме буде '
                        'реалізовано пізніше.',
                      );
                    },
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
                          Icon(
                            Icons.description_outlined,
                            color: Colors.white,
                            size: 30,
                          ),

                          SizedBox(width: 15),

                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Моє резюме',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  'Файл: Resume.pdf',
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Icon(
                            Icons.chevron_right,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // Заголовок секції навичок.
                const Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Навички',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // Демонстраційні навички користувача.
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 7,
                  runSpacing: 18,
                  children: [
                    _skill(
                      'PHP',
                      86,
                      const Color(0xFFFF873D),
                    ),

                    _skill(
                      'Java',
                      48,
                      const Color(0xFF4DBB77),
                    ),

                    _skill(
                      'MySQL',
                      55,
                      const Color(0xFF42A5F5),
                    ),

                    _skill(
                      'React Native',
                      34,
                      const Color(0xFFDD5FBE),
                    ),

                    _skill(
                      'CSS',
                      82,
                      AppColors.primary,
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                // Перехід до екрана зміни пароля.
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                  ),
                  child: AppPrimaryButton(
                    text: 'ЗМІНИТИ ПАРОЛЬ',
                    icon: Icons.lock_outline,
                    onPressed: () {
                      _openChangePassword(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),

      // Нижня панель навігації.
      bottomNavigationBar: NavigationBar(
        selectedIndex: 3,
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFE8DFFF),

        onDestinationSelected: (index) {
          if (index == 0) {
            Navigator.pop(context);
          } else if (index != 3) {
            _showInfo(
              context,
              'Цей розділ буде реалізовано пізніше.',
            );
          }
        },

        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            label: 'Дім',
          ),

          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            label: 'Інтерв’ю',
          ),

          NavigationDestination(
            icon: Icon(Icons.mail_outline),
            label: 'Сповіщення',
          ),

          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(
              Icons.person,
              color: AppColors.primary,
            ),
            label: 'Акаунт',
          ),
        ],
      ),
    );
  }
}
