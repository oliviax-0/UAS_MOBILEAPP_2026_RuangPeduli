import 'package:ruangpeduliapp/panti/homepage/models/berita_model.dart';

class HomePantiState {
  final dynamic api;

  List<BeritaModel> beritaList = [];
  bool isLoading = false;
  Object? error;

  HomePantiState({required this.api});

  Future<void> loadBerita() async {
    isLoading = true;
    error = null;

    try {
      beritaList = await api.getBerita() as List<BeritaModel>;
    } catch (e) {
      beritaList = [];
      error = e;
    } finally {
      isLoading = false;
    }
  }
}
