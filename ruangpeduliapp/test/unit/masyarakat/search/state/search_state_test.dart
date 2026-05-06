import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// State simulation — mencerminkan field di _SearchScreenState
// ---------------------------------------------------------------------------

/// Representasi state SearchScreen yang bisa diuji tanpa Flutter widget tree.
class SearchState {
  bool loadingPanti;
  bool loadingLocation;
  String? errorPanti;
  bool listening;
  bool sttReady;
  String? sttLocale;
  String searchQuery;
  int selectedIndex;
  final Set<int> loadingPantiId;

  SearchState({
    this.loadingPanti = true,
    this.loadingLocation = true,
    this.errorPanti,
    this.listening = false,
    this.sttReady = false,
    this.sttLocale,
    this.searchQuery = '',
    this.selectedIndex = 1,
    Set<int>? loadingPantiId,
  }) : loadingPantiId = loadingPantiId ?? {};

  /// Simulasi hasil _fetchPanti sukses
  void onPantiFetched() {
    loadingPanti = false;
    errorPanti = null;
  }

  /// Simulasi hasil _fetchPanti gagal
  void onPantiError(String error) {
    loadingPanti = false;
    errorPanti = error;
  }

  /// Simulasi retry _fetchPanti
  void onPantiRetry() {
    loadingPanti = true;
    errorPanti = null;
  }

  /// Simulasi _fetchLocation selesai (dengan posisi)
  void onLocationFetched() {
    loadingLocation = false;
  }

  /// Simulasi _fetchLocation selesai (tanpa posisi / ditolak)
  void onLocationUnavailable() {
    loadingLocation = false;
  }

  /// Simulasi _toggleMic saat sttReady = false
  bool toggleMicWithoutReady() {
    if (!sttReady) return false; // snackbar ditampilkan, tidak ada perubahan state
    return true;
  }

  /// Simulasi _toggleMic saat sedang listen → stop
  void stopListening() {
    listening = false;
  }

  /// Simulasi _toggleMic mulai listen
  void startListening() {
    listening = true;
  }

  /// Simulasi _openPantiDetail — tambahkan id ke loadingPantiId
  void startLoadingPanti(int pantiId) {
    loadingPantiId.add(pantiId);
  }

  /// Simulasi _openPantiDetail selesai — hapus id dari loadingPantiId
  void stopLoadingPanti(int pantiId) {
    loadingPantiId.remove(pantiId);
  }

  /// Simulasi _onNavTap
  bool onNavTap(int index) {
    if (index == selectedIndex) return false; // tidak ada perubahan
    selectedIndex = index;
    return true;
  }
}

// ---------------------------------------------------------------------------
// Tests
// ---------------------------------------------------------------------------

