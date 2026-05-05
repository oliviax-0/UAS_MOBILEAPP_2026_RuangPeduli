import 'package:flutter_test/flutter_test.dart';

import '../mock_data.dart';

export '../mock_data.dart';

void main() {
  group('Mock data helper', () {
    test('mockPantiList berisi data panti dummy', () {
      expect(mockPantiList, isNotEmpty);
      expect(mockPantiList.first['id'], 1);
      expect(mockPantiList.first['nama'], 'Panti Asuhan Harapan');
    });

    test('mockKebutuhanList berisi data kebutuhan dummy', () {
      expect(mockKebutuhanList, isNotEmpty);
      expect(mockKebutuhanList.first['kategori'], 'Pendidikan');
      expect(mockKebutuhanList.first['status'], 'Aktif');
    });

    test('mockDonationHistory berisi data donasi dummy', () {
      expect(mockDonationHistory, isNotEmpty);
      expect(mockDonationHistory.first['status'], 'Berhasil');
      expect(mockDonationHistory.first['jumlah'], 100000);
    });

    test('helper pembuat mock mengembalikan map sesuai input', () {
      final panti = createMockPanti(id: 9, nama: 'Panti Baru');
      final kebutuhan = createMockKebutuhan(
        id: 8,
        nama: 'Beras',
        jumlahDibutuhkan: 100,
        jumlahTerkumpul: 25,
      );
      final donation = createMockDonation(id: 7, jumlah: 50000);

      expect(panti['id'], 9);
      expect(panti['nama'], 'Panti Baru');
      expect(kebutuhan['nama'], 'Beras');
      expect(kebutuhan['jumlah_terkumpul'], 25);
      expect(donation['id'], 7);
      expect(donation['jumlah'], 50000);
    });
  });
}
