import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/book.dart';
import '../models/library_book.dart';
import '../services/auth_service.dart';
import '../services/notification_service.dart';

class LibraryController extends GetxController {
  static const boxName = 'library_books';
  static const _finishSoonThreshold = 10;
  static const _staleReadingDays = 3;

  final Box<LibraryBook> _box = Hive.box<LibraryBook>(boxName);
  final books = <LibraryBook>[].obs;

  @override
  void onInit() {
    super.onInit();
    refreshForCurrentUser();
    _box.listenable().addListener(_syncFromHive);
  }

  @override
  void onClose() {
    _box.listenable().removeListener(_syncFromHive);
    super.onClose();
  }

  bool isAdded(String id) => _box.containsKey(_storageKey(id));

  LibraryBook? findById(String id) {
    return books.firstWhereOrNull((book) => book.id == id);
  }

  List<LibraryBook> byStatus(String status) {
    return books.where((book) => book.status == status).toList();
  }

  Future<void> addBook(Book book) async {
    if (isAdded(book.id)) return;

    final libraryBook = LibraryBook.fromBook(book, _currentOwner);
    await _box.put(_storageKey(book.id), libraryBook);
    _syncFromHive();
  }

  Future<void> deleteBook(String id) async {
    final key = _storageKey(id);
    if (!_box.containsKey(key)) return;

    await _box.delete(key);
    _syncFromHive();
  }

  Future<void> updateProgress(LibraryBook book, int newPage) async {
    if (book.pageCount <= 0) return;

    final safePage = newPage.clamp(0, book.pageCount);
    final key = _storageKey(book.id);
    final liveBook = _box.get(key) ?? book;
    final oldPage = liveBook.currentPage;
    final oldStatus = liveBook.status;
    final completedBefore = completedBooks;

    liveBook.currentPage = safePage;
    liveBook.status = _statusFromPage(safePage, liveBook.pageCount);
    if (safePage != oldPage) {
      liveBook.lastProgressUpdatedMillis =
          DateTime.now().millisecondsSinceEpoch;
    }

    await _box.put(key, liveBook);
    _syncFromHive();

    await _notifyFinishSoonIfNeeded(liveBook, oldPage);
    await _notifyCompletedIfNeeded(liveBook, oldStatus);
    await _notifyGoalMilestoneIfNeeded(completedBefore);
  }

  Future<void> updateStatus(LibraryBook book, String newStatus) async {
    final key = _storageKey(book.id);
    final liveBook = _box.get(key) ?? book;
    final oldStatus = liveBook.status;
    final completedBefore = completedBooks;

    liveBook.status = newStatus;
    if (newStatus == BookStatus.completed && liveBook.pageCount > 0) {
      liveBook.currentPage = liveBook.pageCount;
    } else if (newStatus == BookStatus.wantToRead) {
      liveBook.currentPage = 0;
    }
    liveBook.lastProgressUpdatedMillis = DateTime.now().millisecondsSinceEpoch;

    await _box.put(key, liveBook);
    _syncFromHive();

    await _notifyCompletedIfNeeded(liveBook, oldStatus);
    await _notifyGoalMilestoneIfNeeded(completedBefore);
  }

  int get totalBooks => books.length;
  int get completedBooks => byStatus(BookStatus.completed).length;
  double get readingGoalProgress =>
      totalBooks == 0 ? 0 : completedBooks / totalBooks;

  void refreshForCurrentUser() {
    _syncFromHive();
    checkStaleReadingBooks();
  }

  Future<void> checkStaleReadingBooks() async {
    final now = DateTime.now();
    for (final book in books) {
      if (book.status != BookStatus.currentlyReading) continue;

      final daysIdle = now.difference(book.lastProgressUpdatedAt).inDays;
      if (daysIdle < _staleReadingDays) continue;

      final lastReminder = book.staleReminderMillis == 0
          ? null
          : DateTime.fromMillisecondsSinceEpoch(book.staleReminderMillis);
      final alreadyRemindedToday =
          lastReminder != null && now.difference(lastReminder).inHours < 24;
      if (alreadyRemindedToday) continue;

      book.staleReminderMillis = now.millisecondsSinceEpoch;
      await _box.put(_storageKey(book.id), book);
      _syncFromHive();

      await NotificationService.showInstantNotification(
        title: 'Buku belum dilanjutkan',
        body:
            '"${book.title}" sudah $daysIdle hari belum diupdate. Yuk lanjut baca sedikit hari ini.',
      );
      return;
    }
  }

  String get _currentOwner => AuthService.username;

  String _storageKey(String bookId) => '$_currentOwner::$bookId';

  String _statusFromPage(int page, int pageCount) {
    if (page <= 0) return BookStatus.wantToRead;
    if (page >= pageCount) return BookStatus.completed;
    return BookStatus.currentlyReading;
  }

  Future<void> _notifyFinishSoonIfNeeded(LibraryBook book, int oldPage) async {
    final oldRemaining = book.pageCount - oldPage;
    final newRemaining = book.pageCount - book.currentPage;
    final crossedThreshold =
        oldRemaining > _finishSoonThreshold &&
        newRemaining <= _finishSoonThreshold;

    if (!crossedThreshold ||
        newRemaining <= 0 ||
        book.finishSoonNotified ||
        book.status != BookStatus.currentlyReading) {
      return;
    }

    book.finishSoonNotified = true;
    await _box.put(_storageKey(book.id), book);
    _syncFromHive();

    await NotificationService.showInstantNotification(
      title: 'Dikit lagi tamat!',
      body:
          'Sisa $newRemaining halaman lagi untuk menyelesaikan "${book.title}". Yuk, tuntaskan.',
    );
  }

  Future<void> _notifyCompletedIfNeeded(
    LibraryBook book,
    String oldStatus,
  ) async {
    final justCompleted =
        oldStatus != BookStatus.completed &&
        book.status == BookStatus.completed;
    if (!justCompleted || book.completedNotified) return;

    book.completedNotified = true;
    book.finishSoonNotified = true;
    await _box.put(_storageKey(book.id), book);
    _syncFromHive();

    await NotificationService.showInstantNotification(
      title: 'Buku selesai!',
      body:
          'Kamu berhasil menyelesaikan "${book.title}". Mantap, satu buku lagi masuk daftar tamat.',
    );
  }

  Future<void> _notifyGoalMilestoneIfNeeded(int completedBefore) async {
    if (totalBooks == 0) return;

    final beforePercent = (completedBefore / totalBooks * 100).floor();
    final afterPercent = (completedBooks / totalBooks * 100).floor();
    final milestone = afterPercent >= 100
        ? 100
        : afterPercent >= 50
        ? 50
        : 0;

    if (milestone == 0 || beforePercent >= milestone) return;

    await NotificationService.showInstantNotification(
      title: milestone == 100 ? 'Target selesai!' : 'Target setengah jalan!',
      body: milestone == 100
          ? 'Semua buku di library kamu sudah tamat. Keren banget!'
          : 'Kamu sudah menamatkan setengah dari daftar bacaanmu. Pertahankan ritmenya.',
    );
  }

  void _syncFromHive() {
    final owner = _currentOwner;
    if (owner.isEmpty) {
      books.clear();
      return;
    }

    books.assignAll(_box.values.where((book) => book.ownerUsername == owner));
  }
}
