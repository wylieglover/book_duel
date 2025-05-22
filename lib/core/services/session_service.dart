// lib/services/session_service.dart (modified)
import 'dart:math';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/profile/data/models/activity_data.dart';
import '../models/book.dart';
import '../../features/matches/data/models/match_record.dart' show MatchRecord, MatchResult;
import '../models/session.dart';
import '../models/character.dart';

import '../../features/profile/data/services/activity_service.dart';
import '../../features/duel/data/services/book_cover_service.dart';
import '../../features/profile/data/services/profile_service.dart';

class SessionService {
  static final SessionService _instance = SessionService._internal();
  factory SessionService() => _instance;
  SessionService._internal();

  final FirebaseDatabase _db = FirebaseDatabase.instance;
  DatabaseReference? _sessionRef;

  Session? _currentSession;

  bool get isConnected => _sessionRef != null;
  Session? get currentSession => _currentSession;
  String? get currentSessionId => _currentSession?.id;
  String? get userName => _currentSession?.userName;
  String? get friendName => _currentSession?.friendName;
  bool get isCreator => _currentSession?.isCreator ?? false;

  /// Create a new session
  Future<String> createSession(String name) async {
    // Ensure profile service is initialized
    await ProfileService.instance.init();
    
    final code = _generateFriendCode();
    _sessionRef = _db.ref('sessions/$code');
    final profile = ProfileService.instance.currentProfile;
    final myCharacterIndex = profile?.avatarIndex ?? 0;

    // Get current user's UID from ProfileService
    final uid = ProfileService.instance.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    _currentSession = Session(
      id: code,
      userName: name,
      isCreator: true,
      character: CharacterType.values[myCharacterIndex],
    );

    await _sessionRef!.child('meta').set({
      'createdAt': DateTime.now().toIso8601String(),
      'creatorName': name,
      'creatorUid': uid,
      'creatorCharacter': myCharacterIndex,
    });

    await _persistSession();
    
    // Update profile with display name if different
    if (ProfileService.instance.currentProfile?.displayName != name) {
      await ProfileService.instance.updateProfile(displayName: name);
    }
    
    return code;
  }

  /// Join an existing session
  Future<bool> joinSession(String code, String name) async {
    // Ensure profile service is initialized
    await ProfileService.instance.init();
    
    final sessionRef = _db.ref('sessions/$code');
    final snapshot = await sessionRef.child('meta').get();
    if (!snapshot.exists) return false;

    final metaData = snapshot.value as Map<dynamic, dynamic>;
    if (metaData.containsKey('joinerUid') && metaData['joinerUid'] != null) return false;

    final prefs = await SharedPreferences.getInstance();
    final myCharacterIndex = prefs.getInt('character') ?? 0;

    // Get current user's UID from ProfileService
    final uid = ProfileService.instance.uid;
    if (uid == null) {
      throw Exception('User not authenticated');
    }

    _sessionRef = sessionRef;
    _currentSession = Session(
      id: code,
      userName: name,
      friendName: metaData['creatorName'],
      isCreator: false,
      character: CharacterType.values[myCharacterIndex],
      friendCharacter: CharacterType.values[metaData['creatorCharacter'] ?? 0],
    );

    await _sessionRef!.child('meta').update({
      'joinerName': name,
      'joinerUid': uid,
      'joinerCharacter': myCharacterIndex,
    });

    await _persistSession();
    
    // Update profile with display name if different
    if (ProfileService.instance.currentProfile?.displayName != name) {
      await ProfileService.instance.updateProfile(displayName: name);
    }
    
    return true;
  }

  /// Restore session from SharedPreferences + Firebase
  Future<void> restoreSessionIfExists() async {
    final prefs = await SharedPreferences.getInstance();
    final id = prefs.getString('bookduel_session_id');
    final isCreator = prefs.getBool('bookduel_is_creator');
    final charIndex = prefs.getInt('bookduel_character') ?? 0;

    final profile = ProfileService.instance.currentProfile;
    if (id != null && isCreator != null && profile != null) {
      _sessionRef = _db.ref('sessions/$id');

      // Fetch meta data
      final snapshot = await _sessionRef!.child('meta').get();
      if (!snapshot.exists) return;

      final metaData = snapshot.value as Map<dynamic, dynamic>;
      
      // Always use the profile's current name
      final name = profile.displayName;
      final friendName = isCreator ? metaData['joinerName'] : metaData['creatorName'];
      final friendCharIndex = isCreator
          ? metaData['joinerCharacter'] ?? 1
          : metaData['creatorCharacter'] ?? 0;

      _currentSession = Session(
        id: id,
        userName: name,
        friendName: friendName,
        isCreator: isCreator,
        character: CharacterType.values[charIndex],
        friendCharacter: CharacterType.values[friendCharIndex],
      );
      
      // Update the session meta with the latest profile data
      await _sessionRef!.child('meta').update({
        isCreator ? 'creatorName' : 'joinerName': name,
        isCreator ? 'creatorCharacter' : 'joinerCharacter': profile.avatarIndex,
      });
    }
  }

  /// Validate existing session
  Future<void> restoreAndValidateSession() async {
    await restoreSessionIfExists();
    if (isConnected) {
      final snapshot = await _sessionRef!.get();
      if (!snapshot.exists) {
        await leaveSession();
      }
    }
  }

  Future<void> updateMeta(Map<String, dynamic> updates) async {
    if (_sessionRef == null) return;
    await _sessionRef!.child('meta').update(updates);
  }

