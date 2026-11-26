import 'dart:math';
import 'dart:typed_data';

import 'package:supabase_flutter/supabase_flutter.dart';

/// Repository для лабораторної №6: зберігання медіафайлів у Supabase Storage.
/// Для демонстраційного bucket використовується шлях lab6/{firebaseUid}/...
/// ВАЖЛИВО: публічна анонімна INSERT-політика НЕ підтверджує власника UID.
class ProfileMediaRepository {
  ProfileMediaRepository({this.client});

  final SupabaseClient? client;
  static const String bucket = 'profile-photos';

  Future<ProfileMediaUpload> uploadAvatar({
    required String firebaseUid,
    required Uint8List bytes,
    required String contentType,
  }) async {
    const configuredUrl = String.fromEnvironment('SUPABASE_URL');
    const configuredKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');
    if (client == null && (configuredUrl.isEmpty || configuredKey.isEmpty)) {
      throw StateError(
        'Supabase не налаштовано. Запусти застосунок із '
        '--dart-define-from-file=.lab6_supabase.json',
      );
    }
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw StateError('Розмір фотографії повинен бути від 1 байта до 5 МБ.');
    }
    const formats = {
      'image/jpeg': 'jpg',
      'image/png': 'png',
      'image/webp': 'webp',
    };
    final extension = formats[contentType];
    if (extension == null) {
      throw StateError('Дозволені лише JPEG, PNG і WebP.');
    }
    final safeUid = firebaseUid.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    if (safeUid.isEmpty) throw StateError('Відсутній Firebase UID.');

    final nonce = Random.secure().nextInt(0x7fffffff).toRadixString(16);
    final name =
        'avatar_${DateTime.now().microsecondsSinceEpoch}_$nonce.$extension';
    final path = 'lab6/$safeUid/$name';
    final storage = (client ?? Supabase.instance.client).storage.from(bucket);

    // Важливо: upsert=false. Для анонімної політики дозволено тільки INSERT.
    await storage.uploadBinary(
      path,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: false),
    );
    final publicUrl = storage.getPublicUrl(path);
    return ProfileMediaUpload(path: path, url: publicUrl);
  }
}

class ProfileMediaUpload {
  const ProfileMediaUpload({required this.path, required this.url});
  final String path;
  final String url;
}
