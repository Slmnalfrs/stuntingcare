import 'package:firebase_auth/firebase_auth.dart';

/// Layanan autentikasi untuk mengelola akses pengguna menggunakan Firebase Auth.
/// 
/// Menyediakan fungsi untuk pendaftaran, masuk, keluar, dan pengelolaan sesi.
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Getters ─────────────────────────────────────────────────────────────────

  /// Mendapatkan objek [User] yang sedang masuk saat ini.
  User? get currentUser => _auth.currentUser;

  /// Mendapatkan UID pengguna yang sedang masuk.
  String? get currentUserId => _auth.currentUser?.uid;

  /// Stream untuk memantau perubahan status autentikasi (login/logout).
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ─── Email & Password ─────────────────────────────────────────────────────────

  /// Mendaftarkan akun baru menggunakan email dan kata sandi.
  /// 
  /// Melemparkan [FirebaseAuthException] jika proses gagal.
  Future<UserCredential> registerWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Masuk ke akun yang sudah ada menggunakan email dan kata sandi.
  /// 
  /// Melemparkan [FirebaseAuthException] jika kredensial tidak valid.
  Future<UserCredential> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // ─── Password Reset ───────────────────────────────────────────────────────────

  /// Mengirimkan email tautan pengaturan ulang kata sandi ke alamat yang ditentukan.
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  // ─── Sign Out ─────────────────────────────────────────────────────────────────

  /// Mengakhiri sesi pengguna saat ini.
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // ─── Token ────────────────────────────────────────────────────────────────────

  /// Mendapatkan ID Token dari pengguna yang sedang masuk.
  /// 
  /// Gunakan [forceRefresh] true jika ingin memaksa pembaruan token.
  Future<String?> getIdToken({bool forceRefresh = false}) async {
    return await _auth.currentUser?.getIdToken(forceRefresh);
  }
}
