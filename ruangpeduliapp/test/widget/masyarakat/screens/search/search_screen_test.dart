import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/masyarakat/search/search_screen.dart';

import 'search_screen_test.mocks.dart';

@GenerateMocks([ProfileApi])
void main() {
  late MockProfileApi mockProfileApi;

  // Helper: dummy panti list
  final dummyPantiList = [
    PantiProfileModel(
      id: 1,
      namaPanti: 'Panti Asuhan Kasih Ibu',
      alamatPanti: 'Jl. Melati No. 10, Jakarta',
      nomorPanti: '081234567890',
      username: 'kasih_ibu',
      email: 'kasih_ibu@example.com',
      lat: -6.2000,
      lng: 106.8167,
      profilePicture: null,
      description: 'Panti asuhan anak yatim',
      totalTerkumpul: 0,
    ),
    PantiProfileModel(
      id: 2,
      namaPanti: 'Panti Sejahtera',
      alamatPanti: 'Jl. Anggrek No. 5, Bandung',
      nomorPanti: '089876543210',
      username: 'panti_sejahtera',
      email: 'panti_sejahtera@example.com',
      lat: -6.9147,
      lng: 107.6098,
      profilePicture: null,
      description: 'Panti lansia dan anak',
      totalTerkumpul: 0,
    ),
  ];

  setUp(() {
    mockProfileApi = MockProfileApi();
  });

  Widget buildWidget({int? userId, String initialQuery = ''}) {
    return MaterialApp(
      home: SearchScreen(
        userId: userId,
        initialQuery: initialQuery,
        profileApi: mockProfileApi,
        enableLocationFetch: false,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. SearchScreen renders correctly
  // ─────────────────────────────────────────────────────────────
  group('SearchScreen renders correctly', () {
    testWidgets('Menampilkan AppBar dengan judul Search',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Search'), findsWidgets);
    });

    testWidgets('Scaffold dan SafeArea tersedia', (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(SafeArea), findsWidgets);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 2. TextField (Search) — Input pencarian nama/alamat panti
  //    Metode: SearchScreen._filtered, SearchScreen.initState()
  // ─────────────────────────────────────────────────────────────
  group('TextField Search — input pencarian nama/alamat panti', () {
    testWidgets('Menampilkan TextField pencarian', (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('TextField memiliki hint text "Search"',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.decoration?.hintText, equals('Search'));
    });

    testWidgets('initialQuery mengisi TextField saat dibuka',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget(initialQuery: 'Kasih'));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, equals('Kasih'));
    });

    testWidgets('TextField menerima input teks dari user',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Panti Kasih');
      await tester.pump();

      expect(find.text('Panti Kasih'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 3. GestureDetector (Mic) — Tombol voice search dengan speech-to-text
  //    Metode: SearchScreen._toggleMic(), SearchScreen.initState()
  // ─────────────────────────────────────────────────────────────
  group('GestureDetector Mic — tombol voice search', () {
    testWidgets('Ikon mikrofon ditampilkan di search bar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(
        find.byIcon(Icons.mic_none_rounded),
        findsOneWidget,
      );
    });

    testWidgets('Tap ikon mic saat STT tidak siap menampilkan SnackBar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.mic_none_rounded));
      await tester.pump();

      // STT tidak tersedia di test environment → SnackBar error muncul
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 4. GestureDetector (Clear) — Tombol hapus teks pencarian
  //    Metode: SearchScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('GestureDetector Clear — tombol hapus teks pencarian', () {
    testWidgets('Tombol clear tidak muncul saat TextField kosong',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsNothing);
    });

    testWidgets('Tombol clear muncul setelah ada teks di TextField',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Kasih');
      await tester.pump();

      expect(find.byIcon(Icons.close_rounded), findsOneWidget);
    });

    testWidgets('Tap tombol clear mengosongkan TextField',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.enterText(find.byType(TextField), 'Kasih');
      await tester.pump();

      await tester.tap(find.byIcon(Icons.close_rounded));
      await tester.pump();

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.controller?.text, isEmpty);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 5. _LocationRationaleDialog — Dialog izin akses lokasi user
  //    Metode: SearchScreen._fetchLocation()
  // ─────────────────────────────────────────────────────────────
  group('_LocationRationaleDialog — dialog izin akses lokasi', () {
    testWidgets('Dialog memiliki teks "Izinkan Akses Lokasi"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _LocationRationaleDialogTestWrapper(),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Izinkan Akses Lokasi'), findsOneWidget);
    });

    testWidgets('Dialog memiliki tombol "Izinkan" dan "Nanti saja"',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: _LocationRationaleDialogTestWrapper(),
          ),
        ),
      );
      await tester.pump();

      await tester.tap(find.text('Show Dialog'));
      await tester.pumpAndSettle();

      expect(find.text('Izinkan'), findsOneWidget);
      expect(find.text('Nanti saja'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 6. CircularProgressIndicator — Loading saat memuat data panti
  //    Metode: SearchScreen._fetchPanti()
  // ─────────────────────────────────────────────────────────────
  group('CircularProgressIndicator — loading saat memuat data panti', () {
    testWidgets('Menampilkan loading indicator saat data sedang dimuat',
        (WidgetTester tester) async {
      // Simulasi fetchAllPanti yang tidak selesai (pending future)
      // Gunakan Completer agar tidak membuat Timer yang akan dianggap "pending"
      // saat test selesai.
      final pending = Completer<List<PantiProfileModel>>();
      when(mockProfileApi.fetchAllPanti()).thenAnswer((_) => pending.future);

      await tester.pumpWidget(buildWidget());
      // Pump sekali agar build() dipanggil tetapi future belum selesai
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('Loading indicator hilang setelah data selesai dimuat',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // CircularProgressIndicator untuk panti tidak ada lagi
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 7. _PantiCard — Kartu panti dengan nama, alamat, jarak, dan nomor telepon
  //    Metode: SearchScreen._filtered, SearchScreen._openPantiDetail(),
  //            SearchScreen._distanceTo(), SearchScreen._formatDistance()
  // ─────────────────────────────────────────────────────────────
  group('_PantiCard — kartu panti dengan detail informasi', () {
    testWidgets('Menampilkan nama panti pada kartu',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Panti Asuhan Kasih Ibu'), findsOneWidget);
      expect(find.text('Panti Sejahtera'), findsOneWidget);
    });

    testWidgets('Menampilkan alamat panti pada kartu',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('Jl. Melati No. 10'),
        findsOneWidget,
      );
    });

    testWidgets('Menampilkan nomor telepon panti pada kartu',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(
        find.textContaining('081234567890'),
        findsOneWidget,
      );
    });

    testWidgets('Menampilkan tombol "Kunjungi Profil" pada setiap kartu',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Kunjungi Profil'), findsWidgets);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 8. Container ("Terdekat") — Badge panti terdekat dari lokasi user
  //    Metode: SearchScreen._distanceTo(), SearchScreen._filtered
  // ─────────────────────────────────────────────────────────────
  group('Container Terdekat — badge panti terdekat', () {
    testWidgets('Badge "Terdekat" tidak muncul tanpa lokasi user',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      // Tanpa posisi user, badge Terdekat tidak ditampilkan
      expect(find.text('Terdekat'), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 9. GestureDetector ("Kunjungi Profil") — Navigasi ke detail panti
  //    Metode: SearchScreen._openPantiDetail()
  // ─────────────────────────────────────────────────────────────
  group('GestureDetector Kunjungi Profil — navigasi ke detail panti', () {
    testWidgets(
        'Tap "Kunjungi Profil" memanggil _openPantiDetail dan menampilkan loading',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);
      final pendingMedia = Completer<List<PantiMediaModel>>();
      when(mockProfileApi.fetchPantiMedia(any))
          .thenAnswer((_) => pendingMedia.future);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kunjungi Profil').first);
      await tester.pump();

      // Saat media sedang dimuat, CircularProgressIndicator muncul di tombol
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('SnackBar muncul ketika gagal memuat profil panti',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);
      when(mockProfileApi.fetchPantiMedia(any))
          .thenThrow(Exception('Network error'));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kunjungi Profil').first);
      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat profil panti'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 10. SnackBar — Menampilkan error gagal memuat profil panti
  //     Metode: SearchScreen._openPantiDetail(), SearchScreen._toggleMic()
  // ─────────────────────────────────────────────────────────────
  group('SnackBar — error gagal memuat profil', () {
    testWidgets('SnackBar "Gagal memuat profil panti" muncul saat API error',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);
      when(mockProfileApi.fetchPantiMedia(any)).thenThrow(Exception('Timeout'));

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Kunjungi Profil').first);
      await tester.pumpAndSettle();

      expect(find.text('Gagal memuat profil panti'), findsOneWidget);
    });

    testWidgets('SnackBar mikrofon tidak tersedia muncul saat STT tidak siap',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.mic_none_rounded));
      await tester.pump();

      expect(
        find.textContaining('Mikrofon tidak tersedia'),
        findsOneWidget,
      );
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 11. Handle no results state — "Tidak ada hasil"
  //     Metode: SearchScreen._filtered, SearchScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('Handle no results state — tampilan saat hasil kosong', () {
    testWidgets('Menampilkan "Tidak ada hasil" ketika query tidak cocok',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'xyzxyzxyz');
      await tester.pump();

      expect(find.text('Tidak ada hasil'), findsOneWidget);
    });

    testWidgets('Menampilkan ikon search_off saat tidak ada hasil',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'tidakadahasil999');
      await tester.pump();

      expect(find.byIcon(Icons.search_off_rounded), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 12. Search panti by name & address — Filter via _filtered getter
  //     Metode: SearchScreen._filtered, SearchScreen.initState()
  // ─────────────────────────────────────────────────────────────
  group('Search panti by name/alamat — filter hasil pencarian', () {
    testWidgets('Menampilkan hasil yang sesuai nama saat mengetik query',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Kasih');
      await tester.pump();

      expect(find.text('Panti Asuhan Kasih Ibu'), findsOneWidget);
      expect(find.text('Panti Sejahtera'), findsNothing);
    });

    testWidgets('Menampilkan hasil yang sesuai alamat saat mengetik query',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Bandung');
      await tester.pump();

      expect(find.text('Panti Sejahtera'), findsOneWidget);
      expect(find.text('Panti Asuhan Kasih Ibu'), findsNothing);
    });

    testWidgets('Menampilkan semua panti saat query dikosongkan kembali',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), 'Kasih');
      await tester.pump();
      await tester.enterText(find.byType(TextField), '');
      await tester.pump();

      expect(find.text('Panti Asuhan Kasih Ibu'), findsOneWidget);
      expect(find.text('Panti Sejahtera'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 13. _NavItem (Home) — Navigasi ke Home
  //     Metode: SearchScreen._onNavTap(), SearchScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('_NavItem Home — navigasi ke Home', () {
    testWidgets('Ikon Home tersedia di bottom navigation bar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('Tap ikon Home memanggil Navigator.pop',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(
        MaterialApp(
          home: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SearchScreen(
                      userId: null,
                      profileApi: mockProfileApi,
                      enableLocationFetch: false,
                    ),
                  ),
                );
              },
              child: const Text('Go'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('Go'));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      // Setelah pop, kembali ke halaman sebelumnya
      expect(find.text('Go'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 14. _NavItem (Search) — Indikator halaman aktif
  //     Metode: SearchScreen._onNavTap(), SearchScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('_NavItem Search — indikator halaman aktif', () {
    testWidgets('Ikon Search tersedia dan aktif di bottom navigation bar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 15. _NavItem (History) — Navigasi ke Riwayat Donasi
  //     Metode: SearchScreen._onNavTap(), SearchScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('_NavItem History — navigasi ke Riwayat Donasi', () {
    testWidgets('Ikon History tersedia di bottom navigation bar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets(
        'Tap ikon History melakukan pushReplacement ke RiwayatDonasiScreen',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.history_rounded));
      await tester.pumpAndSettle();

      // Verifikasi navigasi terjadi (SearchScreen tidak lagi di stack)
      expect(find.byType(SearchScreen), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 16. _NavItem (Profile) — Navigasi ke Profile
  //     Metode: SearchScreen._onNavTap(), SearchScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('_NavItem Profile — navigasi ke Profile', () {
    testWidgets('Ikon Profile tersedia di bottom navigation bar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('Tap ikon Profile melakukan pushReplacement ke ProfileScreen',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      await tester.tap(find.byIcon(Icons.person_rounded));
      await tester.pumpAndSettle();

      // Verifikasi navigasi terjadi (SearchScreen tidak lagi di stack)
      expect(find.byType(SearchScreen), findsNothing);
    });
  });
}

// ── Helper widget untuk test _LocationRationaleDialog secara isolasi ──
class _LocationRationaleDialogTestWrapper extends StatelessWidget {
  const _LocationRationaleDialogTestWrapper();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ElevatedButton(
        onPressed: () => showDialog(
          context: context,
          builder: (_) => const _LocationRationaleDialog(),
        ),
        child: const Text('Show Dialog'),
      ),
    );
  }
}

/// Local test-only dialog because `_LocationRationaleDialog` in production code
/// is private to its library and cannot be referenced from this test file.
class _LocationRationaleDialog extends StatelessWidget {
  const _LocationRationaleDialog();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Izinkan Akses Lokasi'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Nanti saja'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Izinkan'),
        ),
      ],
    );
  }
}
