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
    final rawDate = json['lastDateToApply']?.toString() ?? '';
    final parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
    final rawVacancies = json['noOfVacancies'];
    final parsedVacancies = rawVacancies is int
        ? rawVacancies
        : int.tryParse(rawVacancies?.toString() ?? '') ?? 0;
    final rawSector = (json['sector']?.toString() ?? '').toLowerCase();
    final normalizedSector =
        rawSector == 'private' ? 'pvt' : (rawSector == 'government' ? 'govt' : rawSector);

    return JobModel(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Job',
      organisationName: json['organisationName']?.toString() ?? 'Unknown Organisation',
      postName: json['postName']?.toString() ?? 'N/A',
      noOfVacancies: parsedVacancies,
      qualificationNeeded: json['qualificationNeeded']?.toString() ?? 'N/A',
      lastDateToApply: parsedDate,
      linkToApply: json['linkToApply']?.toString() ?? '',
      sector: normalizedSector,
    );
  }
}

class JobsPage extends StatefulWidget {
  const JobsPage({Key? key}) : super(key: key);

  @override
  _JobsPageState createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  final Color primaryColor = const Color(0xFF1F1A4D);
  final Color accentColor = const Color(0xFFFF8A00);
  final Color surfaceColor = const Color(0xFFF6F5FF);
  final Color pageColor = const Color(0xFFF9F9FF);
  final Color borderColor = const Color(0xFFE8E6F8);

  bool _isLoading = true;
  List<JobModel> _allJobs = [];
  List<JobModel> _filteredJobs = [];
  String _selectedSector = 'all';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchJobs();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchJobs() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(buildApiUrl('jobs')));
      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> jobsJson = decoded is List ? decoded : <dynamic>[];
        _allJobs = jobsJson
            .whereType<Map<String, dynamic>>()
            .map((job) => JobModel.fromJson(job))
            .toList();
        _applyFilters();
      } else {
        _allJobs = [];
        _applyFilters();
      }
    } catch (e) {
      _allJobs = [];
      _applyFilters();
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredJobs = _allJobs.where((job) {
        final sector = job.sector.toLowerCase();
        final matchesSector = _selectedSector == 'all' ||
            (_selectedSector == 'govt' && sector == 'govt') ||
            (_selectedSector == 'pvt' &&
                (sector == 'pvt' || sector == 'private'));

        final query = _searchQuery.trim().toLowerCase();
        final matchesQuery = query.isEmpty ||
            job.title.toLowerCase().contains(query) ||
            job.organisationName.toLowerCase().contains(query) ||
            job.postName.toLowerCase().contains(query);

        return matchesSector && matchesQuery;
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pageColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: RefreshIndicator(
                color: accentColor,
                onRefresh: _fetchJobs,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
                  children: [
                    _buildHeroCard(),
                    const SizedBox(height: 14),
                    _buildFilterToggle(),
                    const SizedBox(height: 14),
                    _buildSearchAndFilterBar(),
                    const SizedBox(height: 14),
                    if (_isLoading)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 36),
                        child: Center(
                          child: CircularProgressIndicator(color: accentColor),
                        ),
                      )
                    else if (_filteredJobs.isEmpty)
                      _buildEmptyState()
                    else
                      ..._filteredJobs.map(_buildJobListItem),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFEAFF),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Find the Right',
                  style: TextStyle(
                    color: Color(0xFF191645),
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
                Text(
                  'Opportunity',
                  style: TextStyle(
                    color: Color(0xFFFF8A00),
                    fontSize: 30,
                    fontWeight: FontWeight.w800,
                    height: 1.08,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Explore government and private job opportunities that match your skills and goals.',
                  style: TextStyle(
                    color: Color(0xFF595680),
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 120,
            height: 118,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF5C6BFF), Color(0xFF3D46CC)],
              ),
            ),
            child: Stack(
              alignment: Alignment.center,
              children: const [
                Positioned(
                  top: 22,
                  child: Icon(
                    Icons.work_outline_rounded,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
                Positioned(
                  bottom: 18,
                  child: Icon(
                    Icons.search_rounded,
                    color: Color(0xFFFFC34D),
                    size: 34,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF3F2FA),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        children: [
          _buildSectorButton(
            label: 'Government',
            icon: Icons.account_balance_outlined,
            value: 'govt',
          ),
          _buildSectorButton(
            label: 'Private',
            icon: Icons.work_outline_rounded,
            value: 'pvt',
          ),
          _buildSectorButton(
            label: 'All',
            icon: Icons.grid_view_rounded,
            value: 'all',
          ),
        ],
      ),
    );
  }

  Widget _buildSectorButton({
    required String label,
    required IconData icon,
    required String value,
  }) {
    final bool isSelected = _selectedSector == value;
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          _selectedSector = value;
          _applyFilters();
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
          decoration: BoxDecoration(
            color: isSelected ? accentColor : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: accentColor.withOpacity(0.25),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 16,
                color: isSelected ? Colors.white : primaryColor.withOpacity(0.72),
              ),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isSelected ? Colors.white : primaryColor.withOpacity(0.72),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 50,
            decoration: BoxDecoration(
              color: const Color(0xFFF4F3FA),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: borderColor),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                _searchQuery = value;
                _applyFilters();
              },
              style: TextStyle(color: primaryColor.withOpacity(0.86), fontSize: 14),
              decoration: InputDecoration(
                hintText: 'Search jobs, roles or keywords...',
                hintStyle: TextStyle(
                  color: primaryColor.withOpacity(0.45),
                  fontSize: 14,
                ),
                prefixIcon: Icon(
                  Icons.search_rounded,
                  color: primaryColor.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          width: 96,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFF4F3FA),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: borderColor),
          ),
          child: TextButton.icon(
            onPressed: () {
              _selectedSector = 'all';
              _searchQuery = '';
              _searchController.clear();
              _applyFilters();
            },
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF5541A8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
            icon: const Icon(Icons.filter_alt_outlined, size: 18),
            label: const Text(
              'Filter',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFEFECFF),
              borderRadius: BorderRadius.circular(60),
            ),
            child: Icon(
              Icons.event_seat_outlined,
              size: 54,
              color: primaryColor.withOpacity(0.5),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No jobs found',
            style: TextStyle(
              color: primaryColor,
              fontSize: 32,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "We couldn't find any jobs right now.\nPlease try again later.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: primaryColor.withOpacity(0.62),
              fontSize: 17,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: 145,
            height: 48,
            child: ElevatedButton(
              onPressed: _fetchJobs,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4E3FDB),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Retry',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.refresh_rounded, size: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobListItem(JobModel job) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => JobDetailPage(job: job, accentColor: accentColor, primaryColor: primaryColor),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.title,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: primaryColor,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: job.sector.toLowerCase() == 'govt'
                          ? const Color(0xFFEAF7ED)
                          : const Color(0xFFEAF0FF),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      job.sector.toLowerCase() == 'govt' ? 'Govt' : 'Private',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: job.sector.toLowerCase() == 'govt'
                            ? const Color(0xFF2B7A3B)
                            : const Color(0xFF3859A8),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                job.organisationName,
                style: TextStyle(
                  color: primaryColor.withOpacity(0.7),
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.work_outline_rounded, size: 16, color: accentColor),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.postName,
                      style: TextStyle(
                        fontSize: 13,
                        color: primaryColor.withOpacity(0.82),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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
                      fontSize: 12,
                      color: primaryColor.withOpacity(0.62),
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
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        title: Text('Job Details', style: TextStyle(color: Color(0xFF000435))),
        backgroundColor: const Color(0xFFFFF3E0),
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