import 'dart:convert';
import 'package:crypto/crypto.dart';

extension StringExtension on String {
  String toFormattedPhone() {
    var phone = replaceAll(RegExp(r'[^\d+]'), '');
    
    if (phone.startsWith('0')) {
      phone = '+62${phone.substring(1)}';
    } else if (phone.startsWith('62') && !phone.startsWith('+')) {
      phone = '+$phone';
    } else if (!phone.startsWith('+')) {
      phone = '+62$phone';
    }
    return phone;
  }

  /// Hash phone number menggunakan SHA-256 untuk Firebase
  /// Format: hash dari nomor telepon yang sudah diformat
  String toPhoneHash() {
    final formatted = toFormattedPhone();
    final bytes = utf8.encode(formatted);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Hash phone number dengan custom salt untuk keamanan tambahan
  /// Berguna untuk indexing atau searching di Firebase
  String toPhoneHashWithSalt(String salt) {
    final formatted = toFormattedPhone();
    final salted = '$formatted$salt';
    final bytes = utf8.encode(salted);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// Ambil 3 angka terakhir dari nomor telepon
  /// Berguna untuk display atau searching
  String getLast3Digits() {
    // Ambil hanya angka
    final digitsOnly = replaceAll(RegExp(r'[^\d]'), '');
    if (digitsOnly.length >= 3) {
      return digitsOnly.substring(digitsOnly.length - 3);
    }
    return digitsOnly;
  }
}