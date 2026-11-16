import 'package:firebase_auth/firebase_auth.dart';

String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    switch (error.code) {
      case 'invalid-email':
        return 'Невірний формат електронної пошти.';
      case 'invalid-login-credentials':
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Неправильна електронна пошта або пароль.';
      case 'email-already-in-use':
        return 'Акаунт із такою електронною поштою вже існує.';
      case 'weak-password':
        return 'Занадто простий пароль. Спробуйте складніший.';
      case 'requires-recent-login':
        return 'Для цієї дії потрібно повторно увійти в акаунт.';
      case 'user-disabled':
        return 'Цей акаунт заблоковано.';
      case 'too-many-requests':
        return 'Забагато спроб. Повторіть пізніше.';
      case 'network-request-failed':
        return 'Немає з’єднання з мережею. Перевірте інтернет.';
      case 'operation-not-allowed':
        return 'Цей спосіб входу не ввімкнений у Firebase.';
      case 'invalid-password':
        return 'Неправильний поточний пароль.';
      default:
        return 'Не вдалося виконати запит до Firebase. Спробуйте ще раз.';
    }
  }
  if (error is ArgumentError || error is StateError) {
    return error.toString().replaceFirst(
      RegExp(r'^(Invalid argument\(s\)?: |Bad state: )'),
      '',
    );
  }
  return 'Не вдалося виконати дію. Спробуйте ще раз.';
}
