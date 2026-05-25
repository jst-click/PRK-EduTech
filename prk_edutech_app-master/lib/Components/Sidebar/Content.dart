import 'package:flutter/material.dart';

class CourseDetailsPage extends StatelessWidget {
  final String courseId;
  
  const CourseDetailsPage({Key? key, required this.courseId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Course Details'),
          backgroundColor: const Color(0xFFFB7F03),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Subjects'),
              Tab(text: 'Syllabus'),
            ],
            indicatorColor: Colors.white,
            labelColor: Colors.white,
          ),
        ),
        body: TabBarView(
          children: [
            _buildSubjectsTab(),
            _buildSyllabusTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10, // Replace with actual subject count
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: CircleAvatar(
              backgroundColor: const Color(0xFF000435),
              child: Text('${index + 1}', style: const TextStyle(color: Colors.white)),
            ),
            title: Text(
              'Subject ${index + 1}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF000435),
              ),
            ),
            subtitle: const Text(
              'Brief description of the subject content',
              style: TextStyle(color: Colors.grey),
            ),
            onTap: () {
              // Navigate to subject details
            },
          ),
        );
      },
    );
  }

  Widget _buildSyllabusTab() {
    // Sample syllabus data - replace with actual data
    final List<Map<String, dynamic>> syllabusItems = [
      {
        'title': 'Module 1: Introduction',
        'topics': ['Overview', 'Basic Concepts', 'History']
      },
      {
        'title': 'Module 2: Core Concepts',
        'topics': ['Topic A', 'Topic B', 'Topic C', 'Topic D']
      },
      {
        'title': 'Module 3: Advanced Topics',
        'topics': ['Advanced A', 'Advanced B', 'Case Studies']
      },
    ];

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: syllabusItems.length,
      itemBuilder: (context, index) {
        final module = syllabusItems[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ExpansionTile(
            title: Text(
              module['title'],
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF000435),
              ),
            ),
            collapsedBackgroundColor: Colors.white,
            backgroundColor: Colors.white,
            iconColor: const Color(0xFFFB7F03),
            collapsedIconColor: const Color(0xFFFB7F03),
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: module['topics'].length,
                  itemBuilder: (context, topicIndex) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.circle, size: 8, color: Color(0xFFFB7F03)),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              module['topics'][topicIndex],
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF000435),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}