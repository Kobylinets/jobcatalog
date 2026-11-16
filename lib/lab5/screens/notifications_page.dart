import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog_models.dart';
import '../state/catalog_controller.dart';
import '../widgets/design_system.dart';
import 'interviews_page.dart';
import 'vacancies_page.dart';

/// Четверта вкладка з макета ЛР №2: Дім / Інтерв’ю / Сповіщення / Акаунт.
/// Інформаційні картки генеруються з демонстраційних даних каталогу.
class NotificationsPage extends StatelessWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final catalog = context.watch<CatalogController>();
    if (catalog.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    final interviews = catalog.interviews.toList()
      ..sort((a, b) => a.when.compareTo(b.when));
    final offers = catalog.vacancies
        .where((vacancy) => vacancy.status == ApplicationStatus.offer)
        .toList();

    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        const PageHeader(
          title: 'Сповіщення',
          subtitle: 'Важливі події щодо ваших заявок і співбесід',
        ),
        if (interviews.isEmpty && offers.isEmpty)
          const BlankSlate('Поки що немає подій для відображення.'),
        ...interviews.map(
          (entry) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: brandPurple.withValues(alpha: .12),
                  child: const Icon(
                    Icons.event_available_outlined,
                    color: brandPurple,
                  ),
                ),
                title: const Text(
                  'Запланована співбесіда',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${entry.company}\n${dateTimeLabel(entry.when)}'),
                ),
                isThreeLine: true,
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => InterviewDetailPage(id: entry.id),
                  ),
                ),
              ),
            ),
          ),
        ),
        ...offers.map(
          (vacancy) => Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Card(
              child: ListTile(
                contentPadding: const EdgeInsets.all(14),
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFF209D73)
                      .withValues(alpha: .12),
                  child: const Icon(
                    Icons.check_circle_outline,
                    color: Color(0xFF209D73),
                  ),
                ),
                title: const Text(
                  'Отримано офер',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('${vacancy.title} · ${vacancy.company}'),
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => VacancyDetailPage(id: vacancy.id),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