void main() {
  // =========================================================================
  group('State awal (initial state)', () {
    test('loadingPanti true saat inisialisasi', () {
      final s = SearchState();
      expect(s.loadingPanti, isTrue);
    });

    test('loadingLocation true saat inisialisasi', () {
      final s = SearchState();
      expect(s.loadingLocation, isTrue);
    });

    test('errorPanti null saat inisialisasi', () {
      final s = SearchState();
      expect(s.errorPanti, isNull);
    });

    test('selectedIndex default 1 (tab Search)', () {
      final s = SearchState();
      expect(s.selectedIndex, 1);
    });

    test('searchQuery kosong saat inisialisasi', () {
      final s = SearchState();
      expect(s.searchQuery, '');
    });

    test('listening false saat inisialisasi', () {
      final s = SearchState();
      expect(s.listening, isFalse);
    });
  });

  // =========================================================================
  group('State setelah _fetchPanti', () {
    test('loadingPanti false dan errorPanti null setelah fetch sukses', () {
      final s = SearchState();
      s.onPantiFetched();
      expect(s.loadingPanti, isFalse);
      expect(s.errorPanti, isNull);
    });

    test('loadingPanti false dan errorPanti terisi setelah fetch error', () {
      final s = SearchState();
      s.onPantiError('Connection refused');
      expect(s.loadingPanti, isFalse);
      expect(s.errorPanti, 'Connection refused');
    });

    test('loadingPanti kembali true dan errorPanti null setelah retry', () {
      final s = SearchState();
      s.onPantiError('Timeout');
      s.onPantiRetry();
      expect(s.loadingPanti, isTrue);
      expect(s.errorPanti, isNull);
    });
  });

  // =========================================================================
  group('State setelah _fetchLocation', () {
    test('loadingLocation false setelah lokasi berhasil didapat', () {
      final s = SearchState();
      s.onLocationFetched();
      expect(s.loadingLocation, isFalse);
    });

    test('loadingLocation false meskipun lokasi tidak tersedia', () {
      final s = SearchState();
      s.onLocationUnavailable();
      expect(s.loadingLocation, isFalse);
    });
  });

  // =========================================================================
  group('State STT (_toggleMic)', () {
    test('toggleMicWithoutReady mengembalikan false (tidak ubah state)', () {
      final s = SearchState(sttReady: false);
      final result = s.toggleMicWithoutReady();
      expect(result, isFalse);
      expect(s.listening, isFalse); // tetap false
    });

    test('startListening mengubah listening menjadi true', () {
      final s = SearchState(sttReady: true);
      s.startListening();
      expect(s.listening, isTrue);
    });

    test('stopListening mengubah listening menjadi false', () {
      final s = SearchState(listening: true);
      s.stopListening();
      expect(s.listening, isFalse);
    });

    test('sttLocale disimpan setelah inisialisasi berhasil', () {
      final s = SearchState();
      s.sttReady = true;
      s.sttLocale = 'id_ID';
      expect(s.sttReady, isTrue);
      expect(s.sttLocale, 'id_ID');
    });
  });

  // =========================================================================
  group('State _openPantiDetail (loading per-panti)', () {
    test('pantiId ditambahkan ke loadingPantiId saat mulai load', () {
      final s = SearchState();
      s.startLoadingPanti(5);
      expect(s.loadingPantiId.contains(5), isTrue);
    });

    test('pantiId dihapus dari loadingPantiId setelah selesai', () {
      final s = SearchState();
      s.startLoadingPanti(5);
      s.stopLoadingPanti(5);
      expect(s.loadingPantiId.contains(5), isFalse);
    });

    test('beberapa panti bisa loading bersamaan', () {
      final s = SearchState();
      s.startLoadingPanti(1);
      s.startLoadingPanti(2);
      s.startLoadingPanti(3);
      expect(s.loadingPantiId.length, 3);
    });

    test('menghapus id yang tidak ada tidak melempar error', () {
      final s = SearchState();
      expect(() => s.stopLoadingPanti(99), returnsNormally);
    });
  });

  // =========================================================================
  group('State _onNavTap (navigasi tab)', () {
    test('tidak mengubah selectedIndex ketika tap tab yang sama', () {
      final s = SearchState(selectedIndex: 1);
      final changed = s.onNavTap(1);
      expect(changed, isFalse);
      expect(s.selectedIndex, 1);
    });

    test('mengubah selectedIndex ketika tap tab berbeda', () {
      final s = SearchState(selectedIndex: 1);
      final changed = s.onNavTap(2);
      expect(changed, isTrue);
      expect(s.selectedIndex, 2);
    });

    test('selectedIndex 0 (home) dapat dipilih', () {
      final s = SearchState(selectedIndex: 1);
      s.onNavTap(0);
      expect(s.selectedIndex, 0);
    });

    test('selectedIndex 3 (profile) dapat dipilih', () {
      final s = SearchState(selectedIndex: 1);
      s.onNavTap(3);
      expect(s.selectedIndex, 3);
    });
  });

  // =========================================================================
  group('initialQuery state', () {
    test('searchQuery terisi ketika initialQuery tidak kosong', () {
      final s = SearchState(searchQuery: 'Panti Harapan');
      expect(s.searchQuery, 'Panti Harapan');
    });

    test('searchQuery kosong ketika initialQuery tidak diberikan', () {
      final s = SearchState();
      expect(s.searchQuery, isEmpty);
    });
  });
}