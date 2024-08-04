// models/word.dart
class Word {
  final int id;
  final String word;
  final String meaning;
  final int listId;
  int favorite;  // Store as an integer for database compatibility

  Word({
    required this.id,
    required this.word,
    required this.meaning,
    required this.listId,
    this.favorite = 0,  // Default to 0 (not favorite)
  });

  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'] as int,
      word: map['word'] as String,
      meaning: map['meaning'] as String,
      listId: map['list_id'] as int,
      favorite: map['favorite'] as int,  // Store favorite as integer
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'meaning': meaning,
      'list_id': listId,
      'favorite': favorite,  // Directly store integer value
    };
  }

  bool isFavorite() {
    return favorite == 1;  // Helper method to check if favorite
  }

  void toggleFavorite() {
    favorite = favorite == 1 ? 0 : 1;  // Toggle favorite status
  }
}
