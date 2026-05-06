import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// State simulation — mencerminkan field di _NotificationScreenState
// ---------------------------------------------------------------------------

class NotifItem {
  final String pesan;
  final String waktu;
  const NotifItem({required this.pesan, required this.waktu});
  factory NotifItem.welcome() =>
      const NotifItem(pesan: 'Selamat bergabung!', waktu: '');
  factory NotifItem.donation(String panti, String jumlah, String tgl) =>
      NotifItem(pesan: 'Donasi ke $panti sebesar $jumlah berhasil!', waktu: tgl);
}

class NotifState {
  List<NotifItem> items;
  bool loading;
  String? error;

  NotifState({
    List<NotifItem>? items,
    this.loading = true,
    this.error,
  }) : items = items ?? [];

  // Simulasi _load() ketika userId == null
  void loadWithoutUser() {
    items = [NotifItem.welcome()];
    loading = false;
    error = null;
  }

  // Simulasi _load() sukses dengan donasi
  void loadSuccess(List<NotifItem> donations) {
    items = [NotifItem.welcome(), ...donations];
    loading = false;
    error = null;
  }

  // Simulasi _load() gagal
  void loadError(String message) {
    error = message;
    loading = false;
  }

  // Simulasi retry dari tombol "Coba lagi"
  void retry() {
    loading = true;
    error = null;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  group('State awal NotificationScreen', () {
    test('loading true saat inisialisasi', () {
      final s = NotifState();
      expect(s.loading, isTrue);
    });

    test('items kosong sebelum _load() dipanggil', () {
      final s = NotifState();
      expect(s.items, isEmpty);
    });

    test('error null saat inisialisasi', () {
      final s = NotifState();
      expect(s.error, isNull);
    });
  });

  // =========================================================================

  group('State setelah _load() — userId null', () {
    test('hanya ada 1 item welcome', () {
      final s = NotifState();
      s.loadWithoutUser();
      expect(s.items.length, 1);
    });

    test('loading false setelah load tanpa userId', () {
      final s = NotifState();
      s.loadWithoutUser();
      expect(s.loading, isFalse);
    });

    test('error tetap null', () {
      final s = NotifState();
      s.loadWithoutUser();
      expect(s.error, isNull);
    });

    test('item pertama adalah welcome', () {
      final s = NotifState();
      s.loadWithoutUser();
      expect(s.items.first.pesan, contains('bergabung'));
    });
  });

  // =========================================================================

  group('State setelah _load() — sukses dengan donasi', () {
    final fakeDonations = [
      NotifItem.donation('Panti A', 'Rp50.000', '1 Jun 2024'),
      NotifItem.donation('Panti B', 'Rp30.000', '5 Jun 2024'),
    ];

    test('loading false setelah sukses', () {
      final s = NotifState();
      s.loadSuccess(fakeDonations);
      expect(s.loading, isFalse);
    });

    test('error null setelah sukses', () {
      final s = NotifState();
      s.loadSuccess(fakeDonations);
      expect(s.error, isNull);
    });

    test('jumlah items = 1 welcome + jumlah donasi', () {
      final s = NotifState();
      s.loadSuccess(fakeDonations);
      expect(s.items.length, fakeDonations.length + 1);
    });

    test('item pertama selalu welcome', () {
      final s = NotifState();
      s.loadSuccess(fakeDonations);
      expect(s.items.first.pesan, contains('bergabung'));
    });

    test('item donasi ada setelah welcome', () {
      final s = NotifState();
      s.loadSuccess(fakeDonations);
      expect(s.items[1].pesan, contains('Panti A'));
      expect(s.items[2].pesan, contains('Panti B'));
    });

    test('donasi kosong → hanya 1 item welcome', () {
      final s = NotifState();
      s.loadSuccess([]);
      expect(s.items.length, 1);
    });
  });

  // =========================================================================

  group('State setelah _load() — error', () {
    test('error terisi dengan pesan exception', () {
      final s = NotifState();
      s.loadError('Connection refused');
      expect(s.error, 'Connection refused');
    });

    test('loading false setelah error', () {
      final s = NotifState();
      s.loadError('Timeout');
      expect(s.loading, isFalse);
    });

    test('items tetap kosong saat error', () {
      final s = NotifState();
      s.loadError('Server error');
      expect(s.items, isEmpty);
    });
  });

  // =========================================================================

  group('State retry setelah error', () {
    test('loading kembali true setelah retry', () {
      final s = NotifState();
      s.loadError('Timeout');
      s.retry();
      expect(s.loading, isTrue);
    });

    test('error kembali null setelah retry', () {
      final s = NotifState();
      s.loadError('Timeout');
      s.retry();
      expect(s.error, isNull);
    });

    test('setelah retry lalu sukses, items terisi dengan benar', () {
      final s = NotifState();
      s.loadError('Timeout');
      s.retry();
      s.loadSuccess([
        NotifItem.donation('Panti C', 'Rp10.000', '10 Jul 2024'),
      ]);
      expect(s.items.length, 2);
      expect(s.items[1].pesan, contains('Panti C'));
    });
  });

  // =========================================================================

  group('NotifItem — properti waktu untuk kondisional UI', () {
    test('waktu kosong pada item welcome → UI tidak menampilkan waktu', () {
      final item = NotifItem.welcome();
      // Logika UI: if (item.waktu.isNotEmpty) tampilkan label waktu
      expect(item.waktu.isNotEmpty, isFalse);
    });

    test('waktu tidak kosong pada item donasi → UI menampilkan waktu', () {
      final item = NotifItem.donation('Panti X', 'Rp20.000', '7 Jun 2024');
      expect(item.waktu.isNotEmpty, isTrue);
    });
  });
}