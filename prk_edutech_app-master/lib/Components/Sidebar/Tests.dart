// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
//
// void main() {
//   runApp(MyQuizApp());
// }
//
// class MyQuizApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       theme: ThemeData(
//         primaryColor: Color(0xFF000435),
//         scaffoldBackgroundColor: Color(0xFF000435),
//       ),
//       home: AllTestsPage(),
//     );
//   }
// }
//
// class AllTestsPage extends StatefulWidget {
//   @override
//   _AllTestsPageState createState() => _AllTestsPageState();
// }
//
// class _AllTestsPageState extends State<AllTestsPage> {
//   List<dynamic> tests = [];
//   bool isLoading = true;
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTests();
//   }
//
//   Future<void> fetchTests() async {
//     try {
//       final response = await http.get(
//         Uri.parse('https://server.prkedutech.com/api/tests/'),
//       );
//
//       if (response.statusCode == 200) {
//         setState(() {
//           tests = json.decode(response.body);
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         _showErrorSnackBar('Failed to load tests');
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       _showErrorSnackBar('Error: ${e.toString()}');
//     }
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color(0xFFDFA408),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF000435),
//       appBar: AppBar(
//         title: Text(
//           'Available Tests',
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color(0xFF000435),
//         elevation: 0,
//       ),
//       body: isLoading
//           ? Center(
//         child: CircularProgressIndicator(
//           color: Color(0xFFDFA408),
//         ),
//       )
//           : ListView.builder(
//         itemCount: tests.length,
//         itemBuilder: (context, index) {
//           final test = tests[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(
//               horizontal: 16.0,
//               vertical: 8.0,
//             ),
//             child: Card(
//               color: Color(0xFFDFA408).withOpacity(0.2),
//               shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(15),
//               ),
//               child: ListTile(
//                 title: Text(
//                   test['title'],
//                   style: TextStyle(
//                     color: Colors.white,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 subtitle: Text(
//                   '${test['topic']} • ${test['duration']} mins',
//                   style: TextStyle(
//                     color: Colors.white70,
//                   ),
//                 ),
//                 trailing: Icon(
//                   Icons.arrow_forward_ios,
//                   color: Color(0xFFDFA408),
//                 ),
//                 onTap: () {
//                   Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                       builder: (context) => QuizScreen(
//                         testId: test['_id'],
//                         testTitle: test['title'],
//                       ),
//                     ),
//                   );
//                 },
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
// }
//
// class QuizScreen extends StatefulWidget {
//   final String testId;
//   final String testTitle;
//
//   const QuizScreen({
//     Key? key,
//     required this.testId,
//     required this.testTitle,
//   }) : super(key: key);
//
//   @override
//   _QuizScreenState createState() => _QuizScreenState();
// }
//
// class _QuizScreenState extends State<QuizScreen> {
//   Map<String, dynamic>? testData;
//   bool isLoading = true;
//   int currentQuestionIndex = 0;
//   Map<int, String?> selectedAnswers = {};
//
//   @override
//   void initState() {
//     super.initState();
//     fetchTestDetails();
//   }
//
//   Future<void> fetchTestDetails() async {
//     try {
//       final response = await http.get(
//         Uri.parse('http://82.25.110.246:5000/api/tests/${widget.testId}'),
//       );
//
//       if (response.statusCode == 200) {
//         setState(() {
//           testData = json.decode(response.body);
//           isLoading = false;
//         });
//       } else {
//         setState(() {
//           isLoading = false;
//         });
//         _showErrorSnackBar('Failed to load test details');
//       }
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       _showErrorSnackBar('Error: ${e.toString()}');
//     }
//   }
//
//   void _showErrorSnackBar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(
//           message,
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color(0xFFDFA408),
//       ),
//     );
//   }
//
//   void selectAnswer(String optionKey) {
//     setState(() {
//       selectedAnswers[currentQuestionIndex] = optionKey;
//     });
//   }
//
//   void nextQuestion() {
//     if (currentQuestionIndex < (testData!['questions'].length - 1)) {
//       setState(() {
//         currentQuestionIndex++;
//       });
//     } else {
//       // Show results
//       showResults();
//     }
//   }
//
//   void showResults() {
//     int correctAnswers = 0;
//     final questions = testData!['questions'];
//
//     for (int i = 0; i < questions.length; i++) {
//       if (selectedAnswers[i] == questions[i]['correctOption']) {
//         correctAnswers++;
//       }
//     }
//
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         backgroundColor: Color(0xFF000435),
//         title: Text(
//           'Quiz Results',
//           style: TextStyle(color: Colors.white),
//         ),
//         content: Text(
//           'You scored $correctAnswers out of ${questions.length}',
//           style: TextStyle(color: Colors.white),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {
//               Navigator.of(context).pop();
//               Navigator.of(context).pop();
//             },
//             child: Text(
//               'Back to Tests',
//               style: TextStyle(color: Color(0xFFDFA408)),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Color(0xFF000435),
//       appBar: AppBar(
//         title: Text(
//           widget.testTitle,
//           style: TextStyle(color: Colors.white),
//         ),
//         backgroundColor: Color(0xFF000435),
//         elevation: 0,
//         iconTheme: IconThemeData(color: Colors.white),
//       ),
//       body: isLoading
//           ? Center(
//         child: CircularProgressIndicator(
//           color: Color(0xFFDFA408),
//         ),
//       )
//           : testData == null
//           ? Center(
//         child: Text(
//           'No test data available',
//           style: TextStyle(color: Colors.white),
//         ),
//       )
//           : Column(
//         crossAxisAlignment: CrossAxisAlignment.stretch,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: Text(
//               'Question ${currentQuestionIndex + 1}/${testData!['questions'].length}',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.symmetric(horizontal: 16.0),
//               child: Card(
//                 color: Color(0xFFDFA408).withOpacity(0.2),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.stretch,
//                     children: [
//                       Text(
//                         testData!['questions'][currentQuestionIndex]
//                         ['questionText'],
//                         style: TextStyle(
//                           color: Colors.white,
//                           fontSize: 16,
//                         ),
//                       ),
//                       SizedBox(height: 20),
//                       ...((testData!['questions'][currentQuestionIndex]
//                       ['options'] as Map<String, dynamic>)
//                           .entries
//                           .map((entry) => Padding(
//                         padding: const EdgeInsets.symmetric(
//                             vertical: 8.0),
//                         child: ElevatedButton(
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor:
//                             selectedAnswers[currentQuestionIndex] ==
//                                 entry.key
//                                 ? Color(0xFFDFA408)
//                                 : Color(0xFF000435),
//                             side: BorderSide(
//                               color: Color(0xFFDFA408),
//                               width: 2,
//                             ),
//                           ),
//                           onPressed: () =>
//                               selectAnswer(entry.key),
//                           child: Text(
//                             entry.value,
//                             style: TextStyle(
//                               color: selectedAnswers[
//                               currentQuestionIndex] ==
//                                   entry.key
//                                   ? Colors.black
//                                   : Colors.white,
//                             ),
//                           ),
//                         ),
//                       ))
//                           .toList()),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ElevatedButton(
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Color(0xFFDFA408),
//                 padding: EdgeInsets.symmetric(vertical: 15),
//               ),
//               onPressed: selectedAnswers[currentQuestionIndex] != null
//                   ? nextQuestion
//                   : null,
//               child: Text(
//                 currentQuestionIndex ==
//                     (testData!['questions'].length - 1)
//                     ? 'Finish'
//                     : 'Next',
//                 style: TextStyle(
//                   color: Colors.black,
//                   fontSize: 16,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:pie_chart/pie_chart.dart';
import 'package:testing1/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Test Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF000435),
        colorScheme: ColorScheme.light(
          primary: const Color(0xFF000435),
          secondary: const Color(0xFFfb7e02),
        ),
        scaffoldBackgroundColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF000435),
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFfb7e02),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
      home: const AllTestsPage(),
    );
  }
}

