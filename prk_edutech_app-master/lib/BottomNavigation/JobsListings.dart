import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:url_launcher/url_launcher.dart';
import 'package:testing1/constants.dart';

class JobModel {
  final String id;
  final String title;
  final String organisationName;
  final String postName;
  final int noOfVacancies;
  final String qualificationNeeded;
  final DateTime lastDateToApply;
  final String linkToApply;
  final String sector;

  JobModel({
    required this.id,
    required this.title,
    required this.organisationName,
    required this.postName,
    required this.noOfVacancies,
    required this.qualificationNeeded,
    required this.lastDateToApply,
    required this.linkToApply,
    required this.sector,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) {
    return JobModel(
      id: json['_id'],
      title: json['title'],
      organisationName: json['organisationName'],
      postName: json['postName'],
      noOfVacancies: json['noOfVacancies'],
      qualificationNeeded: json['qualificationNeeded'],
      lastDateToApply: DateTime.parse(json['lastDateToApply']),
      linkToApply: json['linkToApply'],
      sector: json['sector'],
    );
  }
}

class JobsPage extends StatefulWidget {
  const JobsPage({Key? key}) : super(key: key);

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  // Colors as per requirement
  final Color primaryColor = const Color(0xFF000435);
  final Color accentColor = const Color(0xFFFB7E02);

  bool _isLoading = true;
  List<JobModel> _allJobs = [];
  List<JobModel> _filteredJobs = [];
  bool _showGovtJobs = true;
  bool _showPrivateJobs = true;

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(buildApiUrl('jobs')));
      if (response.statusCode == 200) {
        final List<dynamic> jobsJson = json.decode(response.body);
        _allJobs = jobsJson.map((job) => JobModel.fromJson(job)).toList();
        _applyFilters();
      } else {
        // Handle error
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load jobs: ${response.statusCode}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredJobs = _allJobs.where((job) {
        if (_showGovtJobs && job.sector == 'govt') return true;
        if (_showPrivateJobs && job.sector == 'pvt') return true;
        return false;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: accentColor))
          : Column(
        children: [
          _buildFilterToggle(),
          Expanded(
            child: _filteredJobs.isEmpty
                ? Center(child: Text('No jobs found'))
                : ListView.builder(
              itemCount: _filteredJobs.length,
              itemBuilder: (context, index) {
                final job = _filteredJobs[index];
                return _buildJobListItem(job);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      margin: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primaryColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showGovtJobs = true;
                  _showPrivateJobs = false;
                  _applyFilters();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showGovtJobs && !_showPrivateJobs ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Government",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showGovtJobs = false;
                  _showPrivateJobs = true;
                  _applyFilters();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !_showGovtJobs && _showPrivateJobs ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "Private",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showGovtJobs = true;
                  _showPrivateJobs = true;
                  _applyFilters();
                });
              },
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: _showGovtJobs && _showPrivateJobs ? accentColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  "All",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobListItem(JobModel job) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailPage(job: job, accentColor: accentColor, primaryColor: primaryColor),
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
                  Expanded(
                    child: Text(
                      job.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: job.sector == 'govt' ? Colors.green[50] : Colors.blue[50],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      job.sector == 'govt' ? 'Govt' : 'Private',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: job.sector == 'govt' ? Colors.green[800] : Colors.blue[800],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.organisationName,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.work, size: 16, color: accentColor),
                  const SizedBox(width: 4),
                  Text(
                    job.postName,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(Icons.calendar_today, size: 16, color: accentColor),
                  const SizedBox(width: 4),
                  Text(
                    'Last date: ${_formatDate(job.lastDateToApply)}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// JobDetailPage - Shows when a job is clicked
class JobDetailPage extends StatelessWidget {
  final JobModel job;
  final Color accentColor;
  final Color primaryColor;

  const JobDetailPage({
    Key? key,
    required this.job,
    required this.accentColor,
    required this.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text('Job Details', style: TextStyle(color: Color(0xFF000435))),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF000435)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    job.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 24,
                      color: primaryColor,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: job.sector == 'govt' ? Colors.green[100] : Colors.blue[100],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    job.sector == 'govt' ? 'Government' : 'Private',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: job.sector == 'govt' ? Colors.green[800] : Colors.blue[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailItem(
              'Organisation',
              job.organisationName,
              Icons.business,
              accentColor,
            ),
            _buildDetailItem(
              'Position',
              job.postName,
              Icons.work,
              accentColor,
            ),
            _buildDetailItem(
              'Vacancies',
              job.noOfVacancies.toString(),
              Icons.people,
              accentColor,
            ),
            _buildDetailItem(
              'Qualification',
              job.qualificationNeeded,
              Icons.school,
              accentColor,
            ),
            _buildDetailItem(
              'Last Date to Apply',
              _formatDate(job.lastDateToApply),
              Icons.calendar_today,
              accentColor,
            ),
            const SizedBox(height: 32),
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _launchURL(job.linkToApply);
                },
                icon: Icon(Icons.link),
                label: Text('Apply Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: accentColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value, IconData icon, Color accentColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey[200]!, width: 1),
        ),
      ),
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: accentColor, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 18,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}