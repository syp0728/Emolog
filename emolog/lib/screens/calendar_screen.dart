/// lib/screens/calendar_screen.dart
import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../models/daily_journal.dart';
import '../widgets/common_drawer.dart';
import '../models/music_data.dart';
import '../models/emotion_images.dart';
import '../providers/journal_provider.dart';
import 'dart:math';
import 'package:intl/intl.dart';

/// 날짜 비교 함수
bool isSameDay(DateTime date1, DateTime date2) {
  return date1.year == date2.year &&
      date1.month == date2.month &&
      date1.day == date2.day;
}

/// 감정에 따라 추천 음악과 요약을 보여주는 BottomSheet 위젯
class MusicBottomSheet extends StatelessWidget {
  final DailyJournal journal;
  final Random _random;

  MusicBottomSheet({super.key, required this.journal}) : _random = Random();

  @override
  Widget build(BuildContext context) {
    if (journal.emotion == 'none') {
      return const SizedBox.shrink();
    }

    final musicList =
        musicData
            .firstWhere(
              (data) =>
                  data.emotion.toLowerCase() == journal.emotion.toLowerCase(),
              orElse: () => musicData.first,
            )
            .songs;

    final selectedSong = musicList[_random.nextInt(musicList.length)];
    final parts = selectedSong.split(' - ');
    final title = parts[0];
    final artist = parts.length > 1 ? parts[1] : 'Unknown Artist';
    final album = parts.length > 2 ? parts[2] : title.toLowerCase();

    final formattedDate =
        '${journal.date.year}.${journal.date.month.toString().padLeft(2, '0')}.${journal.date.day.toString().padLeft(2, '0')}';

    return Container(
      width: MediaQuery.of(context).size.width * 0.95,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// 상단: 날짜 표시
          Center(
            child: Text(
              formattedDate,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 16),

          /// 중간: 감정 이미지와 요약
          Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    image: DecorationImage(
                      image: AssetImage(
                        'lib/src/${journal.emotion.toLowerCase()}.png',
                      ),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    journal.summary,
                    style: Theme.of(context).textTheme.bodyLarge,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          /// 하단: 음악 추천 카드
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        image: DecorationImage(
                          image: AssetImage(
                            'lib/src/${album.toLowerCase()}.png',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            artist,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                // const SizedBox(height: 12),
                // Text(
                //   // '감정에 딱 맞는 곡을 찾아보세요.',
                //   // style: Theme.of(context).textTheme.bodySmall,
                // ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          /// 닫기 버튼
          Align(
            alignment: Alignment.centerRight,
            child: IconButton(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    );
  }
}

/// 달력에서 날짜 선택 시 해당 날짜의 감정일기를 보여주는 화면
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _selectedDate;

  // @override
  // void initState() {
  //   super.initState();
  //   _selectedDate = DateTime.now();
  // }

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();

    // WidgetsBinding을 이용해 프레임이 완료된 후 showModalBottomSheet 실행
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final journalProvider = context.read<JournalProvider>();
      final today = DateTime.now();
      final journal = journalProvider.getJournalForDate(today);

      if (journal.emotion != 'none') {
        showModalBottomSheet(
          context: context,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(40)),
          ),
          builder: (_) => MusicBottomSheet(journal: journal),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final journalProvider = context.watch<JournalProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: const Color(0xFFA783E1),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      drawer: const CommonDrawer(),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: TableCalendar(
              firstDay: DateTime.utc(2020, 1, 1),
              lastDay: DateTime.utc(2030, 12, 31),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(day, _selectedDate),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() => _selectedDate = selectedDay);
                final journal = journalProvider.getJournalForDate(selectedDay);
                if (journal.emotion != 'none') {
                  showModalBottomSheet(
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(40),
                      ),
                    ),
                    builder: (_) => MusicBottomSheet(journal: journal),
                  );
                }
              },
              onPageChanged: (focusedDay) {
                setState(() => _selectedDate = focusedDay);
              },
              daysOfWeekHeight: 50,
              calendarStyle: const CalendarStyle(
                cellMargin: EdgeInsets.zero,
                cellPadding: EdgeInsets.zero,
                markersAlignment: Alignment.bottomCenter,
                defaultTextStyle: TextStyle(color: Colors.black),
                todayDecoration: BoxDecoration(
                  color: Colors.blueAccent,
                  shape: BoxShape.circle,
                ),
                selectedDecoration: BoxDecoration(
                  color: Colors.deepPurple,
                  shape: BoxShape.circle,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekendStyle: TextStyle(
                  color: Colors.purple.shade300,
                  fontWeight: FontWeight.w600,
                ),
                weekdayStyle: const TextStyle(
                  color: Colors.black87,
                  fontWeight: FontWeight.w600,
                ),
              ),
              headerStyle: const HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                titleTextStyle: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
                leftChevronIcon: Icon(Icons.chevron_left, color: Colors.black),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: Colors.black,
                ),
              ),
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, _) {
                  final journal = journalProvider.getJournalForDate(date);
                  if (journal.emotion != 'none') {
                    return Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      child: Center(
                        child: Container(
                          width: 18,
                          height: 18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(9),
                            image: DecorationImage(
                              image: AssetImage(
                                'lib/src/${journal.emotion.toLowerCase()}.png',
                              ),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
