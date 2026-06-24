# StuntingCare Flutter App

Aplikasi mobile berbasis Flutter untuk pencegahan stunting dengan AI Chatbot.

## Prerequisites

- Flutter SDK (3.0.0 atau lebih baru)
- Dart SDK
- Android Studio / Xcode (untuk development)
- Firebase project yang sudah dikonfigurasi

## Installation

### 1. Install Dependencies

```bash
cd stuntingcare_app
flutter pub get
```

### 2. Firebase Configuration

#### Android Setup

1. Download `google-services.json` dari Firebase Console
2. Letakkan file di `android/app/google-services.json`
3. File `android/build.gradle` dan `android/app/build.gradle` sudah dikonfigurasi

#### iOS Setup

1. Download `GoogleService-Info.plist` dari Firebase Console
2. Letakkan file di `ios/Runner/GoogleService-Info.plist`
3. Buka `ios/Runner.xcworkspace` di Xcode
4. Tambahkan file ke project

### 3. Update API Base URL

Edit `lib/utils/constants.dart`:

```dart
static const String apiBaseUrl = 'http://YOUR_IP_ADDRESS:3000/api';
```

**Catatan:**
- Untuk Android Emulator: `http://10.0.2.2:3000/api`
- Untuk Physical Device: `http://192.168.x.x:3000/api` (IP komputer Anda)
- Untuk iOS Simulator: `http://localhost:3000/api`

## Running the App

### Development Mode

```bash
# Run on connected device/emulator
flutter run

# Run on specific device
flutter devices
flutter run -d <device_id>

# Run with hot reload
flutter run --hot
```

### Build for Production

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ios --release
```

## Project Structure

```
stuntingcare_app/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── models/                      # Data models
│   │   ├── user_profile.dart
│   │   ├── risk_score.dart
│   │   └── chat_message.dart
│   ├── services/                    # Business logic
│   │   ├── auth_service.dart
│   │   └── api_service.dart
│   ├── providers/                   # State management
│   │   ├── auth_provider.dart
│   │   ├── profile_provider.dart
│   │   └── chat_provider.dart
│   ├── screens/                     # UI screens
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   └── register_screen.dart
│   │   ├── profile/
│   │   │   └── profile_form_screen.dart
│   │   └── chat/
│   │       ├── chatbot_screen.dart
│   │       └── chat_history_screen.dart
│   ├── widgets/                     # Reusable widgets
│   │   ├── message_bubble.dart
│   │   └── risk_score_card.dart
│   └── utils/                       # Utilities
│       └── constants.dart
├── android/                         # Android configuration
├── ios/                            # iOS configuration
└── pubspec.yaml                    # Dependencies
```

## Features

### 1. Authentication
- Register dengan email & password
- Login dengan Firebase Authentication
- Logout

### 2. User Profile
- Form profil lengkap dengan validasi
- Data: nama, usia, usia kehamilan, tinggi, berat, riwayat kesehatan
- Auto-save ke backend

### 3. Risk Scoring
- Kalkulasi otomatis skor risiko stunting
- Kategori: Rendah, Sedang, Tinggi
- Display IMT (Indeks Massa Tubuh)

### 4. AI Chatbot
- Chat dengan AI Assistant
- Pertanyaan tentang nutrisi & kesehatan
- Jawaban personal berdasarkan profil
- Real-time response

### 5. Chat History
- Riwayat percakapan tersimpan
- Timestamp setiap pesan
- Pagination support

## State Management

Aplikasi menggunakan **Provider** untuk state management:

- `AuthProvider`: Mengelola autentikasi user
- `ProfileProvider`: Mengelola profil dan risk score
- `ChatProvider`: Mengelola chat messages dan history

## API Integration

Semua komunikasi dengan backend melalui `ApiService`:

```dart
// Example usage
final apiService = ApiService();
final profile = await apiService.getProfile(uid);
final riskScore = await apiService.calculateRiskScore(uid);
final response = await apiService.sendChatMessage("Pertanyaan saya");
```

## Firebase Collections

### users
```dart
{
  uid: String,
  nama: String,
  usia: int,
  usia_kehamilan: int,
  tinggi_badan: double,
  berat_badan_awal: double,
  riwayat_anemia: bool,
  riwayat_KEK: bool,
  created_at: String,
  updated_at: String
}
```

### chat_history
```dart
{
  id: String,
  user_id: String,
  pertanyaan: String,
  jawaban: String,
  timestamp: String
}
```

## Troubleshooting

### Firebase Connection Issues

1. Pastikan `google-services.json` / `GoogleService-Info.plist` sudah benar
2. Jalankan `flutter clean` dan `flutter pub get`
3. Rebuild aplikasi

### API Connection Issues

1. Pastikan backend server berjalan
2. Cek API base URL di `constants.dart`
3. Untuk physical device, pastikan di network yang sama dengan server
4. Cek firewall/antivirus tidak memblokir koneksi

### Build Errors

```bash
# Clean build
flutter clean
flutter pub get
flutter pub upgrade

# Rebuild
flutter run
```

## Testing

```bash
# Run tests
flutter test

# Run with coverage
flutter test --coverage
```

## Dependencies

Main dependencies:
- `firebase_core`: ^2.24.2
- `firebase_auth`: ^4.16.0
- `cloud_firestore`: ^4.14.0
- `provider`: ^6.1.1
- `http`: ^1.2.0
- `shared_preferences`: ^2.2.2
- `intl`: ^0.18.1

## License

ISC

## Support

Untuk pertanyaan atau issues, silakan hubungi tim development.
