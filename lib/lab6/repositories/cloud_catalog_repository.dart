import 'package:cloud_firestore/cloud_firestore.dart';

import '../../lab5/models/catalog_models.dart';

/// Хмарний репозиторій. Всі дані окремого користувача зберігаються в
/// users/{uid}/{vacancies|companies|interviews}/{documentId}.
class CloudCatalogRepository {
  CloudCatalogRepository({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _user(String uid) =>
      _db.collection('users').doc(uid);

  CollectionReference<Map<String, dynamic>> _collection(
    String uid,
    String kind,
  ) => _user(uid).collection(kind);

  Map<String, dynamic> vacancyToMap(Vacancy v) => {
    'title': v.title,
    'company': v.company,
    'salary': v.salary,
    'city': v.city,
    'status': v.status.name,
    'appliedAt': Timestamp.fromDate(v.appliedAt),
    'notes': v.notes,
    'favorite': v.favorite,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> companyToMap(Company c) => {
    'name': c.name,
    'industry': c.industry,
    'city': c.city,
    'website': c.website,
    'notes': c.notes,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  Map<String, dynamic> interviewToMap(Interview i) => {
    'company': i.company,
    'position': i.position,
    'kind': i.kind,
    'when': Timestamp.fromDate(i.when),
    'place': i.place,
    'notes': i.notes,
    'updatedAt': FieldValue.serverTimestamp(),
  };

  DateTime _date(Object? raw) {
    if (raw is Timestamp) return raw.toDate();
    if (raw is DateTime) return raw;
    if (raw is String) return DateTime.parse(raw);
    throw const FormatException('Відсутня дата в документі Firestore');
  }

  Vacancy _vacancy(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data();
    return Vacancy(
      id: doc.id,
      title: m['title'] as String? ?? '',
      company: m['company'] as String? ?? '',
      salary: m['salary'] as String? ?? '',
      city: m['city'] as String? ?? '',
      status: ApplicationStatus.values.firstWhere(
        (s) => s.name == m['status'],
        orElse: () => ApplicationStatus.sent,
      ),
      appliedAt: _date(m['appliedAt']),
      notes: m['notes'] as String? ?? '',
      favorite: m['favorite'] as bool? ?? false,
    );
  }

  Company _company(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data();
    return Company(
      id: doc.id,
      name: m['name'] as String? ?? '',
      industry: m['industry'] as String? ?? '',
      city: m['city'] as String? ?? '',
      website: m['website'] as String? ?? '',
      notes: m['notes'] as String? ?? '',
    );
  }

  Interview _interview(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final m = doc.data();
    return Interview(
      id: doc.id,
      company: m['company'] as String? ?? '',
      position: m['position'] as String? ?? '',
      kind: m['kind'] as String? ?? '',
      when: _date(m['when']),
      place: m['place'] as String? ?? '',
      notes: m['notes'] as String? ?? '',
    );
  }

  /// Перший запуск ЛР6: переносимо існуючий локальний каталог ЛР5 у хмару.
  /// Прапорець міграції створюється в тому ж batch, тому наступні запуски
  /// НЕ перезаписуватимуть хмарні дані старими локальними копіями.
  /// Для навчального каталогу до 400 записів (обмеження одного batch).
  Future<void> importLocalIfFirstTime(
    String uid, {
    required List<Vacancy> vacancies,
    required List<Company> companies,
    required List<Interview> interviews,
  }) async {
    final marker = _user(uid).collection('meta').doc('catalog');
    final existing = await marker.get();
    if (existing.exists) return;
    final total = vacancies.length + companies.length + interviews.length;
    if (total > 400) {
      throw StateError(
        'Для міграції понад 400 записів потрібен пакетний імпорт.',
      );
    }
    final batch = _db.batch();
    for (final v in vacancies) {
      batch.set(_collection(uid, 'vacancies').doc(v.id), vacancyToMap(v));
    }
    for (final c in companies) {
      batch.set(_collection(uid, 'companies').doc(c.id), companyToMap(c));
    }
    for (final i in interviews) {
      batch.set(_collection(uid, 'interviews').doc(i.id), interviewToMap(i));
    }
    batch.set(marker, {
      'initialized': true,
      'importedAt': FieldValue.serverTimestamp(),
      'schemaVersion': 1,
    });
    await batch.commit();
  }

  Future<List<Vacancy>> getVacancies(String uid) async =>
      (await _collection(uid, 'vacancies').get()).docs.map(_vacancy).toList();
  Future<List<Company>> getCompanies(String uid) async =>
      (await _collection(uid, 'companies').get()).docs.map(_company).toList();
  Future<List<Interview>> getInterviews(String uid) async => (await _collection(
    uid,
    'interviews',
  ).get()).docs.map(_interview).toList();

  Stream<List<Vacancy>> watchVacancies(String uid) => _collection(
    uid,
    'vacancies',
  ).snapshots().map((snapshot) => snapshot.docs.map(_vacancy).toList());
  Stream<List<Company>> watchCompanies(String uid) => _collection(
    uid,
    'companies',
  ).snapshots().map((snapshot) => snapshot.docs.map(_company).toList());
  Stream<List<Interview>> watchInterviews(String uid) => _collection(
    uid,
    'interviews',
  ).snapshots().map((snapshot) => snapshot.docs.map(_interview).toList());

  Future<void> saveVacancy(String uid, Vacancy v) =>
      _collection(uid, 'vacancies').doc(v.id).set(vacancyToMap(v));
  Future<void> deleteVacancy(String uid, String id) =>
      _collection(uid, 'vacancies').doc(id).delete();
  Future<void> saveCompany(String uid, Company c) =>
      _collection(uid, 'companies').doc(c.id).set(companyToMap(c));
  Future<void> deleteCompany(String uid, String id) =>
      _collection(uid, 'companies').doc(id).delete();
  Future<void> saveInterview(String uid, Interview i) =>
      _collection(uid, 'interviews').doc(i.id).set(interviewToMap(i));
  Future<void> deleteInterview(String uid, String id) =>
      _collection(uid, 'interviews').doc(id).delete();
}
