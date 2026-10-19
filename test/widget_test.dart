import 'package:flutter_test/flutter_test.dart';
import 'package:study_catalog/core/auth_validators.dart';

// Замість стандартного тесту лічильника перевіряємо реальні валідатори.
void main() {
  test('email: порожнє поле і некоректний формат', () {
    expect(AuthValidators.email(''), isNotNull);
    expect(AuthValidators.email('wrong-email'), isNotNull);
    expect(AuthValidators.email('test@example.com'), isNull);
  });

  test('пароль: довжина щонайменше 6 символів', () {
    expect(AuthValidators.newPassword('123'), isNotNull);
    expect(AuthValidators.newPassword('123456'), isNull);
  });

  test('підтвердження пароля має збігатися', () {
    expect(AuthValidators.confirmation('123457', '123456'), isNotNull);
    expect(AuthValidators.confirmation('123456', '123456'), isNull);
  });

  test('ім’я користувача обов’язкове', () {
    expect(AuthValidators.name('  '), isNotNull);
    expect(AuthValidators.name('Іван'), isNull);
  });
}
