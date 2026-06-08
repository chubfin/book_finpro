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
}
