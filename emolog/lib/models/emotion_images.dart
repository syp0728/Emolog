import 'package:flutter/material.dart';

class EmotionImages {
  static const Map<String, String> emotionToImage = {
    'positive': 'lib/src/positive.png',
    'negative': 'lib/src/negative.png',
    'neutral': 'lib/src/neutral.png',
  };

  static String getImagePath(String emotion) {
    return emotionToImage[emotion.toLowerCase()] ?? 'lib/src/neutral.png';
  }
}
