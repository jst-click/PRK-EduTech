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
      title: 'Educational Resources',
      theme: ThemeData(
        primaryColor: Color(0xFF000435),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF000435),
          secondary: Color(0xFFfb7e02),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: EbookAppBooks(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class EbookAppBooks extends StatefulWidget {
  @override
  _EbookAppBooksState createState() => _EbookAppBooksState();
}

class _EbookAppBooksState extends State<EbookAppBooks> with SingleTickerProviderStateMixin {
  List<dynamic> resources = [];
  bool isLoading = true;
  String selectedCategory = 'all';

  String _safeText(dynamic value, {String fallback = 'N/A'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _safeUpper(dynamic value, {String fallback = 'N/A'}) {
    return _safeText(value, fallback: fallback).toUpperCase();
  }

  @override
  void initState() {
    super.initState();
    // Set selectedCategory to 'ebook' to only show ebooks
    selectedCategory = 'ebook';
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

  List<dynamic> getFilteredResources() {
    if (selectedCategory == 'all') {
      return resources;
    } else {
      return resources.where((resource) => resource['contentType'] == selectedCategory).toList();
    }
  }

  Widget _buildResourceCard(dynamic resource) {
    final resourceId = _safeText(resource['_id'], fallback: '');
    final imageUrl = _safeText(resource['imageUrl'], fallback: '');
    final title = _safeText(resource['title'], fallback: 'Untitled Resource');
    final description =
        _safeText(resource['description'], fallback: 'No description available');
    final author = _safeText(resource['author'], fallback: 'Unknown Author');
    final contentType = _safeUpper(resource['contentType'], fallback: 'EBOOK');

    // Check if imageUrl is a base64 encoded string
    bool isBase64Image = imageUrl.startsWith('data:image');

    return GestureDetector(
      onTap: () {
        if (resourceId.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Unable to open this ebook right now')),
          );
          return;
        }
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResourceDetailPage(resourceId: resourceId),
          ),
        );
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 150,
                width: double.infinity,
                child: isBase64Image
                    ? Image.memory(
                  base64Decode(imageUrl.split(',')[1]),
                  fit: BoxFit.cover,
                )
                    : CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFfb7e02),
                    ),
                  ),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000435),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.person, size: 16, color: Color(0xFFfb7e02)),
                          SizedBox(width: 4),
                          Text(
                            author,
                            style: TextStyle(fontSize: 14),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFFfb7e02).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          contentType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFfb7e02),
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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredResources = getFilteredResources();

    return Scaffold(
      body: isLoading
          ? Center(
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
              Icons.library_books,
              size: 80,
              color: Color(0xFF000435).withOpacity(0.3),
            ),
            SizedBox(height: 16),
            Text(
              'No ${selectedCategory == 'notes' ? 'Notes' : 'Ebooks'} Found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF000435),
              ),
            ),
            SizedBox(height: 8),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: fetchResources,
        color: Color(0xFFfb7e02),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(vertical: 16),
          itemCount: filteredResources.length,
          itemBuilder: (context, index) {
            return _buildResourceCard(filteredResources[index]);
          },
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

  String _safeText(dynamic value, {String fallback = 'N/A'}) {
    final text = value?.toString().trim() ?? '';
    return text.isEmpty ? fallback : text;
  }

  String _safeUpper(dynamic value, {String fallback = 'N/A'}) {
    return _safeText(value, fallback: fallback).toUpperCase();
  }

  Future<String?> _resolvePdfUrl(String currentUrl) async {
    final bookId = _safeText(resourceDetail['_id'], fallback: '');
    if (bookId.isEmpty) return null;

    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('ebooks/$bookId/download-url')),
      );
      if (response.statusCode != 200) return null;

      final decoded = json.decode(response.body);
      if (decoded is! Map<String, dynamic>) return null;

      final resolvedUrl = _safeText(decoded['url'], fallback: '');
      if (resolvedUrl.isEmpty || resolvedUrl == currentUrl) return null;
      return resolvedUrl;
    } catch (_) {
      return null;
    }
  }

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
    var pdfUrl = (resourceDetail['pdfUrl'] ?? '').toString().trim();
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
      var response = await http.get(Uri.parse(pdfUrl));
      if (response.statusCode != 200 || response.bodyBytes.isEmpty) {
        final fallbackUrl = await _resolvePdfUrl(pdfUrl);
        if (fallbackUrl != null) {
          pdfUrl = fallbackUrl;
          response = await http.get(Uri.parse(pdfUrl));
        }
      }

      if (response.statusCode != 200) {
        throw Exception('PDF request failed with status ${response.statusCode}');
      }
      if (response.bodyBytes.isEmpty) {
        throw Exception('Received empty PDF file from server');
      }

      // Get temporary directory
      final dir = await getTemporaryDirectory();

      // Create a file name from the resource ID and title
      final String fileName = '${resourceDetail['_id']}_${resourceDetail['title']}.pdf';
      final String filePath = '${dir.path}/$fileName';

      // Write the PDF to temporary storage
      final File file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      setState(() {
        pdfPath = filePath;
        isPdfLoading = false;
      });

      // Navigate to PDF viewer
      final title = _safeText(
        resourceDetail['title'],
        fallback: 'Educational Resource',
      );
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PdfViewerPage(
            pdfPath: filePath,
            title: title,
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
    final title = _safeText(
      resourceDetail['title'],
      fallback: 'Educational Resource',
    );
    final imageUrl = _safeText(resourceDetail['imageUrl'], fallback: '');
    final description =
        _safeText(resourceDetail['description'], fallback: 'No description available');
    final contentType = _safeUpper(resourceDetail['contentType'], fallback: 'EBOOK');
    final difficultyLevel =
        _safeUpper(resourceDetail['difficultyLevel'], fallback: 'GENERAL');
    final pricing = _safeText(resourceDetail['pricing'], fallback: 'free').toLowerCase();
    final author = _safeText(resourceDetail['author'], fallback: 'Unknown Author');
    final subject = _safeText(resourceDetail['subject'], fallback: 'General');
    final createdAt = _safeText(resourceDetail['createdAt'], fallback: '');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isLoading ? 'Loading...' : title,
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF000435),
        iconTheme: IconThemeData(color: Colors.white),
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
              child: isBase64Image(imageUrl)
                  ? Image.memory(
                base64Decode(imageUrl.split(',')[1]),
                fit: BoxFit.cover,
              )
                  : CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFFfb7e02),
                  ),
                ),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
            ),

            // Content section
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
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
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFFfb7e02).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          contentType,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFFfb7e02),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: Color(0xFF000435).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          difficultyLevel,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000435),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: pricing == 'free'
                              ? Colors.green.withOpacity(0.2)
                              : Colors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          pricing.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: pricing == 'free'
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
                    description,
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
                        _buildDetailItem('Author', author, Icons.person),
                        Divider(height: 1),
                        _buildDetailItem('Subject', subject, Icons.subject),
                        Divider(height: 1),
                        _buildDetailItem('Added On', _formatDate(createdAt), Icons.calendar_today),
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
                      label: Text(isPdfLoading ? 'Opening PDF...' : 'Open PDF'),
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
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Color(0xFF000435),
        iconTheme: IconThemeData(color: Colors.white),
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
            backgroundColor: _currentPage > 0 ? Color(0xFFfb7e02) : Colors.grey,
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
            backgroundColor: _currentPage < _totalPages - 1 ? Color(0xFFfb7e02) : Colors.grey,
            child: Icon(Icons.arrow_forward),
            mini: true,
          ),
        ],
      )
          : null,
    );
  }
}