import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:testing1/constants.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Educational Notes',
      theme: ThemeData(
        primaryColor: Color(0xFF000435),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF000435),
          secondary: Color(0xFFfb7e02),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: AllNotesPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class AllNotesPage extends StatefulWidget {
  @override
  _AllNotesPageState createState() => _AllNotesPageState();
}

class _AllNotesPageState extends State<AllNotesPage>
    with SingleTickerProviderStateMixin {
  List<dynamic> resources = [];
  bool isLoading = true;
  String selectedCategory = 'all';
  final List<Map<String, dynamic>> _categoryOptions = const [
    {'value': 'all', 'label': 'All', 'icon': Icons.apps_outlined},
    {'value': 'class', 'label': 'Class Notes', 'icon': Icons.school_outlined},
    {
      'value': 'handwritten',
      'label': 'Handwritten',
      'icon': Icons.edit_note_outlined
    },
    {'value': 'pdf', 'label': 'PDF', 'icon': Icons.picture_as_pdf_outlined},
    {'value': 'filters', 'label': 'Filters', 'icon': Icons.tune_outlined},
  ];

  String _safeText(dynamic value, {String fallback = 'N/A'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  @override
  void initState() {
    super.initState();
    selectedCategory = 'all';
    fetchResources();
  }

  Future<void> fetchResources() async {
    setState(() {
      isLoading = true;
    });

    try {
      http.Response? successResponse;
      for (final endpoint in resourceListApiCandidates()) {
        final response = await http.get(Uri.parse(endpoint));
        if (response.statusCode == 200) {
          successResponse = response;
          break;
        }
      }

      if (successResponse != null) {
        final decoded = json.decode(successResponse.body);
        setState(() {
          resources = normalizeResourceList(decoded);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load resources')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  bool _isNote(dynamic resource) {
    return _safeText(resource['contentType']).toLowerCase() == 'notes';
  }

  bool _matchesCategory(dynamic resource) {
    if (selectedCategory == 'all' || selectedCategory == 'filters') {
      return true;
    }

    final searchable = [
      _safeText(resource['title']),
      _safeText(resource['description']),
      _safeText(resource['subject']),
      _safeText(resource['author']),
    ].join(' ').toLowerCase();

    return searchable.contains(selectedCategory);
  }

  List<dynamic> getFilteredResources() {
    return resources
        .where((resource) => _isNote(resource) && _matchesCategory(resource))
        .toList();
  }

  void _openResource(String resourceId) {
    if (resourceId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open this note right now')),
      );
      return;
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ResourceDetailPage(resourceId: resourceId),
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 6),
      child: Row(
        children: _categoryOptions.map((option) {
          final value = option['value'] as String;
          final isSelected = selectedCategory == value;
          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: InkWell(
              borderRadius: BorderRadius.circular(14),
              onTap: () {
                setState(() {
                  selectedCategory = value;
                });
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFFFFF0E0) : Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected
                        ? const Color(0xFFf59d1c)
                        : const Color(0xFFE9E7E2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      option['icon'] as IconData,
                      size: 18,
                      color: isSelected
                          ? const Color(0xFFf59d1c)
                          : const Color(0xFF484848),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      option['label'] as String,
                      style: TextStyle(
                        color: const Color(0xFF20222A),
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildCoverImage(String imageUrl,
      {double height = 200, double width = double.infinity}) {
    final isBase64Image = imageUrl.startsWith('data:image');
    final borderRadius = BorderRadius.circular(16);

    if (isBase64Image) {
      try {
        return ClipRRect(
          borderRadius: borderRadius,
          child: Image.memory(
            base64Decode(imageUrl.split(',')[1]),
            height: height,
            width: width,
            fit: BoxFit.cover,
          ),
        );
      } catch (_) {}
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: CachedNetworkImage(
        imageUrl: imageUrl,
        height: height,
        width: width,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          height: height,
          width: width,
          color: const Color(0xFFEDEDED),
          alignment: Alignment.center,
          child: const CircularProgressIndicator(color: Color(0xFFfb7e02)),
        ),
        errorWidget: (context, url, error) => Container(
          height: height,
          width: width,
          color: const Color(0xFFEDEDED),
          alignment: Alignment.center,
          child: const Icon(Icons.sticky_note_2_rounded,
              color: Color(0xFF9A9A9A)),
        ),
      ),
    );
  }

  Widget _buildFeaturedCard(dynamic resource) {
    final resourceId = _safeText(resource['_id'], fallback: '');
    final imageUrl = _safeText(resource['imageUrl'], fallback: '');
    final title = _safeText(resource['title'], fallback: 'Untitled note');
    final description = _safeText(resource['description'],
        fallback: 'Detailed notes for fast revision and deep understanding.');
    final author = _safeText(resource['author'], fallback: 'Unknown');
    final pages = _safeText(
      resource['pages'] ?? resource['pageCount'] ?? resource['totalPages'],
      fallback: '--',
    );
    final size = _safeText(
      resource['fileSize'] ?? resource['size'] ?? resource['pdfSize'],
      fallback: '--',
    );

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () => _openResource(resourceId),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _buildCoverImage(imageUrl, height: 200),
                ),
                Positioned(
                  top: 22,
                  right: 24,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1D2342).withOpacity(0.78),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFD69A)),
                    ),
                    child: const Text(
                      'PDF',
                      style: TextStyle(
                        color: Color(0xFFFFE7C0),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 2, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF2E4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.sticky_note_2_rounded,
                        color: Color(0xFFef8306),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF121528),
                            ),
                          ),
                          const SizedBox(height: 2),
                          const Text(
                            'Note Title',
                            style: TextStyle(
                              color: Color(0xFF7E7E88),
                              fontSize: 21,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    height: 1.35,
                    color: Color(0xFF56596C),
                    fontSize: 17,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE7E7E7)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.person_rounded,
                                color: Color(0xFFef8306)),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                author,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE7E7E7)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.description_outlined,
                                color: Color(0xFF545977)),
                            const SizedBox(width: 8),
                            Text(
                              pages,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            const Text(' pages'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 10),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE7E7E7)),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.auto_awesome,
                                color: Color(0xFF635BCE)),
                            const SizedBox(width: 8),
                            Text(
                              size,
                              style:
                                  const TextStyle(fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () => _openResource(resourceId),
                        icon: const Icon(Icons.download_rounded, size: 18),
                        label: const Text('NOTES'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFef8306),
                          foregroundColor: Colors.white,
                          elevation: 0,
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactCard(dynamic resource) {
    final resourceId = _safeText(resource['_id'], fallback: '');
    final imageUrl = _safeText(resource['imageUrl'], fallback: '');
    final title = _safeText(resource['title'], fallback: 'Untitled note');
    final subject = _safeText(resource['subject'], fallback: 'Quick Revision');

    return GestureDetector(
      onTap: () => _openResource(resourceId),
      child: Container(
        width: 172,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: const [
            BoxShadow(
              color: Color(0x12000000),
              blurRadius: 10,
              offset: Offset(0, 3),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                _buildCoverImage(imageUrl, height: 106, width: 172),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.62),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'PDF',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: Color(0xFF1B1D2B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subject,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style:
                        const TextStyle(fontSize: 12, color: Color(0xFF6D7082)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = getFilteredResources();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF9F4),
      appBar: AppBar(
        titleSpacing: 0,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              'Educational Notes',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF0F1230),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'Explore and download notes to learn anytime',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF686B7A),
                fontSize: 13,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFFFF3E0),
        elevation: 0.1,
        toolbarHeight: 74,
        iconTheme: const IconThemeData(color: Color(0xFF191B2F)),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFFBEAD5),
              borderRadius: BorderRadius.circular(14),
            ),
            child: IconButton(
              onPressed: () {},
              icon: const Icon(Icons.search, color: Color(0xFF191B2F)),
            ),
          )
        ],
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Color(0xFFfb7e02),
              ),
            )
          : filteredResources.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.sticky_note_2_outlined,
                        size: 80,
                        color: const Color(0xFF000435).withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'No notes found',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF000435),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add notes from admin panel to show here',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: fetchResources,
                  color: const Color(0xFFfb7e02),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      _buildCategoryFilter(),
                      _buildFeaturedCard(filteredResources.first),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
                        child: Row(
                          children: const [
                            Expanded(
                              child: Text(
                              'More Notes for You',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF15172C),
                              ),
                            ),
                            ),
                            SizedBox(width: 10),
                            Text(
                              'View All',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w500,
                                color: Color(0xFFef8306),
                              ),
                            )
                          ],
                        ),
                      ),
                      if (filteredResources.length <= 1)
                        const Padding(
                          padding: EdgeInsets.fromLTRB(16, 6, 16, 20),
                          child: Text(
                            'Add more notes from admin panel to show suggestions here.',
                            style: TextStyle(color: Color(0xFF7D8192)),
                          ),
                        )
                      else
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            padding: const EdgeInsets.fromLTRB(16, 6, 4, 18),
                            itemCount: filteredResources.length - 1,
                            itemBuilder: (context, index) {
                              return _buildCompactCard(
                                filteredResources[index + 1],
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

class ResourceDetailPage extends StatefulWidget {
  final String resourceId;

  ResourceDetailPage({required this.resourceId});

  @override
  _ResourceDetailPageState createState() => _ResourceDetailPageState();
}

class _ResourceDetailPageState extends State<ResourceDetailPage> {
  Map<String, dynamic> resourceDetail = {};
  bool isLoading = true;
  String? pdfPath;
  bool isPdfLoading = false;

  @override
  void initState() {
    super.initState();
    fetchResourceDetail();
  }

  Future<void> fetchResourceDetail() async {
    setState(() {
      isLoading = true;
    });

    try {
      http.Response? successResponse;
      for (final endpoint in resourceDetailApiCandidates(widget.resourceId)) {
        final response = await http.get(Uri.parse(endpoint));
        if (response.statusCode == 200) {
          successResponse = response;
          break;
        }
      }

      if (successResponse != null) {
        final decoded = json.decode(successResponse.body);
        setState(() {
          resourceDetail = decoded is Map<String, dynamic>
              ? normalizeResourceItem(decoded)
              : <String, dynamic>{};
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load resource details')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  Future<void> downloadAndOpenPdf() async {
    final pdfUrl = (resourceDetail['pdfUrl'] ?? '').toString();
    if (pdfUrl.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No PDF available for this resource')),
      );
      return;
    }

    setState(() {
      isPdfLoading = true;
    });

    try {
      // Get the PDF from network
      final response = await http.get(Uri.parse(pdfUrl));

      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create a file name from the resource ID and title
      final String fileName =
          '${resourceDetail['_id']}_${resourceDetail['title']}.pdf';
      final String filePath = '${dir.path}/$fileName';

      // Write the PDF to temporary storage
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        pdfPath = filePath;
        isPdfLoading = false;
      });

      // Navigate to PDF viewer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            pdfPath: filePath,
            title: resourceDetail['title'],
          ),
        ),
      );
    } catch (e) {
      setState(() {
        isPdfLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error downloading PDF: ${e.toString()}')),
      );
    }
  }

  bool isBase64Image(String url) {
    return url.startsWith('data:image');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? 'Loading...' : resourceDetail['title'],
          style: TextStyle(color: Color(0xFF000435)),
        ),
        backgroundColor: const Color(0xFFFFF3E0),
        iconTheme: IconThemeData(color: Color(0xFF000435)),
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Color(0xFFfb7e02),
              ),
            )
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image section
                  Container(
                    height: 200,
                    width: double.infinity,
                    child: isBase64Image(resourceDetail['imageUrl'])
                        ? Image.memory(
                            base64Decode(
                                resourceDetail['imageUrl'].split(',')[1]),
                            fit: BoxFit.cover,
                          )
                        : CachedNetworkImage(
                            imageUrl: resourceDetail['imageUrl'],
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Center(
                              child: CircularProgressIndicator(
                                color: Color(0xFFfb7e02),
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                Icon(Icons.error),
                          ),
                  ),

                  // Content section
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          resourceDetail['title'],
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000435),
                          ),
                        ),
                        SizedBox(height: 8),

                        // Tags row
                        Row(
                          children: [
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFFfb7e02).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                resourceDetail['contentType'].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFFfb7e02),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: Color(0xFF000435).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                resourceDetail['difficultyLevel'].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF000435),
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              decoration: BoxDecoration(
                                color: resourceDetail['pricing'] == 'free'
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.red.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                resourceDetail['pricing'].toUpperCase(),
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: resourceDetail['pricing'] == 'free'
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: 16),

                        // Description
                        Text(
                          'Description',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000435),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          resourceDetail['description'],
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[800],
                          ),
                        ),

                        SizedBox(height: 16),

                        // Details section
                        Text(
                          'Details',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000435),
                          ),
                        ),
                        SizedBox(height: 8),

                        // Details cards
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            children: [
                              _buildDetailItem('Author',
                                  resourceDetail['author'], Icons.person),
                              Divider(height: 1),
                              _buildDetailItem('Subject',
                                  resourceDetail['subject'], Icons.subject),
                              Divider(height: 1),
                              _buildDetailItem(
                                  'Added On',
                                  _formatDate(resourceDetail['createdAt']),
                                  Icons.calendar_today),
                            ],
                          ),
                        ),

                        SizedBox(height: 24),

                        // PDF Open button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: isPdfLoading ? null : downloadAndOpenPdf,
                            icon: isPdfLoading
                                ? SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(Icons.picture_as_pdf),
                            label: Text(
                                isPdfLoading ? 'Opening PDF...' : 'Open PDF'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color(0xFFfb7e02),
                              padding: EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildDetailItem(String title, String value, IconData icon) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Color(0xFF000435), size: 20),
          SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  value,
                  style: TextStyle(
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

  String _formatDate(String dateString) {
    final date = DateTime.tryParse(dateString);
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }
}

