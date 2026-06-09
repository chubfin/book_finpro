import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/book_controller.dart';
import '../../routes/app_routes.dart';
import '../../widgets/book_card.dart';
import '../../widgets/section_header.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final bookController = Get.find<BookController>();

    final categories = const [
      'all',
      'romance',
      'thriller',
      'self-improvement',
      'science',
      'poetry',
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Reading List')),
      body: RefreshIndicator(
        onRefresh: () =>
            bookController.fetchBooks(bookController.selectedCategory.value),
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 22),
          children: [
            Obx(
              () => Text(
                'Hi, ${authController.username.value}',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFF3B2D2F),
                    ),
              ),
            ),

            const SizedBox(height: 14),

            // 🔍 FITUR BARU: Search Bar Komponen
            TextField(
              onChanged: (value) {
                bookController.searchQuery.value = value; // Update query pencarian
              },
              decoration: InputDecoration(
                hintText: 'Search by title or author...',
                prefixIcon: const Icon(Icons.search_rounded, color: Color(0xFF9B5364)),
                suffixIcon: Obx(() => bookController.searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          // Tombol X untuk reset kolom pencarian
                          bookController.searchQuery.value = '';
                          FocusScope.of(context).unfocus(); // Sembunyikan keyboard
                        },
                      )
                    : const SizedBox.shrink()),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFF0DDD5)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFFF0DDD5)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: const BorderSide(color: Color(0xFF9B5364), width: 1.5),
                ),
                filled: true,
                fillColor: const Color(0xFFFFFCF8),
              ),
            ),

            const SizedBox(height: 18),

            // Bagian Kategori
            SizedBox(
              height: 45,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];

                  return Obx(
                    () => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(category),
                        selected:
                            bookController.selectedCategory.value == category,
                        selectedColor: const Color(0xFFFFD6E7),
                        checkmarkColor: const Color(0xFFE91E63),
                        onSelected: (_) {
                          bookController.searchQuery.value = ''; // Reset search jika ganti kategori
                          bookController.changeCategory(category);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            const SectionHeader(
              title: 'Discover Books',
              subtitle: 'Browse by category',
            ),

            const SizedBox(height: 12),

            Obx(() {
              if (bookController.isLoading.value) {
                return const Padding(
                  padding: EdgeInsets.only(top: 60),
                  child: Center(child: CircularProgressIndicator()),
                );
              }

              if (bookController.errorMessage.value.isNotEmpty) {
                return _ErrorState(
                  message: bookController.errorMessage.value,
                  onRetry: () => bookController.fetchBooks(
                    bookController.selectedCategory.value,
                  ),
                );
              }

              // 🌟 AMBIL DATA YANG SUDAH DISARING 🌟
              final displayBooks = bookController.filteredBooks;

              if (displayBooks.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.only(top: 40),
                  child: Center(
                    child: Text(
                      'No books found matching your criteria.',
                      style: TextStyle(color: Color(0xFF73656A), fontWeight: FontWeight.w600),
                    ),
                  ),
                );
              }

              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayBooks.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.62,
                ),
                itemBuilder: (context, index) {
                  final book = displayBooks[index];

                  return BookCard(
                    book: book,
                    onTap: () => Get.toNamed(AppRoutes.detail, arguments: book),
                  );
                },
              );
            }),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final Future<void> Function() onRetry;

  const _ErrorState({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 42),
      child: Column(
        children: [
          const Icon(
            Icons.wifi_off_rounded,
            size: 42,
            color: Color(0xFF9B5364),
          ),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}