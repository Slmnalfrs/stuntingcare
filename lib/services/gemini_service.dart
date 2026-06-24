import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user_profile.dart';
import '../utils/constants.dart';

/// Layanan untuk berinteraksi dengan Google Gemini AI melalui API REST.
/// 
/// Menggunakan model `gemini-1.5-flash` untuk memberikan respon edukasi
/// berkecepatan tinggi mengenai pencegahan stunting.
class GeminiService {
  /// Index API Key yang sedang aktif saat ini.
  static int _currentKeyIndex = 0;

  /// Membangun prompt sistem yang dipersonalisasi berdasarkan data profil pengguna.
  /// 
  /// Ini memastikan AI mengenal kondisi fisik anak/ibu untuk saran yang lebih relevan.
  String _buildSystemPrompt(UserProfile? profile) {
    String prompt = AppConstants.systemPromptBase;

    if (profile != null) {
      prompt += '''

Profil Pengguna:
- Nama: ${profile.nama}
- Usia Pengguna: ${profile.usia} tahun
- Tinggi Badan: ${profile.tinggiBadan} cm
- Berat Badan: ${profile.beratBadanAwal} kg

Instruksi Tambahan:
Berikan saran edukasi yang dipersonalisasi sesuai kondisi di atas jika relevan dengan pencegahan stunting.''';
    }

    return prompt;
  }

  /// Mengirimkan pesan pertanyaan ke Gemini AI dan mendapatkan jawabannya.
  /// 
  /// Menyertakan mekanisme **Auto-Retry** jika server sibuk (HTTP 503/429)
  /// atau terjadi gangguan jaringan ringan.
  Future<String> sendMessage(String pertanyaan, {UserProfile? profile}) async {
    final apiKeys = AppConstants.geminiApiKeys;

    if (apiKeys.isEmpty) {
      throw Exception(
        'Gemini API Key belum dikonfigurasi. Silakan isi FLUTTER_GEMINI_API_KEY di file .env',
      );
    }

    final systemPrompt = _buildSystemPrompt(profile);
    const modelName = AppConstants.geminiModel; 

    final requestBody = {
      'system_instruction': {
        'parts': [
          {'text': systemPrompt}
        ]
      },
      'contents': [
        {
          'role': 'user',
          'parts': [
            {'text': pertanyaan}
          ]
        }
      ],
      'generationConfig': {
        'maxOutputTokens': 2048,
        'temperature': 0.4, 
      },
    };

    int keysTried = 0;

    // Loop ganti API Key jika ada yang habis kuotanya
    while (keysTried < apiKeys.length) {
      final apiKey = apiKeys[_currentKeyIndex].trim();
      final url = Uri.parse('https://generativelanguage.googleapis.com/v1beta/models/$modelName:generateContent?key=$apiKey');

      int maxRetries = 3;
      int attempt = 0;
      
      while (attempt < maxRetries) {
        attempt++;
        try {
          debugPrint('[GEMINI_DEBUG] Attempt $attempt (Key Index $_currentKeyIndex): Sending request to $modelName...');
          final response = await http
              .post(
                url,
                headers: {'Content-Type': 'application/json'},
                body: jsonEncode(requestBody),
              )
              .timeout(const Duration(seconds: 30));

          if (response.statusCode == 200) {
            final data = jsonDecode(response.body) as Map<String, dynamic>;
            final candidates = data['candidates'] as List<dynamic>;
            if (candidates.isEmpty) {
              throw Exception('Gemini tidak memberikan respons (Candidate Empty)');
            }
            final content = candidates[0]['content'] as Map<String, dynamic>;
            final parts = content['parts'] as List<dynamic>;
            final text = parts[0]['text'] as String;
            return text.trim();
          } else {
            debugPrint('[GEMINI_ERROR_DETAIL] Attempt $attempt - Status: ${response.statusCode}');
            
            final errorData = jsonDecode(response.body);
            final errorMsg = errorData['error']?['message'] ?? 'Unknown error';
            final code = errorData['error']?['code'] ?? response.statusCode;

            // Jika limit token harian habis untuk API Key INI
            if (code == 429 && errorMsg.toLowerCase().contains('quota')) {
              debugPrint('[GEMINI_KEY_EXHAUSTED] Key index $_currentKeyIndex kehabisan kuota.');
              break; // Keluar dari loop attempt, coba API Key selanjutnya
            }

            // Jeda Retry: 2s, lalu 4s
            if ((code == 503 || code == 429) && attempt < maxRetries) {
              final delaySeconds = attempt * 2;
              debugPrint('[GEMINI_RETRY] Server sibuk ($code). Mencoba kembali dalam $delaySeconds detik...');
              await Future.delayed(Duration(seconds: delaySeconds));
              continue;
            }

            throw Exception('Gemini Error ($modelName): $errorMsg');
          }
        } on http.ClientException catch (e) {
          if (attempt < maxRetries) {
            final delaySeconds = attempt * 2;
            await Future.delayed(Duration(seconds: delaySeconds));
            continue;
          }
          throw Exception('Tidak dapat terhubung ke Gemini (Network Error): ${e.message}');
        } catch (e) {
          if (e is Exception) {
            if (e.toString().contains('Gemini Error') || e.toString().contains('Gemini tidak memberikan respons')) {
              rethrow;
            }
          }
          
          if (attempt < maxRetries) {
            final delaySeconds = attempt * 2;
            await Future.delayed(Duration(seconds: delaySeconds));
            continue;
          }
          rethrow;
        }
      }

      // Jika loop attempt dibreak karena quota habis, coba kunci berikutnya
      keysTried++;
      if (keysTried < apiKeys.length) {
        _currentKeyIndex = (_currentKeyIndex + 1) % apiKeys.length;
        debugPrint('[GEMINI_KEY_ROTATION] Beralih ke API Key index $_currentKeyIndex...');
      }
    }

    // Jika semua API keys sudah dicoba dan tidak ada yang berhasil/kehabisan kuota
    throw Exception('QUOTA_EXHAUSTED');
  }

  /// Mengecek apakah API key sudah diatur di konfigurasi aplikasi.
  bool get isConfigured => AppConstants.geminiApiKey.isNotEmpty;
}
