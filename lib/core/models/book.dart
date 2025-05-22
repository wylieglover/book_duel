// lib/models/book.dart

class Book {
  final String id;
  final String title;
  final String author;
  final double rating;
  final String? coverUrl;
  final int? pageCount;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.rating,
    this.coverUrl,
    this.pageCount,
  });

  /// Creates a modified copy of this Book.
  Book copyWith({
    String? id,
    String? title,
    String? author,
    double? rating,
    String? coverUrl,
    int? pageCount,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      rating: rating ?? this.rating,
      coverUrl: coverUrl ?? this.coverUrl,
      pageCount: pageCount ?? this.pageCount,
    );
  }

  factory Book.fromMap(Map<dynamic, dynamic> map) {
    return Book(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      author: map['author'] ?? 'Unknown',
      rating: (map['rating'] as num).toDouble(),
      coverUrl: map['coverUrl'] as String?,
      pageCount: map['pageCount'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'rating': rating,
      if (coverUrl != null) 'coverUrl': coverUrl,
      if (pageCount != null) 'pageCount': pageCount,
    };
  }
}
