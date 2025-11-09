# Panduan Setup Firebase untuk Kasbon

## 📝 Langkah-langkah Setup

### 1. Buat Firebase Project

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Klik **"Add project"** atau **"Tambah project"**
3. Masukkan nama project: **"Kasbon"** (atau nama lain sesuai keinginan)
4. Aktifkan Google Analytics (opsional)
5. Klik **"Create project"**

### 2. Setup Firebase Authentication

1. Di Firebase Console, pilih project Anda
2. Klik menu **"Authentication"** di sidebar
3. Klik tab **"Sign-in method"**
4. Klik **"Email/Password"**
5. Toggle untuk mengaktifkan
6. Klik **"Save"**

### 3. Setup Firestore Database

1. Klik menu **"Firestore Database"** di sidebar
2. Klik **"Create database"**
3. Pilih lokasi server (pilih yang terdekat dengan Indonesia, misalnya: `asia-southeast1` atau `asia-southeast2`)
4. Untuk development, pilih **"Start in test mode"**
5. Klik **"Enable"**

**⚠️ PENTING:** Test mode akan otomatis expired setelah 30 hari. Anda perlu update rules untuk production.

### 4. Setup Firestore Security Rules

Setelah Firestore dibuat, update rules dengan:

#### Untuk Development (Test Mode)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.time < timestamp.date(2025, 12, 31);
    }
  }
}
```

#### Untuk Production (Recommended)
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - hanya bisa dibaca oleh user yang login
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Debts collection
    match /debts/{debtId} {
      // Baca: hanya yang terlibat (debtor atau creditor)
      allow read: if request.auth != null && (
        resource.data.debtorId == request.auth.uid || 
        resource.data.creditorId == request.auth.uid
      );
      
      // Buat: hanya user yang login dan terlibat dalam transaksi
      allow create: if request.auth != null && (
        request.resource.data.creditorId == request.auth.uid ||
        request.resource.data.debtorId == request.auth.uid
      );
      
      // Update & Delete: hanya creditor (pemberi pinjaman)
      allow update, delete: if request.auth != null && 
        resource.data.creditorId == request.auth.uid;
    }
  }
}
```

### 5. Install FlutterFire CLI

Jalankan command berikut di terminal:

```bash
dart pub global activate flutterfire_cli
```

Jika belum ada di PATH, tambahkan ke `.zshrc` atau `.bashrc`:

```bash
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

Restart terminal atau jalankan:
```bash
source ~/.zshrc
```

### 6. Konfigurasi Firebase di Flutter

Jalankan command berikut di root project:

```bash
flutterfire configure
```

Ikuti langkah-langkah:
1. Login ke akun Google Anda
2. Pilih Firebase project yang sudah dibuat
3. Pilih platform yang akan digunakan:
   - [x] android
   - [x] ios
   - [x] web
   - [ ] macos (opsional)
4. Tunggu hingga proses selesai

File `lib/firebase_options.dart` akan otomatis di-generate dengan konfigurasi yang benar.

### 7. Setup Platform-Specific

#### Android

File `android/app/build.gradle` sudah otomatis dikonfigurasi oleh FlutterFire CLI.

Pastikan `minSdkVersion` minimal 21:

```gradle
android {
    defaultConfig {
        minSdkVersion 21
        // ...
    }
}
```

#### iOS

Pastikan iOS deployment target minimal 13.0 di `ios/Podfile`:

```ruby
platform :ios, '13.0'
```

Jalankan:
```bash
cd ios
pod install
cd ..
```

#### Web

Untuk web, pastikan file `web/index.html` sudah menginclude Firebase SDK. FlutterFire CLI akan handle ini secara otomatis.

## 🧪 Testing

### 1. Test Authentication

```bash
flutter run
```

1. Klik "Daftar" untuk membuat akun baru
2. Isi form registrasi
3. Cek di Firebase Console > Authentication > Users, user baru harus muncul

### 2. Test Firestore

1. Login dengan akun yang sudah dibuat
2. Tambah catatan utang baru
3. Cek di Firebase Console > Firestore Database, collection `debts` dan `users` harus muncul dengan data

## 🔧 Troubleshooting

### Error: "No Firebase App '[DEFAULT]' has been created"

**Solusi:**
- Pastikan sudah menjalankan `flutterfire configure`
- Cek file `lib/firebase_options.dart` sudah ter-generate
- Restart aplikasi

### Error: "PERMISSION_DENIED"

**Solusi:**
- Cek Firestore rules di Firebase Console
- Pastikan Authentication sudah diaktifkan
- Pastikan user sudah login

### Error: "Missing google-services.json"

**Solusi:**
```bash
flutterfire configure
```

File akan otomatis di-generate di `android/app/google-services.json`

### Web: CORS Error

**Solusi:**
Tambahkan domain Anda ke Firebase Console:
1. Klik Settings (gear icon) > Project settings
2. Tab "General"
3. Scroll ke "Your apps"
4. Di bagian Web, klik "Add domain"
5. Tambahkan `localhost` untuk development

## 📊 Struktur Database

### Collection: `users`

```javascript
users/{userId}
  - uid: string
  - email: string
  - name: string
  - phoneNumber: string (optional)
  - createdAt: timestamp
```

### Collection: `debts`

```javascript
debts/{debtId}
  - id: string
  - debtorId: string          // UID orang yang berutang
  - debtorName: string        // Nama orang yang berutang
  - creditorId: string        // UID pemberi pinjaman
  - creditorName: string      // Nama pemberi pinjaman
  - amount: number            // Jumlah utang
  - description: string       // Keterangan
  - createdAt: timestamp      // Tanggal dibuat
  - paidAt: timestamp         // Tanggal lunas (nullable)
  - isPaid: boolean           // Status lunas
```

## 💡 Tips

### Index Firestore (Opsional, untuk performa)

Jika aplikasi semakin besar dan ada warning tentang composite index, buat index di:

Firebase Console > Firestore Database > Indexes

Atau klik link di error message untuk auto-create index.

### Backup Data

Untuk backup otomatis, gunakan:
Firebase Console > Firestore Database > Tab "Backups"

### Monitoring

Cek usage dan performance:
Firebase Console > Usage and billing

---

**Selamat! 🎉** Firebase sudah siap digunakan untuk aplikasi Kasbon Anda.

Jika ada pertanyaan, silakan buka issue di repository ini.

