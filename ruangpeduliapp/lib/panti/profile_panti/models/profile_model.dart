class ProfileModel {
  final int id;
  final String namaPanti;
  final String email;
  final String noTelepon;
  final String alamat;
  final String deskripsi;
  final String? fotoProfil;

  ProfileModel({
    required this.id,
    required this.namaPanti,
    required this.email,
    required this.noTelepon,
    required this.alamat,
    required this.deskripsi,
    this.fotoProfil,
  });

  // =========================
  // FROM JSON
  // =========================
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? 0,
      namaPanti: json['nama_panti'] ?? '',
      email: json['email'] ?? '',
      noTelepon: json['no_telepon'] ?? '',
      alamat: json['alamat'] ?? '',
      deskripsi: json['deskripsi'] ?? '',
      fotoProfil: json['foto_profil'], // nullable
    );
  }

  // =========================
  // TO JSON
  // =========================
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nama_panti': namaPanti,
      'email': email,
      'no_telepon': noTelepon,
      'alamat': alamat,
      'deskripsi': deskripsi,
      'foto_profil': fotoProfil,
    };
  }
}