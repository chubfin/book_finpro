import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/library_controller.dart';
import '../../controllers/location_controller.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final libraryController = Get.find<LibraryController>();
    final locationController = Get.find<LocationController>();

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF8D7DA),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 34,
                  backgroundColor: Color(0xFFFFFCF8),
                  child: Icon(
                    Icons.person_rounded,
                    size: 34,
                    color: Color(0xFF9B5364),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Obx(
                    () => Text(
                      authController.username.value,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Obx(() {
            final position = locationController.currentPosition.value;
            final hasLocation = position != null;

            return Container(
              width: double.infinity,
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
                      const Icon(
                        Icons.location_on_rounded,
                        color: Color(0xFF9B5364),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Location Based Service',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w900),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    hasLocation
                        ? 'Lat ${position.latitude.toStringAsFixed(5)}, Long ${position.longitude.toStringAsFixed(5)}'
                        : 'Ambil lokasi saat ini untuk fitur LBS.',
                    style: const TextStyle(color: Color(0xFF73656A)),
                  ),
                  if (locationController.errorMessage.value.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      locationController.errorMessage.value,
                      style: const TextStyle(color: Color(0xFFB85F73)),
                    ),
                  ],
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: locationController.isLoading.value
                          ? null
                          : locationController.loadCurrentLocation,
                      icon: locationController.isLoading.value
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.my_location_rounded),
                      label: const Text('Get Current Location'),
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 18),
          Obx(
            () => Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _StatCard(
                        label: 'Total Books',
                        value: '${libraryController.totalBooks}',
                        icon: Icons.library_books_rounded,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _StatCard(
                        label: 'Completed',
                        value: '${libraryController.completedBooks}',
                        icon: Icons.done_all_rounded,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFCF8),
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFF0DDD5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Reading Goal Progress',
                        style: TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 17,
                        ),
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        minHeight: 10,
                        borderRadius: BorderRadius.circular(99),
                        value: libraryController.readingGoalProgress,
                        backgroundColor: const Color(0xFFF0DDD5),
                        valueColor: const AlwaysStoppedAnimation(
                          Color(0xFF8CA07C),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(libraryController.readingGoalProgress * 100).round()}% completed',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton.icon(
            onPressed: authController.logout,
            icon: const Icon(Icons.logout_rounded),
            label: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
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
          Icon(icon, color: const Color(0xFF9B5364)),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          Text(label, style: const TextStyle(color: Color(0xFF73656A))),
        ],
      ),
    );
  }
}
