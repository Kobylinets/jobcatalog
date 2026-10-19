class AuthValidators {
  static String? name(String? value) {
    if ((value ?? '').trim().isEmpty) return 'Введіть ваше ім’я';
    return null;
  }

  static String? email(String? value) {
    final text = (value ?? '').trim();
    if (text.isEmpty) return 'Введіть електронну пошту';
    if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(text)) {
      return 'Неправильний формат електронної пошти';
    }
    return null;
  }

  static String? loginPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Введіть пароль';
    return null;
  }

  static String? newPassword(String? value) {
    if ((value ?? '').isEmpty) return 'Введіть пароль';
    if (value!.length < 6) return 'Мінімум 6 символів';
    return null;
  }

  static String? confirmation(String? value, String password) {
    if ((value ?? '').isEmpty) return 'Підтвердіть пароль';
    if (value != password) return 'Паролі не збігаються';
    return null;
  }
}
