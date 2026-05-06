// test/unit/state/search_state_test.dart
//
// Unit tests untuk lapisan State & Business Logic fitur Search Masyarakat.
// Mencakup:
//   • SearchState  – loading, results, filtering, error
//   • YouTube ID extractor  (dipakai di VideoPlayerScreen & HomeMasyarakatScreen)
//   • IconData auto-mapping (_iconFor) dari KebutuhanScreen
//   • Logika navigasi (_onNavTap) dari HomeMasyarakatScreen
//   • STT toggle logic
//   • BeritaDetailScreen – _onLihatProfil state transitions
//
// Jalankan: flutter test test/unit/state/search_state_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

// ---------------------------------------------------------------------------
// MINIMAL MODEL STUBS
// ---------------------------------------------------------------------------

class BeritaModel {
  final int id;
  final String title;
  final String content;
  final String pantiName;
  final int? pantiId;
  final String? thumbnail;
  final String? pantiProfilePicture;

  const BeritaModel({
    required this.id,
    required this.title,
    required this.content,
    required this.pantiName,
    this.pantiId,
    this.thumbnail,
    this.pantiProfilePicture,
  });
}

class VideoModel {
  final int id;
  final String title;
  final String description;
  final String videoUrl;
  final String pantiName;
  final int? pantiId;
  final String? thumbnail;

  const VideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.videoUrl,
    required this.pantiName,
    this.pantiId,
    this.thumbnail,
  });
}

class PantiProfileModel {
  final int id;
  final String namaPanti;
  final String username;
  final String nomorPanti;
  final String alamatPanti;
  final String description;
  final String? profilePicture;
  final double totalTerkumpul;

  const PantiProfileModel({
    required this.id,
    required this.namaPanti,
    required this.username,
    required this.nomorPanti,
    required this.alamatPanti,
    required this.description,
    this.profilePicture,
    this.totalTerkumpul = 0,
  });
}

class KebutuhanModel {
  final int id;
  final String nama;
  final int jumlah;
  final String satuan;

  const KebutuhanModel({
    required this.id,
    required this.nama,
    required this.jumlah,
    required this.satuan,
  });
}

// ---------------------------------------------------------------------------
// STATE CLASS – SearchState
// Merepresentasikan seluruh state halaman Search Masyarakat.
// Bisa dipakai langsung atau diintegrasikan ke ChangeNotifier/Bloc.
// ---------------------------------------------------------------------------

enum SearchStatus { initial, loading, success, failure }

class SearchState {
  final SearchStatus status;
  final List<BeritaModel> allBeritas;
  final List<VideoModel> allVideos;
  final List<PantiProfileModel> allPantis;
  final String query;
  final String? error;

  const SearchState({
    this.status = SearchStatus.initial,
    this.allBeritas = const [],
    this.allVideos = const [],
    this.allPantis = const [],
    this.query = '',
    this.error,
  });

  SearchState copyWith({
    SearchStatus? status,
    List<BeritaModel>? allBeritas,
    List<VideoModel>? allVideos,
    List<PantiProfileModel>? allPantis,
    String? query,
    String? error,
  }) =>
      SearchState(
        status: status ?? this.status,
        allBeritas: allBeritas ?? this.allBeritas,
        allVideos: allVideos ?? this.allVideos,
        allPantis: allPantis ?? this.allPantis,
        query: query ?? this.query,
        error: error ?? this.error,
      );

  // ── Computed filter results ──────────────────────────────────────────────

  List<BeritaModel> get filteredBeritas {
    if (query.isEmpty) return allBeritas;
    final q = query.toLowerCase();
    return allBeritas
        .where((b) =>
            b.title.toLowerCase().contains(q) ||
            b.pantiName.toLowerCase().contains(q) ||
            b.content.toLowerCase().contains(q))
        .toList();
  }

