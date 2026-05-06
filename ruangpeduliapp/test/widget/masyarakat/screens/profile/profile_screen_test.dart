import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';
import 'package:ruangpeduliapp/masyarakat/profile/profile_screen.dart';

import 'profile_screen_test.mocks.dart';

@GenerateMocks([ProfileApi, DonationApi])
void main() {
  late MockProfileApi mockProfileApi;
  late MockDonationApi mockDonationApi;

  // ── Dummy data ──
  final dummyProfile = SocietyProfileModel(
    id: 1,
    namaPengguna: 'Budi Santoso',
    username: 'budi_s',
    email: 'budi@email.com',
    nomorTelepon: '081234567890',
    jenisKelamin: 'Laki-laki',
    alamat: 'Jl. Merdeka No. 1',
    profilePicture: null,
  );

  final dummyPantiList = [
    PantiProfileModel(
      id: 1,
      namaPanti: 'Panti Asuhan Kasih Ibu',
      alamatPanti: 'Jl. Melati No. 10, Jakarta',
      nomorPanti: '081111111111',
      username: 'kasih_ibu',
      email: 'kasih_ibu@panti.com',
      lat: -6.2,
      lng: 106.8,
      profilePicture: null,
      description: 'Panti anak yatim',
      totalTerkumpul: 500000,
    ),
  ];

  final dummyDonations = [
    DonasiModel(id: 1, namaPanti: 'Panti Kasih', jumlah: 50000, metodePembayaran: 'Transfer', noReferensi: 'REF001', tanggal: '2024-01-01T10:00:00Z', tanggalLabel: '1 Januari 2024'),
    DonasiModel(id: 2, namaPanti: 'Panti Kasih', jumlah: 150000, metodePembayaran: 'Transfer', noReferensi: 'REF002', tanggal: '2024-01-02T11:00:00Z', tanggalLabel: '2 Januari 2024'),
  ];

  setUp(() {
    mockProfileApi = MockProfileApi();
    mockDonationApi = MockDonationApi();

    // Default stub behavior for tests that do not specify custom responses.
    when(mockProfileApi.fetchMasyarakatProfile(any))
        .thenAnswer((_) async => dummyProfile);
    when(mockProfileApi.fetchAllPanti())
        .thenAnswer((_) async => dummyPantiList);
    when(mockDonationApi.fetchDonations(any))
        .thenAnswer((_) async => []);
  });

  Widget buildWidget({
    int? userId = 1,
    ProfileApi? profileApi,
    DonationApi? donationApi,
    WidgetBuilder? homeScreenBuilder,
    WidgetBuilder? searchScreenBuilder,
    WidgetBuilder? historyScreenBuilder,
  }) {
    return MaterialApp(
      home: ProfileScreen(
        userId: userId,
        profileApi: profileApi ?? mockProfileApi,
        donationApi: donationApi ?? mockDonationApi,
        homeScreenBuilder: homeScreenBuilder,
        searchScreenBuilder: searchScreenBuilder,
        historyScreenBuilder: historyScreenBuilder,
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // 1. Container (Avatar) — Menampilkan foto profil user
  //    Metode: ProfileScreen._loadUserProfile()
  // ─────────────────────────────────────────────────────────────
  group('Container Avatar — menampilkan foto profil user', () {
    testWidgets('Menampilkan ikon person saat tidak ada foto profil',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget(
        profileApi: mockProfileApi,
        donationApi: mockDonationApi,
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.person_rounded), findsWidgets);
    });

    testWidgets('Avatar Container berbentuk lingkaran (BoxShape.circle)',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      final containers = tester.widgetList<Container>(find.byType(Container));
      final avatarContainer = containers.firstWhere(
        (c) =>
            c.decoration is BoxDecoration &&
            (c.decoration as BoxDecoration).shape == BoxShape.circle,
        orElse: () => throw TestFailure('Avatar container not found'),
      );
      expect(avatarContainer, isNotNull);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 2. GestureDetector (Logout) — Tombol keluar akun
  //    Metode: ProfileScreen._confirmLogout()
  // ─────────────────────────────────────────────────────────────
  group('GestureDetector Logout — tombol keluar akun', () {
    testWidgets('Ikon logout tersedia di halaman profil',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.logout_rounded), findsOneWidget);
    });

    testWidgets('Tap ikon logout membuka AlertDialog konfirmasi',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 3. GestureDetector ("Edit Profil") — Navigasi ke Edit Profil
  //    Metode: ProfileScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('GestureDetector Edit Profil — navigasi ke Edit Profil', () {
    testWidgets('Tombol "Edit Profil" tersedia di halaman profil',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Edit Profil'), findsOneWidget);
    });

    testWidgets('Tap "Edit Profil" melakukan navigasi ke EditProfilScreen',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Edit Profil'));
      await tester.pumpAndSettle();

      // Setelah navigasi, ProfileScreen tidak lagi menjadi halaman aktif
      expect(find.byType(ProfileScreen), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 4. Text (Nama & Username) — Menampilkan nama dan username user
  //    Metode: ProfileScreen._loadUserProfile()
  // ─────────────────────────────────────────────────────────────
  group('Text Nama & Username — menampilkan nama dan username user', () {
    testWidgets('Menampilkan nama pengguna setelah data dimuat',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
    });

    testWidgets('Menampilkan username dengan prefix @ setelah data dimuat',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('@budi_s'), findsOneWidget);
    });

    testWidgets('Menampilkan teks fallback "Pengguna" saat profil belum dimuat',
        (WidgetTester tester) async {
      final profileCompleter = Completer<SocietyProfileModel>();
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) => profileCompleter.future);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.text('Pengguna'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 5. Text (Total Donasi) — Menampilkan total donasi yang sudah diberikan
  //    Metode: ProfileScreen._loadTotalDonasi(), ProfileScreen._formattedTotalDonasi
  // ─────────────────────────────────────────────────────────────
  group('Text Total Donasi — menampilkan total donasi', () {
    testWidgets('Menampilkan label "Total Donasi"', (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Total Donasi'), findsOneWidget);
    });

    testWidgets('Menampilkan "Rp0" saat tidak ada donasi',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Rp0'), findsOneWidget);
    });

    testWidgets('Menampilkan total donasi yang diformat dengan benar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => dummyDonations); // 50000 + 150000 = 200000

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Rp200.000'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 6. AlertDialog (Konfirmasi Logout) — Dialog konfirmasi sebelum keluar
  //    Metode: ProfileScreen._confirmLogout()
  // ─────────────────────────────────────────────────────────────
  group('AlertDialog Konfirmasi Logout — dialog konfirmasi keluar', () {
    testWidgets('Dialog menampilkan teks "Apakah Anda yakin ingin keluar?"',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Apakah Anda yakin ingin keluar?'), findsOneWidget);
    });

    testWidgets('Dialog memiliki tombol "Batal" dan "Keluar"',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Batal'), findsOneWidget);
      expect(find.text('Keluar'), findsWidgets);
    });

    testWidgets('Tap "Batal" menutup dialog tanpa logout',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      // Dialog hilang, ProfileScreen masih tampil
      expect(find.byType(AlertDialog), findsNothing);
      expect(find.byType(ProfileScreen), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 7. _PantiDonasCard — Kartu panti sosial dengan tombol donasi
  //    Metode: ProfileScreen._loadPanti(), ProfileScreen._loadTotalDonasi()
  // ─────────────────────────────────────────────────────────────
  group('_PantiDonasCard — kartu panti dengan tombol donasi', () {
    testWidgets('Menampilkan label "Pilih Panti Untuk Donasi Lagi"',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Pilih Panti Untuk Donasi Lagi'), findsOneWidget);
    });

    testWidgets('Menampilkan nama panti pada kartu', (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Panti Asuhan Kasih Ibu'), findsOneWidget);
    });

    testWidgets('Tombol "Donasi" tersedia pada setiap kartu panti',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Donasi'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 8. CircularProgressIndicator — Loading saat memuat data panti
  //    Metode: ProfileScreen._loadPanti()
  // ─────────────────────────────────────────────────────────────
  group('CircularProgressIndicator — loading saat memuat data panti', () {
    testWidgets('Menampilkan loading indicator saat data panti sedang dimuat',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      final pantiCompleter = Completer<List<PantiProfileModel>>();
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) => pantiCompleter.future);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Loading indicator hilang setelah data panti selesai dimuat',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => dummyPantiList);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 9. _NavItem (Home) — Navigasi ke Home
  //    Metode: ProfileScreen._onNavTap(), ProfileScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('_NavItem Home — navigasi ke Home', () {
    testWidgets('Ikon Home tersedia di bottom navigation bar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
    });

    testWidgets('Tap ikon Home melakukan pushReplacement ke HomeMasyarakatScreen',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget(
        homeScreenBuilder: (_) => const Scaffold(
          body: Center(child: Text('Home Placeholder')),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Home Placeholder'), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 10. _NavItem (Search) — Navigasi ke Search
  //     Metode: ProfileScreen._onNavTap(), ProfileScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('_NavItem Search — navigasi ke Search', () {
    testWidgets('Ikon Search tersedia di bottom navigation bar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
    });

    testWidgets('Tap ikon Search melakukan pushReplacement ke SearchScreen',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget(
        searchScreenBuilder: (_) => const Scaffold(
          body: Center(child: Text('Search Placeholder')),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Search Placeholder'), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 11. _NavItem (History) — Navigasi ke Riwayat Donasi
  //     Metode: ProfileScreen._onNavTap(), ProfileScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('_NavItem History — navigasi ke Riwayat Donasi', () {
    testWidgets('Ikon History tersedia di bottom navigation bar',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
    });

    testWidgets('Tap ikon History melakukan pushReplacement ke RiwayatDonasiScreen',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget(
        historyScreenBuilder: (_) => const Scaffold(
          body: Center(child: Text('History Placeholder')),
        ),
      ));
      await tester.pump();

      await tester.tap(find.byIcon(Icons.history_rounded));
      await tester.pumpAndSettle();

      expect(find.text('History Placeholder'), findsOneWidget);
      expect(find.byType(ProfileScreen), findsNothing);
    });
  });

  // ─────────────────────────────────────────────────────────────
  // 12. _NavItem (Profile) — Indikator halaman aktif
  //     Metode: ProfileScreen._onNavTap(), ProfileScreen.build()
  // ─────────────────────────────────────────────────────────────
  group('_NavItem Profile — indikator halaman aktif', () {
    testWidgets('Ikon Profile tersedia dan aktif (selectedIndex == 3)',
        (WidgetTester tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(any))
          .thenAnswer((_) async => dummyProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => []);
      when(mockDonationApi.fetchDonations(any))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pump();

      expect(
        find.byWidgetPredicate(
          (widget) => widget is Icon && widget.icon == Icons.person_rounded && widget.size == 28,
        ),
        findsOneWidget,
      );
    });
  });
}