import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:ruangpeduliapp/data/profile_api.dart';
import 'package:ruangpeduliapp/data/donation_api.dart';
import 'package:ruangpeduliapp/data/data.dart';
import 'package:ruangpeduliapp/data/models/donation_model.dart';
import 'package:ruangpeduliapp/masyarakat/profile/profile_screen.dart';

import '../../../../widget/masyarakat/screens/transaksi/konfirmasi_metode_screen_test.mocks.dart';
import 'profile_state_test.mocks.dart';

@GenerateMocks([ProfileApi, DonationApi])
void main() {
  late MockProfileApi mockProfileApi;
  late MockDonationApi mockDonationApi;

  final tProfile = SocietyProfileModel(
    id: 1,
    namaPengguna: 'Budi Santoso',
    username: 'budi123',
    email: 'budi@email.com',
    nomorTelepon: '08123456789',
    jenisKelamin: 'Laki-laki',
    alamat: 'Jakarta',
    profilePicture: null,
  );

  final tPantiList = [
    PantiProfileModel(
      id: 1,
      namaPanti: 'Panti Asuhan Harapan',
      totalTerkumpul: 1500000,
      profilePicture: null,
    ),
    PantiProfileModel(
      id: 2,
      namaPanti: 'Panti Kasih Ibu',
      totalTerkumpul: 3200000,
      profilePicture: null,
    ),
  ];

  final tDonations = [
    DonationModel(id: 1, userId: 1, pantiId: 1, jumlah: 50000),
    DonationModel(id: 2, userId: 1, pantiId: 2, jumlah: 100000),
  ];

  setUp(() {
    mockProfileApi = MockProfileApi();
    mockDonationApi = MockDonationApi();
  });

  Widget buildWidget({int? userId}) {
    return MaterialApp(
      home: ProfileScreen(
        userId: userId ?? 1,
        profileApi: mockProfileApi,
        donationApi: mockDonationApi,
        homeScreenBuilder: (_) => const Scaffold(body: Text('Home')),
        searchScreenBuilder: (_) => const Scaffold(body: Text('Search')),
        historyScreenBuilder: (_) => const Scaffold(body: Text('History')),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // GROUP: Inisialisasi State
  // ─────────────────────────────────────────────
  group('ProfileScreen - Inisialisasi State', () {
    testWidgets('menampilkan loading indicator saat data pertama dimuat',
        (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return tPantiList;
      });
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('menampilkan judul "Profil" pada app bar', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Profil'), findsOneWidget);
    });

    testWidgets('memanggil fetchMasyarakatProfile saat initState',
        (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      verify(mockProfileApi.fetchMasyarakatProfile(1)).called(1);
    });

    testWidgets('memanggil fetchAllPanti saat initState', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      verify(mockProfileApi.fetchAllPanti()).called(1);
    });

    testWidgets('memanggil fetchDonations saat initState', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      verify(mockDonationApi.fetchDonations(1)).called(1);
    });
  });

  // ─────────────────────────────────────────────
  // GROUP: Tampilan Profil User
  // ─────────────────────────────────────────────
  group('ProfileScreen - Tampilan Data Profil', () {
    testWidgets('menampilkan nama pengguna setelah data dimuat', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Budi Santoso'), findsOneWidget);
    });

    testWidgets('menampilkan username dengan prefix @', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('@budi123'), findsOneWidget);
    });

    testWidgets('menampilkan teks fallback "Pengguna" ketika profil null',
        (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => null);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Pengguna'), findsOneWidget);
    });

    testWidgets('menampilkan total donasi yang sudah diformat',
        (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations); // 50000 + 100000 = 150000

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Rp150.000'), findsOneWidget);
    });

    testWidgets('menampilkan Rp0 ketika belum ada donasi', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => []);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Rp0'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────
  // GROUP: Daftar Panti
  // ─────────────────────────────────────────────
  group('ProfileScreen - Tampilan Daftar Panti', () {
    testWidgets('menampilkan semua nama panti setelah dimuat', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Panti Asuhan Harapan'), findsOneWidget);
      expect(find.text('Panti Kasih Ibu'), findsOneWidget);
    });

    testWidgets('menampilkan tombol "Donasi" untuk setiap panti',
        (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Donasi'), findsNWidgets(tPantiList.length));
    });

    testWidgets('tidak ada panti card ketika fetchAllPanti gagal',
        (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti()).thenThrow(Exception('Error'));
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.text('Donasi'), findsNothing);
    });
  });

  // ─────────────────────────────────────────────
  // GROUP: Navigasi Bottom Bar
  // ─────────────────────────────────────────────
  group('ProfileScreen - Navigasi Bottom Bar', () {
    testWidgets('bottom bar menampilkan 4 item navigasi', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.home_rounded), findsOneWidget);
      expect(find.byIcon(Icons.search_rounded), findsOneWidget);
      expect(find.byIcon(Icons.history_rounded), findsOneWidget);
      expect(find.byIcon(Icons.person_rounded), findsOneWidget);
    });

    testWidgets('tap icon Home menavigasi ke HomeScreen', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.home_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('tap icon Search menavigasi ke SearchScreen', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.search_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Search'), findsOneWidget);
    });

    testWidgets('tap icon History menavigasi ke HistoryScreen', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.history_rounded));
      await tester.pumpAndSettle();

      expect(find.text('History'), findsOneWidget);
    });
  });

  // ─────────────────────────────────────────────
  // GROUP: Dialog Logout
  // ─────────────────────────────────────────────
  group('ProfileScreen - Dialog Logout', () {
    testWidgets('tap tombol logout menampilkan dialog konfirmasi',
        (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      expect(find.text('Keluar'), findsWidgets);
      expect(find.text('Apakah Anda yakin ingin keluar?'), findsOneWidget);
    });

    testWidgets('tap "Batal" pada dialog menutup dialog', (tester) async {
      when(mockProfileApi.fetchMasyarakatProfile(1))
          .thenAnswer((_) async => tProfile);
      when(mockProfileApi.fetchAllPanti())
          .thenAnswer((_) async => tPantiList);
      when(mockDonationApi.fetchDonations(1))
          .thenAnswer((_) async => tDonations);

      await tester.pumpWidget(buildWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.logout_rounded));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Batal'));
      await tester.pumpAndSettle();

      expect(find.text('Apakah Anda yakin ingin keluar?'), findsNothing);
    });
  });
}