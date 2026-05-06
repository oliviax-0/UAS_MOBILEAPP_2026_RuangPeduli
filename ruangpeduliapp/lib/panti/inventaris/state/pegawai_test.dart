import 'package:flutter_test/flutter_test.dart';
import 'package:ruangpeduliapp/panti/inventaris/state/residents_state.dart';
import 'package:ruangpeduliapp/panti/inventaris/models/anggota_model.dart';

/// Fake API
class FakeResidentsApi {
  Future<List<AnggotaModel>> getPegawai() async {
    return [
      AnggotaModel(
        id: 1,
        nama: 'Budi',
        divisi: 'Gudang',
        telepon: '08123456789',
      ),
    ];
  }

  Future<bool> addPegawai(AnggotaModel anggota) async {
    return true;
  }

  Future<bool> deletePegawai(int id) async {
    return true;
  }
}

/// Error API
class ErrorResidentsApi {
  Future<List<AnggotaModel>> getPegawai() async {
    throw Exception('Error');
  }

  Future<bool> addPegawai(AnggotaModel anggota) async {
    throw Exception('Error');
  }

  Future<bool> deletePegawai(int id) async {
    throw Exception('Error');
  }
}

void main() {
  group('PegawaiState Test', () {

    test('loadPegawai success', () async {
      final state = ResidentsState(api: FakeResidentsApi());

      await state.loadPegawai();

      expect(state.pegawaiList.length, 1);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('loadPegawai error', () async {
      final state = ResidentsState(api: ErrorResidentsApi());

      await state.loadPegawai();

      expect(state.pegawaiList.isEmpty, true);
      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });

    test('addPegawai success', () async {
      final state = ResidentsState(api: FakeResidentsApi());

      final anggota = AnggotaModel(
        id: 1,
        nama: 'Budi',
        divisi: 'Gudang',
        telepon: '08123456789',
      );

      final result = await state.addPegawai(anggota);

      expect(result, true);
    });

    test('deletePegawai success', () async {
      final state = ResidentsState(api: FakeResidentsApi());

      final result = await state.deletePegawai(1);

      expect(result, true);
    });

  });
}