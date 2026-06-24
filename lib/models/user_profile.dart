import 'package:cloud_firestore/cloud_firestore.dart';

/// Model data untuk profil pengguna (ibu/anak) dalam aplikasi StuntingCare.
///
/// Menyimpan informasi dasar yang digunakan untuk personalisasi
/// rekomendasi edukasi stunting dari AI.
class UserProfile {
  /// ID unik pengguna dari Firebase Authentication.
  final String uid;

  /// Nama lengkap pengguna.
  final String nama;

  /// Usia pengguna (dalam tahun).
  final int usia;

  /// Tinggi badan dalam sentimeter (cm).
  final double tinggiBadan;

  /// Berat badan awal dalam kilogram (kg).
  final double beratBadanAwal;

  /// Waktu pembuatan profil dalam format ISO 8601.
  final String? createdAt;

  /// Waktu terakhir profil diperbarui dalam format ISO 8601.
  final String? updatedAt;

  /// Membuat instance [UserProfile] baru.
  const UserProfile({
    required this.uid,
    required this.nama,
    required this.usia,
    required this.tinggiBadan,
    required this.beratBadanAwal,
    this.createdAt,
    this.updatedAt,
  });

  /// Membuat [UserProfile] dari respons JSON (backend API).
  ///
  /// Menangani nilai `null` dengan memberikan nilai default yang aman.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      uid: json['uid'] as String? ?? '',
      nama: json['nama'] as String? ?? '',
      usia: (json['usia'] as num?)?.toInt() ?? 0,
      tinggiBadan: (json['tinggi_badan'] as num?)?.toDouble() ?? 0.0,
      beratBadanAwal: (json['berat_badan_awal'] as num?)?.toDouble() ?? 0.0,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Membuat [UserProfile] dari Firestore [DocumentSnapshot].
  ///
  /// Menggunakan `doc.id` sebagai fallback untuk `uid` jika tidak tersedia
  /// dalam data dokumen.
  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: data['uid'] as String? ?? doc.id,
      nama: data['nama'] as String? ?? '',
      usia: (data['usia'] as num?)?.toInt() ?? 0,
      tinggiBadan: (data['tinggi_badan'] as num?)?.toDouble() ?? 0.0,
      beratBadanAwal: (data['berat_badan_awal'] as num?)?.toDouble() ?? 0.0,
      createdAt: data['created_at'] as String?,
      updatedAt: data['updated_at'] as String?,
    );
  }

  /// Mengonversi [UserProfile] ke format JSON untuk penyimpanan
  /// ke Firestore atau pengiriman ke API.
  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'nama': nama,
      'usia': usia,
      'tinggi_badan': tinggiBadan,
      'berat_badan_awal': beratBadanAwal,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  /// Membuat salinan [UserProfile] dengan nilai yang diperbarui.
  ///
  /// Parameter yang tidak diisi akan menggunakan nilai dari instance saat ini.
  UserProfile copyWith({
    String? uid,
    String? nama,
    int? usia,
    double? tinggiBadan,
    double? beratBadanAwal,
    String? createdAt,
    String? updatedAt,
  }) {
    return UserProfile(
      uid: uid ?? this.uid,
      nama: nama ?? this.nama,
      usia: usia ?? this.usia,
      tinggiBadan: tinggiBadan ?? this.tinggiBadan,
      beratBadanAwal: beratBadanAwal ?? this.beratBadanAwal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() =>
      'UserProfile(uid: $uid, nama: $nama, usia: $usia)';
}
