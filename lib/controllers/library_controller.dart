import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/book.dart';
import '../models/library_book.dart';
import '../services/notification_service.dart';

class LibraryController extends GetxController {
  static const boxName = 'library_books';

  final Box<LibraryBook> _box = Hive.box<LibraryBook>(boxName);
  final books = <LibraryBook>[].obs;

  @override
  void onInit() {
    super.onInit();
    books.assignAll(_box.values);
    _box.listenable().addListener(_syncFromHive);
  }

  @override
  void onClose() {
    _box.listenable().removeListener(_syncFromHive);
    super.onClose();
  }

  bool isAdded(String id) => _box.containsKey(id);

  // ✅ PERBAIKAN: Cari dari RxList 'books' agar dideteksi oleh Obx di UI
  LibraryBook? findById(String id) {
    return books.firstWhereOrNull((book) => book.id == id);
  }

  List<LibraryBook> byStatus(String status) {
    return books.where((book) => book.status == status).toList();
  }

  Future<void> addBook(Book book) async {
    if (isAdded(book.id)) return;

    final libraryBook = LibraryBook.fromBook(book);
    await _box.put(book.id, libraryBook);
    _syncFromHive(); // Paksa sync setelah menambah agar UI langsung update
    await NotificationService.scheduleDailyReadingReminder(book.title);
    Get.snackbar('Added', '${book.title} masuk ke library.');
  }

  Future<void> updateProgress(LibraryBook book, int currentPage) async {
    book.currentPage = currentPage.clamp(0, book.pageCount);
    book.status = book.currentPage >= book.pageCount && book.pageCount > 0
        ? BookStatus.completed
        : book.currentPage > 0
        ? BookStatus.currentlyReading
        : BookStatus.wantToRead;
    await book.save();
    books.refresh(); // Memicu Obx untuk memperbarui tampilan progress bar
  }

  Future<void> updateStatus(LibraryBook book, String status) async {
    book.status = status;
    if (status == BookStatus.completed && book.pageCount > 0) {
      book.currentPage = book.pageCount;
    }
    await book.save();
    books.refresh(); // Memicu Obx untuk memperbarui status dropdown
  }

  int get totalBooks => books.length;
  int get completedBooks => byStatus(BookStatus.completed).length;
  double get readingGoalProgress =>
      totalBooks == 0 ? 0 : completedBooks / totalBooks;

  void _syncFromHive() {
    books.assignAll(_box.values);
  }
}
