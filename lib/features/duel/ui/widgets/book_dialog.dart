// lib/widgets/duel_screen/book_dialog.dart

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../../../../core/models/book.dart';
import '../../../../core/theme/theme_provider.dart';

/// Animation wrapper for the add/edit book dialog
class BookDialogAnimation extends StatelessWidget {
  final Widget child;

  const BookDialogAnimation({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate()
        .scale(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutBack,
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
        )
        .fade(
          duration: const Duration(milliseconds: 200),
          begin: 0.0,
          end: 1.0,
        );
  }
}

/// Shows a dialog for adding or editing a [Book].
/// If [existingBook] is provided, the form is pre-filled for editing.
Future<void> showBookDialog(
  BuildContext context,
  bool isYou,
  Future<void> Function(Book newBook) onBookAdded, {
  Book? existingBook,
}) async {
  String bookTitle = existingBook?.title ?? '';
  String author = existingBook?.author ?? '';
  double bookRating = existingBook?.rating ?? 3.0;

  final TextEditingController titleController =
      TextEditingController(text: existingBook?.title ?? '');
  final TextEditingController authorController =
      TextEditingController(text: existingBook?.author ?? '');
  final FocusNode focusNode = FocusNode();

  final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
  final isDark = themeProvider.isDarkMode;

  final Color themeColor = isYou ? const Color(0xFF7ED7C1) : const Color(0xFFFFAFCC);
  final Color background = isDark ? Colors.grey.shade900 : Colors.white;
  final Color textColor = isDark ? Colors.white : Colors.black87;
  final Color fieldColor = isDark ? Colors.grey.shade800 : Colors.grey.shade100;
  final Color borderColor = isDark ? Colors.grey.shade700 : Colors.grey.shade300;

  WidgetsBinding.instance.addPostFrameCallback((_) {
    Future.delayed(const Duration(milliseconds: 300), () {
      if (focusNode.canRequestFocus) {
        focusNode.requestFocus();
      }
    });
  });

  await showDialog<void>(
    context: context,
    useRootNavigator: true,
    barrierDismissible: true,
    barrierColor: Colors.transparent,
    builder: (ctx) => Dialog(
      elevation: 0,
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      child: BookDialogAnimation(
        child: Container(
          width: MediaQuery.of(ctx).size.width * 0.85,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_stories, color: themeColor, size: 28),
                  const SizedBox(width: 12),
                  Text(
                    existingBook != null ? 'Edit Book' : 'Add Book',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Title input
              Container(
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: titleController,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Book Title',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: TextStyle(fontSize: 16, color: textColor),
                  onChanged: (value) => bookTitle = value,
                ),
              ),
              const SizedBox(height: 16),

              // Author input
              Container(
                decoration: BoxDecoration(
                  color: fieldColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: borderColor),
                ),
                child: TextField(
                  controller: authorController,
                  decoration: InputDecoration(
                    hintText: 'Author',
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  ),
                  style: TextStyle(fontSize: 16, color: textColor),
                  onChanged: (value) => author = value,
                ),
              ),
              const SizedBox(height: 24),

              // Rating
              Text(
                'Rate this book:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 12),
              Center(
                child: RatingBar.builder(
                  initialRating: bookRating,
                  minRating: 0,
                  direction: Axis.horizontal,
                  allowHalfRating: true,
                  itemCount: 5,
                  itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
                  itemSize: 32,
                  unratedColor: Colors.grey.shade300,
                  itemBuilder: (_, __) => Icon(
                    Icons.star_rounded,
                    color: isYou ? const Color(0xFFFFD700) : const Color(0xFFFF8E9E),
                  ),
                  onRatingUpdate: (rating) => bookRating = rating,
                ),
              ),
              const SizedBox(height: 32),

              // Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: themeColor,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    onPressed: () async {
                      if (bookTitle.trim().isNotEmpty && author.trim().isNotEmpty) {
                        Navigator.pop(ctx);
                        await onBookAdded(
                          Book(
                            id: existingBook?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            title: bookTitle.trim(),
                            author: author.trim(),
                            rating: bookRating,
                            coverUrl: existingBook?.coverUrl,
                          ),
                        );
                      }
                    },
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
