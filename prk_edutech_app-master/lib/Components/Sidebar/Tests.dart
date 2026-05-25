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
  final String description;
  final int duration;

  Test({
    required this.id,
    required this.title,
    required this.topic,
    required this.description,
    required this.duration,
  });

  factory Test.fromJson(Map<String, dynamic> json) {
    return Test(
      id: json['_id'],
      title: json['title'],
      topic: json['topic'],
      description: json['description'],
      duration: json['duration'],
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
    return Question(
      number: json['number'],
      questionText: json['questionText'],
      options: Map<String, String>.from(json['options']),
      correctOption: json['correctOption'],
      solution: json['solution'],
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
    return TestDetail(
      title: json['title'],
      topic: json['topic'],
      description: json['description'],
      duration: json['duration'],
      questionCount: json['questionCount'],
      questions: List<Question>.from(
        json['questions'].map((q) => Question.fromJson(q)),
      ),
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
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          tests = data.map((item) => Test.fromJson(item)).toList();
          isLoading = false;
        });
      } else {
        setState(() {
          error = 'Failed to load tests. Server returned ${response.statusCode}';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Available Tests'),
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
              onPressed: fetchTests,
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : tests.isEmpty
          ? const Center(
        child: Text('No tests available'),
      )
          : RefreshIndicator(
        onRefresh: fetchTests,
        color: const Color(0xFFfb7e02),
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: tests.length,
          itemBuilder: (context, index) {
            final test = tests[index];
            return TestCard(test: test);
          },
        ),
      ),
    );
  }
}

class TestCard extends StatelessWidget {
  final Test test;

  const TestCard({Key? key, required this.test}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: Colors.white,
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TestDetailPage(testId: test.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      test.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF000435),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFfb7e02).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${test.duration} min',
                      style: const TextStyle(
                        color: Color(0xFFfb7e02),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'Topic: ${test.topic}',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                test.description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TestDetailPage(testId: test.id),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                  child: const Text('Start Test'),
                ),
              ),
            ],
          ),
        ),
      ),
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
        final data = json.decode(response.body);
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
                  backgroundColor: Colors.orange, // Set background color to orange
                ),
                child: const Text(
                  'Start Test',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white, // Ensure text is visible on orange background
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

  Widget _instructionItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle,
            size: 18,
            color: Color(0xFFfb7e02),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 15),
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
    widget.testDetail.questions[index].correctOption;

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