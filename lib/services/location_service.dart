import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class LocationService {
  Future<Position> getCurrentLocation() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('GPS belum aktif. Aktifkan lokasi perangkat dulu.');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      throw Exception('Izin lokasi ditolak.');
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Izin lokasi ditolak permanen. Aktifkan dari settings.');
    }

    return Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
  }

  Future<List<LiteracyPlace>> getNearbyBookPlaces(
    double lat,
    double lng,
  ) async {
    final query =
        '''
      [out:json][timeout:20];
      (
        nwr(around:7000,$lat,$lng)["shop"="books"];
        nwr(around:7000,$lat,$lng)["amenity"="library"];
        nwr(around:7000,$lat,$lng)["amenity"="cafe"]["name"];
      );
      out center tags 50;
    ''';

    final endpoints = [
      'https://overpass-api.de/api/interpreter',
      'https://overpass.kumi.systems/api/interpreter',
    ];

    for (final endpoint in endpoints) {
      try {
        final response = await http
            .get(
              Uri.parse(endpoint).replace(queryParameters: {'data': query}),
              headers: const {
                'User-Agent': 'book_finpro/1.0 Flutter reading tracker',
              },
            )
            .timeout(const Duration(seconds: 20));

        if (response.statusCode != 200) continue;

        final data = jsonDecode(response.body);
        final elements = data is Map ? data['elements'] : null;
        if (elements is! List) continue;

        final places = elements
            .whereType<Map<String, dynamic>>()
            .map(LiteracyPlace.fromOverpass)
            .where((place) => place.name.isNotEmpty)
            .toList();

        if (places.isNotEmpty) return places;
      } catch (_) {
        continue;
      }
    }

    return _fallbackJogjaPlaces(lat, lng);
  }

  List<LiteracyPlace> _fallbackJogjaPlaces(double lat, double lng) {
    final isAroundJogja =
        lat > -8.15 && lat < -7.45 && lng > 110.10 && lng < 110.65;

    if (!isAroundJogja) {
      return [
        LiteracyPlace(
          id: 'fallback-user-library',
          name: 'Cari perpustakaan terdekat',
          category: 'Rekomendasi',
          address: 'Buka rute untuk mencari di Google Maps',
          latitude: lat,
          longitude: lng,
        ),
      ];
    }

    return [
      LiteracyPlace(
        id: 'fallback-grhatama',
        name: 'Grhatama Pustaka',
        category: 'Perpustakaan',
        address: 'Jl. Janti, Banguntapan',
        latitude: -7.7993,
        longitude: 110.3996,
      ),
      LiteracyPlace(
        id: 'fallback-gramedia-sudirman',
        name: 'Gramedia Sudirman Yogyakarta',
        category: 'Toko Buku',
        address: 'Jl. Jenderal Sudirman',
        latitude: -7.7828,
        longitude: 110.3755,
      ),
      LiteracyPlace(
        id: 'fallback-togamas',
        name: 'Togamas Affandi',
        category: 'Toko Buku',
        address: 'Jl. Affandi, Gejayan',
        latitude: -7.7695,
        longitude: 110.3916,
      ),
      LiteracyPlace(
        id: 'fallback-perpus-kota',
        name: 'Perpustakaan Kota Yogyakarta',
        category: 'Perpustakaan',
        address: 'Kotabaru, Yogyakarta',
        latitude: -7.7860,
        longitude: 110.3750,
      ),
    ];
  }
}

class LiteracyPlace {
  final String id;
  final String name;
  final String category;
  final String address;
  final double latitude;
  final double longitude;

  LiteracyPlace({
    required this.id,
    required this.name,
    required this.category,
    required this.address,
    required this.latitude,
    required this.longitude,
  });

  factory LiteracyPlace.fromOverpass(Map<String, dynamic> json) {
    final tags = json['tags'] is Map ? json['tags'] as Map : const {};
    final center = json['center'] is Map ? json['center'] as Map : const {};
    final rawLat = json['lat'] ?? center['lat'] ?? 0;
    final rawLng = json['lon'] ?? center['lon'] ?? 0;
    final amenity = tags['amenity']?.toString();
    final shop = tags['shop']?.toString();

    return LiteracyPlace(
      id: '${json['type'] ?? 'place'}-${json['id'] ?? ''}',
      name: (tags['name'] ?? '').toString(),
      category: _categoryLabel(shop: shop, amenity: amenity),
      address: _addressFromTags(tags),
      latitude: double.tryParse(rawLat.toString()) ?? 0,
      longitude: double.tryParse(rawLng.toString()) ?? 0,
    );
  }

  static String _categoryLabel({String? shop, String? amenity}) {
    if (shop == 'books') return 'Toko Buku';
    if (amenity == 'library') return 'Perpustakaan';
    if (amenity == 'cafe') return 'Cafe Baca';
    return 'Tempat Literasi';
  }

  static String _addressFromTags(Map tags) {
    final parts = [
      tags['addr:street'],
      tags['addr:village'],
      tags['addr:subdistrict'],
      tags['addr:city'],
    ].where((part) => part != null && part.toString().trim().isNotEmpty);

    final address = parts.join(', ');
    return address.isEmpty ? 'Alamat belum tersedia' : address;
  }
}
