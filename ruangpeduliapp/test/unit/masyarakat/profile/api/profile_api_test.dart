import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';
import 'package:ruangpeduliapp/data/data.dart';

void main() {
  late MockClient mockClient;

  setUp(() {
    mockClient = MockClient((request) async {
      final url = request.url.toString();
      if (url.contains('/api/profiles/masyarakat/') && url.contains('user_id=1')) {
        return http.Response('''
{
  "id": 1,
  "username": "testuser",
  "email": "test@example.com",
  "nama_pengguna": "Test User",
  "alamat": "Test Address",
  "nomor_telepon": "123456789",
  "jenis_kelamin": "Laki-laki",
  "profile_picture": "pic.jpg"
}
        ''', 200);
      } else if (url.contains('/api/donations/?user_id=1')) {
        return http.Response('''
[
  {
    "id": 1,
    "nama_panti": "Panti Test",
    "panti_image": null,
    "jumlah": 100000,
    "metode_pembayaran": "Transfer",
    "no_referensi": "REF123",
    "tanggal": "2023-01-01T00:00:00Z",
    "tanggal_label": "1 Januari 2023"
  }
]
        ''', 200);
      } else if (url.contains('/api/donations/') && request.method == 'POST') {
        return http.Response('''
{
  "id": 2,
  "nama_panti": "New Panti",
  "panti_image": null,
  "jumlah": 50000,
  "metode_pembayaran": "Cash",
  "no_referensi": "REF456",
  "tanggal": "2023-01-02T00:00:00Z",
  "tanggal_label": "2 Januari 2023"
}
        ''', 201);
      } else if (url.contains('/api/profiles/panti/')) {
        return http.Response('''
[
  {
    "id": 1,
    "username": "panti1",
    "email": "panti1@example.com",
    "nama_panti": "Panti Asuhan 1",
    "alamat_panti": "Jl. Panti 1",
    "nomor_panti": "111",
    "profile_picture": null,
    "description": "Deskripsi 1",
    "total_terkumpul": 100000,
    "provinsi": "Jawa Barat",
    "kabupaten_kota": "Bandung",
    "kecamatan": "Coblong",
    "kelurahan": "Dago",
    "kode_pos": "40135",
    "lat": -6.2,
    "lng": 106.8
  }
]
        ''', 200);
      }
      return http.Response('Not found', 404);
    });
    http.overrideWith(mockClient);
  });

  tearDown(() {
    http.overrideWith(null);
  });

  group('ProfileApi', () {
    test('fetchMasyarakatProfile returns correct model', () async {
      final api = ProfileApi();
      final result = await api.fetchMasyarakatProfile(1);
      expect(result?.id, 1);
      expect(result?.username, 'testuser');
      expect(result?.namaPengguna, 'Test User');
    });

    test('fetchAllPanti returns list', () async {
      final api = ProfileApi();
      final result = await api.fetchAllPanti();
      expect(result.length, 1);
      expect(result[0].namaPanti, 'Panti Asuhan 1');
    });
  });

  group('DonationApi', () {
    test('fetchDonations returns list', () async {
      final api = DonationApi();
      final result = await api.fetchDonations(1);
      expect(result.length, 1);
      expect(result[0].namaPanti, 'Panti Test');
      expect(result[0].jumlah, 100000);
    });

    test('createDonation returns new donation', () async {
      final api = DonationApi();
      final result = await api.createDonation(
        userId: 1,
        namaPanti: 'New Panti',
        jumlah: 50000,
        metodePembayaran: 'Cash',
        noReferensi: 'REF456',
      );
      expect(result.id, 2);
      expect(result.jumlah, 50000);
    });
  });
}