  /// Leave session
  Future<void> leaveSession() async {
    if (_sessionRef != null && _currentSession != null) {
      // Record match result if applicable
      try {
        final meta = await _sessionRef!.child('meta').get();
        if (meta.exists && meta.value != null) {
          final metaData = meta.value as Map<dynamic, dynamic>;
          final creatorUid = metaData['creatorUid'] as String?;
          final joinerUid = metaData['joinerUid'] as String?;
          
          if (creatorUid != null && joinerUid != null) {
            // Both users joined, match was completed
            // This is a simplified example - need to actually determine the winner
            await _recordMatchResult();
          }
        }
      } catch (e) {
        debugPrint('Error recording match result: $e');
      }
    }
    
    _sessionRef = null;
    _currentSession = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('bookduel_session_id');
    await prefs.remove('bookduel_user_name');
    await prefs.remove('bookduel_is_creator');
    await prefs.remove('bookduel_character');
  }
  
  /// Record the match result for profile stats
  Future<void> _recordMatchResult() async {
    // Skip if profile service is not ready
    if (ProfileService.instance.uid == null || _currentSession == null) return;

    try {
      final meta = await _sessionRef!.child('meta').get();
      if (!meta.exists) return;

      final metaData = meta.value as Map<dynamic, dynamic>;
      final creatorUid = metaData['creatorUid'] as String?;
      final joinerUid = metaData['joinerUid'] as String?;
      final creatorName = metaData['creatorName'] as String?;
      final joinerName = metaData['joinerName'] as String?;

      if (creatorUid == null || joinerUid == null || creatorName == null || joinerName == null) {
        return;
      }

      final opponentUid = isCreator ? joinerUid : creatorUid;
      final opponentName = isCreator ? joinerName : creatorName;

      // 1) add the match to the profile
      await ProfileService.instance.recordMatch(
        MatchRecord(
          sessionId: _currentSession!.id,
          opponentUid: opponentUid,
          opponentName: opponentName,
          timestamp: DateTime.now(),
          result: MatchResult.draw,   // or win/loss
          pointsEarned: 10,           // your logic
          xpEarned: 25,               // your logic
        ),
      );

      // 2) bump today’s “match” in the activity heatmap
      await ActivityService.instance.recordActivity(ActivityType.match);

    } catch (e) {
      debugPrint('Error recording match result: $e');
    }
  }

  /// Add book
  Future<void> addBook(bool isYou, Book book) async {
    if (_sessionRef == null || _currentSession == null) return;

    // 1) Enrich both coverUrl & pageCount in one shot
    final meta = await BookCoverService()
        .fetchBookMetadata(book.title, book.author);
    book = book.copyWith(
      coverUrl: book.coverUrl ?? meta['coverUrl'] as String?,
      pageCount: meta['pageCount'] as int?,
    );

    // 2) Figure out which node to write to
    final addToCreatorBooks = (isYou && isCreator) || (!isYou && !isCreator);
    final ref = addToCreatorBooks
        ? _sessionRef!.child("creatorBooks")
        : _sessionRef!.child("joinerBooks");

    // 3) Push the full map (now including pageCount)
    await ref.push().set(book.toMap());
  }

  /// Book parsing
  Future<List<Book>> parseAndEnhanceBooks(dynamic data) async {
    if (data == null) return [];
    final map = Map<String, dynamic>.from(data);

    final parsed = map.entries.map((e) {
      final bookData = Map<String, dynamic>.from(e.value);
      return Book.fromMap({...bookData, 'id': e.key});
    }).toList();

    return await BookCoverService().enhanceBooksWithCovers(parsed);
  }

  /// Edit book
  Future<void> editBook(bool isYou, Book updatedBook) async {
    if (_sessionRef == null || _currentSession == null) return;

    // 1) Enrich missing fields just like addBook
    final meta = await BookCoverService()
        .fetchBookMetadata(updatedBook.title, updatedBook.author);
    updatedBook = updatedBook.copyWith(
      coverUrl: updatedBook.coverUrl ?? meta['coverUrl'] as String?,
      pageCount: updatedBook.pageCount ?? meta['pageCount'] as int?,
    );

    // 2) Target the correct child node
    final targetCreator = (isYou && isCreator) || (!isYou && !isCreator);
    final node = targetCreator
        ? _sessionRef!.child("creatorBooks")
        : _sessionRef!.child("joinerBooks");

    // 3) Overwrite at the existing key (so the id stays the same)
    await node.child(updatedBook.id).set(updatedBook.toMap());
  }

  Future<void> deleteBook(bool isYou, Book book) async {
    if (_sessionRef == null || _currentSession == null) return;

    final bool targetCreator = (isYou && isCreator) || (!isYou && !isCreator);
    final ref = targetCreator
        ? _sessionRef!.child("creatorBooks").child(book.id)
        : _sessionRef!.child("joinerBooks").child(book.id);

    await ref.remove();
  }

  /// Live updates
  Stream<DatabaseEvent>? get sessionStream =>
      _sessionRef?.onValue;

  /// Local persistence
  Future<void> _persistSession() async {
    if (_currentSession == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('bookduel_session_id', _currentSession!.id);
    await prefs.setString('bookduel_user_name', _currentSession!.userName);
    await prefs.setBool('bookduel_is_creator', _currentSession!.isCreator);
    await prefs.setInt('bookduel_character', _currentSession!.character?.index ?? 0);
  }

  /// Code generator
  String _generateFriendCode({int length = 6}) {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    final rand = Random();
    return List.generate(length, (_) => chars[rand.nextInt(chars.length)]).join();
  }
}