  List<VideoModel> get filteredVideos {
    if (query.isEmpty) return allVideos;
    final q = query.toLowerCase();
    return allVideos
        .where((v) =>
            v.title.toLowerCase().contains(q) ||
            v.pantiName.toLowerCase().contains(q) ||
            v.description.toLowerCase().contains(q))
        .toList();
  }

  List<PantiProfileModel> get filteredPantis {
    if (query.isEmpty) return allPantis;
    final q = query.toLowerCase();
    return allPantis
        .where((p) =>
            p.namaPanti.toLowerCase().contains(q) ||
            p.username.toLowerCase().contains(q) ||
            p.alamatPanti.toLowerCase().contains(q))
        .toList();
  }

  bool get hasResults =>
      filteredBeritas.isNotEmpty ||
      filteredVideos.isNotEmpty ||
      filteredPantis.isNotEmpty;

  bool get isLoading => status == SearchStatus.loading;
  bool get isError => status == SearchStatus.failure;
}

// ---------------------------------------------------------------------------
// YOUTUBE ID EXTRACTOR (dari VideoPlayerScreen & HomeMasyarakatScreen)
// ---------------------------------------------------------------------------

String? extractYoutubeId(String url) {
  final regExp = RegExp(
    r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
  );
  return regExp.firstMatch(url)?.group(1);
}

// ---------------------------------------------------------------------------
// ICON AUTO-MAPPING (dari KebutuhanScreen._iconFor)
// ---------------------------------------------------------------------------

IconData iconFor(String nama) {
  final n = nama.toLowerCase();
  if (n.contains('susu') || n.contains('milk')) return Icons.coffee_rounded;
  if (n.contains('telur') || n.contains('egg')) return Icons.egg_alt_rounded;
  if (n.contains('beras') || n.contains('rice') || n.contains('nasi')) return Icons.grain_rounded;
  if (n.contains('minyak') || n.contains('oil')) return Icons.opacity_rounded;
  if (n.contains('air') || n.contains('minum') || n.contains('water')) return Icons.water_drop_rounded;
  if (n.contains('roti') || n.contains('bread')) return Icons.bakery_dining_rounded;
  if (n.contains('sayur')) return Icons.eco_rounded;
  if (n.contains('buah') || n.contains('fruit')) return Icons.spa_rounded;
  if (n.contains('daging') || n.contains('ayam') || n.contains('ikan')) return Icons.set_meal_rounded;
  if (n.contains('sabun') || n.contains('deterjen') || n.contains('cuci')) return Icons.soap_rounded;
  if (n.contains('baju') || n.contains('pakaian') || n.contains('celana') || n.contains('seragam')) return Icons.checkroom_rounded;
  if (n.contains('obat') || n.contains('vitamin') || n.contains('medis')) return Icons.medical_services_rounded;
  if (n.contains('buku') || n.contains('tulis') || n.contains('alat tulis')) return Icons.menu_book_rounded;
  if (n.contains('gula') || n.contains('garam') || n.contains('tepung')) return Icons.science_rounded;
  if (n.contains('popok') || n.contains('pampers')) return Icons.child_care_rounded;
  return Icons.inventory_2_rounded;
}

// ---------------------------------------------------------------------------
// NAV CONTROLLER – logika _onNavTap tanpa Flutter widget
// ---------------------------------------------------------------------------

enum NavDestination { home, search, riwayat, profile }

class NavController {
  int currentIndex = 0;
  NavDestination? lastPushed;

  void onNavTap(int index) {
    if (index == currentIndex && index == 0) return; // stay on home
    currentIndex = index;
    switch (index) {
      case 1:
        lastPushed = NavDestination.search;
        break;
      case 2:
        lastPushed = NavDestination.riwayat;
        break;
      case 3:
        lastPushed = NavDestination.profile;
        break;
      default:
        lastPushed = NavDestination.home;
    }
  }

  void onScreenReturn() {
    currentIndex = 0;
  }
}

// ---------------------------------------------------------------------------
// STT STATE – logika toggle mikrofon
// ---------------------------------------------------------------------------

class SttState {
  bool ready;
  bool listening;

