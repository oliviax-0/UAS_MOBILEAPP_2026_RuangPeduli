import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/data/data.dart';

import 'profile_api_test.mocks.dart';

@GenerateMocks([ProfileApi])
void main() {
  late MockProfileApi mockProfileApi;

  setUp(() {
    mockProfileApi = MockProfileApi();
  });

  // ─────────────────────────────────────────────
  // GROUP: fetchMasyarakatProfile
  // ─────────────────────────────────────────────
  group('ProfileApi.fetchMasyarakatProfile', () {
    const int testUserId = 1;

    final tProfile = SocietyProfileModel(
      id: testUserId,
      namaPengguna: 'Budi Santoso',
      username: 'budi123',
      email: 'budi@email.com',
      nomorTelepon: '08123456789',
      jenisKelamin: 'Laki-laki',
      alamat: 'Jakarta',
      profilePicture: null,
    );

    test('mengembalikan SocietyProfileModel ketika berhasil', () async {
      when(mockProfileApi.fetchMasyarakatProfile(testUserId))
          .thenAnswer((_) async => tProfile);

      final result = await mockProfileApi.fetchMasyarakatProfile(testUserId);

      expect(result, isNotNull);
      expect(result!.id, equals(testUserId));
      expect(result.namaPengguna, equals('Budi Santoso'));
      expect(result.email, equals('budi@email.com'));
      verify(mockProfileApi.fetchMasyarakatProfile(testUserId)).called(1);
    });

    test('mengembalikan null ketika profil tidak ditemukan', () async {
      when(mockProfileApi.fetchMasyarakatProfile(testUserId))
          .thenAnswer((_) async => null);

      final result = await mockProfileApi.fetchMasyarakatProfile(testUserId);

      expect(result, isNull);
    });

    test('melempar Exception ketika terjadi error jaringan', () async {
      when(mockProfileApi.fetchMasyarakatProfile(testUserId))
          .thenThrow(Exception('Network error'));

      expect(
        mockProfileApi.fetchMasyarakatProfile(testUserId),
        throwsException,
      );
    });
  });

  // ─────────────────────────────────────────────
  // GROUP: fetchAllPanti
  // ─────────────────────────────────────────────
  group('ProfileApi.fetchAllPanti', () {
    final tPantiList = [
      PantiProfileModel(
        id: 1,
        namaPanti: 'Panti Asuhan Harapan',
        username: 'panti_harapan',
        nomorPanti: '021-1234567',
        alamatPanti: 'Jl. Harapan No.1, Jakarta',
        description: 'Panti terpercaya',
        profilePicture: 'https://example.com/img1.jpg',
        totalTerkumpul: 1500000,
      ),
      PantiProfileModel(
        id: 2,
        namaPanti: 'Panti Kasih Ibu',
        username: 'panti_kasih',
        nomorPanti: '021-7654321',
        alamatPanti: 'Jl. Kasih No.2, Jakarta',
        description: 'Panti berkualitas',
        profilePicture: null,
        totalTerkumpul: 3200000,
      ),
    ];

    test('fetchAllPanti: mengembalikan list dengan data panti ketika berhasil', () async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);

      final result = await mockProfileApi.fetchAllPanti();

      expect(result, isNotEmpty);
      expect(result.length, equals(2));
      expect(result.first.namaPanti, equals('Panti Asuhan Harapan'));
      verify(mockProfileApi.fetchAllPanti()).called(1);
    });

    test('fetchAllPanti: mengembalikan list kosong ketika tidak ada panti', () async {
      when(mockProfileApi.fetchAllPanti()).thenAnswer((_) async => []);

      final result = await mockProfileApi.fetchAllPanti();

      expect(result, isEmpty);
    });

    test('fetchAllPanti: melempar Exception ketika server error', () async {
      when(mockProfileApi.fetchAllPanti())
          .thenThrow(Exception('Server error 500'));

      expect(
        mockProfileApi.fetchAllPanti(),
        throwsException,
      );
    });
  });

  // ─────────────────────────────────────────────
  // GROUP: updateMasyarakatProfile
  // ─────────────────────────────────────────────
  group('ProfileApi.updateMasyarakatProfile', () {
    const int profileId = 1;

    final tUpdated = SocietyProfileModel(
      id: profileId,
      namaPengguna: 'Budi Updated',
      username: 'budi_new',
      email: 'budi@email.com',
      nomorTelepon: '08199999999',
      jenisKelamin: 'Laki-laki',
      alamat: 'Bandung',
      profilePicture: null,
    );

    test('mengembalikan profil yang diperbarui ketika berhasil', () async {
      when(mockProfileApi.updateMasyarakatProfile(
        profileId,
        namaPengguna: 'Budi Updated',
        username: 'budi_new',
        nomorTelepon: '08199999999',
        jenisKelamin: 'Laki-laki',
        alamat: 'Bandung',
        profilePicture: null,
        removeProfilePicture: false,
      )).thenAnswer((_) async => tUpdated);

      final result = await mockProfileApi.updateMasyarakatProfile(
        profileId,
        namaPengguna: 'Budi Updated',
        username: 'budi_new',
        nomorTelepon: '08199999999',
        jenisKelamin: 'Laki-laki',
        alamat: 'Bandung',
        profilePicture: null,
        removeProfilePicture: false,
      );

      expect(result, isNotNull);
      expect(result!.namaPengguna, equals('Budi Updated'));
      expect(result.username, equals('budi_new'));
    });

    test('mengembalikan null ketika update gagal dari server', () async {
      when(mockProfileApi.updateMasyarakatProfile(
        profileId,
        namaPengguna: 'Test',
      )).thenAnswer((_) async => null);

      final result = await mockProfileApi.updateMasyarakatProfile(
        profileId,
        namaPengguna: 'Test',
      );

      expect(result, isNull);
    });

    test('melempar Exception ketika koneksi gagal', () async {
      when(mockProfileApi.updateMasyarakatProfile(
        profileId,
        namaPengguna: 'Test',
      )).thenThrow(Exception('Connection timeout'));

      expect(
        mockProfileApi.updateMasyarakatProfile(
          profileId,
          namaPengguna: 'Test',
        ),
        throwsException,
      );
    });
  });
}