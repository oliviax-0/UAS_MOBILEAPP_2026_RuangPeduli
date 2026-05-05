import 'package:ruangpeduliapp/panti/homepage/models/berita_model.dart';

class SearchState {
  final dynamic api;

  List<BeritaModel> result = [];
  bool isLoading = false;
  Object? error;

  SearchState({required this.api});

  Future<void> search(String query) async {
    isLoading = true;
    error = null;

    try {
      result = await api.searchBerita(query) as List<BeritaModel>;
    } catch (e) {
      result = [];
      error = e;
    } finally {
      isLoading = false;
    }
  }
}
