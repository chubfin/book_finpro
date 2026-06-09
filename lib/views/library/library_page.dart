import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/library_controller.dart';
import '../../models/library_book.dart';
import '../../routes/app_routes.dart';
import '../../widgets/library_book_tile.dart';
import '../../widgets/section_header.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibraryController>();

    return Scaffold(
      appBar: AppBar(title: const Text('My Library')),
      body: Obx(
        () => ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
          children: [
            _StatusSection(
              title: BookStatus.wantToRead,
              books: controller.byStatus(BookStatus.wantToRead),
            ),
            const SizedBox(height: 10),
            _StatusSection(
              title: BookStatus.currentlyReading,
              books: controller.byStatus(BookStatus.currentlyReading),
            ),
            const SizedBox(height: 10),
            _StatusSection(
              title: BookStatus.completed,
              books: controller.byStatus(BookStatus.completed),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusSection extends StatelessWidget {
  final String title;
  final List<LibraryBook> books;

  const _StatusSection({required this.title, required this.books});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(title: title, subtitle: '${books.length} books'),
        const SizedBox(height: 8),
        if (books.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFCF8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFFF0DDD5)),
            ),
            child: const Text(
              'Belum ada buku di kategori ini.',
              style: TextStyle(color: Color(0xFF73656A), fontSize: 13),
            ),
          )
        else
          ...books.map(
            (book) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: LibraryBookTile(
                book: book,
                onTap: () => Get.toNamed(AppRoutes.detail, arguments: book),
              ),
            ),
          ),
      ],
    );
  }
}