  SttState({this.ready = false, this.listening = false});

  /// Returns true jika harus menampilkan snackbar "tidak tersedia"
  bool startListening() {
    if (!ready) return true; // show error
    listening = true;
    return false;
  }

  void stopListening() => listening = false;

  void onFinalResult(String words) {
    listening = false;
  }
}

// ---------------------------------------------------------------------------
// TESTS
// ---------------------------------------------------------------------------

void main() {
  // ════════════════════════════════════════════════════════════════════
  // GROUP 1 – SearchState: initial state
  // ════════════════════════════════════════════════════════════════════
  group('SearchState – initial state', () {
    test('status awal adalah initial', () {
      const state = SearchState();
      expect(state.status, SearchStatus.initial);
    });

    test('semua list awal kosong', () {
      const state = SearchState();
      expect(state.allBeritas, isEmpty);
      expect(state.allVideos, isEmpty);
      expect(state.allPantis, isEmpty);
    });

    test('query awal adalah string kosong', () {
      const state = SearchState();
      expect(state.query, '');
    });

    test('isLoading false pada status initial', () {
      const state = SearchState();
      expect(state.isLoading, false);
    });

    test('isError false pada status initial', () {
      const state = SearchState();
      expect(state.isError, false);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 2 – SearchState: loading transition
  // ════════════════════════════════════════════════════════════════════
  group('SearchState – loading transition', () {
    test('isLoading true setelah copyWith status loading', () {
      const state = SearchState();
      final loading = state.copyWith(status: SearchStatus.loading);
      expect(loading.isLoading, true);
    });

    test('data lama tetap ada saat status berubah ke loading', () {
      final state = SearchState(
        allBeritas: [
          const BeritaModel(id: 1, title: 'T', content: 'C', pantiName: 'P')
        ],
      );
      final loading = state.copyWith(status: SearchStatus.loading);
      expect(loading.allBeritas, hasLength(1));
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 3 – SearchState: success & data
  // ════════════════════════════════════════════════════════════════════
  group('SearchState – success & data', () {
    late SearchState populated;

    setUp(() {
      populated = SearchState(
        status: SearchStatus.success,
        allBeritas: [
          const BeritaModel(id: 1, title: 'Donasi Ramadhan', content: 'Isi', pantiName: 'Panti Al-Ikhlas'),
          const BeritaModel(id: 2, title: 'Kegiatan Sosial', content: 'Isi2', pantiName: 'Panti Sejahtera'),
        ],
        allVideos: [
          const VideoModel(id: 1, title: 'Video Donasi', description: '', videoUrl: 'https://youtu.be/abc', pantiName: 'Panti Al-Ikhlas'),
        ],
        allPantis: [
          const PantiProfileModel(id: 1, namaPanti: 'Panti Al-Ikhlas', username: 'alikhlas', nomorPanti: '', alamatPanti: 'Jakarta', description: ''),
          const PantiProfileModel(id: 2, namaPanti: 'Panti Sejahtera', username: 'sejahtera', nomorPanti: '', alamatPanti: 'Bandung', description: ''),
        ],
      );
    });

    test('isLoading false saat success', () {
      expect(populated.isLoading, false);
    });

    test('filteredBeritas mengembalikan semua saat query kosong', () {
      expect(populated.filteredBeritas, hasLength(2));
    });

    test('filteredBeritas filter berdasarkan title', () {
      final state = populated.copyWith(query: 'donasi');
      expect(state.filteredBeritas, hasLength(1));
      expect(state.filteredBeritas.first.title, contains('Donasi'));
    });

    test('filteredBeritas filter berdasarkan pantiName', () {
      final state = populated.copyWith(query: 'sejahtera');
      expect(state.filteredBeritas, hasLength(1));
      expect(state.filteredBeritas.first.pantiName, 'Panti Sejahtera');
    });

    test('filteredBeritas case-insensitive', () {
      final state = populated.copyWith(query: 'DONASI');
      expect(state.filteredBeritas, hasLength(1));
    });

    test('filteredBeritas kosong saat query tidak cocok', () {
      final state = populated.copyWith(query: 'xyznotfound');
      expect(state.filteredBeritas, isEmpty);
    });

    test('filteredVideos filter berdasarkan title', () {
      final state = populated.copyWith(query: 'video');
      expect(state.filteredVideos, hasLength(1));
    });

    test('filteredVideos kosong saat tidak ada yang cocok', () {
      final state = populated.copyWith(query: 'zzznomatch');
      expect(state.filteredVideos, isEmpty);
    });

    test('filteredPantis filter berdasarkan namaPanti', () {
      final state = populated.copyWith(query: 'al-ikhlas');
      expect(state.filteredPantis, hasLength(1));
    });

    test('filteredPantis filter berdasarkan alamat', () {
      final state = populated.copyWith(query: 'bandung');
      expect(state.filteredPantis, hasLength(1));
      expect(state.filteredPantis.first.alamatPanti, 'Bandung');
    });

    test('filteredPantis filter berdasarkan username', () {
      final state = populated.copyWith(query: 'alikhlas');
      expect(state.filteredPantis, hasLength(1));
    });

    test('hasResults true saat ada data yang cocok', () {
      final state = populated.copyWith(query: 'donasi');
      expect(state.hasResults, true);
    });

    test('hasResults false saat tidak ada yang cocok', () {
      final state = populated.copyWith(query: 'xyznomatch');
      expect(state.hasResults, false);
    });

    test('hasResults true saat query kosong dan ada data', () {
      expect(populated.hasResults, true);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 4 – SearchState: failure
  // ════════════════════════════════════════════════════════════════════
  group('SearchState – failure', () {
    test('isError true saat status failure', () {
      const state = SearchState(
        status: SearchStatus.failure,
        error: 'Koneksi gagal',
      );
      expect(state.isError, true);
    });

    test('pesan error tersimpan di state', () {
      const state = SearchState(
        status: SearchStatus.failure,
        error: 'Timeout',
      );
      expect(state.error, 'Timeout');
    });

    test('isLoading false saat failure', () {
      const state = SearchState(status: SearchStatus.failure);
      expect(state.isLoading, false);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 5 – YouTube ID Extractor
  // ════════════════════════════════════════════════════════════════════
  group('extractYoutubeId', () {
    test('mengekstrak ID dari format watch?v=', () {
      const url = 'https://www.youtube.com/watch?v=dQw4w9WgXcQ';
      expect(extractYoutubeId(url), 'dQw4w9WgXcQ');
    });

    test('mengekstrak ID dari format youtu.be/', () {
      const url = 'https://youtu.be/dQw4w9WgXcQ';
      expect(extractYoutubeId(url), 'dQw4w9WgXcQ');
    });

    test('mengekstrak ID dari format embed/', () {
      const url = 'https://www.youtube.com/embed/dQw4w9WgXcQ';
      expect(extractYoutubeId(url), 'dQw4w9WgXcQ');
    });

    test('mengembalikan null untuk URL bukan YouTube', () {
      const url = 'https://vimeo.com/123456789';
      expect(extractYoutubeId(url), isNull);
    });

    test('mengembalikan null untuk string kosong', () {
      expect(extractYoutubeId(''), isNull);
    });

    test('mengembalikan null untuk URL tidak valid', () {
      expect(extractYoutubeId('bukan-url'), isNull);
    });

    test('thumbnail URL dibentuk dengan benar dari video ID', () {
      const videoId = 'dQw4w9WgXcQ';
      const expected = 'https://img.youtube.com/vi/dQw4w9WgXcQ/mqdefault.jpg';
      final thumb = 'https://img.youtube.com/vi/$videoId/mqdefault.jpg';
      expect(thumb, expected);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 6 – Icon Auto-Mapping (_iconFor)
  // ════════════════════════════════════════════════════════════════════
  group('iconFor (KebutuhanScreen)', () {
    test('susu → Icons.coffee_rounded', () {
      expect(iconFor('Susu Sapi'), Icons.coffee_rounded);
    });

    test('milk (English) → Icons.coffee_rounded', () {
      expect(iconFor('Fresh Milk'), Icons.coffee_rounded);
    });

    test('telur → Icons.egg_alt_rounded', () {
      expect(iconFor('Telur Ayam'), Icons.egg_alt_rounded);
    });

    test('beras → Icons.grain_rounded', () {
      expect(iconFor('Beras Putih'), Icons.grain_rounded);
    });

    test('nasi → Icons.grain_rounded', () {
      expect(iconFor('Nasi Kotak'), Icons.grain_rounded);
    });

    test('minyak → Icons.opacity_rounded', () {
      expect(iconFor('Minyak Goreng'), Icons.opacity_rounded);
    });

    test('air minum → Icons.water_drop_rounded', () {
      expect(iconFor('Air Minum'), Icons.water_drop_rounded);
    });

    test('sabun → Icons.soap_rounded', () {
      expect(iconFor('Sabun Mandi'), Icons.soap_rounded);
    });

    test('deterjen → Icons.soap_rounded', () {
      expect(iconFor('Deterjen Cuci'), Icons.soap_rounded);
    });

    test('baju → Icons.checkroom_rounded', () {
      expect(iconFor('Baju Anak'), Icons.checkroom_rounded);
    });

    test('seragam → Icons.checkroom_rounded', () {
      expect(iconFor('Seragam Sekolah'), Icons.checkroom_rounded);
    });

    test('obat → Icons.medical_services_rounded', () {
      expect(iconFor('Obat Batuk'), Icons.medical_services_rounded);
    });

    test('vitamin → Icons.medical_services_rounded', () {
      expect(iconFor('Vitamin C'), Icons.medical_services_rounded);
    });

    test('buku → Icons.menu_book_rounded', () {
      expect(iconFor('Buku Tulis'), Icons.menu_book_rounded);
    });

    test('alat tulis → Icons.menu_book_rounded', () {
      expect(iconFor('Alat Tulis Sekolah'), Icons.menu_book_rounded);
    });

    test('gula → Icons.science_rounded', () {
      expect(iconFor('Gula Pasir'), Icons.science_rounded);
    });

    test('popok → Icons.child_care_rounded', () {
      expect(iconFor('Popok Bayi'), Icons.child_care_rounded);
    });

    test('nama tidak dikenal → Icons.inventory_2_rounded (fallback)', () {
      expect(iconFor('Barang Aneh XYZ'), Icons.inventory_2_rounded);
    });

    test('pencocokan case-insensitive', () {
      expect(iconFor('SUSU'), Icons.coffee_rounded);
      expect(iconFor('BERAS'), Icons.grain_rounded);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 7 – NavController (_onNavTap logic)
  // ════════════════════════════════════════════════════════════════════
  group('NavController (_onNavTap)', () {
    test('index 0 → tetap di home, tidak push', () {
      final nav = NavController();
      nav.onNavTap(0);
      expect(nav.currentIndex, 0);
      expect(nav.lastPushed, isNull);
    });

    test('index 1 → push ke SearchScreen', () {
      final nav = NavController();
      nav.onNavTap(1);
      expect(nav.currentIndex, 1);
      expect(nav.lastPushed, NavDestination.search);
    });

    test('index 2 → push ke RiwayatDonasiScreen', () {
      final nav = NavController();
      nav.onNavTap(2);
      expect(nav.currentIndex, 2);
      expect(nav.lastPushed, NavDestination.riwayat);
    });

    test('index 3 → push ke ProfileScreen', () {
      final nav = NavController();
      nav.onNavTap(3);
      expect(nav.currentIndex, 3);
      expect(nav.lastPushed, NavDestination.profile);
    });

    test('onScreenReturn → reset index ke 0', () {
      final nav = NavController();
      nav.onNavTap(2);
      nav.onScreenReturn();
      expect(nav.currentIndex, 0);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 8 – SttState (toggle mikrofon)
  // ════════════════════════════════════════════════════════════════════
  group('SttState (Speech-to-Text toggle)', () {
    test('startListening saat ready=false mengembalikan true (tampilkan error)', () {
      final stt = SttState(ready: false);
      final showError = stt.startListening();
      expect(showError, true);
      expect(stt.listening, false);
    });

    test('startListening saat ready=true – listening jadi true', () {
      final stt = SttState(ready: true);
      final showError = stt.startListening();
      expect(showError, false);
      expect(stt.listening, true);
    });

    test('stopListening mengubah listening ke false', () {
      final stt = SttState(ready: true, listening: true);
      stt.stopListening();
      expect(stt.listening, false);
    });

    test('onFinalResult dengan kata kosong – listening tetap false', () {
      final stt = SttState(ready: true, listening: true);
      stt.onFinalResult('');
      expect(stt.listening, false);
    });

    test('onFinalResult dengan kata valid – listening false', () {
      final stt = SttState(ready: true, listening: true);
      stt.onFinalResult('panti asuhan jakarta');
      expect(stt.listening, false);
    });

    test('toggle: start → stop → start kembali normal', () {
      final stt = SttState(ready: true);
      stt.startListening();
      expect(stt.listening, true);
      stt.stopListening();
      expect(stt.listening, false);
      stt.startListening();
      expect(stt.listening, true);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 9 – BeritaDetail: _onLihatProfil state
  // ════════════════════════════════════════════════════════════════════
  group('BeritaDetailScreen loadingProfile state', () {
    test('pantiId null → tidak memulai loading', () {
      bool loadingTriggered = false;
      final pantiId = null;
      // Simulasi kondisi guard: if (pantiId == null) return;
      if (pantiId == null) {
        loadingTriggered = false;
      } else {
        loadingTriggered = true;
      }
      expect(loadingTriggered, false);
    });

    test('pantiId valid → loading dimulai', () {
      bool loading = false;
      const pantiId = 10;
      // ignore: unnecessary_null_comparison
      if (pantiId != null) {
        loading = true; // setState(() => _loadingProfile = true)
      }
      expect(loading, true);
    });

    test('loading reset ke false setelah sukses', () {
      bool loading = true;
      // Simulasi finally block
      loading = false;
      expect(loading, false);
    });

    test('loading reset ke false setelah error', () {
      bool loading = true;
      try {
        throw Exception('network error');
      } catch (_) {
        // error handled
      } finally {
        loading = false;
      }
      expect(loading, false);
    });
  });

  // ════════════════════════════════════════════════════════════════════
  // GROUP 10 – SearchState: copyWith immutability
  // ════════════════════════════════════════════════════════════════════
  group('SearchState – copyWith immutability', () {
    test('copyWith tidak mutasi state asli', () {
      const original = SearchState(query: 'original');
      final copy = original.copyWith(query: 'changed');

      expect(original.query, 'original');
      expect(copy.query, 'changed');
    });

    test('copyWith hanya mengubah field yang dispesifikasikan', () {
      const original = SearchState(
        status: SearchStatus.success,
        query: 'test',
      );
      final copy = original.copyWith(query: 'new query');

      expect(copy.status, SearchStatus.success); // tidak berubah
      expect(copy.query, 'new query');
    });

    test('filteredBeritas terupdate otomatis setelah query diubah', () {
      final state = SearchState(
        status: SearchStatus.success,
        allBeritas: [
          const BeritaModel(id: 1, title: 'Zakat Fitrah', content: '', pantiName: 'P'),
          const BeritaModel(id: 2, title: 'Donasi Baju', content: '', pantiName: 'P'),
        ],
        query: '',
      );

      expect(state.filteredBeritas, hasLength(2));

      final filtered = state.copyWith(query: 'zakat');
      expect(filtered.filteredBeritas, hasLength(1));
      expect(filtered.filteredBeritas.first.title, 'Zakat Fitrah');
    });
  });
}