# 🚀 Quick Start - Kasbon

Panduan cepat untuk menjalankan aplikasi Kasbon.

## ⚡ Setup Cepat (5 Menit)

### 1. Install Dependencies
```bash
flutter pub get
```

### 2. Setup Firebase (WAJIB!)

**Buat Firebase Project:**
- Buka https://console.firebase.google.com/
- Klik "Add project"
- Ikuti wizard setup

**Aktifkan Services:**
1. **Authentication**: Enable Email/Password
2. **Firestore**: Create database (Start in test mode)

### 3. Konfigurasi Firebase CLI
```bash
# Install FlutterFire CLI
dart pub global activate flutterfire_cli

# Konfigurasi project
flutterfire configure
```

Pilih platform: Android, iOS, Web (sesuai kebutuhan)

### 4. Jalankan Aplikasi
```bash
flutter run
```

## 📱 Cara Pakai

### Step 1: Register
1. Buka aplikasi
2. Klik **"Daftar"**
3. Isi form (nama, email, password)
4. Klik **"Daftar"**

### Step 2: Tambah Utang
1. Login dengan akun Anda
2. Klik tombol **"+ Tambah Utang"**
3. Pilih orang yang berutang (harus sudah register)
4. Input jumlah dan keterangan
5. Klik **"Simpan"**

### Step 3: Lihat & Kelola Utang

**Tab "Piutang Saya":**
- Lihat orang yang berutang kepada Anda
- Klik nama untuk detail
- Tandai sebagai lunas

**Tab "Utang Saya":**
- Lihat utang Anda ke orang lain
- Lihat detail catatan

## 🎯 Fitur Utama

✅ **Catat Utang Real-time**
- Ketika Anda mencatat utang seseorang
- Orang tersebut langsung bisa lihat di akunnya

✅ **Multi-User**
- Setiap user bisa melihat:
  - Piutang: Orang yang berutang ke mereka
  - Utang: Utang mereka ke orang lain

✅ **Tandai Lunas**
- Pemberi pinjaman bisa tandai utang sebagai lunas
- Otomatis tercatat dengan timestamp

## 🔥 Tips

### Untuk Pemberi Pinjaman (Creditor):
1. Pastikan orang yang berutang sudah punya akun
2. Catat setiap transaksi dengan detail jelas
3. Tandai lunas setelah menerima pembayaran

### Untuk Peminjam (Debtor):
1. Cek tab "Utang Saya" secara berkala
2. Koordinasi dengan pemberi pinjaman
3. Konfirmasi setelah melunasi

## 🐛 Troubleshooting Cepat

**Tidak bisa login?**
- Cek koneksi internet
- Pastikan Firebase Authentication sudah aktif
- Cek email & password

**Tidak bisa tambah utang?**
- Pastikan orang yang dipilih sudah register
- Cek Firestore rules di Firebase Console

**Error "No Firebase App"?**
```bash
flutterfire configure
flutter clean
flutter pub get
flutter run
```

## 📚 Dokumentasi Lengkap

- [README.md](README.md) - Dokumentasi lengkap
- [SETUP_FIREBASE.md](SETUP_FIREBASE.md) - Panduan Firebase detail

## 🆘 Butuh Bantuan?

1. Baca [SETUP_FIREBASE.md](SETUP_FIREBASE.md)
2. Cek Firebase Console untuk errors
3. Lihat logs: `flutter run -v`

---

**Selamat mencoba! 🎉**

Jika ada pertanyaan, buka issue di repository ini.

