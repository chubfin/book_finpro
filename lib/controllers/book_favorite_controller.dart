import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BookFavoriteController extends GetxController {
  // Nama Box Hive yang digunakan
  final String _boxName = 'favorite_books_box';

  // List reaktif untuk menampung data buku favorit
  var favoriteBooks = <Map<String, dynamic>>[].obs;

  @override
  void onInit() {
    super.onInit();
    _initHiveAndLoadData();
  }

  // Fungsi untuk membuka box dan memuat data pertama kali
  Future<void> _initHiveAndLoadData() async {
    // Pastikan Box sudah terbuka
    if (!Hive.isBoxOpen(_boxName)) {
      await Hive.openBox(_boxName);
    }
    loadFavorites();
  }

  // Ambil semua data dari Hive ke dalam List reaktif GetX
  void loadFavorites() {
    final box = Hive.box(_boxName);

    // Mengonversi data Hive menjadi List<Map> yang bisa dibaca reaktif
    final data = box.keys.map((key) {
      final item = box.get(key);
      return {
        "id": key,
        "title": item['title'],
        "author": item['author'],
        "image": item['image'],
      };
    }).toList();

    favoriteBooks.assignAll(data);
  }

  // Tambah atau Hapus Favorit (Toggle System)
  void toggleFavorite(
    String bookId,
    String title,
    String author,
    String image,
  ) {
    final box = Hive.box(_boxName);

    if (box.containsKey(bookId)) {
      // Jika sudah ada, hapus dari favorit
      box.delete(bookId);
      Get.rawSnackbar(
        message: "$title dihapus dari favorit",
        duration: const Duration(seconds: 1),
      );
    } else {
      // Jika belum ada, tambahkan ke favorit
      box.put(bookId, {"title": title, "author": author, "image": image});
      Get.rawSnackbar(
        message: "$title ditambahkan ke favorit",
        duration: const Duration(seconds: 1),
      );
    }

    // Perbarui list reaktif setelah data di Hive berubah
    loadFavorites();
  }

  // Cek apakah buku ini berstatus favorit atau tidak (untuk icon warna bendera/hati)
  bool isFavorite(String bookId) {
    final box = Hive.box(_boxName);
    return box.containsKey(bookId);
  }
}
