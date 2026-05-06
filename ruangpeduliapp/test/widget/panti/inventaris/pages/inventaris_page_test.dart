  import 'package:flutter/material.dart';
  import 'package:flutter_test/flutter_test.dart';
  import 'package:provider/provider.dart';
  import 'package:ruangpeduliapp/panti/inventory/inventory_panti.dart';
  import 'package:ruangpeduliapp/panti/inventaris/state/inventory_state.dart';
  import 'package:ruangpeduliapp/panti/inventaris/state/residents_state.dart';
  import 'package:ruangpeduliapp/panti/inventaris/models/item_model.dart';
  import 'package:ruangpeduliapp/panti/inventaris/models/anggota_model.dart';

  /// Mock API untuk kebutuhan render UI tanpa koneksi internet asli
  class MockInventoryApi {
    Future<Map<String, dynamic>> fetchDashboard() async => {
          'stokMasuk': 10,
          'stokKeluar': 5,
          'notif': 2,
        };
    Future<List<ItemModel>> getItems() async => [];
    Future<List<ItemModel>> getLowStockItems() async => [];
    Future<bool> addItem(ItemModel item) async => true;
    Future<bool> deleteItem(int id) async => true;
    Future<bool> updateItem(ItemModel item) async => true;
  }

  class MockResidentsApi {
    Future<List<AnggotaModel>> getPegawai() async => [];
    Future<List<AnggotaModel>> getResidents() async => [];
    Future<bool> addPegawai(AnggotaModel anggota) async => true;
    Future<bool> deletePegawai(int id) async => true;
  }

  void main() {
    testWidgets('InventarisPage render test', (WidgetTester tester) async {
      // Siapkan state dengan Mock API
      final inventoryState = InventoryState(api: MockInventoryApi());
      final residentsState = ResidentsState(api: MockResidentsApi());

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<InventoryState>.value(value: inventoryState),
            ChangeNotifierProvider<ResidentsState>.value(value: residentsState),
          ],
          child: const MaterialApp(
            home: InventoryPantiPage(),
          ),
        ),
      );

      // Melakukan pump awal untuk inisialisasi state
      await tester.pump();
      // Tunggu proses asinkron (loadDashboard, loadItems, dll) selesai
      await tester.pumpAndSettle();

      expect(find.byType(InventoryPantiPage), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);

      // kondisi kemungkinan: loading / dashboard / empty
      expect(
        find.byType(GridView).evaluate().isNotEmpty || 
        find.byType(CircularProgressIndicator).evaluate().isNotEmpty ||
        find.textContaining('Belum').evaluate().isNotEmpty ||
        find.textContaining('Dashboard').evaluate().isNotEmpty,
        true
      );
    });
  }