import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:testing1/constants.dart';

class YouTubeLiveClassPage extends StatefulWidget {
  const YouTubeLiveClassPage({super.key});

  @override
  State<YouTubeLiveClassPage> createState() => _YouTubeLiveClassPageState();
}

class _YouTubeLiveClassPageState extends State<YouTubeLiveClassPage> {
  static const Color _youtubeColor = Color(0xFFFF7A00);

  List<Map<String, dynamic>> _youtubeLinks = <Map<String, dynamic>>[];
  final Set<String> _savedVideoKeys = <String>{};
  bool _loading = true;
  String _errorMessage = '';

  String? _extractYoutubeVideoId(String link) {
    final String trimmed = link.trim();
    if (trimmed.isEmpty) return null;

    final Uri? uri = Uri.tryParse(trimmed);
    if (uri == null) return null;

    final String host = uri.host.toLowerCase();

    if (host.contains('youtu.be')) {
      return uri.pathSegments.isNotEmpty ? uri.pathSegments.first : null;
    }

    if (host.contains('youtube.com')) {
      final String? queryId = uri.queryParameters['v'];
      if (queryId != null && queryId.isNotEmpty) {
        return queryId;
      }

      if (uri.pathSegments.length >= 2 &&
          (uri.pathSegments.first == 'embed' ||
              uri.pathSegments.first == 'shorts' ||
              uri.pathSegments.first == 'live')) {
        return uri.pathSegments[1];
      }
    }

    final RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );
    final Match? match = regExp.firstMatch(trimmed);
    return match?.group(1);
  }

  Widget _buildYoutubeThumbnail(String link) {
    final String? videoId = _extractYoutubeVideoId(link);

    if (videoId == null) {
      return Container(
        color: const Color(0xFFF2F3F7),
        alignment: Alignment.center,
        child: const Icon(Icons.ondemand_video, size: 44, color: Colors.grey),
      );
    }

    final String thumbnailUrl = 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    return Image.network(
      thumbnailUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFFF2F3F7),
        alignment: Alignment.center,
        child: const Icon(
          Icons.broken_image_outlined,
          size: 44,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildYoutubeCard(Map<String, dynamic> item) {
    final String id = (item['_id'] ?? '').toString();
    final String title = (item['title'] ?? '').toString();
    final String description = (item['description'] ?? '').toString();
    final String link = (item['link'] ?? '').toString();
    final String key = id.isEmpty ? '$title-$link' : id;
    final bool isSaved = _savedVideoKeys.contains(key);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 145,
              height: 138,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _buildYoutubeThumbnail(link),
                    Positioned(
                      left: 8,
                      bottom: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.68),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          '04:35',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 138),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'YouTube',
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(),
                        InkWell(
                          onTap: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('More actions soon')),
                            );
                          },
                          borderRadius: BorderRadius.circular(14),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Icon(
                              Icons.more_vert,
                              color: Colors.grey.shade700,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      title.isEmpty ? 'Untitled YouTube Link' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1E3B),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      description.isEmpty ? '-' : description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: ElevatedButton.icon(
                              onPressed: () => _openYoutubeLink(link),
                              icon: const Icon(Icons.play_circle_fill, size: 18),
                              label: const Text(
                                'Open Video',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _youtubeColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                textStyle: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (isSaved) {
                                _savedVideoKeys.remove(key);
                              } else {
                                _savedVideoKeys.add(key);
                              }
                            });
                          },
                          borderRadius: BorderRadius.circular(18),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white,
                              border: Border.all(color: Colors.grey.shade300),
                            ),
                            child: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? const Color(0xFF4B2EE8) : Colors.grey.shade700,
                              size: 20,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _fetchYoutubeLinks();
  }

  Future<void> _fetchYoutubeLinks() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(buildApiUrl('youtube-links')));
      if (response.statusCode != 200) {
        throw Exception('Failed to load youtube links');
      }

      final dynamic decoded = json.decode(response.body);
      final List<Map<String, dynamic>> parsed = decoded is List
          ? decoded.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[];

      setState(() {
        _youtubeLinks = parsed;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
        _errorMessage = error.toString();
      });
    }
  }

  Future<void> _openYoutubeLink(String link) async {
    if (link.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invalid YouTube link')),
      );
      return;
    }

    final Uri uri = Uri.parse(link.trim());
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to open link')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'YouTube Links',
          style:
              TextStyle(color: Color(0xFF000435), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF9FAFC),
        actions: [
          IconButton(
            onPressed: _fetchYoutubeLinks,
            icon: const Icon(Icons.refresh, color: Color(0xFF4B2EE8)),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFfb7e02)))
          : _errorMessage.isNotEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(_errorMessage, textAlign: TextAlign.center),
                  ),
                )
              : _youtubeLinks.isEmpty
                  ? const Center(
                      child: Text(
                        'No YouTube links available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                      itemCount: _youtubeLinks.length,
                      itemBuilder: (context, index) {
                        final item = _youtubeLinks[index];
                        return _buildYoutubeCard(item);
                      },
                    ),
    );
  }
}
