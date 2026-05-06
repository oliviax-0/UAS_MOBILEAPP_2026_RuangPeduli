import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventaris/state/residents_state.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/anggota_model.dart';

/// Fake API
class FakeResidentsApi {
  Future<List<AnggotaModel>> getPenghuni() async {
    return [
      AnggotaModel(
        id: 1,
        nama: 'Andi',
        divisi: 'Penghuni',
        telepon: '08111111111',
      ),
    ];
  }

  Future<bool> addPenghuni(AnggotaModel anggota) async {
    return true;
  }

  Future<bool> deletePenghuni(int id) async {
    return true;
  }
}

/// Error API
class ErrorResidentsApi {
  Future<List<AnggotaModel>> getPenghuni() async {
    throw Exception('Error');
  }

  Future<bool> addPenghuni(AnggotaModel anggota) async {
    throw Exception('Error');
  }

  Future<bool> deletePenghuni(int id) async {
    throw Exception('Error');
  }
}

void main() {
  group('PenghuniState Test', () {

    test('loadPenghuni success', () async {
      final state = ResidentsState(api: FakeResidentsApi());

      await state.loadPegawai();

      expect(state.pegawaiList.length, 1);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('loadPenghuni error', () async {
      final state = ResidentsState(api: ErrorResidentsApi());

      await state.loadPegawai();

      expect(state.pegawaiList.isEmpty, true);
      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });

    test('addPenghuni success', () async {
      final state = ResidentsState(api: FakeResidentsApi());

      final anggota = AnggotaModel(
        id: 1,
        nama: 'Andi',
        divisi: 'Penghuni',
        telepon: '08111111111',
      );

      final result = await state.addPegawai(anggota);

      expect(result, true);
    });

    test('deletePenghuni success', () async {
      final state = ResidentsState(api: FakeResidentsApi());

      final result = await state.deletePegawai(1);

      expect(result, true);
    });

  });
}