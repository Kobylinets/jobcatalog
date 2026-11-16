import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../state/auth_controller.dart';
import '../state/theme_controller.dart';
import '../widgets/design_system.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});
  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final form = GlobalKey<FormState>();
  final email = TextEditingController();
  final password = TextEditingController();
  final name = TextEditingController();
  final confirm = TextEditingController();
  bool showPassword = false;
  int mode = 0; // 0 - вхід, 1 - реєстрація, 2 - відновлення

  void switchMode(int value) {
    context.read<AuthController>().clearMessage();
    setState(() {
      mode = value;
      form.currentState?.reset();
    });
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    name.dispose();
    confirm.dispose();
    super.dispose();
  }

  Future<void> submit() async {
    if (!(form.currentState?.validate() ?? false)) {
      return;
    }
    final auth = context.read<AuthController>();
    if (mode == 0) {
      await auth.signIn(email.text.trim(), password.text);
    } else if (mode == 1) {
      await auth.signUp(name.text.trim(), email.text.trim(), password.text);
    } else {
      await auth.resetPassword(email.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 35),
                  child: Form(
                    key: form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: CircleAvatar(
                            radius: 31,
                            backgroundColor: brandPurple.withValues(alpha: .12),
                            child: const Icon(
                              Icons.work_outline,
                              color: brandPurple,
                              size: 33,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          mode == 0
                              ? 'Вітаємо знову!'
                              : mode == 1
                              ? 'Створіть акаунт'
                              : 'Відновлення пароля',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          mode == 0
                              ? 'Керуйте вакансіями, співбесідами та своїми заявками.'
                              : mode == 1
                              ? 'Зберігайте всі можливості в одному місці.'
                              : 'Ми надішлемо лист для зміни пароля.',
                          style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (mode == 1) ...[
                          const FieldLabel('Ім’я'),
                          TextFormField(
                            controller: name,
                            textCapitalization: TextCapitalization.words,
                            decoration: const InputDecoration(
                              hintText: 'Ваше ім’я',
                            ),
                            validator: requiredText,
                          ),
                        ],
                        const FieldLabel('Електронна пошта'),
                        TextFormField(
                          controller: email,
                          keyboardType: TextInputType.emailAddress,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            hintText: 'name@example.com',
                          ),
                          validator: emailValidator,
                        ),
                        if (mode != 2) ...[
                          const FieldLabel('Пароль'),
                          TextFormField(
                            controller: password,
                            obscureText: !showPassword,
                            decoration: InputDecoration(
                              hintText: 'Мінімум 6 символів',
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                  () => showPassword = !showPassword,
                                ),
                                icon: Icon(
                                  showPassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                ),
                              ),
                            ),
                            validator: passwordValidator,
                          ),
                        ],
                        if (mode == 1) ...[
                          const FieldLabel('Повторіть пароль'),
                          TextFormField(
                            controller: confirm,
                            obscureText: !showPassword,
                            decoration: const InputDecoration(
                              hintText: 'Повторіть пароль',
                            ),
                            validator: (input) => input != password.text
                                ? 'Паролі не збігаються.'
                                : requiredText(input),
                          ),
                        ],
                        if (mode == 0)
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () => switchMode(2),
                              child: const Text('Забули пароль?'),
                            ),
                          ),
                        FormErrorText(auth.error),
                        FormSuccessText(auth.success),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: auth.busy ? null : submit,
                          child: auth.busy
                              ? const SizedBox(
                                  height: 22,
                                  width: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : Text(
                                  mode == 0
                                      ? 'Увійти'
                                      : mode == 1
                                      ? 'Зареєструватися'
                                      : 'Надіслати лист',
                                ),
                        ),
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: auth.busy
                              ? null
                              : () => switchMode(mode == 0 ? 1 : 0),
                          child: Text(
                            mode == 0
                                ? 'Ще немає акаунта? Зареєструватися'
                                : 'Повернутися до входу',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // LAB5_LOGIN_THEME_TOGGLE: доступний до входу, реєстрації та відновлення пароля.
          Positioned(
            top: 0,
            right: 16,
            child: SafeArea(
              child: Consumer<ThemeController>(
                builder: (context, theme, _) => IconButton(
                  tooltip: theme.isDark
                      ? 'Увімкнути світлу тему'
                      : 'Увімкнути темну тему',
                  icon: Icon(
                    theme.isDark
                        ? Icons.light_mode_outlined
                        : Icons.dark_mode_outlined,
                  ),
                  onPressed: () {
                    theme.setDark(!theme.isDark);
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});
  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final form = GlobalKey<FormState>();
  final oldPassword = TextEditingController();
  final newPassword = TextEditingController();
  final repeat = TextEditingController();
  @override
  void dispose() {
    oldPassword.dispose();
    newPassword.dispose();
    repeat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Зміна пароля')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const FieldLabel('Поточний пароль'),
                  TextFormField(
                    controller: oldPassword,
                    obscureText: true,
                    validator: requiredText,
                    decoration: const InputDecoration(
                      hintText: 'Введіть поточний пароль',
                    ),
                  ),
                  const FieldLabel('Новий пароль'),
                  TextFormField(
                    controller: newPassword,
                    obscureText: true,
                    validator: passwordValidator,
                    decoration: const InputDecoration(
                      hintText: 'Від 6 символів',
                    ),
                  ),
                  const FieldLabel('Повторіть новий пароль'),
                  TextFormField(
                    controller: repeat,
                    obscureText: true,
                    decoration: const InputDecoration(
                      hintText: 'Повторіть пароль',
                    ),
                    validator: (value) => value != newPassword.text
                        ? 'Паролі не збігаються.'
                        : requiredText(value),
                  ),
                  FormErrorText(auth.error),
                  FormSuccessText(auth.success),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: auth.busy
                        ? null
                        : () async {
                            if (!(form.currentState?.validate() ?? false)) {
                              return;
                            }
                            final ok = await context
                                .read<AuthController>()
                                .changePassword(
                                  oldPassword.text,
                                  newPassword.text,
                                );
                            if (ok) {
                              oldPassword.clear();
                              newPassword.clear();
                              repeat.clear();
                            }
                          },
                    child: Text(auth.busy ? 'Зберігаємо...' : 'Змінити пароль'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final form = GlobalKey<FormState>();
  final photoForm = GlobalKey<FormState>();
  late final TextEditingController name;
  late final TextEditingController photo;
  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthController>();
    name = TextEditingController(text: auth.user?.displayName ?? '');
    photo = TextEditingController(text: auth.photoUrl ?? '');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthController>().refreshProfile();
      }
    });
  }

  @override
  void dispose() {
    name.dispose();
    photo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
      children: [
        const PageHeader(
          title: 'Мій профіль',
          subtitle: 'Дані облікового запису Firebase',
        ),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: brandPurple.withValues(alpha: .15),
                  backgroundImage: auth.photoUrl?.isNotEmpty == true
                      ? NetworkImage(auth.photoUrl!)
                      : null,
                  child: auth.photoUrl?.isNotEmpty == true
                      ? null
                      : const Icon(
                          Icons.person_outline,
                          size: 44,
                          color: brandPurple,
                        ),
                ),
                const SizedBox(height: 12),
                Text(
                  auth.name,
                  style: Theme.of(context).textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  auth.email,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: form,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Особисті дані',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const FieldLabel('Ім’я'),
                  TextFormField(
                    controller: name,
                    decoration: const InputDecoration(hintText: 'Ім’я'),
                    validator: requiredText,
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: auth.busy
                        ? null
                        : () {
                            if (form.currentState!.validate()) {
                              context.read<AuthController>().updateName(
                                name.text.trim(),
                              );
                            }
                          },
                    child: const Text('Зберегти ім’я'),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Form(
              key: photoForm,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Фотографія профілю',
                    style: Theme.of(context).textTheme.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                  const FieldLabel('HTTPS-посилання на зображення'),
                  TextFormField(
                    controller: photo,
                    decoration: const InputDecoration(
                      hintText: 'https://example.com/avatar.jpg',
                    ),
                    validator: (value) {
                      final uri = Uri.tryParse(value ?? '');
                      return uri?.scheme == 'https' &&
                              uri?.host.isNotEmpty == true
                          ? null
                          : 'Введіть коректне HTTPS-посилання.';
                    },
                  ),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: auth.busy
                        ? null
                        : () {
                            if (photoForm.currentState!.validate()) {
                              context.read<AuthController>().updatePhoto(
                                photo.text.trim(),
                              );
                            }
                          },
                    child: const Text('Оновити фото'),
                  ),
                ],
              ),
            ),
          ),
        ),
        FormErrorText(auth.error),
        FormSuccessText(auth.success),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.lock_outline),
                title: const Text('Змінити пароль'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  context.read<AuthController>().clearMessage();
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (_) => const ChangePasswordPage(),
                    ),
                  );
                },
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFCE455B)),
                title: const Text('Вийти з акаунта'),
                onTap: auth.busy
                    ? null
                    : () => context.read<AuthController>().signOut(),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
