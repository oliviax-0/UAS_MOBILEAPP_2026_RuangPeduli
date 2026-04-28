import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

class ProvinceModel {
  final String id;
  final String name;
  const ProvinceModel({required this.id, required this.name});
  factory ProvinceModel.fromJson(Map<String, dynamic> json) =>
      ProvinceModel(id: json['id'] as String, name: json['name'] as String);
}

class CityModel {
  final String id;
  final String name;
  const CityModel({required this.id, required this.name});
  factory CityModel.fromJson(Map<String, dynamic> json) =>
      CityModel(id: json['id'] as String, name: json['name'] as String);
}

class DistrictModel {
  final String id;
  final String name;
  const DistrictModel({required this.id, required this.name});
  factory DistrictModel.fromJson(Map<String, dynamic> json) =>
      DistrictModel(id: json['id'] as String, name: json['name'] as String);
}

class VillageModel {
  final String id;
  final String name;
  const VillageModel({required this.id, required this.name});
  factory VillageModel.fromJson(Map<String, dynamic> json) =>
      VillageModel(id: json['id'] as String, name: json['name'] as String);
}

class RegionalApi {
  static const _base = 'https://api-regional-indonesia.vercel.app/api';

  Future<List<ProvinceModel>> fetchProvinces() async {
    return _fetchList('$_base/provinces?sort=name',
        (e) => ProvinceModel.fromJson(e));
  }

  Future<List<CityModel>> fetchCities(String provinceId) async {
    return _fetchList('$_base/cities/$provinceId?sort=name',
        (e) => CityModel.fromJson(e));
  }

  Future<List<DistrictModel>> fetchDistricts(String cityId) async {
    return _fetchList('$_base/districts/$cityId?sort=name',
        (e) => DistrictModel.fromJson(e));
  }

  Future<List<VillageModel>> fetchVillages(String districtId) async {
    return _fetchList('$_base/villages/$districtId?sort=name',
        (e) => VillageModel.fromJson(e));
  }

  Future<List<T>> _fetchList<T>(
      String url, T Function(Map<String, dynamic>) fromJson) async {
    try {
      final res = await http
          .get(Uri.parse(url))
          .timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) throw Exception('Gagal memuat data wilayah');
      final data = jsonDecode(res.body)['data'] as List;
      return data.map((e) => fromJson(e as Map<String, dynamic>)).toList();
    } on SocketException {
      throw Exception('Tidak bisa konek ke server');
    }
  }
}
