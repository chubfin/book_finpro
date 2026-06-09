import 'package:hive/hive.dart';

import 'book.dart';

class BookStatus {
  static const wantToRead = 'Want To Read';
  static const currentlyReading = 'Currently Reading';
  static const completed = 'Completed';

  // values ini yang akan langsung dipanggil oleh Dropdown di DetailPage
  static const values = [wantToRead, currentlyReading, completed];
}

@HiveType(typeId: 1)
class LibraryBook extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  List<String> authors;

  @HiveField(3)
  String description;

  @HiveField(4)
  int pageCount;

  @HiveField(5)
  double averageRating;

  @HiveField(6)
  String thumbnail;

  @HiveField(7)
  int currentPage;

  @HiveField(8)
  String status;

  @HiveField(9)
  String ownerUsername;

  @HiveField(10)
  int lastProgressUpdatedMillis;

  @HiveField(11)
  bool finishSoonNotified;

  @HiveField(12)
  bool completedNotified;

  @HiveField(13)
  int staleReminderMillis;

  @HiveField(14)
  int lastGoalMilestone;

  LibraryBook({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.pageCount,
    required this.averageRating,
    required this.thumbnail,
    required this.ownerUsername,
    int? lastProgressUpdatedMillis,
    this.currentPage = 0,
    this.status =
        BookStatus.wantToRead, // Default status sesuai struktur BookStatus
    this.finishSoonNotified = false,
    this.completedNotified = false,
    this.staleReminderMillis = 0,
    this.lastGoalMilestone = 0,
  }) : lastProgressUpdatedMillis =
           lastProgressUpdatedMillis ?? DateTime.now().millisecondsSinceEpoch;

  factory LibraryBook.fromBook(Book book, String ownerUsername) {
    return LibraryBook(
      id: book.id,
      title: book.title,
      authors: book.authors,
      description: book.description,
      pageCount: book.pageCount,
      averageRating: book.averageRating,
      thumbnail: book.thumbnail,
      ownerUsername: ownerUsername,
    );
  }

  String get authorText => authors.join(', ');
  double get progress =>
      pageCount <= 0 ? 0 : (currentPage / pageCount).clamp(0, 1);
  int get progressPercent => (progress * 100).round();
  DateTime get lastProgressUpdatedAt =>
      DateTime.fromMillisecondsSinceEpoch(lastProgressUpdatedMillis);
}

class LibraryBookAdapter extends TypeAdapter<LibraryBook> {
  @override
  final int typeId = 1;

  @override
  LibraryBook read(BinaryReader reader) {
    final count = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < count; i++) {
      fields[reader.readByte()] = reader.read();
    }

    return LibraryBook(
      id: fields[0] as String,
      title: fields[1] as String,
      authors: (fields[2] as List).cast<String>(),
      description: fields[3] as String,
      pageCount: fields[4] as int,
      averageRating: fields[5] as double,
      thumbnail: fields[6] as String,
      currentPage: fields[7] as int,
      status: fields[8] as String,
      ownerUsername: (fields[9] as String?) ?? '',
      lastProgressUpdatedMillis:
          (fields[10] as int?) ?? DateTime.now().millisecondsSinceEpoch,
      finishSoonNotified: (fields[11] as bool?) ?? false,
      completedNotified: (fields[12] as bool?) ?? false,
      staleReminderMillis: (fields[13] as int?) ?? 0,
      lastGoalMilestone: (fields[14] as int?) ?? 0,
    );
  }

  @override
  void write(BinaryWriter writer, LibraryBook obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.authors)
      ..writeByte(3)
      ..write(obj.description)
      ..writeByte(4)
      ..write(obj.pageCount)
      ..writeByte(5)
      ..write(obj.averageRating)
      ..writeByte(6)
      ..write(obj.thumbnail)
      ..writeByte(7)
      ..write(obj.currentPage)
      ..writeByte(8)
      ..write(obj.status)
      ..writeByte(9)
      ..write(obj.ownerUsername)
      ..writeByte(10)
      ..write(obj.lastProgressUpdatedMillis)
      ..writeByte(11)
      ..write(obj.finishSoonNotified)
      ..writeByte(12)
      ..write(obj.completedNotified)
      ..writeByte(13)
      ..write(obj.staleReminderMillis)
      ..writeByte(14)
      ..write(obj.lastGoalMilestone);
  }
}
