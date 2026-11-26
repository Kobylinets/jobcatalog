import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

import '../../lab5/state/auth_controller.dart';
import '../repositories/profile_media_repository.dart';

/// ЛР №6: image_picker -> Repository/Supabase Storage -> публічний URL
/// -> Firebase Auth (photoURL) + Firestore (метадані).
/// Provider керує станами uploading/error/success, UI не виконує API-запитів.
class ProfileMediaController extends ChangeNotifier {
  ProfileMediaController({
    ImagePicker? picker,
    ProfileMediaRepository? repository,
  }) : _picker = picker ?? ImagePicker(),
       _repository = repository ?? ProfileMediaRepository();

  final ImagePicker _picker;
  final ProfileMediaRepository _repository;

  bool uploading = false;
  String? error;
  String? success;

  Future<bool> pickAndUpload(
    AuthController auth, {
    required ImageSource source,
  }) async {
    if (uploading) return false;
    error = null;
    success = null;
    notifyListeners();

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) throw StateError('Спочатку увійдіть у свій акаунт.');

      final image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1280,
        maxHeight: 1280,
      );
      if (image == null) return false; // Користувач скасував вибір.

      uploading = true;
      notifyListeners();
      final bytes = await image.readAsBytes();
      if (bytes.length > 5 * 1024 * 1024) {
        throw StateError('Файл завеликий. Максимум 5 МБ.');
      }
      final contentType = _detectImageType(bytes);
      if (contentType == null) {
        throw StateError(
          'Цей формат не підтримується. Оберіть JPEG, PNG або WebP.',
        );
      }

      final uploaded = await _repository.uploadAvatar(
        firebaseUid: uid,
        bytes: bytes,
        contentType: contentType,
      );
      if (FirebaseAuth.instance.currentUser?.uid != uid) {
        throw StateError(
          'Акаунт змінився під час завантаження. Повторіть вхід.',
        );
      }

      // Зберігаємо URL у Firebase Auth — він доступний після перезапуску.
      final updated = await auth.updatePhoto(uploaded.url);
      if (!updated) {
        throw StateError('Фото є в Supabase, але профіль не оновився.');
      }

      // Метадані у Firestore потрібні для демонстрації поєднання Storage та БД.
      final recordId = DateTime.now().microsecondsSinceEpoch.toString();
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('media')
            .doc(recordId)
            .set({
              'ownerUid': uid,
              'provider': 'supabase',
              'bucket': ProfileMediaRepository.bucket,
              'storagePath': uploaded.path,
              'downloadUrl': uploaded.url,
              'contentType': contentType,
              'sizeBytes': bytes.length,
              'createdAt': FieldValue.serverTimestamp(),
            });
        success = 'Фото завантажено в Supabase і збережено у профілі.';
      } on FirebaseException catch (exception) {
        debugPrint('Firestore media metadata: $exception');
        success = 'Аватар оновлено, але запис метаданих Firestore не вдався.';
      }
      return true;
    } catch (exception, stack) {
      debugPrint('Supabase avatar upload failed: $exception\n$stack');
      error = exception is StateError
          ? exception.message.toString()
          : 'Не вдалося завантажити фото. Перевірте інтернет, '
                'ключ Supabase та політику lab6_anon_upload.';
      return false;
    } finally {
      uploading = false;
      notifyListeners();
    }
  }

  /// MIME визначається за сигнатурою файлу, а не лише його розширенням.
  String? _detectImageType(Uint8List b) {
    if (b.length >= 3 && b[0] == 0xff && b[1] == 0xd8 && b[2] == 0xff) {
      return 'image/jpeg';
    }
    if (b.length >= 8 &&
        b[0] == 0x89 &&
        b[1] == 0x50 &&
        b[2] == 0x4e &&
        b[3] == 0x47 &&
        b[4] == 0x0d &&
        b[5] == 0x0a &&
        b[6] == 0x1a &&
        b[7] == 0x0a) {
      return 'image/png';
    }
    if (b.length >= 12 &&
        String.fromCharCodes(b.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(b.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }
}
