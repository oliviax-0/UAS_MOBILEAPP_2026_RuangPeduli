class ItemModel {
  final int? id;
  final String nama;
  final String kategori;
  final num stok;
  final String satuan;

  ItemModel({
    this.id,
    required this.nama,
    required this.kategori,
    required this.stok,
    required this.satuan,
  });

  /// Create ItemModel from JSON
  factory ItemModel.fromJson(Map<String, dynamic> json) {
    return ItemModel(
      id: json['id'] as int?,
      nama: json['nama'] as String,
      kategori: json['kategori'] as String,
      stok: json['stok'] as num,
      satuan: json['satuan'] as String,
    );
  }

  /// Convert ItemModel to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama': nama,
      'kategori': kategori,
      'stok': stok,
      'satuan': satuan,
    };
  }
}
