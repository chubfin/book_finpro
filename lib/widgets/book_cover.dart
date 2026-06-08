import 'package:flutter/material.dart';

class BookCover extends StatelessWidget {
  final String imageUrl;
  final double width;
  final double height;

  const BookCover({
    super.key,
    required this.imageUrl,
    this.width = 86,
    this.height = 126,
  });

  @override
  Widget build(BuildContext context) {
    final normalizedUrl = Uri.tryParse(imageUrl)?.toString() ?? '';

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: width,
        height: height,
        color: const Color(0xFFDDE5D3),
        child: normalizedUrl.isEmpty
            ? const Icon(
                Icons.menu_book_rounded,
                size: 34,
                color: Color(0xFF6B7A60),
              )
            : Image.network(
                normalizedUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  }

                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(
                    Icons.menu_book_rounded,
                    size: 34,
                    color: Color(0xFF6B7A60),
                  );
                },
              ),
      ),
    );
  }
}
