import 'package:flutter/material.dart';

enum ApplicationStatus { sent, interview, task, rejected, offer }

extension ApplicationStatusLabel on ApplicationStatus {
  String get label => switch (this) {
    ApplicationStatus.sent => 'Відправлено',
    ApplicationStatus.interview => 'Співбесіда',
    ApplicationStatus.task => 'Тестове',
    ApplicationStatus.rejected => 'Відмова',
    ApplicationStatus.offer => 'Офер',
  };

  Color get color => switch (this) {
    ApplicationStatus.sent => const Color(0xFF5078CE),
    ApplicationStatus.interview => const Color(0xFF7353D8),
    ApplicationStatus.task => const Color(0xFFE49A20),
    ApplicationStatus.rejected => const Color(0xFFD64B62),
    ApplicationStatus.offer => const Color(0xFF209D73),
  };
}

class Vacancy {
  const Vacancy({
    required this.id,
    required this.title,
    required this.company,
    required this.salary,
    required this.city,
    required this.status,
    required this.appliedAt,
    required this.notes,
    this.favorite = false,
  });

  final String id;
  final String title;
  final String company;
  final String salary;
  final String city;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final String notes;
  final bool favorite;

  Vacancy copyWith({
    String? title,
    String? company,
    String? salary,
    String? city,
    ApplicationStatus? status,
    DateTime? appliedAt,
    String? notes,
    bool? favorite,
  }) => Vacancy(
    id: id,
    title: title ?? this.title,
    company: company ?? this.company,
    salary: salary ?? this.salary,
    city: city ?? this.city,
    status: status ?? this.status,
    appliedAt: appliedAt ?? this.appliedAt,
    notes: notes ?? this.notes,
    favorite: favorite ?? this.favorite,
  );
}

class Company {
  const Company({
    required this.id,
    required this.name,
    required this.industry,
    required this.city,
    required this.website,
    required this.notes,
  });

  final String id;
  final String name;
  final String industry;
  final String city;
  final String website;
  final String notes;

  Company copyWith({
    String? name,
    String? industry,
    String? city,
    String? website,
    String? notes,
  }) => Company(
    id: id,
    name: name ?? this.name,
    industry: industry ?? this.industry,
    city: city ?? this.city,
    website: website ?? this.website,
    notes: notes ?? this.notes,
  );
}

class Interview {
  const Interview({
    required this.id,
    required this.company,
    required this.position,
    required this.kind,
    required this.when,
    required this.place,
    required this.notes,
  });

  final String id;
  final String company;
  final String position;
  final String kind;
  final DateTime when;
  final String place;
  final String notes;

  Interview copyWith({
    String? company,
    String? position,
    String? kind,
    DateTime? when,
    String? place,
    String? notes,
  }) => Interview(
    id: id,
    company: company ?? this.company,
    position: position ?? this.position,
    kind: kind ?? this.kind,
    when: when ?? this.when,
    place: place ?? this.place,
    notes: notes ?? this.notes,
  );
}

String dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
String dateTimeLabel(DateTime date) =>
    '${dateLabel(date)}  ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
