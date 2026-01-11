# Kasbon - Aplikasi Pencatat Utang

Aplikasi Flutter untuk mencatat dan mengelola utang dengan mudah. Terintegrasi dengan Firebase untuk real-time sync dan multi-user support.

## 🚀 Fitur

- ✅ Autentikasi dengan nomor telepon (OTP verification)
- ✅ Mencatat utang orang lain (sebagai pemberi pinjaman)
- ✅ Melihat utang sendiri
- ✅ Real-time sync dengan Firebase
- ✅ Menandai utang sebagai lunas
- ✅ Riwayat utang per orang
- ✅ UI modern dan responsif
- ✅ Nomor telepon sebagai identitas utama (core master)

## 📋 Prasyarat

- Flutter SDK (versi 3.9.2 atau lebih baru)
- Firebase Project (buat di [Firebase Console](https://console.firebase.google.com/))
- FlutterFire CLI

## 🛠️ Setup Project

### 1. Clone dan Install Dependencies

```bash
flutter pub get
```

### 2. Setup Firebase

#### Install FlutterFire CLI
```bash
dart pub global activate flutterfire_cli
```

#### Konfigurasi Firebase
```bash
flutterfire configure
```

Ikuti instruksi untuk:
- Pilih atau buat Firebase project
- Pilih platform yang akan digunakan (Android, iOS, Web)
- File `firebase_options.dart` akan otomatis di-generate

### 3. Setup Firebase Authentication

1. Buka [Firebase Console](https://console.firebase.google.com/)
2. Pilih project Anda
3. Masuk ke **Authentication** > **Sign-in method**
4. Aktifkan **Phone** (Phone Number Authentication)
5. Untuk testing, tambahkan test phone numbers di tab **Phone numbers for testing** (opsional)

### 4. Setup Firestore Database

1. Di Firebase Console, masuk ke **Firestore Database**
2. Klik **Create database**
3. Pilih mode **Start in test mode** (untuk development)
4. Pilih location server

#### Struktur Database

Aplikasi ini menggunakan 2 collections:

**users**
```json
{
  "uid": "string",
  "phoneNumber": "string (REQUIRED - Core Master)",
  "name": "string",
  "email": "string (optional)",
  "createdAt": "timestamp"
}
```

**debts**
```json
{
  "id": "string",
  "debtorId": "string",
  "debtorName": "string",
  "creditorId": "string",
  "creditorName": "string",
  "amount": "number",
  "description": "string",
  "createdAt": "timestamp",
  "paidAt": "timestamp (optional)",
  "isPaid": "boolean"
}
```

#### Rules Firestore (untuk production)

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Debts collection
    match /debts/{debtId} {
      allow read: if request.auth != null && (
        resource.data.debtorId == request.auth.uid || 
        resource.data.creditorId == request.auth.uid
      );
      allow create: if request.auth != null && (
        request.resource.data.creditorId == request.auth.uid ||
        request.resource.data.debtorId == request.auth.uid
      );
      allow update, delete: if request.auth != null && (
        resource.data.creditorId == request.auth.uid
      );
    }
  }
}
```

## 🏃‍♂️ Menjalankan Aplikasi

```bash
flutter run
```

Untuk platform tertentu:
```bash
flutter run -d chrome        # Web
flutter run -d android       # Android
flutter run -d ios          # iOS
```

## 📱 Cara Penggunaan

### 1. Login dengan Nomor Telepon
- Masukkan nomor telepon (format: 08xxx atau +62xxx)
- Klik "Kirim Kode OTP"
- Masukkan kode OTP yang diterima via SMS (6 digit)
- Jika nomor baru, lengkapi data (nama wajib, email opsional)
- Jika sudah terdaftar, langsung masuk ke aplikasi

### 2. Menambah Catatan Utang
- Klik tombol **"Tambah Utang"**
- Pilih orang yang berutang dari dropdown
- Masukkan jumlah utang
- Tambahkan keterangan
- Klik **Simpan**

### 3. Melihat Daftar Utang
- **Tab "Piutang Saya"**: Daftar orang yang berutang kepada Anda
- **Tab "Utang Saya"**: Daftar utang Anda kepada orang lain

### 4. Detail Utang
- Klik nama orang untuk melihat detail semua catatan utang
- Lihat total utang yang belum lunas
- Tandai utang sebagai lunas
- Filter untuk melihat utang yang sudah lunas

## 🏗️ Struktur Project

```
lib/
├── main.dart                      # Entry point aplikasi
├── firebase_options.dart          # Konfigurasi Firebase
├── cubit/                         # Cubit State Management
│   ├── auth/
│   │   ├── auth_cubit.dart       # Auth business logic
│   │   └── auth_state.dart       # Auth states
│   ├── debt/
│   │   ├── debt_cubit.dart       # Debt business logic
│   │   └── debt_state.dart       # Debt states
│   └── user/
│       ├── user_cubit.dart       # User business logic
│       └── user_state.dart       # User states
├── models/                        # Data models
│   ├── user_model.dart
│   └── debt_model.dart
├── services/                      # Data layer & Firebase
│   ├── auth_service.dart
│   └── debt_service.dart
└── screens/                       # Presentation layer (UI)
    ├── auth/
    │   ├── phone_login_screen.dart
    │   ├── otp_verification_screen.dart
    │   └── register_screen.dart
    └── home/
        ├── home_screen.dart
        ├── add_debt_screen.dart
        └── debt_detail_screen.dart
```

## 🎨 Teknologi yang Digunakan

- **Flutter** - Framework UI
- **Firebase Authentication** - Autentikasi user dengan Phone Number
- **Cloud Firestore** - Database real-time
- **Cubit** - State management (flutter_bloc)
- **Google Fonts** - Typography (Poppins)
- **Intl** - Formatting currency & date (Indonesia locale)

## 📝 TODO / Pengembangan Selanjutnya

- [ ] Notifikasi untuk utang yang belum dibayar
- [ ] Export data ke PDF/Excel
- [ ] Reminder otomatis
- [ ] Dark mode
- [ ] Fitur cicilan
- [ ] Grafik statistik utang
- [ ] Foto/bukti transaksi

## 🤝 Kontribusi

Pull requests are welcome! Untuk perubahan besar, silakan buka issue terlebih dahulu untuk mendiskusikan perubahan yang ingin dilakukan.

## 📖 Dokumentasi Lengkap

- **[CUBIT_ARCHITECTURE.md](docs/CUBIT_ARCHITECTURE.md)** - Penjelasan lengkap Cubit Pattern
- **[PHONE_AUTH_GUIDE.md](docs/PHONE_AUTH_GUIDE.md)** - Panduan Phone Authentication

## 📄 Lisensi

MIT License

## 👨‍💻 Developer

Dikembangkan dengan ❤️ menggunakan Flutter + Cubit Pattern
