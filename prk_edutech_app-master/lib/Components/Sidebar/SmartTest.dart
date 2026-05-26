import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing1/constants.dart';

void main() {
  runApp(MyQuizApp());
}

class MyQuizApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFF000435),
        scaffoldBackgroundColor: Color(0xFF000435),
      ),
      home: SmartTestPage(),
    );
  }
}

class SmartTestPage extends StatefulWidget {
  @override
  _SmartTestPageState createState() => _SmartTestPageState();
}

class _SmartTestPageState extends State<SmartTestPage> {
  List<Map<String, dynamic>> tests = [];
  bool isLoading = true;
  String _selectedTopic = 'All Topics';
  String _selectedSort = 'Latest';

  @override
  void initState() {
    super.initState();
    fetchTests();
  }

  Future<void> fetchTests() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('tests/')),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> rawTests = decoded is List
            ? decoded
            : (decoded is Map<String, dynamic> && decoded['data'] is List)
                ? decoded['data'] as List<dynamic>
                : (decoded is Map<String, dynamic> && decoded['tests'] is List)
                    ? decoded['tests'] as List<dynamic>
                    : <dynamic>[];
        setState(() {
          tests = rawTests
              .whereType<Map<String, dynamic>>()
              .where((test) => _stringOrFallback(test['_id']).isNotEmpty)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Failed to load tests');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFDFA408),
      ),
    );
  }

  static String _stringOrFallback(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static int _intOrZero(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _titleCaseOrFallback(dynamic value, {String fallback = ''}) {
    final input = _stringOrFallback(value, fallback: fallback).toLowerCase();
    if (input.isEmpty) return fallback;
    return input
        .split(' ')
        .map(
          (part) => part.isEmpty
              ? part
              : '${part[0].toUpperCase()}${part.substring(1)}',
        )
        .join(' ');
  }

  String _topicOf(Map<String, dynamic> test) {
    return _stringOrFallback(
      test['topic'],
      fallback: _stringOrFallback(test['testType'], fallback: 'General'),
    );
  }

  String _categoryOf(Map<String, dynamic> test) {
    return _stringOrFallback(
      test['category'],
      fallback: _stringOrFallback(test['subject'], fallback: 'General'),
    );
  }

  int _questionCountOf(Map<String, dynamic> test) {
    final questions = _intOrZero(
      test['questionCount'] ?? test['totalQuestions'] ?? test['noOfQuestions'],
    );
    return questions == 0 ? 10 : questions;
  }

  int _marksOf(Map<String, dynamic> test) {
    final marks = _intOrZero(test['marks']);
    return marks == 0 ? _questionCountOf(test) : marks;
  }

  int _attemptsOf(Map<String, dynamic> test) {
    final attempts = _intOrZero(test['attempts']);
    if (attempts != 0) return attempts;
    final attemptCount = _intOrZero(test['attemptCount']);
    return attemptCount == 0 ? 1 : attemptCount;
  }

  String _difficultyOf(Map<String, dynamic> test) {
    return _titleCaseOrFallback(test['difficulty'], fallback: 'Medium');
  }

  List<String> get _topics {
    final topicSet = tests.map(_topicOf).toSet();
    final topicList = topicSet.where((topic) => topic.isNotEmpty).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['All Topics', ...topicList];
  }

  List<Map<String, dynamic>> get _visibleTests {
    final filtered = _selectedTopic == 'All Topics'
        ? List<Map<String, dynamic>>.from(tests)
        : tests.where((test) => _topicOf(test) == _selectedTopic).toList();

    if (_selectedSort == 'Duration') {
      filtered.sort((a, b) =>
          _intOrZero(b['duration']).compareTo(_intOrZero(a['duration'])));
    } else if (_selectedSort == 'Title') {
      filtered.sort((a, b) => _stringOrFallback(a['title'])
          .toLowerCase()
          .compareTo(_stringOrFallback(b['title']).toLowerCase()));
    } else {
      filtered.sort(
        (a, b) =>
            _stringOrFallback(b['_id']).compareTo(_stringOrFallback(a['_id'])),
      );
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF0B123F),
        elevation: 0,
        toolbarHeight: 88,
        centerTitle: false,
        titleSpacing: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Available Tests',
              style: TextStyle(
                fontSize: 31,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0B123F),
              ),
            ),
            Text(
              'Choose a test and evaluate your knowledge',
              style: TextStyle(
                fontSize: 13,
                color: Color(0xFF61697A),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFFF2F4FA),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.search, color: Color(0xFF1A2140)),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFfb7e02),
              ),
            )
          : _visibleTests.isEmpty
              ? const Center(child: Text('Coming soon'))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SmartFilterDropdown(
                              value: _selectedTopic,
                              items: _topics,
                              onChanged: (value) {
                                setState(() {
                                  _selectedTopic = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SmartFilterDropdown(
                              value: _selectedSort,
                              items: const ['Latest', 'Duration', 'Title'],
                              onChanged: (value) {
                                setState(() {
                                  _selectedSort = value;
                                });
                              },
                              prefix: 'Sort by: ',
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: const Color(0xFFF2F4FA),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.tune,
                              color: Color(0xFF4E5670),
                              size: 22,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: fetchTests,
                        color: const Color(0xFFfb7e02),
                        child: ListView.builder(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemCount: _visibleTests.length,
                          itemBuilder: (context, index) {
                            final test = _visibleTests[index];
                            return _SmartTestCard(
                              index: index,
                              title: _stringOrFallback(
                                test['title'],
                                fallback: _stringOrFallback(test['name'],
                                    fallback: 'Untitled Test'),
                              ),
                              category: _categoryOf(test),
                              topic: _topicOf(test),
                              description: _stringOrFallback(
                                test['description'],
                                fallback: 'No description available',
                              ),
                              duration: _intOrZero(test['duration']),
                              questionCount: _questionCountOf(test),
                              marks: _marksOf(test),
                              difficulty: _difficultyOf(test),
                              attempts: _attemptsOf(test),
                              onStart: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => QuizScreen(
                                      testId: _stringOrFallback(test['_id']),
                                      testTitle: _stringOrFallback(
                                        test['title'],
                                        fallback: _stringOrFallback(
                                          test['name'],
                                          fallback: 'Test',
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}

class _SmartFilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String? prefix;

  const _SmartFilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
    this.prefix,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4FA),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items.contains(value) ? value : items.first,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFF535B74)),
          style: const TextStyle(
            color: Color(0xFF2C3355),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          onChanged: (newValue) {
            if (newValue != null) {
              onChanged(newValue);
            }
          },
          items: items.map((item) {
            return DropdownMenuItem(
              value: item,
              child: Text(
                '${prefix ?? ''}$item',
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SmartTestCard extends StatelessWidget {
  final int index;
  final String title;
  final String category;
  final String topic;
  final String description;
  final int duration;
  final int questionCount;
  final int marks;
  final String difficulty;
  final int attempts;
  final VoidCallback onStart;

  const _SmartTestCard({
    required this.index,
    required this.title,
    required this.category,
    required this.topic,
    required this.description,
    required this.duration,
    required this.questionCount,
    required this.marks,
    required this.difficulty,
    required this.attempts,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final bool filledButton = index.isEven;
    final Color accent =
        index.isEven ? const Color(0xFF6C4DFF) : const Color(0xFF5EC68A);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: accent.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child:
                      Icon(Icons.assignment_outlined, color: accent, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 17,
                          color: Color(0xFF0B123F),
                          fontWeight: FontWeight.w800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 5),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F7EC),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          category,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF47A96E),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFF2E8),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.access_time_rounded,
                          color: Color(0xFFEE8A2E), size: 18),
                      const SizedBox(width: 4),
                      Text(
                        '$duration min',
                        style: const TextStyle(
                          color: Color(0xFFEE8A2E),
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Divider(
                color: const Color(0xFFDFE3EE).withOpacity(0.9), thickness: 1),
            const SizedBox(height: 12),
            _detailLine(
              icon: Icons.list_alt_rounded,
              label: 'Topic',
              value: topic,
              iconColor: const Color(0xFF7A60FC),
            ),
            const SizedBox(height: 10),
            _detailLine(
              icon: Icons.menu_book_outlined,
              label: 'Description',
              value: description,
              iconColor: const Color(0xFF7A60FC),
            ),
            const SizedBox(height: 12),
            Divider(
                color: const Color(0xFFDFE3EE).withOpacity(0.9), thickness: 1),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _statItem(
                    icon: Icons.help_outline_rounded,
                    iconColor: const Color(0xFF7A60FC),
                    value: '$questionCount',
                    label: 'Questions',
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _statItem(
                    icon: Icons.check_circle_outline_rounded,
                    iconColor: const Color(0xFF46B67E),
                    value: '$marks',
                    label: 'Marks',
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _statItem(
                    icon: Icons.equalizer_rounded,
                    iconColor: const Color(0xFF3A84FF),
                    value: difficulty,
                    label: 'Difficulty',
                  ),
                ),
                _verticalDivider(),
                Expanded(
                  child: _statItem(
                    icon: Icons.history_toggle_off_rounded,
                    iconColor: const Color(0xFFE75A9D),
                    value: '$attempts',
                    label: attempts <= 1 ? 'Attempt' : 'Attempts',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow_rounded, size: 22),
                label: const Text(
                  'Start Test',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                style: ElevatedButton.styleFrom(
                  elevation: 0,
                  backgroundColor:
                      filledButton ? const Color(0xFFFB8700) : Colors.white,
                  foregroundColor:
                      filledButton ? Colors.white : const Color(0xFFFB8700),
                  side: const BorderSide(color: Color(0xFFF3A658), width: 1.2),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(26)),
                ),
                onPressed: onStart,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailLine({
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            color: iconColor.withOpacity(0.12),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: iconColor),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF61697A),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 1),
              Text(
                value.isEmpty ? '-' : value,
                style: const TextStyle(
                  fontSize: 16,
                  color: Color(0xFF1A2140),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _statItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Column(
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(height: 4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 24,
            color: Color(0xFF111938),
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: Color(0xFF61697A),
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _verticalDivider() {
    return Container(
      width: 1,
      height: 46,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      color: const Color(0xFFE6E9F1),
    );
  }
}

class QuizScreen extends StatefulWidget {
  final String testId;
  final String testTitle;

  const QuizScreen({
    Key? key,
    required this.testId,
    required this.testTitle,
  }) : super(key: key);

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  Map<String, dynamic>? testData;
  bool isLoading = true;
  int currentQuestionIndex = 0;
  Map<int, String?> selectedAnswers = {};

  @override
  void initState() {
    super.initState();
    fetchTestDetails();
  }

  Future<void> fetchTestDetails() async {
    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('tests/${widget.testId}')),
      );

      if (response.statusCode == 200) {
        setState(() {
          testData = json.decode(response.body);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Failed to load test details');
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackBar('Error: ${e.toString()}');
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFFDFA408),
      ),
    );
  }

  void selectAnswer(String optionKey) {
    setState(() {
      selectedAnswers[currentQuestionIndex] = optionKey;
    });
  }

  void nextQuestion() {
    if (currentQuestionIndex < (testData!['questions'].length - 1)) {
      setState(() {
        currentQuestionIndex++;
      });
    } else {
      // Show results
      showResults();
    }
  }

  void showResults() {
    int correctAnswers = 0;
    final questions = testData!['questions'];

    for (int i = 0; i < questions.length; i++) {
      if (selectedAnswers[i] == questions[i]['correctOption']) {
        correctAnswers++;
      }
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Color(0xFF000435),
        title: Text(
          'Quiz Results',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(
          'You scored $correctAnswers out of ${questions.length}',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text(
              'Back to Tests',
              style: TextStyle(color: Color(0xFFDFA408)),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000435),
      appBar: AppBar(
        title: Text(
          widget.testTitle,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF000435),
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFDFA408),
              ),
            )
          : testData == null
              ? Center(
                  child: Text(
                    'No test data available',
                    style: TextStyle(color: Colors.white),
                  ),
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        'Question ${currentQuestionIndex + 1}/${testData!['questions'].length}',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Card(
                          color: Color(0xFFDFA408).withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  testData!['questions'][currentQuestionIndex]
                                      ['questionText'],
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                  ),
                                ),
                                SizedBox(height: 20),
                                ...((testData!['questions']
                                            [currentQuestionIndex]['options']
                                        as Map<String, dynamic>)
                                    .entries
                                    .map((entry) => Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 8.0),
                                          child: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: selectedAnswers[
                                                          currentQuestionIndex] ==
                                                      entry.key
                                                  ? Color(0xFFDFA408)
                                                  : Color(0xFF000435),
                                              side: BorderSide(
                                                color: Color(0xFFDFA408),
                                                width: 2,
                                              ),
                                            ),
                                            onPressed: () =>
                                                selectAnswer(entry.key),
                                            child: Text(
                                              entry.value,
                                              style: TextStyle(
                                                color: selectedAnswers[
                                                            currentQuestionIndex] ==
                                                        entry.key
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            ),
                                          ),
                                        ))
                                    .toList()),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFFDFA408),
                          padding: EdgeInsets.symmetric(vertical: 15),
                        ),
                        onPressed: selectedAnswers[currentQuestionIndex] != null
                            ? nextQuestion
                            : null,
                        child: Text(
                          currentQuestionIndex ==
                                  (testData!['questions'].length - 1)
                              ? 'Finish'
                              : 'Next',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
