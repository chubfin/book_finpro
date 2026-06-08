import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'controllers/auth_controller.dart';
import 'controllers/book_controller.dart';
import 'controllers/library_controller.dart';
import 'controllers/location_controller.dart';
import 'models/library_book.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Hive.initFlutter();
  Hive.registerAdapter(LibraryBookAdapter());
  await Hive.openBox<LibraryBook>(LibraryController.boxName);

  await AuthService.init();
  await NotificationService.init();

  Get.put(AuthController(), permanent: true);
  Get.put(BookController(), permanent: true);
  Get.put(LibraryController(), permanent: true);
  Get.put(LocationController(), permanent: true);

  runApp(const ReadingListApp());
}

class ReadingListApp extends StatelessWidget {
  const ReadingListApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Reading List',
      initialRoute: AuthService.isLoggedIn ? AppRoutes.main : AppRoutes.login,
      getPages: AppPages.pages,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFFFF8F0),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFFF8D7DA),
          primary: const Color(0xFFB85F73),
          secondary: const Color(0xFFDDE5D3),
          surface: const Color(0xFFFFFCF8),
        ),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Color(0xFFFFF8F0),
          foregroundColor: Color(0xFF3B2D2F),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFCF8),
          elevation: 0,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFF0DDD5)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(18),
            borderSide: const BorderSide(color: Color(0xFFB85F73), width: 1.4),
          ),
        ),
      ),
    );
  }
}
