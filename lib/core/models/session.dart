// lib/models/session.dart
import 'character.dart';

class Session {
  final String id;
  final String userName;
  final String? friendName;
  final bool isCreator;

  CharacterType? character;        // mutable for live updates
  CharacterType? friendCharacter;  // mutable for live updates

  Session({
    required this.id,
    required this.userName,
    this.friendName,
    required this.isCreator,
    this.character,
    this.friendCharacter,
  });

  factory Session.fromMap(String id, Map<dynamic, dynamic> data, bool isCreator) {
    final userName = isCreator ? data['creatorName'] ?? '' : data['joinerName'] ?? '';
    final friendName = isCreator ? data['joinerName'] : data['creatorName'];
    final characterIndex = isCreator ? data['creatorCharacter'] ?? 0 : data['joinerCharacter'] ?? 1;
    final friendCharIndex = isCreator ? data['joinerCharacter'] ?? 1 : data['creatorCharacter'] ?? 0;

    return Session(
      id: id,
      userName: userName,
      friendName: friendName,
      isCreator: isCreator,
      character: CharacterType.values[characterIndex],
      friendCharacter: CharacterType.values[friendCharIndex],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'sessionId': id,
      'userName': userName,
      'friendName': friendName,
      'isCreator': isCreator,
      'character': character?.index,
      'friendCharacter': friendCharacter?.index,
    };
  }
}
