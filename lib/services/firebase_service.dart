import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';
import '../models/chat_message.dart';

/// Layanan untuk mengelola data di Firebase Firestore.
/// 
/// Mencakup manajemen profil pengguna dan riwayat percakapan chat.
class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  static const String _usersCollection = 'users';
  static const String _chatHistoryCollection = 'chat_history';

  // ─── Profile ──────────────────────────────────────────────────────────────────

  /// Menyimpan atau memperbarui profil pengguna di Firestore.
  /// 
  /// Secara otomatis mengatur `created_at` jika profil baru, 
  /// dan memperbarui `updated_at` pada setiap pembaruan.
  Future<UserProfile> saveProfile(UserProfile profile) async {
    try {
      final now = DateTime.now().toIso8601String();
      final docRef = _firestore.collection(_usersCollection).doc(profile.uid);
      final docSnap = await docRef.get();

      final data = profile.toJson();
      data['updated_at'] = now;

      if (!docSnap.exists) {
        data['created_at'] = now;
        debugPrint('[FIREBASE] Creating new profile for UID: ${profile.uid}');
      } else {
        debugPrint('[FIREBASE] Updating profile for UID: ${profile.uid}');
      }

      await docRef.set(data, SetOptions(merge: true));

      return UserProfile.fromJson(data);
    } catch (e) {
      debugPrint('[FIREBASE] saveProfile error: $e');
      throw Exception('Gagal menyimpan profil: $e');
    }
  }

  /// Mengambil data profil berdasarkan UID pengguna.
  /// 
  /// Mengembalikan `null` jika dokumen profil tidak ditemukan di Firestore.
  Future<UserProfile?> getProfile(String uid) async {
    try {
      final docSnap =
          await _firestore.collection(_usersCollection).doc(uid).get();

      if (!docSnap.exists) {
        debugPrint('[FIREBASE] Profile not found for UID: $uid');
        return null;
      }

      return UserProfile.fromFirestore(docSnap);
    } catch (e) {
      debugPrint('[FIREBASE] getProfile error: $e');
      throw Exception('Gagal mengambil profil: $e');
    }
  }

  // ─── Chat History ─────────────────────────────────────────────────────────────

  /// Menyimpan riwayat percakapan baru ke Firestore.
  /// 
  /// Mengembalikan objek [ChatMessage] yang berisi ID dokumen yang dihasilkan.
  Future<ChatMessage> saveChatMessage({
    required String userId,
    required String pertanyaan,
    required String jawaban,
  }) async {
    try {
      final timestamp = DateTime.now().toIso8601String();
      final chatData = {
        'user_id': userId,
        'pertanyaan': pertanyaan,
        'jawaban': jawaban,
        'timestamp': timestamp,
      };

      final docRef =
          await _firestore.collection(_chatHistoryCollection).add(chatData);

      debugPrint('[FIREBASE] Chat saved with ID: ${docRef.id}');

      return ChatMessage(
        id: docRef.id,
        userId: userId,
        pertanyaan: pertanyaan,
        jawaban: jawaban,
        timestamp: timestamp,
        isUser: false,
      );
    } catch (e) {
      debugPrint('[FIREBASE] saveChatMessage error: $e');
      throw Exception('Gagal menyimpan pesan: $e');
    }
  }

  /// Mengambil daftar riwayat chat milik pengguna tertentu.
  /// 
  /// Daftar diurutkan berdasarkan waktu terbaru dan dibatasi oleh [limit].
  Future<List<ChatMessage>> getChatHistory(String userId,
      {int limit = 50}) async {
    try {
      final snapshot = await _firestore
          .collection(_chatHistoryCollection)
          .where('user_id', isEqualTo: userId)
          .get();

      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();

      // Sort lokal untuk menjamin urutan meskipun offline
      messages.sort((a, b) {
        final dateA = DateTime.tryParse(a.timestamp) ?? DateTime(0);
        final dateB = DateTime.tryParse(b.timestamp) ?? DateTime(0);
        return dateB.compareTo(dateA);
      });

      return messages.take(limit).toList();
    } catch (e) {
      debugPrint('[FIREBASE] getChatHistory error: $e');
      throw Exception('Gagal mengambil riwayat chat: $e');
    }
  }

  /// Menghapus satu entri riwayat chat berdasarkan ID dokumen.
  Future<void> deleteChatMessage(String chatId) async {
    try {
      await _firestore.collection(_chatHistoryCollection).doc(chatId).delete();
      debugPrint('[FIREBASE] Chat deleted with ID: $chatId');
    } catch (e) {
      debugPrint('[FIREBASE] deleteChatMessage error: $e');
      throw Exception('Gagal menghapus pesan: $e');
    }
  }
}
