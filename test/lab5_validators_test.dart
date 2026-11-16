import 'package:flutter_test/flutter_test.dart';
import 'package:study_catalog/lab5/widgets/design_system.dart';

void main() {
  test('required field', () {
    expect(requiredText(''), isNotNull);
    expect(requiredText('  '), isNotNull);
    expect(requiredText('Flutter'), isNull);
  });
  test('email format', () {
    expect(emailValidator('not-email'), isNotNull);
    expect(emailValidator('test@example.com'), isNull);
  });
  test('password length', () {
    expect(passwordValidator('123'), isNotNull);
    expect(passwordValidator('123456'), isNull);
  });
}
