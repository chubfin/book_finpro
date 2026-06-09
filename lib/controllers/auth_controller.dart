import 'package:get/get.dart';

import '../routes/app_routes.dart';
import '../services/auth_service.dart';

class AuthController extends GetxController {
  final username = AuthService.username.obs;

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
    Get.offAllNamed(AppRoutes.login);
  }
}