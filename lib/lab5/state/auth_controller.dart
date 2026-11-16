import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../../repositories/auth_repository.dart';

/// Provider для входу, реєстрації, профілю та зміни пароля.
/// Вся мережева логіка залишається у Firebase AuthRepository з ЛР №4.
class AuthController extends ChangeNotifier {
  AuthController(this.repository) {
    _subscription = repository.authStateChanges().listen(
      (user) {
        _user = user;
        initialized = true;
        notifyListeners();
      },
      onError: (Object failure) {
        initialized = true;
        error = 'Не вдалося перевірити сеанс користувача.';
        notifyListeners();
      },
    );
  }

  final AuthRepository repository;
  late final StreamSubscription<User?> _subscription;
  User? _user;
  bool initialized = false;
  bool busy = false;
  String? error;
  String? success;
  User? get user => _user;
  bool get signedIn => _user != null;
  String get name => _user?.displayName?.trim().isNotEmpty == true
      ? _user!.displayName!
      : 'Користувач Job Catalog';
  String get email => _user?.email ?? '';
  String? get photoUrl => _user?.photoURL;

  void clearMessage() {
    error = null;
    success = null;
    notifyListeners();
  }

  Future<bool> _perform(
    Future<void> Function() action, {
    String? successText,
  }) async {
    error = null;
    success = null;
    busy = true;
    notifyListeners();
    try {
      await action();
      if (successText != null) success = successText;
      return true;
    } on FirebaseAuthException catch (exception) {
      error = switch (exception.code) {
        'invalid-email' => 'Перевірте правильність електронної пошти.',
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => 'Неправильна пошта або пароль.',
        'email-already-in-use' => 'Користувач із такою поштою вже існує.',
        'weak-password' => 'Пароль надто слабкий. Використайте надійніший.',
        'network-request-failed' => 'Перевірте підключення до інтернету.',
        'too-many-requests' => 'Забагато спроб. Спробуйте пізніше.',
        'requires-recent-login' => 'Для зміни даних виконайте повторний вхід.',
        _ => exception.message ?? 'Не вдалося виконати операцію.',
      };
      return false;
    } catch (exception) {
      error = exception is ArgumentError
          ? 'Введіть коректні дані.'
          : 'Сталася помилка. Спробуйте ще раз.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  Future<bool> signIn(String email, String password) =>
      _perform(() => repository.signIn(email: email, password: password));
  Future<bool> signUp(String name, String email, String password) =>
      _perform(() async {
        await repository.signUp(name: name, email: email, password: password);
        _user = repository.currentUser;
      });
  Future<void> refreshProfile() async {
    try {
      await repository.reloadUser();
      _user = repository.currentUser;
      notifyListeners();
    } catch (_) {
      // Кешовані дані профілю залишаються доступними без мережі.
    }
  }

  Future<bool> resetPassword(String email) => _perform(
    () => repository.resetPassword(email: email),
    successText: 'Лист для відновлення пароля надіслано. Перевірте пошту.',
  );
  Future<bool> signOut() => _perform(repository.signOut);

  Future<bool> updateName(String name) => _perform(() async {
    await repository.updateName(name);
    _user = repository.currentUser;
  }, successText: 'Ім’я профілю оновлено.');

  Future<bool> updatePhoto(String url) => _perform(() async {
    await repository.updatePhoto(url);
    _user = repository.currentUser;
  }, successText: 'Фотографію профілю оновлено.');

  Future<bool> changePassword(String oldPassword, String newPassword) =>
      _perform(
        () => repository.changePassword(
          currentPassword: oldPassword,
          newPassword: newPassword,
        ),
        successText: 'Пароль успішно змінено.',
      );

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
