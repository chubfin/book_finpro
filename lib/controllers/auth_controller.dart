import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controllers/library_controller.dart';
import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final username = AuthService.username.obs;
  final profilePhotoPath = AuthService.profilePhotoPath.obs;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> login(String usernameValue, String passwordValue) async {
    final cleanUsername = usernameValue.trim();
    final cleanPassword = passwordValue.trim();
    if (cleanUsername.isEmpty) {
      Get.snackbar('Login gagal', 'Username wajib diisi.');
      return;
    }
    if (cleanPassword.isEmpty) {
      Get.snackbar('Login gagal', 'Password wajib diisi.');
      return;
    }
    if (!AuthService.canLogin(cleanUsername, cleanPassword)) {
      Get.snackbar('Login gagal', 'Username atau password salah.');
      return;
    }

    await AuthService.login(cleanUsername, cleanPassword);
    username.value = cleanUsername;
    profilePhotoPath.value = AuthService.profilePhotoPath;
    _refreshLibrary();
    Get.offAllNamed(AppRoutes.main);
  }

  Future<void> register(String usernameValue, String passwordValue) async {
    final cleanUsername = usernameValue.trim();
    final cleanPassword = passwordValue.trim();
    if (cleanUsername.length < 3) {
      Get.snackbar('Register gagal', 'Username minimal 3 karakter.');
      return;
    }
    if (cleanPassword.length < 4) {
      Get.snackbar('Register gagal', 'Password minimal 4 karakter.');
      return;
    }

    final created = await AuthService.register(cleanUsername, cleanPassword);
    if (!created) {
      Get.snackbar('Register gagal', 'Username sudah terdaftar.');
      return;
    }

    // register berhasil → arahkan ke login
    Get.snackbar('Register berhasil', 'Silakan login dengan akun kamu.');
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> logout() async {
    await AuthService.logout();
    username.value = '';
    profilePhotoPath.value = '';
    _refreshLibrary();
    Get.offAllNamed(AppRoutes.login);
  }

  Future<void> pickProfilePhoto() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 900,
    );
    if (image == null) return;

    await AuthService.saveProfilePhotoPath(image.path);
    profilePhotoPath.value = image.path;
  }

  void _refreshLibrary() {
    if (Get.isRegistered<LibraryController>()) {
      Get.find<LibraryController>().refreshForCurrentUser();
    }
  }
}
