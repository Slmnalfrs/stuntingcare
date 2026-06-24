import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Konfigurasi statis dan nilai konstanta global untuk aplikasi StuntingCare.
/// 
/// Mengelola konfigurasi API, identitas visual aplikasi (layanan AI), 
/// dan prompt dasar untuk personalisasi chatbot.
class AppConstants {
  /// Nama model Gemini AI yang digunakan untuk percakapan.
  static const String geminiModel = 'gemini-2.5-flash';

  /// Mendapatkan daftar API Key Gemini dari file environment (.env).
  static List<String> get geminiApiKeys {
    final keyString = dotenv.env['FLUTTER_GEMINI_API_KEY'] ?? '';
    if (keyString.isEmpty) return [];
    return keyString.split(',').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
  }

  /// Mendapatkan API Key Gemini dari file environment (.env).
  static String get geminiApiKey {
    final keys = geminiApiKeys;
    return keys.isNotEmpty ? keys.first : '';
  }

  /// Prompt sistem dasar (baseline) untuk mengarahkan perilaku AI.
  /// 
  /// Menginstruksikan AI untuk berperan sebagai pakar edukasi stunting
  /// yang empatik, terstruktur, dan akurat secara medis.
  static const String systemPromptBase = '''
Anda adalah AI StuntingCare Expert, sebuah asisten edukasi kesehatan yang ahli dalam pencegahan stunting.
Tujuan Anda adalah membantu ibu hamil dan orang tua dengan anak balita untuk memahami bahaya stunting dan cara mencegahnya.

Pedoman Jawaban Anda:
1. EDUKATIF & TERPERCAYA: Berikan saran berdasarkan pedoman medis resmi (Kemenkes/WHO).
2. EMPATIK: Gunakan bahasa yang sopan, mendukung, dan mudah dipahami oleh orang tua.
3. TERSTRUKTUR: Gunakan format markdown (poin-poin, bold, heading) untuk jawaban yang panjang.
4. TO THE POINT: Jangan memberikan jawaban yang terlalu bertele-tele.
5. BATASAN: Jika pertanyaan di luar konteks kesehatan/stunting/parenting, arahkan kembali dengan sopan ke topik utama.
6. DISCLAIMER: Pastikan untuk mencantumkan catatan kecil di akhir setiap jawaban penting bahwa informasi ini hanya bersifat 
   edukasi dan bukan pengganti diagnosis atau anjuran dari ahli gizi maupun tenaga medis.
''';
}
