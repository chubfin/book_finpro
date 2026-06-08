import 'package:get/get.dart';

import '../views/detail/detail_page.dart';
import '../views/home/main_shell.dart';
import '../views/login/login_page.dart';
import '../views/login/register_page.dart';
import 'app_routes.dart';

class AppPages {
  static final pages = [
    GetPage(name: AppRoutes.login, page: () => const LoginPage()),
    GetPage(name: AppRoutes.register, page: () => const RegisterPage()),
    GetPage(name: AppRoutes.main, page: () => const MainShell()),
    GetPage(name: AppRoutes.detail, page: () => const DetailPage()),
  ];
}
