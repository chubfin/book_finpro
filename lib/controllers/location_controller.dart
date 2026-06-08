import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';

import '../services/location_service.dart';

class LocationController extends GetxController {
  final LocationService _locationService = LocationService();

  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final currentPosition = Rxn<Position>();

  Future<void> loadCurrentLocation() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      currentPosition.value = await _locationService.getCurrentPosition();
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }
}
