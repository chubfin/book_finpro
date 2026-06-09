import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/library_controller.dart';
import '../../controllers/location_controller.dart';
import '../../models/library_book.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final AuthController _authController;
  late final LibraryController _libraryController;
  late final LocationController _locationController;

  @override
  void initState() {
    super.initState();
    _authController = Get.find<AuthController>();
    _libraryController = Get.find<LibraryController>();
    _locationController = Get.find<LocationController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_locationController.currentPosition.value == null &&
          !_locationController.isLoading.value) {
        _locationController.loadCurrentLocation();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          _ProfileHeader(authController: _authController),
          const SizedBox(height: 16),
          Obx(() {
            final books = _libraryController.books;
            final totalBooks = books.length;
            final completedBooks = books
                .where((book) => book.status == BookStatus.completed)
                .length;
            final readingBooks = books
                .where((book) => book.status == BookStatus.currentlyReading)
                .length;
            final progress = totalBooks == 0
                ? 0.0
                : completedBooks / totalBooks;

            return _ReadingSummary(
              totalBooks: totalBooks,
              completedBooks: completedBooks,
              readingBooks: readingBooks,
              progress: progress,
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final position = _locationController.currentPosition.value;
            return _LocationCard(
              latitude: position?.latitude,
              longitude: position?.longitude,
              isLoading: _locationController.isLoading.value,
              errorMessage: _locationController.errorMessage.value,
              onRefresh: _locationController.loadCurrentLocation,
            );
          }),
          const SizedBox(height: 16),
          Obx(() {
            final books = _libraryController.books;
            return _StatusBreakdown(
              wantToRead: books
                  .where((book) => book.status == BookStatus.wantToRead)
                  .length,
              reading: books
                  .where((book) => book.status == BookStatus.currentlyReading)
                  .length,
              completed: books
                  .where((book) => book.status == BookStatus.completed)
                  .length,
            );
          }),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: _authController.logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final AuthController authController;

  const _ProfileHeader({required this.authController});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF8D7DA),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Obx(() {
            final photoPath = authController.profilePhotoPath.value;
            final hasPhoto =
                photoPath.isNotEmpty && File(photoPath).existsSync();

            return Stack(
              children: [
                CircleAvatar(
                  radius: 42,
                  backgroundColor: const Color(0xFFFFFCF8),
                  backgroundImage: hasPhoto ? FileImage(File(photoPath)) : null,
                  child: hasPhoto
                      ? null
                      : const Icon(
                          Icons.person_rounded,
                          size: 42,
                          color: Color(0xFF9B5364),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: InkWell(
                    onTap: authController.pickProfilePhoto,
                    borderRadius: BorderRadius.circular(99),
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        color: const Color(0xFF9B5364),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: const Icon(
                        Icons.camera_alt_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(width: 16),
          Expanded(
            child: Obx(
              () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    authController.username.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF3B2D2F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Keep building the reading habit.',
                    style: TextStyle(
                      color: Color(0xFF73656A),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ReadingSummary extends StatelessWidget {
  final int totalBooks;
  final int completedBooks;
  final int readingBooks;
  final double progress;

  const _ReadingSummary({
    required this.totalBooks,
    required this.completedBooks,
    required this.readingBooks,
    required this.progress,
  });

  @override
  Widget build(BuildContext context) {
    final percent = (progress * 100).round();

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0DDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Reading Progress',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
                ),
              ),
              Text(
                '$percent%',
                style: const TextStyle(
                  color: Color(0xFF9B5364),
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            minHeight: 10,
            borderRadius: BorderRadius.circular(99),
            value: progress,
            backgroundColor: const Color(0xFFF0DDD5),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF8CA07C)),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _MiniStat(
                  label: 'Library',
                  value: '$totalBooks',
                  icon: Icons.library_books_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Reading',
                  value: '$readingBooks',
                  icon: Icons.auto_stories_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _MiniStat(
                  label: 'Done',
                  value: '$completedBooks',
                  icon: Icons.done_all_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LocationCard extends StatelessWidget {
  final double? latitude;
  final double? longitude;
  final bool isLoading;
  final String errorMessage;
  final VoidCallback onRefresh;

  const _LocationCard({
    required this.latitude,
    required this.longitude,
    required this.isLoading,
    required this.errorMessage,
    required this.onRefresh,
  });

  @override
  Widget build(BuildContext context) {
    final hasLocation = latitude != null && longitude != null;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0DDD5)),
      ),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFFDDE5D3),
              shape: BoxShape.circle,
            ),
            child: isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.near_me_rounded, color: Color(0xFF6B7A60)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lokasi kamu',
                  style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  hasLocation
                      ? 'Lat ${latitude!.toStringAsFixed(5)}, Long ${longitude!.toStringAsFixed(5)}'
                      : errorMessage.isNotEmpty
                      ? errorMessage
                      : 'Mengambil lokasi otomatis...',
                  style: const TextStyle(
                    color: Color(0xFF73656A),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Refresh lokasi',
            onPressed: isLoading ? null : onRefresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _StatusBreakdown extends StatelessWidget {
  final int wantToRead;
  final int reading;
  final int completed;

  const _StatusBreakdown({
    required this.wantToRead,
    required this.reading,
    required this.completed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MiniStat(
            label: 'Want',
            value: '$wantToRead',
            icon: Icons.bookmark_add_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            label: 'Active',
            value: '$reading',
            icon: Icons.local_fire_department_rounded,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MiniStat(
            label: 'Finished',
            value: '$completed',
            icon: Icons.workspace_premium_rounded,
          ),
        ),
      ],
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _MiniStat({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0DDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF9B5364), size: 21),
          const SizedBox(height: 8),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF3B2D2F),
            ),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Color(0xFF73656A), fontSize: 12),
          ),
        ],
      ),
    );
  }
}
