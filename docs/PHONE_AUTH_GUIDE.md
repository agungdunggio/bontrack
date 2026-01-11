# 📱 Panduan Phone Authentication

Aplikasi Kasbon menggunakan **Phone Number Authentication** sebagai metode login utama. Nomor telepon adalah **core master** (identitas utama) setiap user.

## 🎯 Kenapa Phone Authentication?

1. **Lebih Mudah** - User tidak perlu mengingat password
2. **Lebih Aman** - OTP verification langsung ke HP user
3. **User-Friendly** - Familiar untuk user Indonesia
4. **Identitas Unik** - Nomor telepon sebagai identifier utama

## 🔧 Setup Phone Authentication di Firebase

### 1. Aktifkan Phone Authentication

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. Klik **Authentication** di sidebar
4. Tab **Sign-in method**
5. Klik **Phone**
6. Toggle untuk **Enable**
7. Klik **Save**

### 2. Setup Test Phone Numbers (Untuk Development)

Agar tidak menghabiskan kuota SMS saat testing:

1. Di halaman Phone Authentication
2. Klik **Phone numbers for testing**
3. Tambahkan test numbers, contoh:
   - Phone: `+6281234567890`
   - Code: `123456`
4. Klik **Add**

Sekarang saat login dengan `+6281234567890`, Anda bisa langsung masukkan `123456` tanpa perlu SMS.

### 3. Quota & Pricing

**Free Tier (Spark Plan):**
- 10 phone authentications per day
- Gratis selamanya

**Blaze Plan (Pay as you go):**
- $0.05 per verification di Indonesia
- Unlimited verifications

**Tips:**
- Gunakan test phone numbers untuk development
- Aktifkan reCAPTCHA untuk production (otomatis di web)

## 📱 Alur Login User

### Untuk User Baru (First Time)

```
1. User buka aplikasi
   ↓
2. Masukkan nomor telepon
   ↓
3. Klik "Kirim Kode OTP"
   ↓
4. SMS OTP dikirim ke nomor user
   ↓
5. User masukkan 6 digit OTP
   ↓
6. Verifikasi berhasil
   ↓
7. Sistem deteksi: User baru
   ↓
8. Redirect ke halaman Register
   ↓
9. User isi nama (wajib) dan email (opsional)
   ↓
10. Data disimpan ke Firestore
   ↓
11. Redirect ke Home Screen
```

### Untuk User yang Sudah Terdaftar

```
1. User buka aplikasi
   ↓
2. Masukkan nomor telepon
   ↓
3. Klik "Kirim Kode OTP"
   ↓
4. SMS OTP dikirim
   ↓
5. User masukkan 6 digit OTP
   ↓
6. Verifikasi berhasil
   ↓
7. Sistem deteksi: User sudah ada
   ↓
8. Langsung redirect ke Home Screen
```

## 🔐 Keamanan

### OTP Expiration
- OTP valid selama **60 detik**
- Setelah expired, user perlu request OTP baru

### Rate Limiting
- Firebase otomatis limit request dari IP yang sama
- Mencegah spam OTP

### reCAPTCHA (Web Only)
- Otomatis aktif di web
- Mencegah bot attack

## 📝 Format Nomor Telepon

Aplikasi otomatis format nomor telepon:

| Input User | Diformat Menjadi |
|------------|------------------|
| 08123456789 | +628123456789 |
| 8123456789 | +628123456789 |
| 628123456789 | +628123456789 |
| +628123456789 | +628123456789 |

Semua format akan dikonversi ke format internasional: `+62xxx`

## 🐛 Troubleshooting

### Error: "TOO_MANY_REQUESTS"

**Penyebab:** Terlalu banyak request OTP dalam waktu singkat

**Solusi:**
- Tunggu beberapa menit
- Gunakan test phone numbers untuk development
- Check Firebase quota

### Error: "INVALID_PHONE_NUMBER"

**Penyebab:** Format nomor tidak valid

**Solusi:**
- Pastikan nomor valid (minimal 10 digit)
- Gunakan format: `08xxx` atau `+62xxx`

### Error: "SESSION_EXPIRED"

**Penyebab:** OTP sudah expired (> 60 detik)

**Solusi:**
- Klik "Kirim Ulang" untuk request OTP baru

### OTP Tidak Masuk

**Solusi:**
1. Cek koneksi internet
2. Pastikan nomor telepon benar
3. Cek SMS spam/blocked
4. Tunggu 2-3 menit
5. Coba kirim ulang OTP

### Testing di iOS

**Requirement:**
- iOS 13.0+
- Push Notification Capability enabled
- APNs certificate di Firebase Console

**Setup:**
1. Buka Xcode
2. Select project → Target → Signing & Capabilities
3. Add "Push Notifications" capability

## 🔄 Struktur Data

### Firestore Collection: `users`

```javascript
users/{uid}
  - uid: string              // Firebase Auth UID
  - phoneNumber: string      // +628123456789 (REQUIRED - Core Master)
  - name: string             // User's full name (REQUIRED)
  - email: string            // Optional
  - createdAt: timestamp     // Registration time
```

### Index yang Diperlukan

Create composite index di Firestore:

**Collection:** `users`
**Fields:**
- phoneNumber (Ascending)
- createdAt (Descending)

## 💡 Best Practices

### 1. Validasi Nomor

```dart
String _formatPhoneNumber(String phone) {
  // Remove spaces and special characters
  phone = phone.replaceAll(RegExp(r'[^\d+]'), '');
  
  // If starts with 0, replace with +62
  if (phone.startsWith('0')) {
    phone = '+62${phone.substring(1)}';
  }
  
  return phone;
}
```

### 2. Handle Auto-Verification (Android)

Pada Android, Firebase bisa auto-verify tanpa perlu input OTP:

```dart
verificationCompleted: (PhoneAuthCredential credential) async {
  // Auto-verified, directly sign in
  UserCredential result = await _auth.signInWithCredential(credential);
  // Handle successful login
}
```

### 3. User Experience

- **Loading State:** Tampilkan loading saat kirim OTP
- **Error Message:** Tampilkan error yang jelas ke user
- **Resend OTP:** Berikan opsi kirim ulang setelah 30-60 detik
- **Edit Phone:** Berikan opsi edit nomor sebelum verifikasi

## 📊 Monitoring

### Firebase Console

Monitor authentication di:
- **Authentication** → **Users**: Lihat daftar user
- **Authentication** → **Usage**: Monitor quota usage

### Analytics (Optional)

Track events:
- `otp_sent` - OTP dikirim
- `otp_verified` - OTP berhasil diverifikasi
- `login_success` - Login berhasil
- `registration_complete` - Registrasi selesai

## 🚀 Production Checklist

- [ ] Phone Authentication enabled di Firebase
- [ ] Test dengan real phone numbers
- [ ] Setup billing (Blaze Plan) jika perlu unlimited
- [ ] Remove test phone numbers
- [ ] Enable reCAPTCHA (web)
- [ ] Setup analytics
- [ ] Test error scenarios
- [ ] Monitor quota usage

---

**Selamat! 🎉** Phone Authentication sudah siap digunakan!

Untuk pertanyaan lebih lanjut, lihat [Firebase Phone Auth Documentation](https://firebase.google.com/docs/auth/android/phone-auth)

