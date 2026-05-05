class BeritaDetailState {
  final dynamic api;

  bool isLoading = false;
  Object? error;

  BeritaDetailState({required this.api});

  Future<bool> upvote(int id) async {
    return _run(() => api.upvote(id) as Future<bool>);
  }

  Future<bool> downvote(int id) async {
    return _run(() => api.downvote(id) as Future<bool>);
  }

  Future<bool> _run(Future<bool> Function() action) async {
    isLoading = true;
    error = null;

    try {
      return await action();
    } catch (e) {
      error = e;
      return false;
    } finally {
      isLoading = false;
    }
  }
}
