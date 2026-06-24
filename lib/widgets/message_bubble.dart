import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:intl/intl.dart';
import '../models/chat_message.dart';

/// Widget untuk menampilkan satu gelembung pesan dalam percakapan chat.
/// 
/// Membedakan tampilan antara pesan pengguna dan respons AI,
/// serta mendukung perenderan teks Markdown untuk jawaban AI.
class MessageBubble extends StatelessWidget {
  /// Objek pesan yang berisi teks, pengirim, dan waktu.
  final ChatMessage message;

  /// Membuat instance [MessageBubble] baru.
  const MessageBubble({super.key, required this.message});

  bool get _isUser =>
      message.isUser ||
      message.pertanyaan.isNotEmpty && message.jawaban.isEmpty;

  String get _text {
    if (message.isUser) return message.pertanyaan;
    if (message.jawaban.isNotEmpty) return message.jawaban;
    return message.pertanyaan;
  }

  /// Memformat timestamp ISO 8601 menjadi format jam menit (HH:mm).
  String _formatTime(String timestamp) {
    try {
      final dt = DateTime.parse(timestamp).toLocal();
      return DateFormat('HH:mm').format(dt);
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isUser = _isUser;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Avatar AI ditampilkan di sebelah kiri jika pesan dari AI
          if (!isUser) ...[
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colorScheme.primary,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.psychology_rounded,
                  color: Colors.white, size: 16),
            ),
            const SizedBox(width: 8),
          ],

          // Konten Utama Gelembung Pesan
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.78,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? colorScheme.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(16),
                      topRight: const Radius.circular(16),
                      bottomLeft: isUser
                          ? const Radius.circular(16)
                          : const Radius.circular(4),
                      bottomRight: isUser
                          ? const Radius.circular(4)
                          : const Radius.circular(16),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isUser
                            ? colorScheme.primary.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.06),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: isUser
                      ? Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          child: Text(
                            _text,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              height: 1.5,
                            ),
                          ),
                        )
                      : _AiMarkdownBody(text: _text),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(message.timestamp),
                  style: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),

          // Avatar Pengguna ditampilkan di sebelah kanan jika pesan dari pengguna
          if (isUser) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_rounded,
                  color: Colors.grey[500], size: 16),
            ),
          ],
        ],
      ),
    );
  }
}

/// Widget internal untuk merender teks respons AI menggunakan format Markdown.
/// 
/// Memberikan gaya visual premium seperti heading berwarna primary,
/// daftar poin yang rapi, dan blok kutipan spesial.
class _AiMarkdownBody extends StatelessWidget {
  final String text;
  const _AiMarkdownBody({required this.text});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: MarkdownBody(
        data: text,
        selectable: true,
        shrinkWrap: true,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 14,
            height: 1.6,
          ),
          strong: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
          em: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontStyle: FontStyle.italic,
            fontSize: 14,
          ),
          h1: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 17,
            height: 1.4,
          ),
          h2: TextStyle(
            color: colorScheme.primary,
            fontWeight: FontWeight.bold,
            fontSize: 15.5,
            height: 1.4,
          ),
          h3: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontWeight: FontWeight.bold,
            fontSize: 14.5,
            height: 1.4,
          ),
          listBullet: const TextStyle(
            color: Color(0xFF1E1E1E),
            fontSize: 14,
            height: 1.6,
          ),
          listIndent: 16,
          code: const TextStyle(
            fontFamily: 'monospace',
            fontSize: 13,
            color: Color(0xFF0891B2),
            backgroundColor: Color(0xFFE0F2FE),
          ),
          blockquote: const TextStyle(
            color: Color(0xFF555555),
            fontSize: 13,
            fontStyle: FontStyle.italic,
            height: 1.5,
          ),
          blockquoteDecoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(6),
            border: Border(
              left: BorderSide(
                color: colorScheme.primary,
                width: 3,
              ),
            ),
          ),
          blockquotePadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          horizontalRuleDecoration: const BoxDecoration(
            border: Border(
              top: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
          ),
          pPadding: const EdgeInsets.only(bottom: 4),
          h1Padding: const EdgeInsets.only(top: 8, bottom: 4),
          h2Padding: const EdgeInsets.only(top: 6, bottom: 4),
          h3Padding: const EdgeInsets.only(top: 4, bottom: 2),
        ),
      ),
    );
  }
}
