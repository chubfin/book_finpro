import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/location_service.dart';

class BookPlacesPage extends StatefulWidget {
  const BookPlacesPage({super.key});

  @override
  State<BookPlacesPage> createState() => _BookPlacesPageState();
}

class _BookPlacesPageState extends State<BookPlacesPage> {
  final _locationService = LocationService();
  final _mapController = MapController();
  final _defaultCenter = const LatLng(-7.7829, 110.3671);

  Position? _position;
  List<LiteracyPlace> _places = [];
  bool _isLoading = true;
  String _message = '';

  LatLng get _center => _position == null
      ? _defaultCenter
      : LatLng(_position!.latitude, _position!.longitude);

  @override
  void initState() {
    super.initState();
    _loadPlaces();
  }

  Future<void> _loadPlaces() async {
    setState(() {
      _isLoading = true;
      _message = '';
    });

    try {
      final position = await _locationService.getCurrentLocation();
      final places = await _locationService.getNearbyBookPlaces(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;
      setState(() {
        _position = position;
        _places = places;
        _message = places.isEmpty
            ? 'Belum ada toko buku, perpustakaan, atau cafe yang tercatat di sekitar lokasi kamu.'
            : '';
        _isLoading = false;
      });

      _mapController.move(LatLng(position.latitude, position.longitude), 14);
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _message = error.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _openRoute(LiteracyPlace place) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${place.latitude},${place.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: _center, initialZoom: 13.5),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.book_finpro',
              ),
              MarkerLayer(markers: _markers),
            ],
          ),
          Positioned(
            left: 18,
            right: 18,
            top: MediaQuery.paddingOf(context).top + 10,
            child: _TopBar(isLoading: _isLoading, onRefresh: _loadPlaces),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: _PlacesPanel(
              isLoading: _isLoading,
              message: _message,
              places: _places,
              onRoute: _openRoute,
            ),
          ),
        ],
      ),
    );
  }

  List<Marker> get _markers {
    final markers = <Marker>[
      Marker(
        point: _center,
        width: 42,
        height: 42,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF9B5364),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.18),
                blurRadius: 10,
              ),
            ],
          ),
          child: const Icon(
            Icons.my_location_rounded,
            color: Colors.white,
            size: 20,
          ),
        ),
      ),
    ];

    markers.addAll(
      _places.map(
        (place) => Marker(
          point: LatLng(place.latitude, place.longitude),
          width: 42,
          height: 42,
          child: const _PlaceMarker(),
        ),
      ),
    );

    return markers;
  }
}

class _TopBar extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onRefresh;

  const _TopBar({required this.isLoading, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.94),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Row(
          children: [
            const Icon(Icons.travel_explore_rounded, color: Color(0xFF9B5364)),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                'Tempat Membaca & Berbelanja',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
            IconButton(
              tooltip: 'Refresh',
              onPressed: isLoading ? null : onRefresh,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlacesPanel extends StatelessWidget {
  final bool isLoading;
  final String message;
  final List<LiteracyPlace> places;
  final ValueChanged<LiteracyPlace> onRoute;

  const _PlacesPanel({
    required this.isLoading,
    required this.message,
    required this.places,
    required this.onRoute,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.38,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(26)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.10),
            blurRadius: 18,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 5,
            decoration: BoxDecoration(
              color: const Color(0xFFE1D5D1),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Rekomendasi sekitar',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
                ),
              ),
              Text(
                '${places.length} tempat',
                style: const TextStyle(
                  color: Color(0xFF73656A),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : places.isEmpty
                ? Center(
                    child: Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Color(0xFF73656A)),
                    ),
                  )
                : ListView.separated(
                    padding: EdgeInsets.zero,
                    itemCount: places.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final place = places[index];
                      return _PlaceTile(
                        place: place,
                        onRoute: () => onRoute(place),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _PlaceTile extends StatelessWidget {
  final LiteracyPlace place;
  final VoidCallback onRoute;

  const _PlaceTile({required this.place, required this.onRoute});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0DDD5)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFF8D7DA),
            child: Icon(Icons.menu_book_rounded, color: Color(0xFF9B5364)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  place.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  '${place.category} - ${place.address}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF73656A),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          IconButton.filledTonal(
            tooltip: 'Rute',
            onPressed: onRoute,
            icon: const Icon(Icons.directions_rounded),
          ),
        ],
      ),
    );
  }
}

class _PlaceMarker extends StatelessWidget {
  const _PlaceMarker();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: const Color(0xFF8CA07C),
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Icon(
        Icons.local_library_rounded,
        color: Colors.white,
        size: 20,
      ),
    );
  }
}
