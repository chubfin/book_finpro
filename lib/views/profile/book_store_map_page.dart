import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Menggunakan LatLng bawaan dari package ini
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class BookStoreMapPage extends StatefulWidget {
  final double userLat;
  final double userLng;

  const BookStoreMapPage({
    super.key,
    required this.userLat,
    required this.userLng,
  });

  @override
  State<BookStoreMapPage> createState() => _BookStoreMapPageState();
}

class _BookStoreMapPageState extends State<BookStoreMapPage> {
  final MapController _mapController = MapController();
  List<Marker> _markers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchNearbyBooksOpenSource();
  }

  Future<void> _fetchNearbyBooksOpenSource() async {
    // Validasi awal koordinat agar tidak menembak API dengan nilai kosong
    if (widget.userLat == 0.0 || widget.userLng == 0.0) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Format koordinat GPS tidak valid.")),
        );
        setState(() => _isLoading = false);
      }
      return;
    }

    // Radius kotak pencarian (0.05 derajat setara kurang lebih 5 KM)
    final double radius = 0.05;
    final double minLat = widget.userLat - radius;
    final double maxLat = widget.userLat + radius;
    final double minLng = widget.userLng - radius;
    final double maxLng = widget.userLng + radius;

    // MENGGUNAKAN SERVER KUMI SYSTEMS (Lebih responsif & jarang overload dibanding server utama)
    final String url = 'https://overpass.kumi.systems/api/interpreter?data=[out:json];'
        '(node["shop"="books"]($minLat,$minLng,$maxLat,$maxLng);'
        'node["amenity"="library"]($minLat,$minLng,$maxLat,$maxLng););out;';

    try {
      // Diberi batas waktu 12 detik agar tidak loading selamanya jika internet lambat
      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 12));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final List elements = data['elements'];

        List<Marker> tempMarkers = [];

        // 1. Tambah Marker Posisi Pengguna (Warna Biru)
        tempMarkers.add(
          Marker(
            point: LatLng(widget.userLat, widget.userLng),
            width: 40,
            height: 40,
            child: const Icon(
              Icons.my_location_rounded,
              color: Colors.blue,
              size: 35,
            ),
          ),
        );

        // 2. Tambah Marker Toko Buku / Perpustakaan dari OpenStreetMap
        for (var element in elements) {
          final lat = element['lat'];
          final lon = element['lon'];
          final tags = element['tags'];
          final name = tags != null && tags['name'] != null 
              ? tags['name'] 
              : (tags?['shop'] == 'books' ? 'Toko Buku' : 'Perpustakaan');

          tempMarkers.add(
            Marker(
              point: LatLng(lat, lon),
              width: 45,
              height: 45,
              child: GestureDetector(
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(name),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF9B5364),
                  size: 40,
                ),
              ),
            ),
          );
        }

        if (mounted) {
          setState(() {
            _markers = tempMarkers;
            _isLoading = false;
          });
        }
      } else {
        throw Exception("Server merespon dengan kode: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Error fetching OSM places: $e");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Gagal memuat tempat terdekat. Pastikan koneksi internet aktif."),
            backgroundColor: const Color(0xFFB85F73),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tempat Buku Terdekat (Gratis)')),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(widget.userLat, widget.userLng),
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.book_finpro',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          
          // Loading Overlay Widget
          if (_isLoading)
            const Center(
              child: Card(
                elevation: 4,
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(width: 16),
                      Text("Mencari lokasi buku terdekat..."),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}