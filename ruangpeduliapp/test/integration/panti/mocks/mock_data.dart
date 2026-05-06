// test/mocks/mock_data.dart

import 'package:ruangpeduliapp/panti/homepage/models/berita_model.dart';
import 'package:test/test.dart';

/// =========================
/// SINGLE BERITA
/// =========================
final mockBerita = BeritaModel(
  id: 1,
  judul: 'Judul Mock',
  isi: 'Isi Mock',
  thumbnail: '',
  createdAt: '2024-01-01',
);

/// =========================
/// LIST BERITA
/// =========================
final mockBeritaList = [
  mockBerita,
  BeritaModel(
    id: 2,
    judul: 'Judul Kedua',
    isi: 'Isi Kedua',
    thumbnail: '',
    createdAt: '2024-01-02',
  ),
];

/// =========================
/// SEARCH RESULT
/// =========================
final mockSearchResult = [
  BeritaModel(
    id: 3,
    judul: 'Hasil beras',
    isi: 'Isi hasil pencarian',
    thumbnail: '',
    createdAt: '2024-01-03',
  ),
];

void main() {
  group('Mock data', () {
    test('mockBerita has valid values', () {
      expect(mockBerita.id, 1);
      expect(mockBerita.judul, 'Judul Mock');
      expect(mockBerita.isi, 'Isi Mock');
    });

    test('mockBeritaList contains two items', () {
      expect(mockBeritaList, hasLength(2));
      expect(mockBeritaList.first, mockBerita);
      expect(mockBeritaList.last.judul, 'Judul Kedua');
    });

    test('mockSearchResult contains search item', () {
      expect(mockSearchResult, hasLength(1));
      expect(mockSearchResult.first.judul, 'Hasil beras');
    });
  });
}
