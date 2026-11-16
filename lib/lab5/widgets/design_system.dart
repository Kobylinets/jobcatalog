import 'package:flutter/material.dart';

import '../models/catalog_models.dart';

const brandPurple = Color(0xFF4D23B5);
const bgLight = Color(0xFFFAF7FF);

ThemeData makeJobTheme(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final scheme = ColorScheme.fromSeed(
    seedColor: brandPurple,
    brightness: brightness,
  );
  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: scheme,
    scaffoldBackgroundColor: dark ? const Color(0xFF121019) : bgLight,
    appBarTheme: AppBarThemeData(
      centerTitle: false,
      backgroundColor: dark ? const Color(0xFF121019) : bgLight,
      foregroundColor: scheme.onSurface,
      elevation: 0,
    ),
    cardTheme: CardThemeData(
      color: dark ? const Color(0xFF211C2D) : Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      elevation: 0,
    ),
    inputDecorationTheme: InputDecorationTheme(
      errorMaxLines: 2,
      filled: true,
      fillColor: dark ? const Color(0xFF292437) : Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: dark ? Colors.white12 : const Color(0xFFE8E1F2),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: brandPurple, width: 1.6),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCF3552)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFCF3552), width: 1.6),
      ),
      errorStyle: const TextStyle(
        color: Color(0xFFDE4261),
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 17),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: brandPurple,
        foregroundColor: Colors.white,
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        elevation: 0,
      ),
    ),
  );
}

class PageHeader extends StatelessWidget {
  const PageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.trailing,
  });
  final String title;
  final String? subtitle;
  final Widget? trailing;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
    child: Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall
                    ?.copyWith(fontWeight: FontWeight.w800),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(
                  subtitle!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
        ?trailing,
      ],
    ),
  );
}

class FormErrorText extends StatelessWidget {
  const FormErrorText(this.message, {super.key});
  final String? message;
  @override
  Widget build(BuildContext context) => message == null || message!.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 9, bottom: 5),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                color: Color(0xFFDE4261),
                size: 17,
              ),
              const SizedBox(width: 7),
              Expanded(
                child: Text(
                  message!,
                  style: const TextStyle(
                    color: Color(0xFFDE4261),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
}

class FormSuccessText extends StatelessWidget {
  const FormSuccessText(this.message, {super.key});
  final String? message;
  @override
  Widget build(BuildContext context) => message == null || message!.isEmpty
      ? const SizedBox.shrink()
      : Padding(
          padding: const EdgeInsets.only(top: 9),
          child: Text(
            message!,
            style: const TextStyle(
              color: Color(0xFF239C77),
              fontWeight: FontWeight.w600,
            ),
          ),
        );
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label, {super.key});
  final String label;
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 15, bottom: 7),
    child: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

class StatusPill extends StatelessWidget {
  const StatusPill(this.status, {super.key});
  final ApplicationStatus status;
  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: status.color.withValues(alpha: .11),
      borderRadius: BorderRadius.circular(22),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      child: Text(
        status.label,
        style: TextStyle(
          color: status.color,
          fontSize: 12,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class BlankSlate extends StatelessWidget {
  const BlankSlate(this.label, {super.key, this.icon = Icons.inbox_outlined});
  final String label;
  final IconData icon;
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 42, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 12),
          Text(
            label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    ),
  );
}

Future<bool> confirmDeletion(BuildContext context, String name) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Видалити запис?',
            style: Theme.of(sheetContext).textTheme.titleLarge
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 9),
          Text('«$name» буде видалено з поточного списку.'),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: () => Navigator.pop(sheetContext, true),
            icon: const Icon(Icons.delete_outline),
            label: const Text('Так, видалити'),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFD3485F),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(sheetContext, false),
            child: const Text('Скасувати'),
          ),
        ],
      ),
    ),
  );
  return result ?? false;
}

String? requiredText(String? input) =>
    input == null || input.trim().isEmpty ? 'Це поле обов’язкове.' : null;
String? emailValidator(String? input) {
  if (requiredText(input) != null) {
    return 'Введіть електронну пошту.';
  }
  if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(input!.trim())) {
    return 'Введіть коректний email, наприклад name@example.com.';
  }
  return null;
}

String? passwordValidator(String? input) {
  if (requiredText(input) != null) {
    return 'Введіть пароль.';
  }
  if (input!.length < 6) {
    return 'Пароль повинен містити щонайменше 6 символів.';
  }
  return null;
}
