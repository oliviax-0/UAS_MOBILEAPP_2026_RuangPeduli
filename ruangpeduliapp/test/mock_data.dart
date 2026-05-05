/// Mock data untuk testing fitur Masyarakat

/// Mock Panti data
const mockPantiList = [
  {
    'id': 1,
    'nama': 'Panti Asuhan Harapan',
    'alamat': 'Jl. Pendidikan No. 123',
    'kota': 'Jakarta',
    'provinsi': 'DKI Jakarta',
    'nomor_telepon': '021-1234567',
    'email': 'panti@example.com',
    'deskripsi': 'Panti asuhan untuk anak-anak kurang mampu',
    'image_url': 'assets/images/panti_1.jpg',
    'rating': 4.5,
  },
  {
    'id': 2,
    'nama': 'Panti Lansia Sejahtera',
    'alamat': 'Jl. Raya Utama No. 456',
    'kota': 'Bandung',
    'provinsi': 'Jawa Barat',
    'nomor_telepon': '022-7654321',
    'email': 'pantilansia@example.com',
    'deskripsi': 'Panti jompo untuk lansia',
    'image_url': 'assets/images/panti_2.jpg',
    'rating': 4.2,
  },
];

/// Mock Kebutuhan data
const mockKebutuhanList = [
  {
    'id': 1,
    'nama': 'Biaya Pendidikan',
    'deskripsi': 'Biaya sekolah dan buku pelajaran untuk siswa',
    'kategori': 'Pendidikan',
    'jumlah_dibutuhkan': 50000000,
    'jumlah_terkumpul': 35000000,
    'gambar_url': 'assets/images/pendidikan.jpg',
    'status': 'Aktif',
    'panti_id': 1,
    'deadline': '2026-12-31',
  },
  {
    'id': 2,
    'nama': 'Obat-obatan',
    'deskripsi': 'Obat-obatan untuk kebutuhan kesehatan lanjut usia',
    'kategori': 'Kesehatan',
    'jumlah_dibutuhkan': 20000000,
    'jumlah_terkumpul': 8000000,
    'gambar_url': 'assets/images/kesehatan.jpg',
    'status': 'Aktif',
    'panti_id': 2,
    'deadline': '2026-11-30',
  },
];

/// Mock Berita/News data
const mockBeritaList = [
  {
    'id': 1,
    'judul': 'Program Baru Ruang Peduli untuk Pendidikan Anak',
    'slug': 'program-baru-ruang-peduli',
    'konten': 'Kami dengan senang hati mengumumkan program baru...',
    'gambar_url': 'assets/images/berita_1.jpg',
    'tanggal_publish': '2026-05-01',
    'penulis': 'Admin',
    'kategori': 'Program',
    'views': 1250,
  },
  {
    'id': 2,
    'judul': 'Testimoni Penerima Manfaat Donasi',
    'slug': 'testimoni-penerima',
    'konten': 'Terima kasih kepada semua donatur...',
    'gambar_url': 'assets/images/berita_2.jpg',
    'tanggal_publish': '2026-04-28',
    'penulis': 'Admin',
    'kategori': 'Testimoni',
    'views': 856,
  },
];

/// Mock Donation data
const mockDonationHistory = [
  {
    'id': 1,
    'panti_id': 1,
    'panti_nama': 'Panti Asuhan Harapan',
    'jumlah': 100000,
    'metode_pembayaran': 'Transfer Bank',
    'status': 'Berhasil',
    'tanggal': '2026-05-01T10:30:00',
    'receipt_url': 'assets/receipts/receipt_001.pdf',
  },
  {
    'id': 2,
    'panti_id': 2,
    'panti_nama': 'Panti Lansia Sejahtera',
    'jumlah': 250000,
    'metode_pembayaran': 'E-Wallet',
    'status': 'Berhasil',
    'tanggal': '2026-04-28T14:15:00',
    'receipt_url': 'assets/receipts/receipt_002.pdf',
  },
];

/// Mock User Profile data
const mockUserProfile = {
  'id': 1,
  'nama': 'John Doe',
  'email': 'john@example.com',
  'nomor_telepon': '0812-3456-7890',
  'alamat': 'Jl. Contoh No. 123',
  'kota': 'Jakarta',
  'provinsi': 'DKI Jakarta',
  'foto_profil_url': 'assets/images/profile_default.jpg',
  'total_donasi': 350000,
  'jumlah_donasi': 2,
};

/// Mock Chat History data
const mockChatHistory = [
  {
    'id': 1,
    'pesan_user': 'Halo, bagaimana caranya berdonasi?',
    'pesan_bot': 'Anda dapat berdonasi dengan mengikuti langkah-langkah berikut...',
    'timestamp': '2026-05-01T10:00:00',
  },
  {
    'id': 2,
    'pesan_user': 'Apakah ada kartu member?',
    'pesan_bot': 'Ya, kami memiliki program kartu member dengan berbagai keuntungan...',
    'timestamp': '2026-05-01T10:05:00',
  },
];

/// Mock Notification data
const mockNotifications = [
  {
    'id': 1,
    'judul': 'Donasi Anda Berhasil',
    'deskripsi': 'Terima kasih telah mendonasikan Rp 100.000',
    'tipe': 'donation_success',
    'tanggal': '2026-05-01T10:30:00',
    'dibaca': false,
  },
  {
    'id': 2,
    'judul': 'Kebutuhan Baru',
    'deskripsi': 'Panti Asuhan Harapan membuka kebutuhan baru',
    'tipe': 'new_need',
    'tanggal': '2026-04-30T14:20:00',
    'dibaca': true,
  },
];

/// Helper function untuk create mock Panti
Map<String, dynamic> createMockPanti({
  int id = 1,
  String nama = 'Panti Test',
  String alamat = 'Jl. Test No. 123',
  String kota = 'Jakarta',
  String provinsi = 'DKI Jakarta',
  double rating = 4.5,
}) {
  return {
    'id': id,
    'nama': nama,
    'alamat': alamat,
    'kota': kota,
    'provinsi': provinsi,
    'rating': rating,
  };
}

/// Helper function untuk create mock Kebutuhan
Map<String, dynamic> createMockKebutuhan({
  int id = 1,
  String nama = 'Kebutuhan Test',
  int jumlahDibutuhkan = 1000000,
  int jumlahTerkumpul = 500000,
}) {
  return {
    'id': id,
    'nama': nama,
    'jumlah_dibutuhkan': jumlahDibutuhkan,
    'jumlah_terkumpul': jumlahTerkumpul,
  };
}

/// Helper function untuk create mock Donation
Map<String, dynamic> createMockDonation({
  int id = 1,
  int pantiId = 1,
  int jumlah = 100000,
  String status = 'Berhasil',
}) {
  return {
    'id': id,
    'panti_id': pantiId,
    'jumlah': jumlah,
    'status': status,
    'tanggal': DateTime.now().toIso8601String(),
  };
}
