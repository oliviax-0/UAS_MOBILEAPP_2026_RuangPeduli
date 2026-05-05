import 'package:ruangpeduliapp/panti/homepage/models/berita_model.dart';

class BeritaBaruState {
  final dynamic api;

  bool isLoading = false;
  Object? error;

  BeritaBaruState({required this.api});

  Future<bool> tambahBerita(BeritaModel berita) async {
    isLoading = true;
    error = null;

    try {
      final result = await api.tambahBerita(berita) as bool;
      return result;
    } catch (e) {
      error = e;
      return false;
    } finally {
      isLoading = false;
    }
  }
}
