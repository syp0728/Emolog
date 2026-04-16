/// lib/models/music_data.dart

class MusicData {
  final String emotion;
  final List<String> songs;

  MusicData({required this.emotion, required this.songs});
}

// 각 감정별 음악 리스트
final List<MusicData> musicData = [
  MusicData(
    emotion: 'positive',
    songs: [
      'Happy - Pharrell Williams',
      'Walking on Sunshine - Katrina & The Waves',
      'Good Day - IU',
      'Can\'t Stop the Feeling! - Justin Timberlake',
      'Here Comes the Sun - The Beatles',
    ],
  ),
  MusicData(
    emotion: 'negative',
    songs: [
      'Someone Like You - Adele',
      'Fix You - Coldplay',
      'Lost Stars - Adam Levine',
      'Lonely - Justin Bieber',
      'Let Her Go - Passenger',
    ],
  ),
  MusicData(
    emotion: 'neutral',
    songs: [
      'Photograph - Ed Sheeran',
      'Banana Pancakes - Jack Johnson',
      'River Flows in You - Yiruma',
      'Lost in Japan - Shawn Mendes',
      'Vienna - Billy Joel',
    ],
  ),
];