class PdfViewerPage extends StatefulWidget {
  final String pdfPath;
  final String title;

  PdfViewerPage({required this.pdfPath, required this.title});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  int _totalPages = 0;
  int _currentPage = 0;
  bool _isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(color: Color(0xFF000435)),
        ),
        backgroundColor: const Color(0xFFFFF3E0),
        iconTheme: IconThemeData(color: Color(0xFF000435)),
        actions: [
          if (_totalPages > 0)
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  'Page ${_currentPage + 1} of $_totalPages',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          PDFView(
            filePath: widget.pdfPath,
            enableSwipe: true,
            swipeHorizontal: true,
            autoSpacing: true,
            pageFling: true,
            pageSnap: true,
            defaultPage: _currentPage,
            fitPolicy: FitPolicy.BOTH,
            preventLinkNavigation: false,
            onRender: (_pages) {
              setState(() {
                _totalPages = _pages!;
                _isLoading = false;
              });
            },
            onError: (error) {
              setState(() {
                _isLoading = false;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $error')),
              );
            },
            onPageError: (page, error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error loading page $page: $error')),
              );
            },
            onViewCreated: (PDFViewController pdfViewController) {
              // You can save the controller for further use
            },
            onPageChanged: (int? page, int? total) {
              if (page != null) {
                setState(() {
                  _currentPage = page;
                });
              }
            },
          ),
          if (_isLoading)
            Center(
              child: CircularProgressIndicator(
                color: Color(0xFFfb7e02),
              ),
            ),
        ],
      ),
      floatingActionButton: _totalPages > 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  heroTag: 'prev',
                  onPressed: _currentPage > 0
                      ? () {
                          setState(() {
                            _currentPage--;
                          });
                          // You would need PDFViewController to jump to specific page
                        }
                      : null,
                  backgroundColor:
                      _currentPage > 0 ? Color(0xFFfb7e02) : Colors.grey,
                  child: Icon(Icons.arrow_back),
                  mini: true,
                ),
                SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: 'next',
                  onPressed: _currentPage < _totalPages - 1
                      ? () {
                          setState(() {
                            _currentPage++;
                          });
                          // You would need PDFViewController to jump to specific page
                        }
                      : null,
                  backgroundColor: _currentPage < _totalPages - 1
                      ? Color(0xFFfb7e02)
                      : Colors.grey,
                  child: Icon(Icons.arrow_forward),
                  mini: true,
                ),
              ],
            )
          : null,
    );
  }
}
