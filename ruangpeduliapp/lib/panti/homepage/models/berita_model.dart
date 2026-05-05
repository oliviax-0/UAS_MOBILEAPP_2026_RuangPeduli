class BeritaModel {
  final int id;
  final String judul;
  final String isi;
  final String? thumbnail;
  final String createdAt;

  const BeritaModel({
    required this.id,
    required this.judul,
    required this.isi,
    this.thumbnail,
    required this.createdAt,
  });

  factory BeritaModel.fromJson(Map<String, dynamic> json) {
    return BeritaModel(
      id: json['id'] ?? 0,
      judul: json['judul'] ?? json['title'] ?? '',
      isi: json['isi'] ?? json['content'] ?? '',
      thumbnail: json['thumbnail'],
      createdAt: json['created_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'judul': judul,
      'isi': isi,
      'thumbnail': thumbnail,
      'created_at': createdAt,
    };
  }
}
