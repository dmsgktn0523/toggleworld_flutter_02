// models/word.dart
class Word {
  final int id;
  final String word;
  final String meaning;
  final int listId;
  bool favorite;

  Word({
    required this.id,
    required this.word,
    required this.meaning,
    required this.listId,
    this.favorite = false,
  });

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      meaning: map['meaning'],
      listId: map['list_id'],
      favorite: map['favorite'] == 1,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'list_id': listId,
      'favorite': favorite ? 1 : 0,
    };
  }
}
