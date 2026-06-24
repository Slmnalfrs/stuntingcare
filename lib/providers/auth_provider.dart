import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import 'profile_provider.dart';

/// Provider untuk mengelola state autentikasi pengguna secara global.
/// 
/// Menggunakan [AuthService] untuk berinteraksi dengan Firebase Auth dan
/// memberitahu UI setiap kali ada perubahan status login.
class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  /// Objek [User] dari Firebase jika pengguna sudah login.
  User? get user => _user;

  /// Menandakan apakah proses autentikasi sedang berjalan.
  bool get isLoading => _isLoading;

  /// Pesan error terakhir jika terjadi kegagalan autentikasi.
  String? get errorMessage => _errorMessage;

  /// Menandakan apakah ada sesi pengguna yang aktif.
  bool get isAuthenticated => _user != null;

  /// Inisialisasi [AuthProvider] dan mulai mendengarkan perubahan status autentikasi.
  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // ─── Register ─────────────────────────────────────────────────────────────────

  /// Mendaftarkan pengguna baru dengan email dan kata sandi.
  /// 
  /// Setelah berhasil, pengguna akan langsung dikeluarkan (Sign out) 
  /// agar harus masuk secara manual untuk validasi awal.
  Future<bool> register(String email, String password) async {
    try {
      _setLoading(true);
      await _authService.registerWithEmailAndPassword(email, password);
      await _authService.signOut();
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan yang tidak terduga');
      return false;
    }
  }

  // ─── Sign In ──────────────────────────────────────────────────────────────────

  /// Masuk ke aplikasi menggunakan email dan kata sandi.
  Future<bool> signIn(String email, String password) async {
    try {
      _setLoading(true);
      await _authService.signInWithEmailAndPassword(email, password);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan yang tidak terduga');
      return false;
    }
  }

  // ─── Forgot Password ──────────────────────────────────────────────────────────

  /// Mengirimkan instruksi pengaturan ulang kata sandi ke email pengguna.
  Future<bool> sendPasswordReset(String email) async {
    try {
      _setLoading(true);
      await _authService.sendPasswordResetEmail(email);
      _setLoading(false);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(_getErrorMessage(e.code));
      return false;
    } catch (e) {
      _setError('Terjadi kesalahan saat mengirim email reset kata sandi');
      return false;
    }
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────────

  /// Mengakhiri sesi pengguna dan membersihkan data profil dari [ProfileProvider].
  Future<void> signOut(BuildContext context) async {
    await _authService.signOut();
    _user = null;

    if (context.mounted) {
      try {
        context.read<ProfileProvider>().clearProfile();
      } catch (_) {}
    }

    notifyListeners();
  }

  // ─── Helpers ──────────────────────────────────────────────────────────────────

  /// Menghapus pesan error yang sedang tersimpan.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

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

  /// Menerjemahkan kode error Firebase ke dalam pesan bahasa Indonesia yang ramah pengguna.
  String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan';
      case 'user-not-found':
        return 'Pengguna tidak ditemukan';
      case 'wrong-password':
        return 'Kata sandi salah';
      case 'email-already-in-use':
        return 'Email sudah digunakan oleh akun lain';
      case 'weak-password':
        return 'Kata sandi terlalu lemah (minimal 6 karakter)';
      case 'operation-not-allowed':
        return 'Metode masuk ini tidak diizinkan';
      case 'invalid-credential':
        return 'Email atau kata sandi salah';
      case 'network-request-failed':
        return 'Koneksi internet bermasalah. Silakan coba lagi';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Silakan coba lagi nanti';
      default:
        return 'Terjadi kesalahan autentikasi ($code)';
    }
  }
}
