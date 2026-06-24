import 'package:flutter/material.dart';
import '../models/chat_message.dart';
import '../models/user_profile.dart';
import '../services/firebase_service.dart';
import '../services/gemini_service.dart';
import '../services/auth_service.dart';

/// Provider untuk mengelola percakapan chat dengan AI.
/// 
/// Bertanggung jawab atas pengiriman pesan, penerimaan respons dari Gemini,
/// dan pengarsipan percakapan ke Firestore.
class ChatProvider with ChangeNotifier {
  final FirebaseService _firebaseService = FirebaseService();
  final GeminiService _geminiService = GeminiService();
  final AuthService _authService = AuthService();

  final List<ChatMessage> _messages = [];
  List<ChatMessage> _history = [];
  bool _isLoading = false;
  bool _isSending = false;
  String? _errorMessage;

  /// Daftar pesan dalam sesi chat yang sedang aktif.
  List<ChatMessage> get messages => List.unmodifiable(_messages);

  /// Daftar riwayat percakapan yang dimuat dari Firestore.
  List<ChatMessage> get history => List.unmodifiable(_history);

  /// Menandakan apakah aplikasi sedang memuat riwayat chat.
  bool get isLoading => _isLoading;

  /// Menandakan apakah aplikasi sedang menunggu jawaban dari AI.
  bool get isSending => _isSending;

  /// Pesan error jika terjadi kegagalan pada proses chat.
  String? get errorMessage => _errorMessage;

  // ─── Send Message ─────────────────────────────────────────────────────────────

  /// Mengirim pertanyaan ke Gemini AI.
  /// 
  /// Jika [profile] disertakan, saran AI akan disesuaikan dengan data kesehatan pengguna.
  /// Pesan akan disimpan ke Firestore jika pengguna telah masuk.
  Future<void> sendMessage(String pertanyaan, {UserProfile? profile}) async {
    if (pertanyaan.trim().isEmpty) return;

    final uid = _authService.currentUserId;

    // Tampilkan pesan pengguna di UI secara instan
    final userMsg = ChatMessage.userMessage(pertanyaan.trim());
    _messages.add(userMsg);
    _isSending = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Panggil layanan Gemini AI
      final jawaban = await _geminiService.sendMessage(
        pertanyaan.trim(),
        profile: profile,
      );

      // Simpan ke Firestore jika User ID tersedia
      ChatMessage aiMsg;
      if (uid != null) {
        aiMsg = await _firebaseService.saveChatMessage(
          userId: uid,
          pertanyaan: pertanyaan.trim(),
          jawaban: jawaban,
        );
      } else {
        aiMsg = ChatMessage.aiMessage(jawaban);
      }

      _messages.add(aiMsg);
      _isSending = false;
      notifyListeners();
    } catch (e) {
      _isSending = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');

      if (_errorMessage!.contains('QUOTA_EXHAUSTED')) {
        _errorMessage = 'Maaf, kuota token percakapan gratis hari ini telah mencapai batasnya. Kuota akan otomatis di-reset oleh sistem dalam 24 jam. Silakan kembali besok!';
      }

      // Tampilkan pesan kesalahan sebagai balasan AI
      _messages.add(ChatMessage.aiMessage(_errorMessage!));
      notifyListeners();
    }
  }

  // ─── Load Chat History ────────────────────────────────────────────────────────

  /// Memuat riwayat percakapan pengguna dari Firestore.
  Future<void> loadChatHistory() async {
    final uid = _authService.currentUserId;
    if (uid == null) return;

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _history = await _firebaseService.getChatHistory(uid);
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  /// Memindahkan satu percakapan dari riwayat ke sesi chat aktif.
  void loadChatSession(ChatMessage historyItem) {
    _messages.clear();
    _messages.add(ChatMessage.userMessage(historyItem.pertanyaan));
    _messages.add(ChatMessage(
      id: historyItem.id,
      userId: historyItem.userId,
      pertanyaan: historyItem.pertanyaan,
      jawaban: historyItem.jawaban,
      timestamp: historyItem.timestamp,
      isUser: false,
    ));
    notifyListeners();
  }

  /// Menghapus secara permanen satu percakapan dari riwayat Firestore.
  Future<void> deleteChatFromHistory(String chatId) async {
    try {
      await _firebaseService.deleteChatMessage(chatId);
      _history.removeWhere((item) => item.id == chatId);
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
    }
  }

  // ─── Clear ────────────────────────────────────────────────────────────────────

  /// Membersihkan seluruh pesan dari sesi chat aktif.
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }

  /// Menghapus status error.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
