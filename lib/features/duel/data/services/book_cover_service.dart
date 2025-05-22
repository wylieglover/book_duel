// lib/services/book_cover_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/models/book.dart';
import '../../../../utils/image_proxy.dart';

class BookCoverService {
  static final BookCoverService _instance = BookCoverService._internal();
  factory BookCoverService() => _instance;
  BookCoverService._internal();

  final Map<String, String?> _coverCache = {};

  static const String _baseUrl = 'https://www.googleapis.com/books/v1/volumes';
  static const String _openLibraryUrl = 'https://covers.openlibrary.org/b/isbn/';
  static const int _cacheExpirationDays = 30;

  // Get the image proxy base URL from config
  static final String _imageProxyBase = ImageProxyConfig.baseUrl;

  Future<void> initCache() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('book_cover_cache');
    if (cached != null) {
      try {
        final decoded = json.decode(cached) as Map<String, dynamic>;
        _coverCache.addAll(decoded.map((k, v) => MapEntry(k, v as String?)));
      } catch (e) {
        _log('Error loading cover cache: $e');
      }
    }
    _cleanExpiredCache();
  }

  Future<void> _saveCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('book_cover_cache', json.encode(_coverCache));
    } catch (e) {
      _log('Error saving cover cache: $e');
    }
  }

  void _cleanExpiredCache() async {
    final prefs = await SharedPreferences.getInstance();
    final lastCleanup = prefs.getInt('last_cover_cache_cleanup') ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;
    final weekMillis = const Duration(days: 7).inMilliseconds;
    if (now - lastCleanup < weekMillis) return;
    await prefs.setInt('last_cover_cache_cleanup', now);

    final expirationMillis = const Duration(days: _cacheExpirationDays).inMilliseconds;
    final tsRaw = prefs.getString('cover_cache_timestamps');
    if (tsRaw != null) {
      try {
        final timestamps = json.decode(tsRaw) as Map<String, dynamic>;
        final toRemove = <String>[];
        timestamps.forEach((key, ts) {
          if (now - (ts as int) > expirationMillis) {
            toRemove.add(key);
          }
        });
        for (var k in toRemove) {
          _coverCache.remove(k);
          timestamps.remove(k);
        }
        await prefs.setString('cover_cache_timestamps', json.encode(timestamps));
        await _saveCache();
      } catch (e) {
        _log('Error cleaning cover cache: $e');
      }
    }
  }

  Future<void> _updateCacheTimestamp(String key) async {
    final prefs = await SharedPreferences.getInstance();
    final rawTs = prefs.getString('cover_cache_timestamps') ?? '{}';
    try {
      final timestamps = json.decode(rawTs) as Map<String, dynamic>;
      timestamps[key] = DateTime.now().millisecondsSinceEpoch;
      await prefs.setString('cover_cache_timestamps', json.encode(timestamps));
    } catch (e) {
      _log('Error updating cache timestamp: $e');
    }
  }

  /// Handle image URLs properly based on platform
  String _processImageUrl(String url) {
    if (url.startsWith('http:')) {
      url = url.replaceFirst('http:', 'https:');
    }
    
    // On Web, we need to proxy Google Books and Open Library requests
    if (kIsWeb && (url.contains('books.google.com') || url.contains('covers.openlibrary.org'))) {
      if (_imageProxyBase.isNotEmpty) {
        return '$_imageProxyBase?url=${Uri.encodeComponent(url)}';
      }
    }
    
    return url;
  }

  /// Try to HEAD-check fallback images so we don't cache 404's
  Future<bool> _isValidImageUrl(String url) async {
    try {
      final resp = await http.head(Uri.parse(url));
      final len = int.tryParse(resp.headers['content-length'] ?? '') ?? 0;
      return resp.statusCode == 200 && len > 500;
    } catch (e) {
      _log('Failed to validate image URL: $url - $e');
      return false;
    }
  }

  /// Fetch both cover URL and pageCount in one call.
  Future<Map<String, dynamic>> fetchBookMetadata(
      String title, String author) async {
    final cacheKey = '${title}_$author'.toLowerCase();

    if (_coverCache.containsKey(cacheKey)) {
      final cached = _coverCache[cacheKey];
      return {'coverUrl': cached, 'pageCount': null};
    }

    // 1) Single Google Books query
    final qUrl =
        '$_baseUrl?q=${Uri.encodeComponent('intitle:$title inauthor:$author')}&maxResults=1';
    final resp = await http.get(Uri.parse(qUrl));
    if (resp.statusCode != 200) {
      _log('GB API error ${resp.statusCode}');
      return {'coverUrl': null, 'pageCount': null};
    }

    final data = json.decode(resp.body) as Map<String, dynamic>;
    final items = data['items'] as List<dynamic>?;
    if (items == null || items.isEmpty) {
      _log('No items for: $title');
      return {'coverUrl': null, 'pageCount': null};
    }

    final vol = items.first['volumeInfo'] as Map<String, dynamic>;
    String? thumbnail;
    int? pageCount = vol['pageCount'] as int?;

    // 2) Pick the best imageLinks if available
    if (vol.containsKey('imageLinks')) {
      thumbnail = (vol['imageLinks']['thumbnail'] ??
              vol['imageLinks']['smallThumbnail'])
          as String?;
      if (thumbnail != null) {
        thumbnail = _processImageUrl(thumbnail);
        _coverCache[cacheKey] = thumbnail;
      }
    }

    // 3) Fallback to Open Library if no Google thumbnail
    if (thumbnail == null && vol.containsKey('industryIdentifiers')) {
      final ids = (vol['industryIdentifiers'] as List<dynamic>);
      final entry = ids.firstWhere(
          (i) => i['type'] == 'ISBN_13' || i['type'] == 'ISBN_10',
          orElse: () => null) as Map<String, dynamic>?;
      final isbn = entry?['identifier'] as String?;
      if (isbn != null) {
        final fallback = '$_openLibraryUrl$isbn-M.jpg';
        if (await _isValidImageUrl(fallback)) {
          thumbnail = _processImageUrl(fallback);
          _coverCache[cacheKey] = thumbnail;
        }
      }
    }

    await _updateCacheTimestamp(cacheKey);
    await _saveCache();

    return {
      'coverUrl': thumbnail,
      'pageCount': pageCount,
    };
  }

  Future<List<Book>> enhanceBooksWithCovers(List<Book> books) async {
    final service = BookCoverService();
    final result = <Book>[];

    for (final book in books) {
      // If we already have both cover & pageCount, skip the API
      if (book.coverUrl != null && book.coverUrl!.isNotEmpty && book.pageCount != null) {
        result.add(book);
        continue;
      }

      final meta = await service.fetchBookMetadata(book.title, book.author);
      result.add(
        book.copyWith(
          coverUrl: book.coverUrl ?? meta['coverUrl'] as String?,
          pageCount: book.pageCount ?? meta['pageCount'] as int?,
        ),
      );
    }
    return result;
  }
  /// Helper method to only log during development
  void _log(String message) {
    if (kDebugMode) {
      debugPrint('📚 BookCoverService: $message');
    }
  }
}