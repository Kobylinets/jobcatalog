import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/catalog_models.dart';

/// Каталог лабораторної №5 зберігається локально у форматі JSON.
/// У кожного Firebase UID — власний ключ; токени та паролі не зберігаються.
/// Для невеликого демонстраційного набору даних достатньо SharedPreferencesAsync.
class CatalogController extends ChangeNotifier {
  CatalogController({SharedPreferencesAsync? preferences})
    : _preferences = preferences ?? SharedPreferencesAsync();

  static const _storagePrefix = 'jobcatalog_catalog_v1_';
  final SharedPreferencesAsync _preferences;
  final List<Vacancy> _vacancies = [];
  final List<Company> _companies = [];
  final List<Interview> _interviews = [];

  bool loading = true;
  String? error;
  String? _userId;
  bool _sessionInitialized = false;
  int _generation = 0;
  int _nextId = 100;
  Future<void> _writes = Future<void>.value();

  List<Vacancy> get vacancies => List.unmodifiable(_vacancies);
  List<Company> get companies => List.unmodifiable(_companies);
  List<Interview> get interviews => List.unmodifiable(_interviews);
  int get offers =>
      _vacancies.where((v) => v.status == ApplicationStatus.offer).length;
  int get rejected =>
      _vacancies.where((v) => v.status == ApplicationStatus.rejected).length;
  int get active => _vacancies
      .where(
        (v) =>
            v.status != ApplicationStatus.offer &&
            v.status != ApplicationStatus.rejected,
      )
      .length;

  bool isReadyFor(String? uid) =>
      _sessionInitialized && _userId == uid && !loading;

  String nextId() => 'item-${_nextId++}';

  /// Викликати після встановлення або зміни Firebase-сеансу.
  /// Початкові тестові дані створюються ЛИШЕ коли ще немає збереженого JSON.
  Future<void> loadForUser(String? uid) async {
    if (_sessionInitialized && _userId == uid) return;
    _sessionInitialized = true;
    _userId = uid;
    final currentGeneration = ++_generation;
    _clearLists();
    error = null;
    loading = true;
    notifyListeners();

    if (uid == null) {
      loading = false;
      notifyListeners();
      return;
    }

    try {
      // Дочекатися можливих попередніх записів, перш ніж читати сховище.
      await _writes;
      final raw = await _preferences.getString('$_storagePrefix$uid');
      if (currentGeneration != _generation) return;
      if (raw == null) {
        _seedDemoData();
        // Зберігаємо початковий стан, щоб навіть порожні колекції
        // після видалення ВСІХ записів не засівалися знову.
        await _enqueueSnapshot();
      } else {
        _restore(raw);
      }
    } catch (exception) {
      if (currentGeneration != _generation) return;
      // Не перезаписуємо потенційно пошкоджені дані тестовими.
      error =
          'Не вдалося прочитати або зберегти локальні дані. '
          'Перевірте доступне місце на пристрої.';
      debugPrint('Catalog local storage: $exception');
    } finally {
      if (currentGeneration == _generation) {
        loading = false;
        notifyListeners();
      }
    }
  }

  void _clearLists() {
    _vacancies.clear();
    _companies.clear();
    _interviews.clear();
    _nextId = 100;
  }

