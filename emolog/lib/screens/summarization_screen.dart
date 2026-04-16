import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/daily_journal.dart';
import '../widgets/common_drawer.dart';
import '../providers/journal_provider.dart';

class SummarizationScreen extends StatefulWidget {
  const SummarizationScreen({super.key});

  @override
  State<SummarizationScreen> createState() => _SummarizationScreenState();
}

class _SummarizationScreenState extends State<SummarizationScreen> {
  int selectedYear = DateTime.now().year;
  int selectedMonth = DateTime.now().month;
  String expandedEmotion = ''; // Track expanded emotion type

  @override
  Widget build(BuildContext context) {
    final journalProvider = context.watch<JournalProvider>();

    final filteredJournals =
        journalProvider.journalList.where((j) {
          return j.date.year == selectedYear && j.date.month == selectedMonth;
        }).toList();

    final emotionCounts = {
      'positive': filteredJournals.where((j) => j.emotion == 'positive').length,
      'negative': filteredJournals.where((j) => j.emotion == 'negative').length,
      'neutral': filteredJournals.where((j) => j.emotion == 'neutral').length,
    };

    final total = emotionCounts.values.fold(0, (sum, e) => sum + e);

    List<PieChartSectionData> showingSections() {
      if (total == 0) return [];
      return emotionCounts.entries.map((entry) {
        final color = switch (entry.key) {
          'positive' => const Color(0xFFF2BF27),
          'neutral' => const Color(0xFF67BF63),
          'negative' => const Color(0xFF94A2F2),
          _ => Colors.grey,
        };

        return PieChartSectionData(
          value: entry.value.toDouble(),
          title: '',
          color: color,
          radius: 40,
        );
      }).toList();
    }

    Widget emotionButton(
      String label,
      String emotion,
      Color color,
      String imagePath,
    ) {
      return GestureDetector(
        onTap: () {
          setState(() {
            expandedEmotion = expandedEmotion == emotion ? '' : emotion;
          });
        },
        child: Column(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: color.withOpacity(0.2),
              backgroundImage: AssetImage(imagePath),
            ),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 16)),
          ],
        ),
      );
    }

    Widget emotionRecordList(String emotion, Color color) {
      final entries =
          filteredJournals.where((j) => j.emotion == emotion).toList();

      return Column(
        children:
            entries
                .map(
                  (j) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: ListTile(
                      leading: Icon(Icons.circle, size: 12, color: color),
                      title: Text(j.summary),
                      subtitle: Text(
                        '${j.date.year}-${j.date.month.toString().padLeft(2, '0')}-${j.date.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                )
                .toList(),
      );
    }

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        title: const Text('Summary'),
        backgroundColor: const Color(0xFFA783E1),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.w500,
        ),
      ),
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 24),
            const Text(
              'Summary of your emotion',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                DropdownButton<int>(
                  value: selectedYear,
                  onChanged: (val) => setState(() => selectedYear = val!),
                  items: List.generate(5, (i) {
                    final year = DateTime.now().year - i;
                    return DropdownMenuItem(value: year, child: Text('$year'));
                  }),
                ),
                const SizedBox(width: 16),
                DropdownButton<int>(
                  value: selectedMonth,
                  onChanged: (val) => setState(() => selectedMonth = val!),
                  items: List.generate(12, (i) {
                    return DropdownMenuItem(
                      value: i + 1,
                      child: Text('${i + 1}월'),
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (total > 0) ...[
              SizedBox(
                height: 160,
                child: PieChart(
                  PieChartData(
                    sections: showingSections(),
                    centerSpaceRadius: 50,
                    sectionsSpace: 2,
                    borderData: FlBorderData(show: false),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Column(
                children: [
                  _buildLegendRow(
                    const Color(0xFFF2BF27),
                    'Positive',
                    (emotionCounts['positive']! * 100 ~/ total),
                  ),
                  _buildLegendRow(
                    const Color(0xFF67BF63),
                    'Neutral',
                    (emotionCounts['neutral']! * 100 ~/ total),
                  ),
                  _buildLegendRow(
                    const Color(0xFF94A2F2),
                    'Negative',
                    (emotionCounts['negative']! * 100 ~/ total),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              const Divider(),
              const Text(
                'Emotion Records',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  emotionButton(
                    'Positive',
                    'positive',
                    const Color(0xFFF2BF27),
                    'lib/src/positive.png',
                  ),
                  emotionButton(
                    'Neutral',
                    'neutral',
                    const Color(0xFF67BF63),
                    'lib/src/neutral.png',
                  ),
                  emotionButton(
                    'Negative',
                    'negative',
                    const Color(0xFF94A2F2),
                    'lib/src/negative.png',
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (expandedEmotion == 'positive')
                emotionRecordList('positive', const Color(0xFFF2BF27)),
              if (expandedEmotion == 'neutral')
                emotionRecordList('neutral', const Color(0xFF67BF63)),
              if (expandedEmotion == 'negative')
                emotionRecordList('negative', const Color(0xFF94A2F2)),
              const SizedBox(height: 24),
              const Center(
                child: Text(
                  'Support mail - lizxxyn@handong.ac.kr',
                  style: TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ),
            ] else ...[
              const SizedBox(height: 12),
              const Text('No data for this month.'),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildLegendRow(Color color, String label, int percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 12, height: 12, color: color),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 8),
          Text(
            '$percent%',
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
