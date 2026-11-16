import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog_models.dart';
import '../state/catalog_controller.dart';
import '../widgets/design_system.dart';

class VacanciesPage extends StatefulWidget {
  const VacanciesPage({super.key});
  @override
  State<VacanciesPage> createState() => _VacanciesPageState();
}

class _VacanciesPageState extends State<VacanciesPage> {
  final search = TextEditingController();
  ApplicationStatus? status;
  String order = 'newest';
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  List<Vacancy> visible(List<Vacancy> source) {
    final query = search.text.trim().toLowerCase();
    final result = source
        .where(
          (v) =>
              (status == null || v.status == status) &&
              (query.isEmpty ||
                  '${v.title} ${v.company} ${v.city}'.toLowerCase().contains(
                    query,
                  )),
        )
        .toList();
    switch (order) {
      case 'oldest':
        result.sort((a, b) => a.appliedAt.compareTo(b.appliedAt));
        break;
      case 'az':
        result.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
        );
        break;
      case 'company':
        result.sort(
          (a, b) => a.company.toLowerCase().compareTo(b.company.toLowerCase()),
        );
        break;
      default:
        result.sort((a, b) => b.appliedAt.compareTo(a.appliedAt));
        break;
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CatalogController>();
    final items = visible(state.vacancies);
    return Column(
      children: [
        PageHeader(
          title: 'Мої вакансії',
          subtitle: 'Заявки та етапи розгляду',
          trailing: IconButton.filled(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const VacancyFormPage()),
            ),
            icon: const Icon(Icons.add),
            tooltip: 'Додати вакансію',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Пошук за назвою, компанією або містом',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<ApplicationStatus?>(
                  initialValue: status,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Статус',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: [
                    const DropdownMenuItem<ApplicationStatus?>(
                      value: null,
                      child: Text('Усі'),
                    ),
                    ...ApplicationStatus.values.map(
                      (v) => DropdownMenuItem<ApplicationStatus?>(
                        value: v,
                        child: Text(v.label),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => status = v),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: DropdownButtonFormField<String>(
                  initialValue: order,
                  isExpanded: true,
                  decoration: const InputDecoration(
                    labelText: 'Сортування',
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 12,
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'newest',
                      child: Text('Спочатку нові'),
                    ),
                    DropdownMenuItem(
                      value: 'oldest',
                      child: Text('Спочатку старі'),
                    ),
                    DropdownMenuItem(value: 'az', child: Text('За назвою')),
                    DropdownMenuItem(
                      value: 'company',
                      child: Text('За компанією'),
                    ),
                  ],
                  onChanged: (v) => setState(() => order = v ?? 'newest'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: state.loading
              ? const Center(child: CircularProgressIndicator())
              : state.error != null
              ? BlankSlate(state.error!)
              : items.isEmpty
              ? const BlankSlate(
                  'За цими фільтрами вакансій немає.',
                  icon: Icons.search_off,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final v = items[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: CircleAvatar(
                          backgroundColor: brandPurple.withValues(alpha: .12),
                          child: Text(
                            v.company.isNotEmpty ? v.company[0] : '?',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: brandPurple,
                            ),
                          ),
                        ),
                        title: Text(
                          v.title,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Padding(
                          padding: const EdgeInsets.only(top: 7),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('${v.company} · ${v.city}'),
                              const SizedBox(height: 8),
                              StatusPill(v.status),
                            ],
                          ),
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => VacancyDetailPage(id: v.id),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}

class VacancyDetailPage extends StatelessWidget {
  const VacancyDetailPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    final state = context.watch<CatalogController>();
    final results = state.vacancies.where((v) => v.id == id);
    if (results.isEmpty) {
      return const Scaffold(body: BlankSlate('Вакансію видалено.'));
    }
    final v = results.first;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Деталі вакансії'),
        actions: [
          IconButton(
            tooltip: 'До обраного',
            icon: Icon(v.favorite ? Icons.bookmark : Icons.bookmark_border),
            onPressed: () => context.read<CatalogController>().saveVacancy(
              v.copyWith(favorite: !v.favorite),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    v.company,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    v.title,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 14),
                  StatusPill(v.status),
                  const Divider(height: 30),
                  ListTile(
                    leading: const Icon(
                      Icons.payments_outlined,
                      color: brandPurple,
                    ),
                    title: const Text('Зарплата'),
                    subtitle: Text(v.salary.isEmpty ? 'Не вказано' : v.salary),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.location_on_outlined,
                      color: brandPurple,
                    ),
                    title: const Text('Місце роботи'),
                    subtitle: Text(v.city),
                    contentPadding: EdgeInsets.zero,
                  ),
                  ListTile(
                    leading: const Icon(
                      Icons.calendar_month_outlined,
                      color: brandPurple,
                    ),
                    title: const Text('Дата заявки'),
                    subtitle: Text(dateLabel(v.appliedAt)),
                    contentPadding: EdgeInsets.zero,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Опис і нотатки',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 12),
                  Text(v.notes.isEmpty ? 'Нотаток немає.' : v.notes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 25),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => VacancyFormPage(existing: v),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Редагувати вакансію'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              final ok = await confirmDeletion(context, v.title);
              if (ok && context.mounted) {
                context.read<CatalogController>().deleteVacancy(v.id);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_outline, color: Color(0xFFD3485F)),
            label: const Text(
              'Видалити',
              style: TextStyle(color: Color(0xFFD3485F)),
            ),
          ),
        ],
      ),
    );
  }
}

class VacancyFormPage extends StatefulWidget {
  const VacancyFormPage({super.key, this.existing});
  final Vacancy? existing;
  @override
  State<VacancyFormPage> createState() => _VacancyFormPageState();
}

class _VacancyFormPageState extends State<VacancyFormPage> {
  final form = GlobalKey<FormState>();
  late final TextEditingController title;
  late final TextEditingController company;
  late final TextEditingController salary;
  late final TextEditingController city;
  late final TextEditingController notes;
  late ApplicationStatus status;
  late DateTime appliedAt;
  @override
  void initState() {
    super.initState();
    final v = widget.existing;
    title = TextEditingController(text: v?.title ?? '');
    company = TextEditingController(text: v?.company ?? '');
    salary = TextEditingController(text: v?.salary ?? '');
    city = TextEditingController(text: v?.city ?? '');
    notes = TextEditingController(text: v?.notes ?? '');
    status = v?.status ?? ApplicationStatus.sent;
    appliedAt = v?.appliedAt ?? DateTime.now();
  }

  @override
  void dispose() {
    for (final c in [title, company, salary, city, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  void save() {
    if (!(form.currentState?.validate() ?? false)) {
      return;
    }
    final store = context.read<CatalogController>();
    store.saveVacancy(
      Vacancy(
        id: widget.existing?.id ?? store.nextId(),
        title: title.text.trim(),
        company: company.text.trim(),
        salary: salary.text.trim(),
        city: city.text.trim(),
        status: status,
        appliedAt: appliedAt,
        notes: notes.text.trim(),
        favorite: widget.existing?.favorite ?? false,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.existing == null ? 'Нова вакансія' : 'Редагування вакансії',
      ),
    ),
    body: SafeArea(
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const FieldLabel('Назва посади *'),
            TextFormField(
              controller: title,
              validator: requiredText,
              decoration: const InputDecoration(
                hintText: 'Наприклад, Flutter Developer',
              ),
            ),
            const FieldLabel('Компанія *'),
            TextFormField(
              controller: company,
              validator: requiredText,
              decoration: const InputDecoration(hintText: 'Назва компанії'),
            ),
            const FieldLabel('Зарплата'),
            TextFormField(
              controller: salary,
              decoration: const InputDecoration(hintText: r'$1000–$1500'),
            ),
            const FieldLabel('Місто / формат роботи *'),
            TextFormField(
              controller: city,
              validator: requiredText,
              decoration: const InputDecoration(hintText: 'Львів / Віддалено'),
            ),
            const FieldLabel('Статус заявки'),
            DropdownButtonFormField<ApplicationStatus>(
              initialValue: status,
              decoration: const InputDecoration(),
              items: ApplicationStatus.values
                  .map((v) => DropdownMenuItem(value: v, child: Text(v.label)))
                  .toList(),
              onChanged: (v) =>
                  setState(() => status = v ?? ApplicationStatus.sent),
            ),
            const FieldLabel('Дата подачі'),
            OutlinedButton.icon(
              onPressed: () async {
                final value = await showDatePicker(
                  context: context,
                  initialDate: appliedAt,
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2035),
                );
                if (value != null) {
                  setState(() => appliedAt = value);
                }
              },
              icon: const Icon(Icons.calendar_month_outlined),
              label: Text(dateLabel(appliedAt)),
            ),
            const FieldLabel('Опис / нотатки'),
            TextFormField(
              controller: notes,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Що важливо запам’ятати?',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: save,
              icon: const Icon(Icons.check),
              label: const Text('Зберегти вакансію'),
            ),
          ],
        ),
      ),
    ),
  );
}
