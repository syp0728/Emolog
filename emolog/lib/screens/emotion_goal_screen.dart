import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import '../widgets/common_drawer.dart';

class EmotionGoalScreen extends StatefulWidget {
  const EmotionGoalScreen({super.key});

  @override
  State<EmotionGoalScreen> createState() => _EmotionGoalScreenState();
}

class _EmotionGoalScreenState extends State<EmotionGoalScreen> {
  final TextEditingController _goalController = TextEditingController();
  List<String> _goals = []; // 여러 개의 목표
  Map<String, List<String>> _checkedDatesPerGoal =
      {}; // {goal: [yyyy-MM-dd, ...]}

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGoals = prefs.getStringList('emotion_goals') ?? [];
    final checkedMap = <String, List<String>>{};

    for (final goal in savedGoals) {
      final checkedDates = prefs.getStringList('checked_$goal') ?? [];
      checkedMap[goal] = checkedDates;
    }

    setState(() {
      _goals = savedGoals;
      _checkedDatesPerGoal = checkedMap;
    });
  }

  Future<void> _saveGoal() async {
    final newGoal = _goalController.text.trim();
    if (newGoal.isEmpty || _goals.contains(newGoal)) return;

    final prefs = await SharedPreferences.getInstance();
    final updatedGoals = [..._goals, newGoal];
    await prefs.setStringList('emotion_goals', updatedGoals);
    await prefs.setStringList('checked_$newGoal', []);

    setState(() {
      _goals.add(newGoal);
      _checkedDatesPerGoal[newGoal] = [];
    });

    _goalController.clear();
  }

  Future<void> _toggleDate(String goal, String dateStr) async {
    final prefs = await SharedPreferences.getInstance();
    final checkedDates = _checkedDatesPerGoal[goal] ?? [];

    setState(() {
      if (checkedDates.contains(dateStr)) {
        checkedDates.remove(dateStr);
      } else {
        checkedDates.add(dateStr);
      }
      _checkedDatesPerGoal[goal] = checkedDates;
    });

    await prefs.setStringList('checked_$goal', checkedDates);
  }

  List<DateTime> getThisWeekDates() {
    final today = DateTime.now();
    final monday = today.subtract(Duration(days: today.weekday - 1));
    return List.generate(7, (i) => monday.add(Duration(days: i)));
  }

  @override
  Widget build(BuildContext context) {
    final thisWeek = getThisWeekDates();
    final dateFormatter = DateFormat('yyyy-MM-dd');
    final dayLabel = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Scaffold(
      drawer: const CommonDrawer(),
      appBar: AppBar(
        title: const Text('Emotion Goals'),
        backgroundColor: const Color(0xFFA783E1),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 20),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add a new goal',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _goalController,
                    decoration: const InputDecoration(
                      hintText: 'e.g., Smile more today',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _saveGoal,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFA783E1),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            if (_goals.isEmpty)
              const Text('No goals yet.')
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _goals.length,
                  itemBuilder: (context, index) {
                    final goal = _goals[index];
                    final checkedDates = _checkedDatesPerGoal[goal] ?? [];
                    bool isEditing = false;
                    final editController = TextEditingController(text: goal);

                    return StatefulBuilder(
                      builder: (context, setInnerState) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                if (isEditing)
                                  Expanded(
                                    child: TextField(
                                      controller: editController,
                                      autofocus: true,
                                      onSubmitted: (newValue) async {
                                        final newGoal = newValue.trim();
                                        if (newGoal.isEmpty ||
                                            _goals.contains(newGoal))
                                          return;

                                        final prefs =
                                            await SharedPreferences.getInstance();

                                        // 저장소 갱신
                                        _goals[index] = newGoal;
                                        _checkedDatesPerGoal[newGoal] =
                                            _checkedDatesPerGoal[goal] ?? [];
                                        _checkedDatesPerGoal.remove(goal);

                                        await prefs.setStringList(
                                          'emotion_goals',
                                          _goals,
                                        );
                                        await prefs.setStringList(
                                          'checked_$newGoal',
                                          _checkedDatesPerGoal[newGoal]!,
                                        );
                                        await prefs.remove('checked_$goal');

                                        setState(() {});
                                        setInnerState(() => isEditing = false);
                                      },
                                    ),
                                  )
                                else
                                  Expanded(
                                    child: Text(
                                      '🎯 $goal',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                IconButton(
                                  icon: const Icon(Icons.edit, size: 20),
                                  onPressed: () {
                                    setInnerState(() => isEditing = true);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                    size: 20,
                                  ),
                                  onPressed: () async {
                                    final prefs =
                                        await SharedPreferences.getInstance();
                                    setState(() {
                                      _goals.removeAt(index);
                                      _checkedDatesPerGoal.remove(goal);
                                    });
                                    await prefs.setStringList(
                                      'emotion_goals',
                                      _goals,
                                    );
                                    await prefs.remove('checked_$goal');
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Wrap(
                              spacing: 8,
                              runSpacing: 8,
                              children: List.generate(7, (i) {
                                final date = thisWeek[i];
                                final dateStr = dateFormatter.format(date);
                                final isChecked = checkedDates.contains(
                                  dateStr,
                                );

                                return GestureDetector(
                                  onTap: () => _toggleDate(goal, dateStr),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      color:
                                          isChecked
                                              ? const Color(0xFFA783E1)
                                              : Colors.grey[300],
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            dayLabel[i],
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  isChecked
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                          const SizedBox(height: 6),
                                          Text(
                                            '${date.day}',
                                            style: TextStyle(
                                              fontSize: 18,
                                              color:
                                                  isChecked
                                                      ? Colors.white
                                                      : Colors.black,
                                            ),
                                          ),
                                          if (isChecked)
                                            const Icon(
                                              Icons.check,
                                              color: Colors.white,
                                              size: 16,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: 24),
                          ],
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
