class Book {
  final String id;
  final String title;
  final List<String> authors;
  final String description;
  final int pageCount;
  final double averageRating;
  final String thumbnail;
  final String category;
  final String publisher;
  final String price;
  final String publishedDate;
  final String buyUrl;
  final List<String> tags;

  Book({
    required this.id,
    required this.title,
    required this.authors,
    required this.description,
    required this.pageCount,
    required this.averageRating,
    required this.thumbnail,
    this.category = '',
    this.publisher = '',
    this.price = '',
    this.publishedDate = '',
    this.buyUrl = '',
    this.tags = const [],
  });

  String get authorText =>
      authors.isNotEmpty ? authors.join(', ') : 'Unknown Author';

  bool matchesCategory(String keyword) {
    final source = [
      category,
      publisher,
      ...tags,
      title,
      authorText,
    ].join(' ').toLowerCase();
    return source.contains(keyword);
  }

  factory Book.fromApi(Map<String, dynamic> json) {
    final parsedId = json['_id'] ?? json['id'] ?? '';

    List<String> authorsList = [];
    final authorData = json['author'] ?? json['authors'];

    if (authorData != null) {
      if (authorData is Map && authorData['name'] != null) {
        authorsList.add(authorData['name'].toString());
      } else if (authorData is List) {
        authorsList = authorData
            .map((e) => e is Map && e['name'] != null ? e['name'] : e)
            .map((e) => e.toString())
            .toList();
      } else if (authorData is String) {
        authorsList.add(authorData);
      }
    }
    if (authorsList.isEmpty) {
      authorsList.add('Unknown Author');
    }

    final parsedDescription = json['summary'] ?? json['description'] ?? '';

    int pages = 0;
    final details = json['details'];
    if (details is Map && details['total_pages'] != null) {
      final pagesString = details['total_pages'].toString();
      pages = int.tryParse(pagesString.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    } else {
      final pageCountData = json['pageCount'] ?? json['total_pages'];
      if (pageCountData != null) {
        pages = int.tryParse(pageCountData.toString()) ?? 0;
      }
    }

    String parsedThumbnail = '';
    final imageLinks =
        json['cover_image'] ??
        json['coverImage'] ??
        json['thumbnail'] ??
        json['image'] ??
        json['imageLinks'];

    if (imageLinks is Map) {
      parsedThumbnail =
          imageLinks['thumbnail'] ?? imageLinks['smallThumbnail'] ?? '';
    } else if (imageLinks != null) {
      parsedThumbnail = imageLinks.toString();
    }

    double rating = 0.0;
    final ratingData = json['averageRating'] ?? json['rating'];
    if (ratingData != null) {
      rating = double.tryParse(ratingData.toString()) ?? 0.0;
    }

    final category = json['category'];
    final tags = json['tags'];
    final buyLinks = json['buy_links'];
    final firstBuyLink = buyLinks is List && buyLinks.isNotEmpty
        ? buyLinks.first
        : null;

    return Book(
      id: parsedId.toString(),
      title: json['title'] ?? '',
      authors: authorsList,
      description: parsedDescription.toString(),
      pageCount: pages,
      averageRating: rating,
      thumbnail: parsedThumbnail,
      category: category is Map && category['name'] != null
          ? category['name'].toString()
          : (json['category'] ?? '').toString(),
      publisher: (json['publisher'] ?? '').toString(),
      price: details is Map ? (details['price'] ?? '').toString() : '',
      publishedDate: details is Map
          ? (details['published_date'] ?? '').toString()
          : '',
      buyUrl: firstBuyLink is Map && firstBuyLink['url'] != null
          ? firstBuyLink['url'].toString()
          : '',
      tags: tags is List
          ? tags
                .map(
                  (tag) =>
                      tag is Map && tag['name'] != null ? tag['name'] : tag,
                )
                .map((tag) => tag.toString())
                .toList()
          : const [],
    );
  }

  factory Book.fromJson(Map<String, dynamic> json) => Book.fromApi(json);
}
