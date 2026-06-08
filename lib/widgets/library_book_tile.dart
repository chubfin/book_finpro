import 'package:flutter/material.dart';

import '../models/library_book.dart';
import 'book_cover.dart';

class LibraryBookTile extends StatelessWidget {
  final LibraryBook book;
  final VoidCallback onTap;

  const LibraryBookTile({super.key, required this.book, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              BookCover(imageUrl: book.thumbnail, width: 66, height: 96),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      book.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      book.authorText,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF73656A),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(99),
                      value: book.progress,
                      backgroundColor: const Color(0xFFF0DDD5),
                      valueColor: const AlwaysStoppedAnimation(
                        Color(0xFF8CA07C),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${book.currentPage} / ${book.pageCount} pages  ${book.progressPercent}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
