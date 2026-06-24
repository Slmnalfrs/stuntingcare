import 'package:flutter/material.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

/// Provider untuk mengelola data profil anak/ibu secara global.
/// 
/// Memastikan informasi kesehatan pengguna tersedia untuk diproses oleh 
/// AI dan ditampilkan di seluruh bagian aplikasi.
class ProfileProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final AuthService _authService = AuthService();

  UserProfile? _profile;
  bool _isLoading = false;
  String? _errorMessage;

  /// Mendapatkan data profil pengguna saat ini.
  UserProfile? get profile => _profile;

  /// Menandakan apakah data profil sedang dimuat atau disimpan.
  bool get isLoading => _isLoading;

  /// Pesan error jika terjadi kegagalan pada operasi profil.
  String? get errorMessage => _errorMessage;

  /// Mengetahui apakah pengguna sudah melengkapi data profil.
  bool get hasProfile => _profile != null;

  // ─── Save Profile ─────────────────────────────────────────────────────────────

  /// Menyimpan [UserProfile] baru atau memperbarui profil yang sudah ada.
  Future<bool> saveProfile(UserProfile profile) async {
    try {
      _setLoading(true);
      _profile = await _firebaseService.saveProfile(profile);
      _setLoading(false);
      return true;
    } catch (e) {
      _setError(e.toString().replaceAll('Exception: ', ''));
      return false;
    }
  }

  // ─── Load Profile ─────────────────────────────────────────────────────────────

  /// Memuat data profil pengguna dari Firestore.
  /// 
  /// Gunakan [force] true untuk memaksa pemuatan ulang data dari server.
  Future<void> loadProfile({bool force = false}) async {
    final uid = _authService.currentUserId;
    if (uid == null) return;

    // Lewati jika profil sudah ada dalam memori (kecuali dipaksa)
    if (_profile != null && !force) {
      debugPrint('[PROFILE_PROVIDER] Profile already loaded, skipping');
      return;
    }

    try {
      _setLoading(true);
      _profile = await _firebaseService.getProfile(uid);
      _setLoading(false);
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // ─── Check Profile Exists ─────────────────────────────────────────────────────

  /// Memeriksa apakah dokumen profil pengguna sudah terdaftar di Firestore.
  /// 
  /// Berguna untuk menentukan apakah pengguna harus diarahkan ke form profil
  /// setelah pertama kali mendaftar.
  Future<bool> checkProfileExists() async {
    final uid = _authService.currentUserId;
    if (uid == null) return false;

    try {
      _profile = await _firebaseService.getProfile(uid);
      return _profile != null;
    } catch (e) {
      _profile = null;
      return false;
    }
  }

  // ─── Clear ────────────────────────────────────────────────────────────────────

  /// Menghapus data profil dari memori (digunakan saat logout).
  void clearProfile() {
    _profile = null;
    _errorMessage = null;
    notifyListeners();
  }

  /// Menghapus status error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  void _setLoading(bool value) {
    _isLoading = value;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _isLoading = false;
    _errorMessage = message;
    notifyListeners();
  }
}
