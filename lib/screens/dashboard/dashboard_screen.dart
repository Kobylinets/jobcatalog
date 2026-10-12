
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/app_theme.dart';
import '../profile/profile_screen.dart';

// Головний екран застосунку Job Catalog.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  // Перехід на екран профілю користувача.
  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => const ProfileScreen(),
      ),
    );
  }

  // Тимчасовий екран для майбутніх розділів.
  void _openPage(BuildContext context, String title) {
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (context) => Scaffold(
          appBar: AppBar(
            title: Text(title),
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
          ),
          body: Center(
            child: Text(
              'Екран "$title" буде реалізовано пізніше.',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  // Картка статистики.
  Widget _statCard(
    String number,
    String label,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        height: 112,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Stack(
          children: [
            Positioned(
              right: 0,
              bottom: 0,
              child: Icon(
                icon,
                size: 50,
                color: Colors.white24,
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  number,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Заголовок секції.
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 25,
        bottom: 14,
      ),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  // Значок категорії.
  Widget _categoryIcon(IconData icon) {
    return Container(
      margin: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Icon(
        icon,
        size: 25,
        color: AppColors.primary,
      ),
    );
  }

  // Логотип компанії.
  Widget _companyLogo(Color color, IconData icon) {
    return Container(
      width: 43,
      height: 43,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        icon,
        color: Colors.white,
        size: 25,
      ),
    );
  }

  // Картка рекомендованої вакансії.
  Widget _recommendedVacancy(
    String title,
    String city,
    Color color,
  ) {
    return Container(
      width: 220,
      margin: const EdgeInsets.only(right: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: AppColors.border,
        ),
      ),
      child: Row(
        children: [
          _companyLogo(color, Icons.work_outline),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  city,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 7),
                const Text(
                  '500–1 000 USD',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Картка вакансії у звичайному списку.
  Widget _vacancyCard(
    String company,
    String position,
    String city,
    Color color,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _companyLogo(color, icon),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  position,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 7),
                const Row(
                  children: [
                    Icon(
                      Icons.payments_outlined,
                      color: AppColors.primary,
                      size: 15,
                    ),
                    SizedBox(width: 5),
                    Text(
                      '500–1 000 USD',
                      style: TextStyle(fontSize: 11),
                    ),
                  ],
                ),
                const SizedBox(height: 5),
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      color: AppColors.primary,
                      size: 15,
                    ),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        city,
                        style: const TextStyle(
                          fontSize: 11,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // Світлі системні індикатори на фіолетовому фоні.
      value: const SystemUiOverlayStyle(
        statusBarBrightness: Brightness.dark,
        statusBarIconBrightness: Brightness.light,
      ),

      child: Scaffold(
        backgroundColor: AppColors.background,

        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  // Верхня фіолетова панель.
                  Container(
                    padding: EdgeInsets.fromLTRB(
                      20,
                      MediaQuery.paddingOf(context).top + 20,
                      20,
                      26,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(25),
                        bottomRight: Radius.circular(25),
                      ),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            const Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Добрий ранок!',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.white70,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Іван Кобилінець',
                                    style: TextStyle(
                                      fontSize: 21,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Створення вакансії.
                            IconButton(
                              onPressed: () {
                                _openPage(
                                  context,
                                  'Створення вакансії',
                                );
                              },
                              icon: const Icon(
                                Icons.add_circle,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),

                            // Аватар: перехід до профілю.
                            GestureDetector(
                              onTap: () {
                                _openProfile(context);
                              },
                              child: const CircleAvatar(
                                radius: 23,
                                backgroundColor: Colors.white,
                                child: Icon(
                                  Icons.person,
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 22),

                        // Демонстраційний рядок пошуку.
                        Container(
                          height: 48,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(25),
                          ),
                          child: const Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 10),
                              Text(
                                'Шукай роботу тут',
                                style: TextStyle(
                                  color: AppColors.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Основний вміст дашборду.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      20,
                      24,
                      20,
                      25,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        // Статистика вакансій та інтерв'ю.
                        Row(
                          children: [
                            _statCard(
                              '29',
                              'Розглянуті вакансії',
                              AppColors.primary,
                              Icons.work_outline,
                            ),
                            const SizedBox(width: 12),
                            _statCard(
                              '3',
                              'Інтерв’ю',
                              const Color(0xFF49A8F6),
                              Icons.question_answer_outlined,
                            ),
                          ],
                        ),

                        // Категорії.
                        _sectionTitle('Категорії'),

                        GridView.count(
                          // Прибираємо зайвий верхній відступ.
                          padding: EdgeInsets.zero,
                          crossAxisCount: 4,
                          shrinkWrap: true,
                          physics:
                              const NeverScrollableScrollPhysics(),
                          childAspectRatio: 1.2,
                          children: [
                            _categoryIcon(Icons.bolt_outlined),
                            _categoryIcon(Icons.edit_outlined),
                            _categoryIcon(Icons.crop_free),
                            _categoryIcon(Icons.translate),
                            _categoryIcon(Icons.code),
                            _categoryIcon(Icons.dns_outlined),
                            _categoryIcon(Icons.build_outlined),
                            _categoryIcon(Icons.more_horiz),
                          ],
                        ),

                        // Рекомендовані вакансії.
                        _sectionTitle('Рекомендовані вакансії'),

                        SizedBox(
                          height: 104,
                          child: ListView(
                            scrollDirection: Axis.horizontal,
                            children: [
                              _recommendedVacancy(
                                'Software Engineer',
                                'Львів, Україна',
                                const Color(0xFF39A875),
                              ),
                              _recommendedVacancy(
                                'UI/UX Designer',
                                'Київ, Україна',
                                const Color(0xFFE5893B),
                              ),
                              _recommendedVacancy(
                                'QA Engineer',
                                'Львів, Україна',
                                const Color(0xFF8655D5),
                              ),
                            ],
                          ),
                        ),

                        // Нещодавні вакансії.
                        _sectionTitle('Нещодавні вакансії'),

                        _vacancyCard(
                          'Highspeed Studios',
                          'Junior Software Engineer',
                          'Київ, Україна',
                          const Color(0xFFFF743B),
                          Icons.code,
                        ),

                        _vacancyCard(
                          'Lunar Dojo Corp.',
                          'Database Engineer',
                          'Луцьк, Україна',
                          const Color(0xFF9355D8),
                          Icons.storage_outlined,
                        ),

                        _vacancyCard(
                          'Darkseer Studios',
                          'Senior Software Engineer',
                          'Харків, Україна',
                          const Color(0xFF555555),
                          Icons.terminal,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),

        // Нижня навігаційна панель.
        bottomNavigationBar: NavigationBar(
          selectedIndex: 0,
          height: 72,
          backgroundColor: Colors.white,
          indicatorColor: const Color(0xFFE8DFFF),

          onDestinationSelected: (index) {
            if (index == 1) {
              _openPage(context, 'Мої інтерв’ю');
            } else if (index == 2) {
              _openPage(context, 'Сповіщення');
            } else if (index == 3) {
              // Перехід до створеного екрана профілю.
              _openProfile(context);
            }
          },

          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(
                Icons.home,
                color: AppColors.primary,
              ),
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
              label: 'Акаунт',
            ),
          ],
        ),
      ),
    );
  }
}
