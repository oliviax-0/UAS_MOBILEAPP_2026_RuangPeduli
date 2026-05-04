class BeritaModel {
  final int id;
  final String judul;
  final String deskripsi;
  final String? gambar;
  final String createdAt;

  BeritaModel({
    required this.id,
    required this.judul,
    required this.deskripsi,
    this.gambar,
    required this.createdAt,
  });

  // =========================
  // FROM JSON
  // =========================
  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      gambar: json['gambar'], // nullable
      createdAt: json['created_at'] ?? '',
    );
  }

  // =========================
  // TO JSON
  // =========================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'deskripsi': deskripsi,
      'gambar': gambar,
      'created_at': createdAt,
    };
  }
}