  void _seedDemoData() {
    _companies.addAll(const [
      Company(
        id: 'c1',
        name: 'Highspeed Studios',
        industry: 'IT / Gamedev',
        city: 'Львів',
        website: 'https://example.com',
        notes: 'Компанія з розробки програмного забезпечення.',
      ),
      Company(
        id: 'c2',
        name: 'SoftServe',
        industry: 'IT / Outsourcing',
        city: 'Львів',
        website: 'https://softserveinc.com',
        notes: 'Міжнародна ІТ-компанія.',
      ),
      Company(
        id: 'c3',
        name: 'GlobalLogic',
        industry: 'IT / Engineering',
        city: 'Київ',
        website: 'https://www.globallogic.com',
        notes: 'Розробка інженерних рішень.',
      ),
    ]);
    _vacancies.addAll([
      Vacancy(
        id: 'v1',
        title: 'Senior Software Engineer',
        company: 'Highspeed Studios',
        salary: r'$500–$1000/місяць',
        city: 'Львів',
        status: ApplicationStatus.sent,
        appliedAt: DateTime(2026, 10, 12),
        notes: 'Віддалено · Повний день · Погодинно. Шукаємо інженера для розробки нового функціоналу.',
        favorite: true,
      ),
      Vacancy(
        id: 'v2',
        title: 'Flutter Developer',
        company: 'SoftServe',
        salary: r'$1200–$2000',
        city: 'Львів',
        status: ApplicationStatus.interview,
        appliedAt: DateTime(2026, 10, 15),
        notes: 'Співбесіда з технічним спеціалістом.',
      ),
      Vacancy(
        id: 'v3',
        title: 'Junior QA Engineer',
        company: 'GlobalLogic',
        salary: r'$700–$1100',
        city: 'Київ',
        status: ApplicationStatus.task,
        appliedAt: DateTime(2026, 10, 18),
        notes: 'Надіслано тестове завдання.',
      ),
      Vacancy(
        id: 'v4',
        title: 'UI Developer',
        company: 'SoftServe',
        salary: r'$900–$1400',
        city: 'Віддалено',
        status: ApplicationStatus.offer,
        appliedAt: DateTime(2026, 10, 21),
        notes: 'Отримано офер.',
      ),
      Vacancy(
        id: 'v5',
        title: 'Backend Developer',
        company: 'Highspeed Studios',
        salary: r'$800–$1300',
        city: 'Львів',
        status: ApplicationStatus.rejected,
        appliedAt: DateTime(2026, 10, 23),
        notes: 'Відмовлено після первинного відбору.',
      ),
    ]);
    _interviews.addAll([
      Interview(
        id: 'i1',
        company: 'Highspeed Studios',
        position: 'Senior Software Engineer',
        kind: 'Technical Interview',
        when: DateTime(2026, 11, 18, 14),
        place: 'Google Meet',
        notes: 'Підготувати приклади з Flutter.',
      ),
      Interview(
        id: 'i2',
        company: 'SoftServe',
        position: 'Flutter Developer',
        kind: 'HR Interview',
        when: DateTime(2026, 11, 20, 11, 30),
        place: 'Zoom',
        notes: 'Зустріч із рекрутером.',
      ),
      Interview(
        id: 'i3',
        company: 'GlobalLogic',
        position: 'Junior QA Engineer',
        kind: 'Technical Interview',
        when: DateTime(2026, 11, 24, 16),
        place: 'Офіс / Львів',
        notes: 'Повторити тест-дизайн.',
      ),
    ]);
  }

  Map<String, Object?> _snapshot() => {
    'version': 1,
    'nextId': _nextId,
    'vacancies': [
      for (final v in _vacancies)
        {
          'id': v.id,
          'title': v.title,
          'company': v.company,
          'salary': v.salary,
          'city': v.city,
          'status': v.status.name,
          'appliedAt': v.appliedAt.toIso8601String(),
          'notes': v.notes,
          'favorite': v.favorite,
        },
    ],
    'companies': [
      for (final c in _companies)
        {
          'id': c.id,
          'name': c.name,
          'industry': c.industry,
          'city': c.city,
          'website': c.website,
          'notes': c.notes,
        },
    ],
    'interviews': [
      for (final i in _interviews)
        {
          'id': i.id,
          'company': i.company,
          'position': i.position,
          'kind': i.kind,
          'when': i.when.toIso8601String(),
          'place': i.place,
          'notes': i.notes,
        },
    ],
  };

