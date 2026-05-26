import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/BottomNavigation/AppScaffold.dart';
import 'package:testing1/constants.dart';
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(LeaderboardApp());
}

class LeaderboardApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primaryColor: Color(0xFFf5f2f9),
        scaffoldBackgroundColor: Color(0xFFf5f2f9),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFFf5f2f9),
          elevation: 0,
        ),
      ),
      home: LeaderboardPage(),
    );
  }
}

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> leaderboardEntries = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLeaderboardData();
  }

  Future<void> fetchLeaderboardData() async {
    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('leaderboard')),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final List<dynamic> rawEntries = responseData is List
            ? responseData
            : (responseData is Map<String, dynamic> &&
                    responseData['data'] is List)
                ? responseData['data'] as List<dynamic>
                : (responseData is Map<String, dynamic> &&
                        responseData['entries'] is List)
                    ? responseData['entries'] as List<dynamic>
                    : <dynamic>[];
        setState(() {
          leaderboardEntries = rawEntries
              .whereType<Map<String, dynamic>>()
              .map((entry) => <String, dynamic>{
                    'name': (entry['name'] ?? 'Unknown').toString(),
                    'designation':
                        (entry['designation'] ?? 'No designation').toString(),
                    'email': (entry['email'] ?? 'No email').toString(),
                    'website': (entry['website'] ?? '').toString(),
                  })
              .toList();
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackBar('Failed to load leaderboard');
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
          style: TextStyle(color: Color(0xFF000435)),
        ),
        backgroundColor: Color(0xFFfb7e02),
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (url.trim().isEmpty) {
      _showErrorSnackBar('Website not available');
      return;
    }
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      _showErrorSnackBar('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFf5f2f9),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back,
              color: Color(0xFF000435)), // Back icon
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => AppScaffold()),
            );
          },
        ),
        title: const Text(
          'Leaderboard',
          style: TextStyle(
            color: Color(0xFF000435),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFFf5f2f9), // Match background color
        iconTheme:
            const IconThemeData(color: Color(0xff000435)), // Match icon color
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFfb7e02),
              ),
            )
          : leaderboardEntries.isEmpty
              ? Center(
                  child: Text(
                    'Coming soon',
                    style: TextStyle(
                      color: Color(0xFFfb7e02),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )
              : Column(
                  children: [
                    // Container(
                    //   padding: EdgeInsets.symmetric(vertical: 20),
                    //   color: Color(0xFFfb7e02).withOpacity(0.1),
                    //   child: Center(
                    //     child: Text(
                    //       'Top Performers',
                    //       style: TextStyle(
                    //         color: Color(0xFFfb7e02),
                    //         fontSize: 24,
                    //         fontWeight: FontWeight.bold,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    Expanded(
                      child: ListView.builder(
                        itemCount: leaderboardEntries.length,
                        itemBuilder: (context, index) {
                          final entry = leaderboardEntries[index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 8.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFFfb7e02).withOpacity(0.2),
                                    Color(0xFFfb7e02).withOpacity(0.1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(15),
                                border: Border.all(
                                  color: Color(0xFFfb7e02).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.all(16),
                                leading: CircleAvatar(
                                  backgroundColor: Color(0xFFfb7e02),
                                  child: Text(
                                    entry['name']
                                        .toString()
                                        .trim()
                                        .substring(0, 1)
                                        .toUpperCase(),
                                    style: TextStyle(
                                      color: Color(0xFFf5f2f9),
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                title: Text(
                                  entry['name'].toString(),
                                  style: TextStyle(
                                    color: Color(0xFF000435),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    SizedBox(height: 8),
                                    Text(
                                      entry['designation'].toString(),
                                      style: TextStyle(
                                        color: Color(0xFF000435),
                                        fontSize: 14,
                                      ),
                                    ),
                                    SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.email,
                                          color: Color(0xFFfb7e02),
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            entry['email'].toString(),
                                            style: TextStyle(
                                              color: Color(0xFF000435),
                                              fontSize: 12,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  icon: Icon(
                                    Icons.open_in_new,
                                    color: Color(0xFFfb7e02),
                                  ),
                                  onPressed: () =>
                                      _launchURL(entry['website'].toString()),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }
}
