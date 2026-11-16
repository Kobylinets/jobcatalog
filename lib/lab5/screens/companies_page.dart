import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/catalog_models.dart';
import '../state/catalog_controller.dart';
import '../widgets/design_system.dart';

class CompaniesPage extends StatefulWidget {
  const CompaniesPage({super.key});
  @override
  State<CompaniesPage> createState() => _CompaniesPageState();
}

class _CompaniesPageState extends State<CompaniesPage> {
  final search = TextEditingController();
  bool alphabetical = true;
  @override
  void dispose() {
    search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<CatalogController>();
    final items = state.companies
        .where(
          (c) => '${c.name} ${c.city} ${c.industry}'.toLowerCase().contains(
            search.text.toLowerCase().trim(),
          ),
        )
        .toList();
    if (alphabetical) {
      items.sort(
        (a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()),
      );
    }
    return Column(
      children: [
        PageHeader(
          title: 'Компанії',
          subtitle: 'Контакти та картки роботодавців',
          trailing: IconButton.filled(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(builder: (_) => const CompanyFormPage()),
            ),
            icon: const Icon(Icons.add),
            tooltip: 'Додати компанію',
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          child: TextField(
            controller: search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Пошук компанії',
              prefixIcon: Icon(Icons.search),
            ),
          ),
        ),
        SwitchListTile.adaptive(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20),
          title: const Text('Сортувати за назвою (А–Я)'),
          value: alphabetical,
          onChanged: (value) => setState(() => alphabetical = value),
        ),
        Expanded(
          child: state.loading
              ? const Center(child: CircularProgressIndicator())
              : items.isEmpty
              ? const BlankSlate('Компаній не знайдено.')
              : ListView.separated(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  itemCount: items.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final c = items[index];
                    return Card(
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(14),
                        leading: CircleAvatar(
                          backgroundColor: brandPurple.withValues(alpha: .12),
                          child: const Icon(
                            Icons.business_outlined,
                            color: brandPurple,
                          ),
                        ),
                        title: Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        subtitle: Text('${c.industry} · ${c.city}'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute<void>(
                            builder: (_) => CompanyDetailPage(id: c.id),
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

class CompanyDetailPage extends StatelessWidget {
  const CompanyDetailPage({super.key, required this.id});
  final String id;
  @override
  Widget build(BuildContext context) {
    final result = context.watch<CatalogController>().companies.where(
      (c) => c.id == id,
    );
    if (result.isEmpty) {
      return const Scaffold(body: BlankSlate('Компанію видалено.'));
    }
    final c = result.first;
    return Scaffold(
      appBar: AppBar(title: const Text('Деталі компанії')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const CircleAvatar(
                    radius: 27,
                    backgroundColor: Color(0xFFF0E9FF),
                    child: Icon(Icons.business_outlined, color: brandPurple),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    c.name,
                    style: Theme.of(context).textTheme.headlineSmall
                        ?.copyWith(fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 18),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.category_outlined),
                    title: const Text('Сфера'),
                    subtitle: Text(c.industry),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.place_outlined),
                    title: const Text('Місто'),
                    subtitle: Text(c.city),
                  ),
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.language),
                    title: const Text('Вебсайт'),
                    subtitle: Text(
                      c.website.isEmpty ? 'Не вказано' : c.website,
                    ),
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
                    'Нотатки',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 10),
                  Text(c.notes.isEmpty ? 'Нотаток немає.' : c.notes),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute<void>(
                builder: (_) => CompanyFormPage(existing: c),
              ),
            ),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Редагувати компанію'),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () async {
              if (await confirmDeletion(context, c.name) && context.mounted) {
                context.read<CatalogController>().deleteCompany(c.id);
                Navigator.pop(context);
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Видалити компанію'),
          ),
        ],
      ),
    );
  }
}

class CompanyFormPage extends StatefulWidget {
  const CompanyFormPage({super.key, this.existing});
  final Company? existing;
  @override
  State<CompanyFormPage> createState() => _CompanyFormPageState();
}

class _CompanyFormPageState extends State<CompanyFormPage> {
  final form = GlobalKey<FormState>();
  late final TextEditingController name, industry, city, website, notes;
  @override
  void initState() {
    super.initState();
    name = TextEditingController(text: widget.existing?.name ?? '');
    industry = TextEditingController(text: widget.existing?.industry ?? '');
    city = TextEditingController(text: widget.existing?.city ?? '');
    website = TextEditingController(text: widget.existing?.website ?? '');
    notes = TextEditingController(text: widget.existing?.notes ?? '');
  }

  @override
  void dispose() {
    for (final item in [name, industry, city, website, notes]) {
      item.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(
        widget.existing == null ? 'Нова компанія' : 'Редагування компанії',
      ),
    ),
    body: SafeArea(
      child: Form(
        key: form,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const FieldLabel('Назва компанії *'),
            TextFormField(
              controller: name,
              validator: requiredText,
              decoration: const InputDecoration(hintText: 'Назва'),
            ),
            const FieldLabel('Сфера діяльності *'),
            TextFormField(
              controller: industry,
              validator: requiredText,
              decoration: const InputDecoration(hintText: 'IT / Розробка'),
            ),
            const FieldLabel('Місто *'),
            TextFormField(
              controller: city,
              validator: requiredText,
              decoration: const InputDecoration(hintText: 'Львів'),
            ),
            const FieldLabel('Вебсайт'),
            TextFormField(
              controller: website,
              keyboardType: TextInputType.url,
              decoration: const InputDecoration(
                hintText: 'https://example.com',
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) {
                  return null;
                }
                final u = Uri.tryParse(v.trim());
                return u?.hasScheme == true && u?.host.isNotEmpty == true
                    ? null
                    : 'Вкажіть повне посилання, починаючи з https://';
              },
            ),
            const FieldLabel('Нотатки'),
            TextFormField(
              controller: notes,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Що відомо про компанію?',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Зберегти компанію'),
              onPressed: () {
                if (!form.currentState!.validate()) {
                  return;
                }
                final state = context.read<CatalogController>();
                state.saveCompany(
                  Company(
                    id: widget.existing?.id ?? state.nextId(),
                    name: name.text.trim(),
                    industry: industry.text.trim(),
                    city: city.text.trim(),
                    website: website.text.trim(),
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
