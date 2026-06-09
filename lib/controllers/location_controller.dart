import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class LocationController extends GetxController {
  final isLoading = false.obs;
  final currentPosition = Rxn<Position>();
  final errorMessage = ''.obs;

  final LocationService _locationService = LocationService();

  Future<void> loadCurrentLocation() async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final position = await _locationService.getCurrentLocation();
      currentPosition.value = position;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      currentPosition.value = null;
    } finally {
      isLoading.value = false;
    }
  }
}
