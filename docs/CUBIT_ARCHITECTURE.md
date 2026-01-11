# 🏗️ Cubit Architecture - Kasbon App

## 📖 Apa itu Cubit?

**Cubit** adalah versi yang lebih sederhana dari BLoC Pattern. Cubit adalah bagian dari package `flutter_bloc` yang memudahkan state management tanpa perlu menggunakan Events.

### Perbedaan BLoC vs Cubit

| Aspek | BLoC | Cubit |
|-------|------|-------|
| **Events** | ✅ Ya, menggunakan Events | ❌ Tidak, langsung call method |
| **Complexity** | Lebih kompleks | Lebih sederhana |
| **Boilerplate** | Lebih banyak | Lebih sedikit |
| **Best For** | Aplikasi besar & kompleks | Aplikasi menengah |

### Contoh Perbandingan

**BLoC Pattern:**
```dart
// Event
context.read<AuthBloc>().add(AuthLoginRequested(phone));

// Bloc
on<AuthLoginRequested>((event, emit) async {
  emit(AuthLoading());
  // ... logic
});
```

**Cubit Pattern:**
```dart
// Langsung call method
context.read<AuthCubit>().login(phone);

// Cubit
Future<void> login(String phone) async {
  emit(AuthLoading());
  // ... logic
}
```

---

## 🏛️ Arsitektur Aplikasi Kasbon

Aplikasi ini menggunakan **Cubit Pattern** dengan 3 layer utama:

```
┌─────────────────────────────────────────┐
│           UI Layer (Screens)            │
│  - BlocBuilder (untuk build widget)     │
│  - BlocListener (untuk side effects)    │
│  - context.read<Cubit>() (call methods) │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         Cubit Layer (State Management)  │
│  - AuthCubit, DebtCubit, UserCubit      │
│  - emit() states berdasarkan logic      │
│  - Tidak ada Events                     │
└──────────────────┬──────────────────────┘
                   │
┌──────────────────▼──────────────────────┐
│         Service Layer (Business Logic)  │
│  - AuthService, DebtService             │
│  - Komunikasi dengan Firebase           │
│  - Pure Dart logic                      │
└─────────────────────────────────────────┘
```

---

## 📦 Struktur Cubit di Aplikasi

### 1️⃣ AuthCubit (`lib/cubit/auth/`)

**Tanggung Jawab:**
- Phone authentication (OTP)
- User registration
- Login/Logout
- Auth state management

**States:**
```dart
AuthInitial          // Kondisi awal
AuthLoading          // Sedang loading
AuthAuthenticated    // User sudah login
AuthUnauthenticated  // User belum login
AuthOTPSent          // OTP sudah dikirim
AuthOTPVerifiedNewUser // OTP benar, tapi user baru
AuthError            // Ada error
```

**Methods:**
```dart
checkAuthStatus()                    // Check apakah user sudah login
sendOTP(String phoneNumber)          // Kirim OTP ke nomor telepon
verifyOTP(String verificationId, String code) // Verifikasi kode OTP
registerUser(...)                    // Daftarkan user baru
logout()                             // Keluar
```

**Contoh Penggunaan:**
```dart
// Di Screen
final authCubit = context.read<AuthCubit>();

// Kirim OTP
authCubit.sendOTP('+6281234567890');

// Listen state changes
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    if (state is AuthLoading) {
      return CircularProgressIndicator();
    }
    if (state is AuthOTPSent) {
      return OTPVerificationScreen();
    }
    // ...
  },
)
```

---

### 2️⃣ DebtCubit (`lib/cubit/debt/`)

**Tanggung Jawab:**
- CRUD catatan utang
- Real-time subscribe ke Firestore
- Mark utang sebagai lunas

**States:**
```dart
DebtInitial            // Kondisi awal
DebtLoading            // Sedang loading
DebtCreditsLoaded      // Piutang berhasil dimuat
DebtDebtsLoaded        // Utang berhasil dimuat
DebtOperationSuccess   // Operasi CRUD berhasil
DebtError              // Ada error
```

**Methods:**
```dart
subscribeToCredits(String userId)  // Subscribe real-time piutang
subscribeToDebts(String userId)    // Subscribe real-time utang
addDebt(DebtModel debt)            // Tambah catatan utang
updateDebt(DebtModel debt)         // Update catatan
markAsPaid(String debtId)          // Tandai lunas
deleteDebt(String debtId)          // Hapus catatan
```

**Contoh Penggunaan:**
```dart
// Subscribe ke real-time updates
@override
void initState() {
  super.initState();
  final userId = getCurrentUserId();
  context.read<DebtCubit>().subscribeToCredits(userId);
  context.read<DebtCubit>().subscribeToDebts(userId);
}

// Tambah utang baru
final debtCubit = context.read<DebtCubit>();
debtCubit.addDebt(newDebt);

// Listen changes
BlocBuilder<DebtCubit, DebtState>(
  builder: (context, state) {
    if (state is DebtCreditsLoaded) {
      return ListView.builder(
        itemCount: state.credits.length,
        // ...
      );
    }
    // ...
  },
)
```

---

### 3️⃣ UserCubit (`lib/cubit/user/`)

**Tanggung Jawab:**
- Load data user
- Load semua users (untuk dropdown)
- Search users

**States:**
```dart
UserInitial     // Kondisi awal
UserLoading     // Sedang loading
UserLoaded      // Single user berhasil dimuat
UserAllLoaded   // Semua users berhasil dimuat
UserError       // Ada error
```

