class KebutuhanModel {
  final int id;
  final String nama;
  final int jumlah;
  final String satuan;

  KebutuhanModel({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.satuan,
  });

  // =========================
  // FROM JSON
  // =========================
  factory KebutuhanModel.fromJson(Map<String, dynamic> json) {
    return KebutuhanModel(
      id: json['id'] ?? 0,
      nama: json['nama'] ?? '',
      jumlah: json['jumlah'] ?? 0,
      satuan: json['satuan'] ?? '',
    );
  }

  // =========================
  // TO JSON
  // =========================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'satuan': satuan,
    };
  }
}