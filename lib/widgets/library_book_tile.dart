import 'package:flutter/material.dart';
import '../models/library_book.dart';

class LibraryBookTile extends StatelessWidget {
  final LibraryBook book;
  final VoidCallback onTap;

  const LibraryBookTile({
    super.key,
    required this.book,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFFFFCF8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFF0DDD5)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Cover Buku
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                book.thumbnail,
                width: 60,
                height: 85,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 60,
                  height: 85,
                  color: Colors.grey[300],
                  child: const Icon(Icons.book_rounded, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 14),

            // 2. Detail Konten Buku
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFF3B2D2F),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.authorText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                  
                  // 🔥 LOGIKA KONDISIONAL PROGRESS BAR BERDASARKAN STATUS 🔥
                  if (book.status == BookStatus.currentlyReading) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: book.progress,
                      backgroundColor: const Color(0xFFF5EBE6),
                      valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9B5364)),
                      minHeight: 6,
                      borderRadius: BorderRadius.circular(3),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${book.currentPage} / ${book.pageCount} pages (${book.progressPercent}%)',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF73656A), fontWeight: FontWeight.w500),
                    ),
                  ] else if (book.status == BookStatus.wantToRead) ...[
                    const SizedBox(height: 10),
                    Text(
                      '💤 Not started yet (${book.pageCount} pages)',
                      style: const TextStyle(fontSize: 11, color: Color(0xFF9B8A8F), fontStyle: FontStyle.italic),
                    ),
                  ] else if (book.status == BookStatus.completed) ...[
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9), // Background hijau soft
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.check_circle_rounded, size: 12, color: Colors.green),
                          SizedBox(width: 4),
                          Text(
                            'Finished! 🎉',
                            style: TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}