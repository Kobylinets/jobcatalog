import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Уся взаємодія з Firebase Authentication винесена з UI.
class AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? get currentUser => _auth.currentUser;
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  Future<void> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await credential.user!.updateDisplayName(name.trim());
    await credential.user!.reload();
    await _logAnalytics('registration_completed');
  }

  Future<void> signIn({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    await _logAnalytics('login_completed');
  }

  Future<void> signOut() => _auth.signOut();

  Future<void> resetPassword({required String email}) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<void> reloadUser() async {
    await _auth.currentUser?.reload();
  }

  Future<void> updateName(String name) async {
    final user = _requireUser();
    await user.updateDisplayName(name.trim());
    await user.reload();
  }

  Future<void> updatePhoto(String photoUrl) async {
    final uri = Uri.tryParse(photoUrl);
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) {
      throw ArgumentError('Потрібне коректне HTTPS-посилання.');
    }
    final user = _requireUser();
    await user.updatePhotoURL(photoUrl);
    await user.reload();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _requireUser();
    final email = user.email;
    if (email == null) {
      throw StateError('Для цього акаунта недоступна зміна пароля.');
    }

    // Потрібний поточний пароль: підтверджуємо особу перед зміною.
    final credential = EmailAuthProvider.credential(
      email: email,
      password: currentPassword,
    );
    await user.reauthenticateWithCredential(credential);
    await user.updatePassword(newPassword);
  }

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('Спочатку увійдіть в акаунт.');
    }
    return user;
  }

  Future<void> _logAnalytics(String name) async {
    try {
      await FirebaseAnalytics.instance.logEvent(name: name);
    } catch (_) {
      // Збій аналітики не скасовує успішну реєстрацію або вхід.
    }
  }
}
