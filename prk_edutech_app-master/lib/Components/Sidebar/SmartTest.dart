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
  List<dynamic> tests = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTests();
  }

  Future<void> fetchTests() async {
    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('tests/')),
      );

      if (response.statusCode == 200) {
        setState(() {
          tests = json.decode(response.body);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF000435),
      appBar: AppBar(
        title: Text(
          'Available Tests',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF000435),
        elevation: 0,
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(
          color: Color(0xFFDFA408),
        ),
      )
          : ListView.builder(
        itemCount: tests.length,
        itemBuilder: (context, index) {
          final test = tests[index];
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Card(
              color: Color(0xFFDFA408).withOpacity(0.2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              child: ListTile(
                title: Text(
                  test['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  '${test['topic']} • ${test['duration']} mins',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  color: Color(0xFFDFA408),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuizScreen(
                        testId: test['_id'],
                        testTitle: test['title'],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
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
                      ...((testData!['questions'][currentQuestionIndex]
                      ['options'] as Map<String, dynamic>)
                          .entries
                          .map((entry) => Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0),
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                            selectedAnswers[currentQuestionIndex] ==
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