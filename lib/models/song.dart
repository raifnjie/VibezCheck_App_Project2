class Song {
  final String id;
  final String title;
  final String artist;
  final String mood;
  int votes;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    required this.mood,
    this.votes = 0,
  });

  int get recommendationScore {
    int moodBonus = mood == 'hype' || mood == 'chill' ? 2 : 1;
    return (votes * 2) + moodBonus;
  }
}