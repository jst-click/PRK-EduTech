import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({Key? key}) : super(key: key);

  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class LeaderboardModel {
  final String id;
  final String name;
  final String designation;
  final String phoneNo;
  final String email;
  final String website;

  LeaderboardModel({
    required this.id,
    required this.name,
    required this.designation,
    required this.phoneNo,
    required this.email,
    required this.website,
  });

  factory LeaderboardModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardModel(
      id: json['_id'],
      name: json['name'],
      designation: json['designation'],
      phoneNo: json['phoneNo'],
      email: json['email'],
      website: json['website'],
    );
  }
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<LeaderboardModel> _leaderboardEntries = [];
  bool _isLoading = true;
  String _error = '';

  @override
  void initState() {
    super.initState();
    _fetchLeaderboardEntries();
  }

  Future<void> _fetchLeaderboardEntries() async {
    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('leaderboard')),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        final List<dynamic> entriesData = jsonResponse['data'];

        setState(() {
          _leaderboardEntries = entriesData
              .map((item) => LeaderboardModel.fromJson(item))
              .toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load leaderboard entries';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch $url')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error launching URL: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text(
          'Leaderboard',
          style: TextStyle(
            color: Color(0xFF000435),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFFFFF3E0),
        elevation: 0,
        centerTitle: true,
      ),
      body: _isLoading
          ? Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFDFA408)),
        ),
      )
          : _error.isNotEmpty
          ? Center(
        child: Text(
          _error,
          style: TextStyle(color: Color(0xFF000435)),
        ),
      )
          : ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: _leaderboardEntries.length,
        itemBuilder: (context, index) {
          final entry = _leaderboardEntries[index];
          return Container(
            margin: EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Color(0xFF000435).withOpacity(0.2),
                width: 1,
              ),
              borderRadius: BorderRadius.circular(8),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF000435).withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Name', entry.name),
                  Divider(color: Color(0xFFDFA408).withOpacity(0.3)),
                  _buildInfoRow('Designation', entry.designation),
                  Divider(color: Color(0xFFDFA408).withOpacity(0.3)),
                  _buildInfoRow('Phone', entry.phoneNo,
                      onTap: () => _launchURL('tel:${entry.phoneNo}')),
                  Divider(color: Color(0xFFDFA408).withOpacity(0.3)),
                  _buildInfoRow('Email', entry.email,
                      onTap: () => _launchURL('mailto:${entry.email}')),
                  Divider(color: Color(0xFFDFA408).withOpacity(0.3)),
                  _buildInfoRow('Website', entry.website,
                      onTap: () => _launchURL(entry.website)),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            Expanded(
              flex: 2,
              child: Text(
                label,
                style: TextStyle(
                  color: Color(0xFF000435),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
            Expanded(
              flex: 3,
              child: Text(
                value,
                style: TextStyle(
                  color: onTap != null ? Color(0xFFDFA408) : Color(0xFF000435),
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (onTap != null)
              Icon(
                Icons.launch,
                color: Color(0xFFDFA408),
                size: 18,
              ),
          ],
        ),
      ),
    );
  }
}