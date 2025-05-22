// lib/widgets/duel_screen/user_side_card.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/book.dart';
import '../../../../core/models/character.dart';
import 'book_list_bottom_sheet.dart';
import '../../../../core/widgets/character/character_avatar.dart';
import '../../../../core/theme/theme_provider.dart';

class UserSideCard extends StatelessWidget {
  final String name;
  final String displayName;
  final List<Book> books;
  final Color color;
  final bool isYou;
  final CharacterType characterType;
  final VoidCallback onAddBook;
  final ValueChanged<Book>? onEditBook;
  final ValueChanged<Book>? onDeleteBook;
  final bool animateAvatar;

  const UserSideCard({
    super.key,
    required this.name,
    required this.displayName,
    required this.books,
    required this.color,
    required this.isYou,
    required this.characterType,
    required this.onAddBook,
    this.onEditBook,
    this.onDeleteBook,
    this.animateAvatar = false,
  });

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final cardBackground = isDark ? Colors.grey.shade900 : Colors.white;
    final textColor = isDark ? Colors.white : Colors.grey[600]!;
    final buttonBackground = isDark ? Colors.grey.shade800 : color.withAlpha(30);

    final totalRating = books.isEmpty ? 0.0 : books.map((b) => b.rating).reduce((a, b) => a + b);
    final avgRating = books.isEmpty ? 0.0 : totalRating / books.length;

    return Container(
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(15),
            blurRadius: 5,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: buttonBackground,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CharacterAvatar(
                  characterType: characterType,
                  size: 30,
                  animate: animateAvatar,
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color,
                      decoration: TextDecoration.none,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),

          // Stats + buttons
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Column(
              children: [
                // Display name
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),

                // Book count and label: wrap to allow breaking
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 5,
                  children: [
                    Text(
                      '${books.length}',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    Text(
                      books.length == 1 ? 'Book' : 'Books',
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                        decoration: TextDecoration.none,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
                const SizedBox(height: 5),

                // Rating stars: wrap so they don't overflow
                if (books.isNotEmpty)
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 2,
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < avgRating.floor()
                            ? Icons.star
                            : i < avgRating
                                ? Icons.star_half
                                : Icons.star_border,
                        size: 14,
                        color: i < avgRating ? const Color(0xFFFFD700) : Colors.grey[300],
                      ),
                    ),
                  ),
                const SizedBox(height: 10),

                // Buttons: Wrap the buttons container itself
                Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (isYou) _buildAddBookButton(buttonBackground),
                    if (books.isNotEmpty) _buildViewBooksButton(context, buttonBackground),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddBookButton(Color background) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onAddBook,
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Icon(Icons.add, size: 16, color: color),
                Text(
                  'Add Book',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildViewBooksButton(BuildContext context, Color background) => Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showBooksList(context),
          borderRadius: BorderRadius.circular(15),
          child: Ink(
            padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 10),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              children: [
                Icon(Icons.menu_book, size: 16, color: color),
                Text(
                  'View',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: color,
                    decoration: TextDecoration.none,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      );

  void _showBooksList(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Wrap(
        children: [
          Container(
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[900] : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: BookListBottomSheet(
              books: books,
              name: displayName,
              color: color,
              isYou: isYou,
              onEdit: onEditBook ?? (_) {},
              onDelete: onDeleteBook ?? (_) {},
            ),
          ),
        ],
      ),
    );
  }
}
