import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog_models.dart';
import '../state/catalog_controller.dart';
import '../widgets/design_system.dart';

class InterviewsPage extends StatefulWidget {
  const InterviewsPage({super.key});
  @override
  State<InterviewsPage> createState() => _InterviewsPageState();
}

class _InterviewsPageState extends State<InterviewsPage> {
  final search = TextEditingController();
  bool upcomingFirst = true;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<CatalogController>();
    final entries = store.interviews
        .where(
          (i) => '${i.company} ${i.position} ${i.kind}'.toLowerCase().contains(
            search.text.toLowerCase().trim(),
          ),
        )
        .toList();
    entries.sort(
      (a, b) =>
          upcomingFirst ? a.when.compareTo(b.when) : b.when.compareTo(a.when),
    );
    return Column(
      children: [
        PageHeader(
          title: 'Мої співбесіди',
          subtitle: 'Заплановані зустрічі',
          trailing: IconButton.filled(
            icon: const Icon(Icons.add),
            tooltip: 'Запланувати співбесіду',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => const InterviewFormPage(),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Пошук інтерв’ю',
            ),
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Text('Спочатку найближчі'),
          value: upcomingFirst,
          onChanged: (v) => setState(() => upcomingFirst = v),
        ),
        Expanded(
          child: store.loading
              ? const Center(child: CircularProgressIndicator())
              : entries.isEmpty
              ? const BlankSlate(
                  'Співбесід не знайдено.',
                  icon: Icons.event_busy_outlined,
                )
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 22),
                  itemCount: entries.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) {
                    final i = entries[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16),
                        leading: const CircleAvatar(
                          backgroundColor: Color(0xFFF0E9FF),
                          child: Icon(
                            Icons.video_call_outlined,
                            color: brandPurple,
                          ),
                        ),
                        title: Text(
                          i.kind,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 5),
                            Text(i.company),
                            Text(i.position),
                            const SizedBox(height: 8),
                            Text(
                              dateTimeLabel(i.when),
                              style: const TextStyle(
                                color: brandPurple,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(i.place),
                          ],
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => InterviewDetailPage(id: i.id),
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

class InterviewDetailPage extends StatelessWidget {
  const InterviewDetailPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    final matches = context.watch<CatalogController>().interviews.where(
      (i) => i.id == id,
    );
    if (matches.isEmpty) {
      return const Scaffold(body: BlankSlate('Співбесіду видалено.'));
    }
    final i = matches.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Деталі співбесіди')),
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
                    i.kind,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text('${i.company} · ${i.position}'),
                  const Divider(height: 28),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.event, color: brandPurple),
                    title: const Text('Дата й час'),
                    subtitle: Text(dateTimeLabel(i.when)),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(
                      Icons.place_outlined,
                      color: brandPurple,
                    ),
                    title: const Text('Місце / посилання'),
                    subtitle: Text(i.place),
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
                    'Нотатки до зустрічі',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(i.notes.isEmpty ? 'Нотаток немає.' : i.notes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => InterviewFormPage(existing: i),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Редагувати співбесіду'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              if (await confirmDeletion(context, i.kind) && context.mounted) {
                context.read<CatalogController>().deleteInterview(i.id);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Видалити співбесіду'),
          ),
        ],
      ),
    );
  }
}

class InterviewFormPage extends StatefulWidget {
  const InterviewFormPage({super.key, this.existing});
  final Interview? existing;
  @override
  State<InterviewFormPage> createState() => _InterviewFormPageState();
}

class _InterviewFormPageState extends State<InterviewFormPage> {
  final form = GlobalKey<FormState>();
  late final TextEditingController company, position, kind, place, notes;
  late DateTime when;
  @override
  void initState() {
    super.initState();
    company = TextEditingController(text: widget.existing?.company ?? '');
    position = TextEditingController(text: widget.existing?.position ?? '');
    kind = TextEditingController(
      text: widget.existing?.kind ?? 'Technical Interview',
    );
    place = TextEditingController(
      text: widget.existing?.place ?? 'Google Meet',
    );
    notes = TextEditingController(text: widget.existing?.notes ?? '');
    when = widget.existing?.when ?? DateTime.now().add(const Duration(days: 1));
  }

  @override
  void dispose() {
    for (final c in [company, position, kind, place, notes]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> pickDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: when,
      firstDate: DateTime(2020),
      lastDate: DateTime(2036),
    );
    if (date == null || !mounted) {
      return;
    }
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(when),
    );
    if (time != null) {
      setState(
        () => when = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.existing == null ? 'Нова співбесіда' : 'Редагування співбесіди',
      ),
    ),
    body: SafeArea(
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const FieldLabel('Компанія *'),
            TextFormField(
              controller: company,
              validator: requiredText,
              decoration: const InputDecoration(hintText: 'Назва компанії'),
            ),
            const FieldLabel('Посада *'),
            TextFormField(
              controller: position,
              validator: requiredText,
              decoration: const InputDecoration(hintText: 'Посада'),
            ),
            const FieldLabel('Тип співбесіди *'),
            TextFormField(
              controller: kind,
              validator: requiredText,
              decoration: const InputDecoration(
                hintText: 'Technical / HR Interview',
              ),
            ),
            const FieldLabel('Дата та час'),
            OutlinedButton.icon(
              onPressed: pickDateTime,
              icon: const Icon(Icons.event),
              label: Text(dateTimeLabel(when)),
            ),
            const FieldLabel('Місце або платформа *'),
            TextFormField(
              controller: place,
              validator: requiredText,
              decoration: const InputDecoration(
                hintText: 'Google Meet / Адреса',
              ),
            ),
            const FieldLabel('Нотатки'),
            TextFormField(
              controller: notes,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Що потрібно підготувати?',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Зберегти співбесіду'),
              onPressed: () {
                if (!form.currentState!.validate()) {
                  return;
                }
                final store = context.read<CatalogController>();
                store.saveInterview(
                  Interview(
                    id: widget.existing?.id ?? store.nextId(),
                    company: company.text.trim(),
                    position: position.text.trim(),
                    kind: kind.text.trim(),
                    when: when,
                    place: place.text.trim(),
                    notes: notes.text.trim(),
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    ),
  );
}
