// lib/providers/journal_provider.dart
import 'package:flutter/material.dart';
import 'dart:math';
import '../models/daily_journal.dart';

class JournalProvider extends ChangeNotifier {
  final List<DailyJournal> _journalList = [];

  List<DailyJournal> get journalList => _journalList;

  JournalProvider() {
    _journalList.addAll(_generateDummyData());
  }

  List<DailyJournal> _generateDummyData() {
    final now = DateTime.now();
    final random = Random();
    final emotions = ['positive', 'negative', 'neutral'];
    final summaries = {
      'positive': [
        'I had a great day today!',
        'Something good happened to me.',
        'I felt energized and happy.',
        'Things went better than expected!',
      ],
      'negative': [
        'It was a really frustrating day.',
        'I felt down and tired.',
        'Nothing seemed to go right.',
        'I felt lonely and sad today.',
      ],
      'neutral': [
        'It was just an ordinary day.',
        'Nothing special happened.',
        'It was quiet and uneventful.',
        'The day went by quickly.',
      ],
    };

    return List.generate(30, (i) {
      final day = now.subtract(Duration(days: 30 - (i + 1)));
      final emotion = emotions[random.nextInt(3)];
      final summaryList = summaries[emotion]!;
      final summary = summaryList[random.nextInt(summaryList.length)];

      return DailyJournal(
        date: DateTime(day.year, day.month, day.day),
        summary: summary,
        emotion: emotion,
      );
    });
  }

  DailyJournal getJournalForDate(DateTime day) {
    // Check if we have a journal entry for this exact date
    try {
      return _journalList.firstWhere(
        (j) => j.date.year == day.year &&
              j.date.month == day.month &&
              j.date.day == day.day,
      );
    } catch (e) {
      // No entry found for this date, return a default one
      return DailyJournal(date: day, summary: '', emotion: 'none');
    }
  }

  void addJournal(DailyJournal journal) {
    // 동일한 날짜의 기존 기록 제거
    _journalList.removeWhere(
      (j) =>
          j.date.year == journal.date.year &&
          j.date.month == journal.date.month &&
          j.date.day == journal.date.day,
    );

    _journalList.add(journal);
    notifyListeners(); // 상태 변경 알림
  }

  void updateTodayJournal(String summary, String emotion) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    addJournal(DailyJournal(date: today, summary: summary, emotion: emotion));
  }
}