  void _restore(String raw) {
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic> || decoded['version'] != 1) {
      throw const FormatException('Невідома версія локальних даних');
    }
    final companies = (decoded['companies'] as List<dynamic>).map((item) {
      final c = Map<String, dynamic>.from(item as Map);
      return Company(
        id: c['id'] as String,
        name: c['name'] as String,
        industry: c['industry'] as String,
        city: c['city'] as String,
        website: c['website'] as String,
        notes: c['notes'] as String,
      );
    }).toList();
    final vacancies = (decoded['vacancies'] as List<dynamic>).map((item) {
      final v = Map<String, dynamic>.from(item as Map);
      return Vacancy(
        id: v['id'] as String,
        title: v['title'] as String,
        company: v['company'] as String,
        salary: v['salary'] as String,
        city: v['city'] as String,
        status: ApplicationStatus.values.byName(v['status'] as String),
        appliedAt: DateTime.parse(v['appliedAt'] as String),
        notes: v['notes'] as String,
        favorite: v['favorite'] as bool? ?? false,
      );
    }).toList();
    final interviews = (decoded['interviews'] as List<dynamic>).map((item) {
      final i = Map<String, dynamic>.from(item as Map);
      return Interview(
        id: i['id'] as String,
        company: i['company'] as String,
        position: i['position'] as String,
        kind: i['kind'] as String,
        when: DateTime.parse(i['when'] as String),
        place: i['place'] as String,
        notes: i['notes'] as String,
      );
    }).toList();

    // Міняємо колекції тільки після повного успішного розбору JSON.
    _clearLists();
    _companies.addAll(companies);
    _vacancies.addAll(vacancies);
    _interviews.addAll(interviews);
    _nextId = (decoded['nextId'] as num?)?.toInt() ?? 100;
  }

  Future<void> _enqueueSnapshot() {
    final uid = _userId;
    if (uid == null) return Future<void>.value();
    final key = '$_storagePrefix$uid';
    final data = jsonEncode(_snapshot());
    // Послідовний запис гарантує, що швидкі редагування не
    // збережуться на диску у зворотному порядку.
    _writes = _writes.then((_) => _preferences.setString(key, data));
    return _writes;
  }

  void _persist() {
    if (_userId == null || loading) return;
    unawaited(
      _enqueueSnapshot()
          .then((_) {
            if (error != null &&
                error!.startsWith('Не вдалося зберегти зміни')) {
              error = null;
              notifyListeners();
            }
          })
          .catchError((Object failure) {
            error = 'Не вдалося зберегти зміни на пристрої.';
            debugPrint('Catalog save failed: $failure');
            notifyListeners();
            // Наступна спроба запису має бути можлива навіть після помилки.
            _writes = Future<void>.value();
          }),
    );
  }

  void saveVacancy(Vacancy value) {
    final index = _vacancies.indexWhere((item) => item.id == value.id);
    if (index < 0) {
      _vacancies.insert(0, value);
    } else {
      _vacancies[index] = value;
    }
    notifyListeners();
    _persist();
  }

  void deleteVacancy(String id) {
    _vacancies.removeWhere((v) => v.id == id);
    notifyListeners();
    _persist();
  }

  void saveCompany(Company value) {
    final index = _companies.indexWhere((c) => c.id == value.id);
    if (index < 0) {
      _companies.insert(0, value);
    } else {
      _companies[index] = value;
    }
    notifyListeners();
    _persist();
  }

  void deleteCompany(String id) {
    _companies.removeWhere((c) => c.id == id);
    notifyListeners();
    _persist();
  }

  void saveInterview(Interview value) {
    final index = _interviews.indexWhere((i) => i.id == value.id);
    if (index < 0) {
      _interviews.insert(0, value);
    } else {
      _interviews[index] = value;
    }
    notifyListeners();
    _persist();
  }

  void deleteInterview(String id) {
    _interviews.removeWhere((i) => i.id == id);
    notifyListeners();
    _persist();
  }
}