class Test {
  final String id;
  final String title;
  final String topic;
  final String category;
  final String description;
  final int duration;
  final int questionCount;
  final int marks;
  final String difficulty;
  final int attempts;

  Test({
    required this.id,
    required this.title,
    required this.topic,
    required this.category,
    required this.description,
    required this.duration,
    required this.questionCount,
    required this.marks,
    required this.difficulty,
    required this.attempts,
  });

  static String _stringOrFallback(
    dynamic value, {
    String fallback = '',
  }) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  static int _intOrZero(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  static String _titleCaseOrFallback(
    dynamic value, {
    String fallback = '',
  }) {
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

  factory Test.fromJson(Map<String, dynamic> json) {
    final questionCount = _intOrZero(
      json['questionCount'] ?? json['totalQuestions'] ?? json['noOfQuestions'],
    );
    final category = _stringOrFallback(
      json['category'],
      fallback: _stringOrFallback(json['subject'], fallback: 'General'),
    );

    return Test(
      id: _stringOrFallback(json['_id']),
      title: _stringOrFallback(
        json['title'],
        fallback: _stringOrFallback(json['name'], fallback: 'Untitled Test'),
      ),
      topic: _stringOrFallback(
        json['topic'],
        fallback: _stringOrFallback(json['testType'], fallback: 'General'),
      ),
      category: category,
      description: _stringOrFallback(
        json['description'],
        fallback: 'No description available',
      ),
      duration: _intOrZero(json['duration']),
      questionCount: questionCount,
      marks: _intOrZero(json['marks']) == 0
          ? (questionCount == 0 ? 10 : questionCount)
          : _intOrZero(json['marks']),
      difficulty: _titleCaseOrFallback(json['difficulty'], fallback: 'Medium'),
      attempts: _intOrZero(json['attempts']) == 0
          ? _intOrZero(json['attemptCount'])
          : _intOrZero(json['attempts']),
    );
  }
}

class Question {
  final int number;
  final String questionText;
  final Map<String, String> options;
  final String correctOption;
  final String solution;

  Question({
    required this.number,
    required this.questionText,
    required this.options,
    required this.correctOption,
    required this.solution,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    final rawOptions = json['options'];
    final optionsMap = rawOptions is Map
        ? rawOptions.map(
            (key, value) => MapEntry(
              key.toString(),
              (value ?? '').toString(),
            ),
          )
        : <String, String>{};

    return Question(
      number: Test._intOrZero(json['number']),
      questionText: Test._stringOrFallback(
        json['questionText'],
        fallback: 'Question not available',
      ),
      options: optionsMap.cast<String, String>(),
      correctOption: Test._stringOrFallback(json['correctOption']),
      solution: Test._stringOrFallback(
        json['solution'],
        fallback: 'Solution not available',
      ),
    );
  }
}

class TestDetail {
  final String title;
  final String topic;
  final String description;
  final int duration;
  final int questionCount;
  final List<Question> questions;

  TestDetail({
    required this.title,
    required this.topic,
    required this.description,
    required this.duration,
    required this.questionCount,
    required this.questions,
  });

  factory TestDetail.fromJson(Map<String, dynamic> json) {
    final rawQuestions = json['questions'];
    final questionList = rawQuestions is List
        ? rawQuestions
            .whereType<Map<String, dynamic>>()
            .map(Question.fromJson)
            .toList()
        : <Question>[];

    return TestDetail(
      title: Test._stringOrFallback(
        json['title'],
        fallback: 'Test Details',
      ),
      topic: Test._stringOrFallback(
        json['topic'],
        fallback: Test._stringOrFallback(json['testType'], fallback: 'General'),
      ),
      description: Test._stringOrFallback(
        json['description'],
        fallback: 'No description available',
      ),
      duration: Test._intOrZero(json['duration']),
      questionCount: Test._intOrZero(json['questionCount']) == 0
          ? questionList.length
          : Test._intOrZero(json['questionCount']),
      questions: questionList,
    );
  }
}

class AllTestsPage extends StatefulWidget {
  const AllTestsPage({Key? key}) : super(key: key);

  @override
  _AllTestsPageState createState() => _AllTestsPageState();
}

class _AllTestsPageState extends State<AllTestsPage> {
  List<Test> tests = [];
  bool isLoading = true;
  String? error;
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
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('tests')),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> data = decoded is List
            ? decoded
            : (decoded is Map<String, dynamic> && decoded['data'] is List)
                ? decoded['data'] as List<dynamic>
                : (decoded is Map<String, dynamic> && decoded['tests'] is List)
                    ? decoded['tests'] as List<dynamic>
                    : <dynamic>[];
        setState(() {
          tests = data
              .whereType<Map<String, dynamic>>()
              .map(Test.fromJson)
              .where((test) => test.id.isNotEmpty)
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error =
              'Failed to load tests. Server returned ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error connecting to server: $e';
        isLoading = false;
      });
    }
  }

