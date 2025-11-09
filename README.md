# Kasbon - Aplikasi Pencatat Utang

Aplikasi Flutter untuk mencatat dan mengelola utang dengan mudah. Terintegrasi dengan Firebase untuk real-time sync dan multi-user support.

## 🚀 Fitur

- ✅ Autentikasi pengguna (Register & Login)
- ✅ Mencatat utang orang lain (sebagai pemberi pinjaman)
- ✅ Melihat utang sendiri
- ✅ Real-time sync dengan Firebase
- ✅ Menandai utang sebagai lunas
- ✅ Riwayat utang per orang
- ✅ UI modern dan responsif

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
4. Aktifkan **Email/Password**

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
  "email": "string",
  "name": "string",
  "phoneNumber": "string (optional)",
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

### 1. Register & Login
- Buat akun baru dengan email dan password
- Login dengan akun yang sudah dibuat

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
├── main.dart                 # Entry point aplikasi
├── firebase_options.dart     # Konfigurasi Firebase
├── models/                   # Data models
│   ├── user_model.dart
│   └── debt_model.dart
├── services/                 # Business logic & Firebase
│   ├── auth_service.dart
│   └── debt_service.dart
└── screens/                  # UI Screens
    ├── auth/
    │   ├── login_screen.dart
    │   └── register_screen.dart
    └── home/
        ├── home_screen.dart
        ├── add_debt_screen.dart
        └── debt_detail_screen.dart
```

## 🎨 Teknologi yang Digunakan

- **Flutter** - Framework UI
- **Firebase Authentication** - Autentikasi user
- **Cloud Firestore** - Database real-time
- **Google Fonts** - Typography
- **Provider** - State management
- **Intl** - Formatting currency & date

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

## 📄 Lisensi

MIT License

## 👨‍💻 Developer

Dikembangkan dengan ❤️ menggunakan Flutter
