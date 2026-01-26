import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {

  static String getPhoneHashSalt() {
    final envSalt = dotenv.env['PHONE_HASH_SALT'];
    if (envSalt == null || envSalt.isEmpty) {
      throw Exception(
        'PHONE_HASH_SALT tidak ditemukan di .env file. '
        'Pastikan file .env sudah dibuat dan berisi PHONE_HASH_SALT',
      );
    }
    return envSalt;
  }
}
