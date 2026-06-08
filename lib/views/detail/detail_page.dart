import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/library_controller.dart';
import '../../models/book.dart';
import '../../models/library_book.dart';
import '../../widgets/book_cover.dart';

class DetailPage extends StatelessWidget {
  const DetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    final argument = ModalRoute.of(context)?.settings.arguments;
    final libraryController = Get.find<LibraryController>();
    final book = _bookFromArgument(argument);

    if (book == null) {
      return const Scaffold(body: Center(child: Text('Book not found.')));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Book Detail')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
        children: [
          Center(
            child: BookCover(imageUrl: book.thumbnail, width: 148, height: 218),
          ),
          const SizedBox(height: 22),
          Text(
            book.title,
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            book.authorText,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Color(0xFF73656A),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InfoBox(
                  icon: Icons.star_rounded,
                  label: 'Rating',
                  value: book.averageRating.toStringAsFixed(1),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _InfoBox(
                  icon: Icons.auto_stories_rounded,
                  label: 'Pages',
                  value: '${book.pageCount}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          if (book.category.isNotEmpty ||
              book.publisher.isNotEmpty ||
              book.price.isNotEmpty ||
              book.publishedDate.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (book.category.isNotEmpty)
                  _MetaChip(icon: Icons.category_rounded, label: book.category),
                if (book.publisher.isNotEmpty)
                  _MetaChip(
                    icon: Icons.apartment_rounded,
                    label: book.publisher,
                  ),
                if (book.price.isNotEmpty)
                  _MetaChip(icon: Icons.sell_rounded, label: book.price),
                if (book.publishedDate.isNotEmpty)
                  _MetaChip(
                    icon: Icons.event_rounded,
                    label: book.publishedDate,
                  ),
              ],
            ),
          const SizedBox(height: 18),

          Obx(() {
            libraryController.books.length;

            final libraryBook = libraryController.findById(book.id);
            final isAdded = libraryBook != null;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                FilledButton.icon(
                  onPressed: isAdded
                      ? null
                      : () => libraryController.addBook(book),
                  icon: Icon(
                    isAdded ? Icons.check_circle_rounded : Icons.add_rounded,
                  ),
                  label: Text(isAdded ? 'Added' : 'Add To Library'),
                ),
                if (libraryBook != null) ...[
                  const SizedBox(height: 18),
                  _ProgressEditor(book: libraryBook),
                ],
              ],
            );
          }),

          const SizedBox(height: 22),
          Text(
            'Description',
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w900),
          ),
          const SizedBox(height: 8),
          Text(
            book.description,
            style: const TextStyle(height: 1.55, color: Color(0xFF4B3B3E)),
          ),
        ],
      ),
    );
  }

  Book? _bookFromArgument(Object? argument) {
    if (argument is Book) return argument;
    if (argument is LibraryBook) {
      return Book(
        id: argument.id,
        title: argument.title,
        authors: argument.authors,
        description: argument.description,
        pageCount: argument.pageCount,
        averageRating: argument.averageRating,
        thumbnail: argument.thumbnail,
      );
    }
    return null;
  }
}

class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: const Color(0xFF9B5364)),
      label: Text(label),
      backgroundColor: const Color(0xFFFFFCF8),
      side: const BorderSide(color: Color(0xFFF0DDD5)),
    );
  }
}

class _ProgressEditor extends StatefulWidget {
  final LibraryBook book;

  const _ProgressEditor({required this.book});

  @override
  State<_ProgressEditor> createState() => _ProgressEditorState();
}

class _ProgressEditorState extends State<_ProgressEditor> {
  late final TextEditingController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = TextEditingController(
      text: widget.book.currentPage.toString(),
    );
  }

  @override
  void didUpdateWidget(covariant _ProgressEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.book.currentPage != widget.book.currentPage) {
      _pageController.text = widget.book.currentPage.toString();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<LibraryController>();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCF8),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFF0DDD5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Reading Progress',
            style: TextStyle(fontWeight: FontWeight.w900, fontSize: 17),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            minHeight: 9,
            borderRadius: BorderRadius.circular(99),
            value: widget.book.progress,
            backgroundColor: const Color(0xFFF0DDD5),
            valueColor: const AlwaysStoppedAnimation(Color(0xFF8CA07C)),
          ),
          const SizedBox(height: 8),
          Text(
            '${widget.book.currentPage} / ${widget.book.pageCount} pages  ${widget.book.progressPercent}%',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _pageController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Current Page'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.filled(
                tooltip: 'Save progress',
                onPressed: () {
                  final currentPage = int.tryParse(_pageController.text) ?? 0;
                  controller.updateProgress(widget.book, currentPage);
                },
                icon: const Icon(Icons.save_rounded),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: widget.book.status,
            decoration: const InputDecoration(labelText: 'Status'),
            items: BookStatus.values
                .map(
                  (status) =>
                      DropdownMenuItem(value: status, child: Text(status)),
                )
                .toList(),
            onChanged: (status) {
              if (status != null) controller.updateStatus(widget.book, status);
            },
          ),
        ],
      ),
    );
  }
}

class _InfoBox extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoBox({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8D7DA).withAlpha(143),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF9B5364)),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Color(0xFF73656A), fontSize: 12),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
          ),
        ],
      ),
    );
  }
}
