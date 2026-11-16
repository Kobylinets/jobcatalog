import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog_models.dart';
import '../state/catalog_controller.dart';
import '../state/theme_controller.dart';
import '../widgets/design_system.dart';
import 'companies_page.dart';
import 'interviews_page.dart';
import 'vacancies_page.dart';
import 'auth_pages.dart';
import 'notifications_page.dart';

class HomeTabs extends StatefulWidget {
  const HomeTabs({super.key});
  @override
  State<HomeTabs> createState() => _HomeTabsState();
}

class _HomeTabsState extends State<HomeTabs> {
  int selected = 0;
  void go(int tab) => setState(() => selected = tab);
  @override
  Widget build(BuildContext context) {
    final theme = context.watch<ThemeController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Job Catalog',
          style: TextStyle(fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            tooltip: theme.isDark
                ? 'Увімкнути світлу тему'
                : 'Увімкнути темну тему',
            onPressed: () =>
                context.read<ThemeController>().setDark(!theme.isDark),
            icon: Icon(
              theme.isDark
                  ? Icons.light_mode_outlined
                  : Icons.dark_mode_outlined,
            ),
          ),
          const SizedBox(width: 9),
        ],
      ),
      body: IndexedStack(
        index: selected,
        children: [
          DashboardPage(
            onOpenInterviews: () => go(1),
            onOpenVacancies: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Мої вакансії')),
                  body: const VacanciesPage(),
                ),
              ),
            ),
            onOpenCompanies: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => Scaffold(
                  appBar: AppBar(title: const Text('Компанії')),
                  body: const CompaniesPage(),
                ),
              ),
            ),
          ),
          const InterviewsPage(),
          const NotificationsPage(),
          const ProfilePage(),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: selected,
        onDestinationSelected: go,
        height: 73,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Дім',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Інтерв’ю',
          ),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            selectedIcon: Icon(Icons.notifications),
            label: 'Сповіщення',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Акаунт',
          ),
        ],
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({
    super.key,
    required this.onOpenInterviews,
    required this.onOpenVacancies,
    required this.onOpenCompanies,
  });
  final VoidCallback onOpenInterviews;
  final VoidCallback onOpenVacancies;
  final VoidCallback onOpenCompanies;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CatalogController>();
    if (state.loading) return const Center(child: CircularProgressIndicator());
    if (state.error != null) return BlankSlate(state.error!);
    final recent = state.vacancies.toList()
      ..sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
    final scheduled = state.interviews.toList()
      ..sort((a, b) => a.when.compareTo(b.when));
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ваш кар’єрний прогрес',
                  style: Theme.of(context).textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 5),
                Text(
                  'Усі важливі етапи пошуку роботи в одному місці.',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 18),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF4D23B5), Color(0xFF805DE2)],
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Усього заявок',
                          style: TextStyle(color: Colors.white70, fontSize: 15),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          '${state.vacancies.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 42,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            _Stat(label: 'Активні', value: state.active),
                            const SizedBox(width: 20),
                            _Stat(label: 'Офери', value: state.offers),
                            const SizedBox(width: 20),
                            _Stat(label: 'Відмови', value: state.rejected),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                Text(
                  'Швидкі дії',
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.work_outline,
                        label: 'Вакансії',
                        onTap: onOpenVacancies,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.business_outlined,
                        label: 'Компанії',
                        onTap: onOpenCompanies,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _QuickAction(
                        icon: Icons.event_outlined,
                        label: 'Співбесіди',
                        onTap: onOpenInterviews,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Останні вакансії',
                        style: Theme.of(context).textTheme.titleLarge
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                    ),
                    TextButton(
                      onPressed: onOpenVacancies,
                      child: const Text('Всі'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (recent.isEmpty)
          const SliverToBoxAdapter(
            child: BlankSlate('Додайте першу вакансію.'),
          ),
        SliverList.builder(
          itemCount: recent.length > 3 ? 3 : recent.length,
          itemBuilder: (context, index) {
            final v = recent[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 9),
              child: Card(
                child: ListTile(
                  leading: const Icon(Icons.work_outline, color: brandPurple),
                  title: Text(
                    v.title,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text(v.company),
                  trailing: StatusPill(v.status),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => VacancyDetailPage(id: v.id),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 6),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    'Найближчі співбесіди',
                    style: Theme.of(context).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ),
                TextButton(
                  onPressed: onOpenInterviews,
                  child: const Text('Всі'),
                ),
              ],
            ),
          ),
        ),
        if (scheduled.isEmpty)
          const SliverToBoxAdapter(
            child: BlankSlate('Співбесіди ще не заплановано.'),
          ),
        SliverList.builder(
          itemCount: scheduled.length > 2 ? 2 : scheduled.length,
          itemBuilder: (context, index) {
            final i = scheduled[index];
            return Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 9),
              child: Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.calendar_month_outlined,
                    color: brandPurple,
                  ),
                  title: Text(
                    i.kind,
                    style: const TextStyle(fontWeight: FontWeight.w800),
                  ),
                  subtitle: Text('${i.company} · ${dateTimeLabel(i.when)}'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => InterviewDetailPage(id: i.id),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value});
  final String label;
  final int value;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '$value',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
        ),
      ),
      Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
    ],
  );
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 5),
        child: Column(
          children: [
            Icon(icon, color: brandPurple, size: 26),
            const SizedBox(height: 10),
            Text(
              label,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    ),
  );
}
