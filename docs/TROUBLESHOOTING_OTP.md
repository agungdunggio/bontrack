# 🔧 Troubleshooting OTP Crash

## Masalah yang Sudah Diperbaiki

### 1. **BLoC Emit di Callback** ✅
**Masalah:** `emit()` dipanggil langsung dari callback Firebase, yang bisa crash jika BLoC sudah closed.

**Solusi:** 
- Tambahkan check `!isClosed` sebelum setiap `emit()`
- Tambahkan try-catch di semua callback

```dart
codeSent: (String verificationId) {
  if (!isClosed) {
    emit(AuthOTPSent(...));
  }
}
```

### 2. **Widget Disposed saat Navigation** ✅
**Masalah:** Navigasi terjadi saat widget sudah disposed.

**Solusi:**
- Check `mounted` sebelum navigasi
- Gunakan `listenWhen` untuk filter state changes

```dart
listener: (context, state) {
  if (!mounted) return;
  // Safe navigation
}
```

### 3. **Error Handling yang Lebih Baik** ✅
**Masalah:** Error dari Firebase tidak di-handle dengan baik.

**Solusi:**
- Handle specific Firebase error codes
- Tampilkan pesan error yang user-friendly

## Common Crash Causes & Solutions

### 1. Invalid Phone Number Format

**Error:** `invalid-phone-number`

**Solusi:**
```dart
// Pastikan format: +62xxxxxxxxxxx
String _formatPhoneNumber(String phone) {
  phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
  if (phone.startsWith('0')) {
    phone = '+62${phone.substring(1)}';
  } else if (!phone.startsWith('+')) {
    phone = '+62$phone';
  }
  return phone;
}
```

### 2. Too Many Requests

**Error:** `too-many-requests`

**Solusi:**
- Tambahkan cooldown period
- Limit jumlah request per user
- Tampilkan pesan yang jelas

### 3. Quota Exceeded

**Error:** `quota-exceeded`

**Solusi:**
- Check Firebase quota di console
- Upgrade ke Blaze plan jika perlu
- Gunakan test phone numbers untuk development

### 4. Network Issues

**Error:** Timeout atau connection error

**Solusi:**
- Check koneksi internet
- Tambahkan retry mechanism
- Tampilkan loading indicator

### 5. Android Permissions

**Error:** SMS permission not granted

**Solusi:**
- Tambahkan permission di AndroidManifest.xml:
```xml
<uses-permission android:name="android.permission.RECEIVE_SMS"/>
<uses-permission android:name="android.permission.READ_SMS"/>
```

### 6. Firebase Configuration

**Error:** Firebase not initialized

**Solusi:**
- Pastikan `firebase_options.dart` sudah di-generate
- Check `google-services.json` ada di `android/app/`
- Pastikan Firebase project sudah setup Phone Auth

## Debug Checklist

### ✅ Pre-Check
- [ ] Firebase Phone Auth enabled
- [ ] `google-services.json` ada
- [ ] `firebase_options.dart` sudah di-generate
- [ ] Android permissions ditambahkan
- [ ] Format nomor telepon benar (+62xxx)

### ✅ Testing
1. **Test dengan Test Phone Number**
   ```
   Phone: +6281234567890
   Code: 123456
   ```

2. **Check Logs**
   ```bash
   flutter run -v
   # atau
   adb logcat | grep -i firebase
   ```

3. **Check Firebase Console**
   - Authentication > Users
   - Usage & billing

### ✅ Common Fixes

**Fix 1: Clear App Data**
```bash
adb shell pm clear com.example.bontrack
```

**Fix 2: Rebuild App**
```bash
flutter clean
flutter pub get
flutter run
```

**Fix 3: Check Firebase Rules**
```javascript
// Firestore rules harus allow read/write untuk authenticated users
```

## Error Messages & Solutions

| Error Code | Message | Solution |
|------------|---------|----------|
| `invalid-phone-number` | Nomor tidak valid | Format: +62xxxxxxxxxxx |
| `too-many-requests` | Terlalu banyak request | Tunggu beberapa menit |
| `quota-exceeded` | Kuota habis | Upgrade Firebase plan |
| `session-expired` | Sesi expired | Request OTP baru |
| `invalid-verification-code` | Kode salah | Masukkan kode yang benar |

## Best Practices

### 1. Error Handling
```dart
try {
  await verifyPhoneNumber(...);
} catch (e) {
  if (!isClosed) {
    emit(AuthError('Error: ${e.toString()}'));
  }
}
```

### 2. State Management
```dart
// Always check isClosed before emit
if (!isClosed) {
  emit(NewState());
}
```

### 3. Navigation Safety
```dart
if (mounted) {
  Navigator.push(...);
}
```

### 4. User Feedback
```dart
// Show loading
emit(AuthLoading());

// Show error with clear message
emit(AuthError('Pesan error yang jelas'));
```

## Testing Steps

1. **Test dengan Nomor Test**
   - Setup test phone di Firebase Console
   - Gunakan nomor test untuk development

2. **Test dengan Nomor Real**
   - Pastikan koneksi internet stabil
   - Check SMS inbox
   - Test di device yang berbeda

3. **Test Error Scenarios**
   - Invalid phone number
   - Network offline
   - Wrong OTP code
   - Expired session

## Monitoring

### Firebase Console
- **Authentication > Users**: Check registered users
- **Usage & Billing**: Monitor quota usage
- **Firestore**: Check user documents

### App Logs
```dart
// Enable debug logging
FirebaseAuth.instance.setSettings(
  appVerificationDisabledForTesting: false,
);
```

## Still Having Issues?

1. **Check Logs**
   ```bash
   flutter run -v
   ```

2. **Check Firebase Console**
   - Authentication settings
   - Usage quota
   - Error logs

3. **Test dengan Minimal Code**
   - Buat test app sederhana
   - Isolate masalah

4. **Check Dependencies**
   ```bash
   flutter pub outdated
   flutter pub upgrade
   ```

---

**Semua masalah crash sudah diperbaiki! 🎉**

Jika masih ada masalah, check logs dan pastikan semua setup sudah benar.

