// lib/widgets/duel_screen/book_list_bottom_sheet.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../../core/models/book.dart';
import '../../../../core/services/session_service.dart';

class BookListBottomSheet extends StatefulWidget {
  final List<Book> books;
  final String name;
  final Color color;
  final bool isYou;
  final ValueChanged<Book>? onEdit;
  final ValueChanged<Book>? onDelete;

  const BookListBottomSheet({
    super.key,
    required this.books,
    required this.name,
    required this.color,
    required this.isYou,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<BookListBottomSheet> createState() => _BookListBottomSheetState();
}

class _BookListBottomSheetState extends State<BookListBottomSheet> {
  late List<Book> _books;
  StreamSubscription? _sessionSub;

  @override
  void initState() {
    super.initState();
    _books = List.of(widget.books);

    if (widget.isYou) {
      final session = SessionService();
      _sessionSub = session.sessionStream?.listen(
        (event) {
          final data = event.snapshot.value as Map?;
          if (data == null) return;

          final isCreator = session.isCreator;
          final booksKey = isCreator ? 'creatorBooks' : 'joinerBooks';
          final yourRaw = data[booksKey];

          if (yourRaw != null) {
            session.parseAndEnhanceBooks(yourRaw).then((updatedBooks) {
              if (mounted) {
                setState(() {
                  _books = updatedBooks;
                });
              }
            });
          }
        },
        onError: (err) {
          final msg = err.toString();
          if (msg.contains("Unknown event type")) return;
          debugPrint("Session stream error: $err");
        },
      );
    }
  }

  @override
  void dispose() {
    _sessionSub?.cancel();
    super.dispose();
  }

  @override
  void didUpdateWidget(BookListBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update book list when widget props change
    if (widget.books != oldWidget.books) {
      setState(() {
        _books = List.of(widget.books);
      });
    }
  }

  Future<bool> _confirmDelete(Book book) async {
    widget.onDelete?.call(book);
    setState(() => _books.remove(book));
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg   = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final surf = isDark ? const Color(0xFF2C2C2C) : Colors.white;
    final div  = isDark ? Colors.grey.shade800     : Colors.grey.shade200;
    final prim = isDark ? Colors.white             : Colors.black87;
    final sec  = isDark ? Colors.grey.shade400     : Colors.grey.shade600;

    return Container(
      height: MediaQuery.of(context).size.height * .6,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40, height: 4,
            decoration: BoxDecoration(color: sec, borderRadius: BorderRadius.circular(4)),
          ),
          const SizedBox(height: 8),

          // — HEADER —
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                Icon(Icons.menu_book, color: widget.color),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.isYou ? 'My Book List' : "${widget.name}'s Book List",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: prim),
                  ),
                ),
                Text(
                  "${_books.length} ${_books.length == 1 ? 'book' : 'books'}",
                  style: TextStyle(color: sec),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: div),

          // — LIST —
          Expanded(
            child: _books.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.book_outlined, size: 64, color: sec),
                      const SizedBox(height: 16),
                      Text(
                        widget.isYou
                          ? "You haven't added any books yet"
                          : "${widget.name} hasn't added any books yet",
                        style: TextStyle(color: sec),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _books.length,
                  itemBuilder: (ctx, i) {
                    final book = _books[i];
                    return Dismissible(
                      key: ValueKey(book.id),
                      direction: widget.isYou ? DismissDirection.endToStart : DismissDirection.none,
                      confirmDismiss: (_) => _confirmDelete(book),
                      background: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        padding: const EdgeInsets.only(right: 20),
                        alignment: Alignment.centerRight,
                        decoration: BoxDecoration(
                          color: Colors.redAccent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.delete_outline, color: Colors.red),
                      ),
                      child: _buildItem(book, surf, prim, sec),
                    );
                  },
                ),
          ),

          // — CLOSE BUTTON —
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: widget.color,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                minimumSize: const Size.fromHeight(44),
              ),
              child: const Text('Close'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItem(Book book, Color surf, Color prim, Color sec) {
    final hasCover = (book.coverUrl ?? '').isNotEmpty;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: surf,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4, offset: const Offset(0, 2))],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: 40,
              height: 60,
              child: hasCover
              ? CachedNetworkImage(
                  imageUrl: book.coverUrl!,           // now safe
                  placeholder: (ctx, url) => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  errorWidget: (ctx, url, error) => const Icon(Icons.book, size: 40),
                  fit: BoxFit.cover,
                )
              : Icon(Icons.book_outlined, size: 40, color: sec),  // fallback
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(book.title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: prim)),
                  const SizedBox(height: 4),
                  Text(book.author, style: TextStyle(color: sec)),
                  // Display page count if available
                  if (book.pageCount != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${book.pageCount} pages',
                      style: TextStyle(fontSize: 12, color: sec),
                    ),
                  ],
                  const SizedBox(height: 4),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < book.rating.floor()
                            ? Icons.star
                            : i < book.rating
                                ? Icons.star_half
                                : Icons.star_border,
                        size: 14,
                        color: i < book.rating ? const Color(0xFFFFD700) : Colors.grey[300],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (widget.isYou) ...[
              IconButton(
                icon: Icon(Icons.edit, color: widget.color),
                onPressed: () {
                  widget.onEdit?.call(book);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}