  List<String> get _topics {
    final topicSet = tests.map((test) => test.topic.trim()).toSet();
    final topicList = topicSet.where((topic) => topic.isNotEmpty).toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['All Topics', ...topicList];
  }

  List<Test> get _visibleTests {
    final filtered = _selectedTopic == 'All Topics'
        ? List<Test>.from(tests)
        : tests.where((test) => test.topic == _selectedTopic).toList();

    if (_selectedSort == 'Duration') {
      filtered.sort((a, b) => b.duration.compareTo(a.duration));
    } else if (_selectedSort == 'Title') {
      filtered.sort(
          (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    } else {
      filtered.sort((a, b) => b.id.compareTo(a.id));
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
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchTests,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : _visibleTests.isEmpty
                  ? const Center(
                      child: Text('Coming soon'),
                    )
                  : Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                          child: Row(
                            children: [
                              Expanded(
                                child: _FilterDropdown(
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
                                child: _FilterDropdown(
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
                                return TestCard(test: test, index: index);
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;
  final String? prefix;

  const _FilterDropdown({
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

class TestCard extends StatelessWidget {
  final Test test;
  final int index;

  const TestCard({Key? key, required this.test, required this.index})
      : super(key: key);

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
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TestDetailPage(testId: test.id),
              ),
            );
          },
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
                      child: Icon(
                        Icons.assignment_outlined,
                        color: accent,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            test.title,
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
                              test.category,
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
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
                            '${test.duration} min',
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
                    color: const Color(0xFFDFE3EE).withOpacity(0.9),
                    thickness: 1),
                const SizedBox(height: 12),
                _detailLine(
                  icon: Icons.list_alt_rounded,
                  label: 'Topic',
                  value: test.topic,
                  iconColor: const Color(0xFF7A60FC),
                ),
                const SizedBox(height: 10),
                _detailLine(
                  icon: Icons.menu_book_outlined,
                  label: 'Description',
                  value: test.description,
                  iconColor: const Color(0xFF7A60FC),
                ),
                const SizedBox(height: 12),
                Divider(
                    color: const Color(0xFFDFE3EE).withOpacity(0.9),
                    thickness: 1),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _statItem(
                        icon: Icons.help_outline_rounded,
                        iconColor: const Color(0xFF7A60FC),
                        value:
                            '${test.questionCount == 0 ? 10 : test.questionCount}',
                        label: 'Questions',
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _statItem(
                        icon: Icons.check_circle_outline_rounded,
                        iconColor: const Color(0xFF46B67E),
                        value: '${test.marks}',
                        label: 'Marks',
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _statItem(
                        icon: Icons.equalizer_rounded,
                        iconColor: const Color(0xFF3A84FF),
                        value: test.difficulty,
                        label: 'Difficulty',
                      ),
                    ),
                    _verticalDivider(),
                    Expanded(
                      child: _statItem(
                        icon: Icons.history_toggle_off_rounded,
                        iconColor: const Color(0xFFE75A9D),
                        value: '${test.attempts == 0 ? 1 : test.attempts}',
                        label: test.attempts <= 1 ? 'Attempt' : 'Attempts',
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
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                    ),
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor:
                          filledButton ? const Color(0xFFFB8700) : Colors.white,
                      foregroundColor:
                          filledButton ? Colors.white : const Color(0xFFFB8700),
                      side: const BorderSide(
                          color: Color(0xFFF3A658), width: 1.2),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26)),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => TestDetailPage(testId: test.id),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
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

class TestDetailPage extends StatefulWidget {
  final String testId;

  const TestDetailPage({Key? key, required this.testId}) : super(key: key);

  @override
  _TestDetailPageState createState() => _TestDetailPageState();
}

class _TestDetailPageState extends State<TestDetailPage> {
  TestDetail? testDetail;
  bool isLoading = true;
  String? error;
  bool showInstructions = true;

  @override
  void initState() {
    super.initState();
    fetchTestDetail();
  }

  Future<void> fetchTestDetail() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('tests/${widget.testId}')),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final data = decoded is Map<String, dynamic>
            ? (decoded['data'] is Map<String, dynamic>
                ? decoded['data'] as Map<String, dynamic>
                : decoded)
            : <String, dynamic>{};
        setState(() {
          testDetail = TestDetail.fromJson(data);
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load test. Server returned ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        error = 'Error connecting to server: $e';
        isLoading = false;
      });
    }
  }

  void startTest() {
    setState(() {
      showInstructions = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          testDetail?.title ?? 'Test Details',
          style: const TextStyle(fontSize: 18),
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFfb7e02),
              ),
            )
          : error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: fetchTestDetail,
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : showInstructions
                  ? _buildInstructionsView()
                  : TestQuestionsPage(testDetail: testDetail!),
    );
  }

  Widget _buildInstructionsView() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            elevation: 3,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Test Information',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000435),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _infoRow(
                    icon: Icons.title,
                    label: 'Title',
                    value: testDetail!.title,
                  ),
                  _infoRow(
                    icon: Icons.topic,
                    label: 'Topic',
                    value: testDetail!.topic,
                  ),
                  _infoRow(
                    icon: Icons.description,
                    label: 'Description',
                    value: testDetail!.description,
                  ),
                  _infoRow(
                    icon: Icons.timer,
                    label: 'Duration',
                    value: '${testDetail!.duration} minutes',
                  ),
                  _infoRow(
                    icon: Icons.question_answer,
                    label: 'Questions',
                    value: testDetail!.questionCount.toString(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Card(
          //   elevation: 3,
          //   shape: RoundedRectangleBorder(
          //     borderRadius: BorderRadius.circular(12),
          //   ),
          //   child: Padding(
          //     padding: const EdgeInsets.all(16),
          //     child: Column(
          //       crossAxisAlignment: CrossAxisAlignment.start,
          //       children: [
          //         const Text(
          //           'Instructions',
          //           style: TextStyle(
          //             fontSize: 20,
          //             fontWeight: FontWeight.bold,
          //             color: Color(0xFF000435),
          //           ),
          //         ),
          //         const SizedBox(height: 16),
          //         _instructionItem(
          //           'Read each question carefully before answering.',
          //         ),
          //         _instructionItem(
          //           'You have ${testDetail!.duration} minutes to complete the test.',
          //         ),
          //         _instructionItem(
          //           'Each question has only one correct answer.',
          //         ),
          //         _instructionItem(
          //           'You can review your answers before submission.',
          //         ),
          //         _instructionItem(
          //           'Results will be available immediately after submission.',
          //         ),
          //       ],
          //     ),
          //   ),
          // ),
          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: ElevatedButton(
                onPressed: startTest,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor:
                      Colors.orange, // Set background color to orange
                ),
                child: const Text(
                  'Start Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors
                        .white, // Ensure text is visible on orange background
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: const Color(0xFFfb7e02),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class TestQuestionsPage extends StatefulWidget {
  final TestDetail testDetail;

  const TestQuestionsPage({Key? key, required this.testDetail})
      : super(key: key);

  @override
  _TestQuestionsPageState createState() => _TestQuestionsPageState();
}

class _TestQuestionsPageState extends State<TestQuestionsPage> {
  late PageController _pageController;
  int _currentIndex = 0;
  Map<int, String> _userAnswers = {};
  bool _testSubmitted = false;
  bool _reviewMode = false;
  int _remainingSeconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
    _remainingSeconds = widget.testDetail.duration * 60;
    _startTimer();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        _timer?.cancel();
        if (!_testSubmitted) {
          _submitTest();
        }
      }
    });
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void _selectAnswer(int questionIndex, String option) {
    if (!_testSubmitted) {
      setState(() {
        _userAnswers[questionIndex] = option;
      });
    }
  }

  void _nextQuestion() {
    if (_currentIndex < widget.testDetail.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousQuestion() {
    if (_currentIndex > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _goToQuestion(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _submitTest() {
    setState(() {
      _testSubmitted = true;
      _timer?.cancel();
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Test Completed'),
        content: const Text('Would you like to see your results?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showResults();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }

  void _toggleReviewMode() {
    setState(() {
      _reviewMode = !_reviewMode;
    });
  }

  void _showResults() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TestResultsPage(
          testDetail: widget.testDetail,
          userAnswers: _userAnswers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        if (!_testSubmitted) {
          final result = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Quit Test?'),
              content: const Text(
                'Are you sure you want to quit? Your progress will be lost.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
          return result ?? false;
        }
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false, // Removes the back button
          title: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.timer,
                size: 20,
                color: _remainingSeconds < 60 ? Colors.red : Colors.black,
              ),
              const SizedBox(width: 8),
              Text(
                _formatTime(_remainingSeconds),
                style: TextStyle(
                  fontSize: 18,
                  color: _remainingSeconds < 60 ? Colors.red : Colors.black54,
                ),
              ),
            ],
          ),
          centerTitle: true,
          actions: [
            if (_testSubmitted)
              IconButton(
                onPressed: _toggleReviewMode,
                icon: Icon(
                  _reviewMode ? Icons.visibility_off : Icons.visibility,
                  color: Colors.white,
                ),
              ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                itemCount: widget.testDetail.questions.length,
                itemBuilder: (context, index) {
                  final question = widget.testDetail.questions[index];
                  final userAnswer = _userAnswers[index];
                  final isCorrect = userAnswer == question.correctOption;

                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF000435),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Question ${index + 1}/${widget.testDetail.questions.length}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Spacer(),
                            if (_testSubmitted)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: userAnswer == null
                                      ? Colors.grey
                                      : isCorrect
                                          ? Colors.green
                                          : Colors.red,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  userAnswer == null
                                      ? 'Not Answered'
                                      : isCorrect
                                          ? 'Correct'
                                          : 'Incorrect',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          question.questionText,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ...question.options.entries.map((entry) {
                          final optionKey = entry.key;
                          final optionText = entry.value;
                          final isSelected = userAnswer == optionKey;
                          final isCorrectOption =
                              question.correctOption == optionKey;

                          Color? backgroundColor;
                          if (_testSubmitted) {
                            if (_reviewMode) {
                              if (isCorrectOption) {
                                backgroundColor = Colors.green.withOpacity(0.2);
                              } else if (isSelected && !isCorrectOption) {
                                backgroundColor = Colors.red.withOpacity(0.2);
                              }
                            } else if (isSelected) {
                              backgroundColor = isCorrectOption
                                  ? Colors.green.withOpacity(0.2)
                                  : Colors.red.withOpacity(0.2);
                            }
                          } else if (isSelected) {
                            backgroundColor =
                                const Color(0xFFfb7e02).withOpacity(0.1);
                          }

                          return GestureDetector(
                            onTap: () {
                              if (!_testSubmitted) {
                                _selectAnswer(index, optionKey);
                              }
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: backgroundColor,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFfb7e02)
                                      : Colors.grey.shade300,
                                  width: isSelected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    height: 24,
                                    width: 24,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isSelected
                                          ? const Color(0xFFfb7e02)
                                          : Colors.white,
                                      border: Border.all(
                                        color: isSelected
                                            ? const Color(0xFFfb7e02)
                                            : Colors.grey.shade400,
                                      ),
                                    ),
                                    child: isSelected
                                        ? const Icon(
                                            Icons.check,
                                            size: 16,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      optionText,
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: isSelected
                                            ? FontWeight.w500
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ),
                                  if (_testSubmitted && !_reviewMode)
                                    Icon(
                                      isCorrectOption
                                          ? Icons.check_circle
                                          : isSelected
                                              ? Icons.cancel
                                              : null,
                                      color: isCorrectOption
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                        if (_testSubmitted)
                          Container(
                            margin: const EdgeInsets.only(top: 16),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.blue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: Colors.blue.shade200,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Solution:',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Color(0xFF000435),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  question.solution,
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  SizedBox(
                    height: 50,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: widget.testDetail.questions.length,
                      itemBuilder: (context, index) {
                        final isActive = _currentIndex == index;
                        final isAnswered = _userAnswers.containsKey(index);
                        final isCorrect = _testSubmitted &&
                            isAnswered &&
                            _userAnswers[index] ==
                                widget
                                    .testDetail.questions[index].correctOption;

                        Color backgroundColor;
                        if (_testSubmitted) {
                          backgroundColor = !isAnswered
                              ? Colors.grey
                              : isCorrect
                                  ? Colors.green
                                  : Colors.red;
                        } else {
                          backgroundColor = isActive
                              ? const Color(0xFFfb7e02)
                              : isAnswered
                                  ? const Color(0xFF000435)
                                  : Colors.grey;
                        }

                        return GestureDetector(
                          onTap: () => _goToQuestion(index),
                          child: Container(
                            width: 36,
                            height: 36,
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            decoration: BoxDecoration(
                              color: backgroundColor,
                              shape: BoxShape.circle,
                              border: isActive
                                  ? Border.all(
                                      color: const Color(0xFFfb7e02),
                                      width: 2,
                                    )
                                  : null,
                            ),
                            child: Center(
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      ElevatedButton(
                        onPressed: _currentIndex > 0 ? _previousQuestion : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000435),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Previous'),
                      ),
                      if (!_testSubmitted)
                        ElevatedButton(
                          onPressed: _submitTest,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                          ),
                          child: const Text('Submit Test'),
                        )
                      else
                        ElevatedButton(
                          onPressed: _showResults,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000435),
                          ),
                          child: const Text('View Results'),
                        ),
                      ElevatedButton(
                        onPressed: _currentIndex <
                                widget.testDetail.questions.length - 1
                            ? _nextQuestion
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF000435),
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: Colors.grey.shade300,
                        ),
                        child: const Text('Next'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TestResultsPage extends StatelessWidget {
  final TestDetail testDetail;
  final Map<int, String> userAnswers;

  const TestResultsPage({
    Key? key,
    required this.testDetail,
    required this.userAnswers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final int totalQuestions = testDetail.questions.length;
    final int attemptedQuestions = userAnswers.length;
    final int correctAnswers = _countCorrectAnswers();
    final int incorrectAnswers = attemptedQuestions - correctAnswers;
    final int unattemptedQuestions = totalQuestions - attemptedQuestions;
    final double score = (correctAnswers / totalQuestions) * 100;

    final Map<String, double> dataMap = {
      "Correct": correctAnswers.toDouble(),
      "Incorrect": incorrectAnswers.toDouble(),
      "Unattempted": unattemptedQuestions.toDouble(),
    };

    final List<Color> colorList = [
      Colors.green,
      Colors.red,
      Colors.grey,
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Test Results'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Text(
                      'Your Score: ${score.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000435),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$correctAnswers out of $totalQuestions correct',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color(0xFFfb7e02),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 300,
                      padding: const EdgeInsets.all(8),
                      child: PieChart(
                        dataMap: dataMap,
                        animationDuration: const Duration(milliseconds: 800),
                        chartLegendSpacing: 32,
                        chartRadius: MediaQuery.of(context).size.width / 2.5,
                        colorList: colorList,
                        initialAngleInDegree: 0,
                        chartType: ChartType.disc,
                        ringStrokeWidth: 32,
                        centerText: "Results",
                        legendOptions: const LegendOptions(
                          showLegendsInRow: false,
                          legendPosition: LegendPosition.right,
                          showLegends: true,
                          legendTextStyle: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        chartValuesOptions: const ChartValuesOptions(
                          showChartValueBackground: true,
                          showChartValues: true,
                          showChartValuesInPercentage: true,
                          showChartValuesOutside: false,
                          decimalPlaces: 1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Summary',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000435),
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryItem(
              icon: Icons.check_circle,
              color: Colors.green,
              title: 'Correct Answers',
              value: '$correctAnswers',
            ),
            _buildSummaryItem(
              icon: Icons.cancel,
              color: Colors.red,
              title: 'Incorrect Answers',
              value: '$incorrectAnswers',
            ),
            _buildSummaryItem(
              icon: Icons.help_outline,
              color: Colors.grey,
              title: 'Unattempted Questions',
              value: '$unattemptedQuestions',
            ),
            _buildSummaryItem(
              icon: Icons.stars,
              color: const Color(0xFFfb7e02),
              title: 'Accuracy',
              value: attemptedQuestions > 0
                  ? '${((correctAnswers / attemptedQuestions) * 100).toStringAsFixed(1)}%'
                  : '0%',
            ),
            const SizedBox(height: 24),
            const Text(
              'Question Review',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000435),
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: testDetail.questions.length,
              itemBuilder: (context, index) {
                final question = testDetail.questions[index];
                final userAnswer = userAnswers[index];
                final isCorrect = userAnswer == question.correctOption;
                final correctOptionText =
                    question.options[question.correctOption] ?? '';
                final selectedOptionText = userAnswer != null
                    ? question.options[userAnswer] ?? ''
                    : 'Not answered';

                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: BorderSide(
                      color: userAnswer == null
                          ? Colors.grey
                          : isCorrect
                              ? Colors.green
                              : Colors.red,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF000435),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Q${index + 1}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: userAnswer == null
                                    ? Colors.grey
                                    : isCorrect
                                        ? Colors.green
                                        : Colors.red,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                userAnswer == null
                                    ? 'Not Answered'
                                    : isCorrect
                                        ? 'Correct'
                                        : 'Incorrect',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                            const Spacer(),
                            IconButton(
                              onPressed: () {
                                showDialog(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    title: const Text('Question Detail'),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            question.questionText,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Your Answer:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(selectedOptionText),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Correct Answer:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(correctOptionText),
                                          const SizedBox(height: 12),
                                          const Text(
                                            'Solution:',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(question.solution),
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: const Text('Close'),
                                      ),
                                    ],
                                  ),
                                );
                              },
                              icon: const Icon(
                                Icons.info_outline,
                                color: Color(0xFFfb7e02),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          question.questionText,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        if (userAnswer != null) ...[
                          Text(
                            'Your answer: $selectedOptionText',
                            style: TextStyle(
                              color: isCorrect ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ] else
                          const Text(
                            'Your answer: Not attempted',
                            style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        if (!isCorrect && userAnswer != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Correct answer: $correctOptionText',
                            style: const TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.popUntil(
                    context,
                    (route) => route.isFirst,
                  );
                },
                icon: const Icon(Icons.home),
                label: const Text('Return to Home'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  int _countCorrectAnswers() {
    int count = 0;
    for (int i = 0; i < testDetail.questions.length; i++) {
      if (userAnswers.containsKey(i) &&
          userAnswers[i] == testDetail.questions[i].correctOption) {
        count++;
      }
    }
    return count;
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required Color color,
    required String title,
    required String value,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade800,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// // Extension for Timer
// extension on Timer {
//   void cancel() {
//     if (isActive) {
//       super.cancel();
//     }
//   }
// }