**Methods:**
```dart
loadUser(String uid)         // Load data satu user
loadAllUsers()               // Load semua users
searchUsers(String query)    // Search user by name/phone
```

**Contoh Penggunaan:**
```dart
// Load all users untuk dropdown
@override
void initState() {
  super.initState();
  context.read<UserCubit>().loadAllUsers();
}

// Display users
BlocBuilder<UserCubit, UserState>(
  builder: (context, state) {
    if (state is UserAllLoaded) {
      return DropdownButton(
        items: state.users.map((user) {
          return DropdownMenuItem(
            value: user,
            child: Text(user.name),
          );
        }).toList(),
        // ...
      );
    }
    // ...
  },
)
```

---

## 🎯 Best Practices

### 1. Menggunakan BlocBuilder untuk UI

```dart
BlocBuilder<AuthCubit, AuthState>(
  builder: (context, state) {
    // Build UI based on state
    if (state is AuthLoading) return LoadingWidget();
    if (state is AuthAuthenticated) return HomeScreen();
    return LoginScreen();
  },
)
```

### 2. Menggunakan BlocListener untuk Side Effects

```dart
BlocListener<AuthCubit, AuthState>(
  listener: (context, state) {
    // Handle side effects (navigation, snackbar, etc)
    if (state is AuthError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
    if (state is AuthAuthenticated) {
      Navigator.pushReplacement(context, ...);
    }
  },
  child: YourWidget(),
)
```

### 3. Combine BlocBuilder + BlocListener

```dart
BlocConsumer<DebtCubit, DebtState>(
  listener: (context, state) {
    // Side effects
    if (state is DebtOperationSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(state.message)),
      );
    }
  },
  builder: (context, state) {
    // Build UI
    if (state is DebtCreditsLoaded) {
      return ListView(children: ...);
    }
    return Container();
  },
)
```

### 4. Gunakan context.read() untuk Call Methods

```dart
// ✅ BENAR - untuk call methods
ElevatedButton(
  onPressed: () {
    context.read<AuthCubit>().logout();
  },
  child: Text('Logout'),
)

// ❌ SALAH - jangan gunakan watch() untuk call methods
ElevatedButton(
  onPressed: () {
    context.watch<AuthCubit>().logout(); // ❌
  },
  child: Text('Logout'),
)
```

### 5. Check isClosed Sebelum emit()

```dart
Future<void> loadData() async {
  emit(DataLoading());
  
  final data = await fetchData();
  
  // Check if cubit still active
  if (!isClosed) {
    emit(DataLoaded(data));
  }
}
```

---

## 🔄 Flow Data Aplikasi

### 1. Login Flow

```
User Input Phone Number
        ↓
context.read<AuthCubit>().sendOTP(phone)
        ↓
AuthCubit calls AuthService.verifyPhoneNumber()
        ↓
Firebase sends OTP
        ↓
AuthCubit emits AuthOTPSent
        ↓
UI navigates to OTP Screen (via BlocListener)
        ↓
User inputs OTP
        ↓
context.read<AuthCubit>().verifyOTP(code)
        ↓
AuthCubit emits AuthAuthenticated atau AuthOTPVerifiedNewUser
        ↓
UI navigates to Home atau Register Screen
```

### 2. Add Debt Flow

```
User fills form & clicks submit
        ↓
context.read<DebtCubit>().addDebt(debt)
        ↓
DebtCubit calls DebtService.addDebt()
        ↓
Firestore writes data
        ↓
DebtCubit emits DebtOperationSuccess
        ↓
UI shows success snackbar (via BlocListener)
        ↓
Real-time subscription triggers update
        ↓
DebtCubit emits DebtCreditsLoaded with updated list
        ↓
UI rebuilds list (via BlocBuilder)
```

---

## 📊 State Management Strategy

### Kapan Menggunakan Cubit vs Provider?

| Use Cubit When | Use Provider When |
|----------------|-------------------|
| Complex state logic | Simple state |
| Need state history/replay | Just passing data down |
| Testing is important | Quick prototyping |
| Multiple states per feature | Single state object |

### Kenapa Kami Pilih Cubit?

✅ **Sederhana**: Tidak perlu Events, langsung call methods  
✅ **Terstruktur**: Setiap state terpisah & type-safe  
✅ **Testable**: Mudah di-test karena logic terisolasi  
✅ **Scalable**: Mudah add fitur baru tanpa breaking existing code  
✅ **Real-time**: Support Streams dengan baik (Firestore)  

---

## 🧪 Testing Cubit

```dart
// auth_cubit_test.dart
void main() {
  group('AuthCubit', () {
    late AuthCubit authCubit;
    late MockAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockAuthService();
      authCubit = AuthCubit(authService: mockAuthService);
    });

    test('initial state is AuthInitial', () {
      expect(authCubit.state, AuthInitial());
    });

    blocTest<AuthCubit, AuthState>(
      'emits [AuthLoading, AuthOTPSent] when sendOTP is called',
      build: () => authCubit,
      act: (cubit) => cubit.sendOTP('+6281234567890'),
      expect: () => [
        AuthLoading(),
        AuthOTPSent(verificationId: 'test-id', phoneNumber: '+6281234567890'),
      ],
    );
  });
}
```

---

## 🎓 Resources

- [Cubit Documentation](https://bloclibrary.dev/#/coreconcepts?id=cubit)
- [flutter_bloc Package](https://pub.dev/packages/flutter_bloc)
- [BLoC vs Cubit Comparison](https://bloclibrary.dev/#/architecture?id=bloc-vs-cubit)

---

**Happy Coding! 🚀**

