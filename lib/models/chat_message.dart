import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data untuk pesan chat antara pengguna dan AI StuntingCare.
///
/// Setiap instance merepresentasikan satu sesi tanya-jawab yang terdiri
/// dari pertanyaan pengguna dan jawaban dari Gemini AI.
class ChatMessage {
  /// ID unik pesan, biasanya dari Firestore Document ID.
  final String id;

  /// ID pengguna yang mengirim pesan.
  final String userId;

  /// Teks pertanyaan yang diajukan oleh pengguna.
  final String pertanyaan;

  /// Teks jawaban yang dihasilkan oleh Gemini AI.
  final String jawaban;

  /// Waktu pesan dibuat dalam format ISO 8601.
  final String timestamp;

  /// Menandakan apakah pesan ini berasal dari pengguna (`true`)
  /// atau dari AI (`false`).
  final bool isUser;

  /// Membuat instance [ChatMessage] baru.
  const ChatMessage({
    required this.id,
    required this.userId,
    required this.pertanyaan,
    required this.jawaban,
    required this.timestamp,
    this.isUser = false,
  });

  /// Membuat [ChatMessage] dari respons JSON (backend API).
  ///
  /// Mendukung key `id` maupun `chat_id` sebagai identifier.
  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as String? ?? json['chat_id'] as String? ?? '',
      userId: json['user_id'] as String? ?? '',
      pertanyaan: json['pertanyaan'] as String? ?? '',
      jawaban: json['jawaban'] as String? ?? '',
      timestamp: json['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  /// Membuat [ChatMessage] dari Firestore [DocumentSnapshot].
  factory ChatMessage.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      userId: data['user_id'] as String? ?? '',
      pertanyaan: data['pertanyaan'] as String? ?? '',
      jawaban: data['jawaban'] as String? ?? '',
      timestamp: data['timestamp'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  /// Mengonversi [ChatMessage] ke format JSON untuk penyimpanan ke Firestore.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'pertanyaan': pertanyaan,
      'jawaban': jawaban,
      'timestamp': timestamp,
    };
  }

  /// Membuat pesan sementara dari pengguna untuk ditampilkan
  /// di UI sebelum respons AI diterima.
  factory ChatMessage.userMessage(String message) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '',
      pertanyaan: message,
      jawaban: '',
      timestamp: DateTime.now().toIso8601String(),
      isUser: true,
    );
  }

  /// Membuat pesan dari AI untuk ditampilkan di UI.
  factory ChatMessage.aiMessage(String message) {
    return ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: '',
      pertanyaan: '',
      jawaban: message,
      timestamp: DateTime.now().toIso8601String(),
      isUser: false,
    );
  }

  @override
  String toString() =>
      'ChatMessage(id: $id, isUser: $isUser, timestamp: $timestamp)';
}
