class KategoriModel {
  final int? id;
  final String nama;

  KategoriModel({
    this.id,
    required this.nama,
  });

  /// Create KategoriModel from JSON
  factory KategoriModel.fromJson(Map<String, dynamic> json) {
    return KategoriModel(
      id: json['id'] as int?,
      nama: json['nama'] as String,
    );
  }

  /// Convert KategoriModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
    };
  }
}
