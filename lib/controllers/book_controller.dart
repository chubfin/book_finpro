import 'package:get/get.dart';

import '../models/book.dart';
import '../services/api_service.dart';

class BookController extends GetxController {
  final ApiService _apiService = ApiService();

  final books = <Book>[].obs;
  final selectedCategory = 'all'.obs;
  final isLoading = false.obs;
  final errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchBooks(selectedCategory.value);
  }

  Future<void> fetchBooks(String category) async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      books.assignAll(await _apiService.fetchBooks(category));
      if (books.isEmpty) {
        errorMessage.value = 'Buku untuk kategori ini belum tersedia.';
      }
    } catch (error) {
      errorMessage.value = error.toString().replaceFirst('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  void changeCategory(String category) {
    selectedCategory.value = category;
    fetchBooks(category);
  }

  // --- Tambahkan ini di dalam class BookController ---

  // 1. Variabel penampung teks pencarian secara reaktif
  var searchQuery = ''.obs;

  // 2. Getter untuk menyaring buku berdasarkan judul atau author
  List<Book> get filteredBooks {
    if (searchQuery.isEmpty) {
      return books; // Jika kolom pencarian kosong, kembalikan semua buku dari API
    }

    final query = searchQuery.value.toLowerCase();
    return books.where((book) {
      final matchTitle = book.title.toLowerCase().contains(query);

      // Sesuaikan pengecekan author dengan struktur data model Book kamu
      // Jika book.authors berupa List<String>:
      final matchAuthor = book.authors.any(
        (author) => author.toLowerCase().contains(query),
      );

      // ATAU jika book.authorText/book.authors berupa String tunggal, gunakan baris bawah ini:
      // final matchAuthor = book.authors.toLowerCase().contains(query);

      return matchTitle || matchAuthor;
    }).toList();
  }
}
