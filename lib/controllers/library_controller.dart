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

  // ✅ Cari dari RxList 'books' agar dideteksi oleh Obx di UI
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
    
    // Mengaktifkan notifikasi harian bawaan aplikasimu
    await NotificationService.scheduleDailyReadingReminder(book.title);
  }

  // ✅ SOLUSI FITUR HAPUS: Menambahkan fungsi deleteBook yang dicari oleh DetailPage
  Future<void> deleteBook(String id) async {
    if (_box.containsKey(id)) {
      await _box.delete(id);
      _syncFromHive(); // Paksa sinkronisasi ulang setelah data dihapus dari Hive
    }
  }

  // ✅ PERBAIKAN PROGRESS: Sekarang otomatis menyimpan perubahan ke Hive database
  Future<void> updateProgress(LibraryBook book, int newPage) async {
    if (newPage >= 0 && newPage <= book.pageCount) {
      book.currentPage = newPage;
      
      // Auto-complete jika halaman yang dibaca sudah mentok
      if (newPage == book.pageCount) {
        book.status = 'Completed'; 
      }
      
      // Simpan perubahan object ke dalam database Hive agar permanen
      await _box.put(book.id, book);
      books.refresh(); // Memberi tahu Obx di UI untuk menggambar ulang komponen
    }
  }

  // ✅ PERBAIKAN STATUS: Sekarang otomatis menyimpan perubahan ke Hive database
  Future<void> updateStatus(LibraryBook book, String newStatus) async {
    book.status = newStatus;
    if (newStatus == 'Completed') {
      book.currentPage = book.pageCount;
    }
    
    // Simpan perubahan object ke dalam database Hive agar permanen
    await _box.put(book.id, book);
    books.refresh(); // Triggers Obx rebuild
  }

  int get totalBooks => books.length;
  int get completedBooks => byStatus(BookStatus.completed).length;
  double get readingGoalProgress =>
      totalBooks == 0 ? 0 : completedBooks / totalBooks;

  void _syncFromHive() {
    books.assignAll(_box.values);
  }
}