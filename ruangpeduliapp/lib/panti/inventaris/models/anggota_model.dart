class AnggotaModel {
  final int? id;
  final String nama;
  final String divisi;
  final String telepon;

  AnggotaModel({
    this.id,
    required this.nama,
    required this.divisi,
    required this.telepon,
  });

  /// Create AnggotaModel from JSON
  factory AnggotaModel.fromJson(Map<String, dynamic> json) {
    return AnggotaModel(
      id: json['id'] as int?,
      nama: json['nama'] as String,
      divisi: json['divisi'] as String,
      telepon: json['telepon'] as String,
    );
  }

  /// Convert AnggotaModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'divisi': divisi,
      'telepon': telepon,
    };
  }
}
