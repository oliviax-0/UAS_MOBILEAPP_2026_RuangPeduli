import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:ruangpeduliapp/panti/profile_panti/state/kebutuhan_state.dart';
import 'package:ruangpeduliapp/panti/profile_panti/models/kebutuhan_model.dart';
import 'package:ruangpeduliapp/panti/profile_panti/api/kebutuhan_api.dart';

/// FAKE API SUCCESS
class FakeKebutuhanApi extends KebutuhanApi {
  FakeKebutuhanApi() : super(client: http.Client());

  @override
  Future<List<KebutuhanModel>> getKebutuhan() async {
    return [
      KebutuhanModel(id: 1, nama: 'Beras', jumlah: 10, satuan: 'Kg'),
    ];
  }
}

/// FAKE API ERROR
class ErrorKebutuhanApi extends KebutuhanApi {
  ErrorKebutuhanApi() : super(client: http.Client());

  @override
  Future<List<KebutuhanModel>> getKebutuhan() async {
    throw Exception('Error');
  }
}

void main() {
  group('KebutuhanState Test (simple)', () {

    test('loadKebutuhan success', () async {
      final state = KebutuhanState(api: FakeKebutuhanApi());

      await state.loadKebutuhan();

      expect(state.kebutuhanList.length, 1);
      expect(state.error, isNull);
      expect(state.isLoading, false);
    });

    test('loadKebutuhan error', () async {
      final state = KebutuhanState(api: ErrorKebutuhanApi());

      await state.loadKebutuhan();

      expect(state.kebutuhanList.isEmpty, true);
      expect(state.error, isNotNull);
      expect(state.isLoading, false);
    });

  });
}