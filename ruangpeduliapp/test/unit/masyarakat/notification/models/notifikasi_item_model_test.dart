import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Replika _NotifItem dari notification_screen.dart
// (class bersifat private sehingga direplikasi di sini untuk unit test)
// ---------------------------------------------------------------------------

class NotifItem {
  final String pesan;
  final String waktu;
  final IconData icon;
  final Color iconColor;

  const NotifItem({
    required this.pesan,
    required this.waktu,
    required this.icon,
    required this.iconColor,
  });

  factory NotifItem.welcome() => const NotifItem(
        pesan: 'Selamat bergabung! Terima kasih sudah peduli sesama 💛',
        waktu: '',
        icon: Icons.favorite_rounded,
        iconColor: Color(0xFFF47B8C),
      );

  /// Replika factory yang dibuat di _load() dari data donasi.
  factory NotifItem.fromDonation({
    required String namaPanti,
    required String formattedJumlah,
    required String tanggalLabel,
  }) =>
      NotifItem(
        pesan:
            'Donasi kamu ke $namaPanti sebesar $formattedJumlah berhasil! Terima kasih sudah peduli 💛',
        waktu: tanggalLabel,
        icon: Icons.volunteer_activism_rounded,
        iconColor: const Color(0xFFF47B8C),
      );
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('NotifItem.welcome()', () {
    test('pesan selamat datang tidak kosong', () {
      final item = NotifItem.welcome();
      expect(item.pesan, isNotEmpty);
    });

    test('waktu kosong pada notifikasi welcome', () {
      final item = NotifItem.welcome();
      expect(item.waktu, isEmpty);
    });

    test('icon adalah favorite_rounded', () {
      final item = NotifItem.welcome();
      expect(item.icon, Icons.favorite_rounded);
    });

    test('iconColor adalah pink F47B8C', () {
      final item = NotifItem.welcome();
      expect(item.iconColor, const Color(0xFFF47B8C));
    });

    test('pesan mengandung kata "bergabung"', () {
      final item = NotifItem.welcome();
      expect(item.pesan.toLowerCase(), contains('bergabung'));
    });
  });

  // -------------------------------------------------------------------------

  group('NotifItem.fromDonation()', () {
    test('pesan mengandung nama panti', () {
      final item = NotifItem.fromDonation(
        namaPanti: 'Panti Harapan',
        formattedJumlah: 'Rp50.000',
        tanggalLabel: '1 Jun 2024',
      );
      expect(item.pesan, contains('Panti Harapan'));
    });

    test('pesan mengandung jumlah donasi', () {
      final item = NotifItem.fromDonation(
        namaPanti: 'Panti Kasih',
        formattedJumlah: 'Rp75.000',
        tanggalLabel: '2 Jun 2024',
      );
      expect(item.pesan, contains('Rp75.000'));
    });

    test('pesan mengandung kata "berhasil"', () {
      final item = NotifItem.fromDonation(
        namaPanti: 'Panti Sejahtera',
        formattedJumlah: 'Rp100.000',
        tanggalLabel: '3 Jun 2024',
      );
      expect(item.pesan.toLowerCase(), contains('berhasil'));
    });

    test('waktu diisi dengan tanggalLabel dari donasi', () {
      final item = NotifItem.fromDonation(
        namaPanti: 'Panti Ceria',
        formattedJumlah: 'Rp20.000',
        tanggalLabel: '5 Jul 2024',
      );
      expect(item.waktu, '5 Jul 2024');
    });

    test('icon adalah volunteer_activism_rounded', () {
      final item = NotifItem.fromDonation(
        namaPanti: 'Panti X',
        formattedJumlah: 'Rp10.000',
        tanggalLabel: '',
      );
      expect(item.icon, Icons.volunteer_activism_rounded);
    });

    test('waktu kosong string jika tanggalLabel kosong', () {
      final item = NotifItem.fromDonation(
        namaPanti: 'Panti Y',
        formattedJumlah: 'Rp5.000',
        tanggalLabel: '',
      );
      expect(item.waktu, isEmpty);
    });
  });

  // -------------------------------------------------------------------------

  group('List NotifItem — susunan dari _load()', () {
    test('list selalu diawali dengan item welcome', () {
      final items = <NotifItem>[NotifItem.welcome()];
      items.add(NotifItem.fromDonation(
        namaPanti: 'Panti A',
        formattedJumlah: 'Rp10.000',
        tanggalLabel: '1 Jan 2024',
      ));

      expect(items.first.pesan, contains('bergabung'));
    });

    test('jumlah item = 1 (welcome) + jumlah donasi', () {
      const donationCount = 3;
      final items = <NotifItem>[NotifItem.welcome()];
      for (var i = 0; i < donationCount; i++) {
        items.add(NotifItem.fromDonation(
          namaPanti: 'Panti $i',
          formattedJumlah: 'Rp${i * 10}.000',
          tanggalLabel: '$i Jan 2024',
        ));
      }

      expect(items.length, donationCount + 1);
    });

    test('userId null → hanya item welcome, tidak ada donasi', () {
      const int? userId = null;
      final items = <NotifItem>[];

      if (userId == null) {
        items.add(NotifItem.welcome());
      }

      expect(items.length, 1);
      expect(items.first.waktu, isEmpty);
    });

    test('list kosong donasi → hanya 1 item welcome', () {
      final List<Map<String, dynamic>> donations = [];
      final items = <NotifItem>[NotifItem.welcome()];
      for (final _ in donations) {
        items.add(NotifItem.fromDonation(
          namaPanti: '',
          formattedJumlah: '',
          tanggalLabel: '',
        ));
      }

      expect(items.length, 1);
    });
  });
}