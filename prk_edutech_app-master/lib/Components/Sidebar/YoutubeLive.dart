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
  List<Map<String, dynamic>> _youtubeLinks = <Map<String, dynamic>>[];
  bool _loading = true;
  String _errorMessage = '';

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
      appBar: AppBar(
        title: const Text(
          'YouTube Links',
          style:
              TextStyle(color: Color(0xFF000435), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _fetchYoutubeLinks,
            icon: const Icon(Icons.refresh, color: Color(0xFF000435)),
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
                      padding: const EdgeInsets.all(10),
                      itemCount: _youtubeLinks.length,
                      itemBuilder: (context, index) {
                        final item = _youtubeLinks[index];
                        final title = (item['title'] ?? '').toString();
                        final description =
                            (item['description'] ?? '').toString();
                        final link = (item['link'] ?? '').toString();

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  title.isEmpty
                                      ? 'Untitled YouTube Link'
                                      : title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF000435),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  description.isEmpty ? '-' : description,
                                  style: const TextStyle(
                                      fontSize: 14, height: 1.4),
                                ),
                                const SizedBox(height: 10),
                                InkWell(
                                  onTap: () => _openYoutubeLink(link),
                                  child: Text(
                                    link.isEmpty ? 'No link available' : link,
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () => _openYoutubeLink(link),
                                    icon: const Icon(Icons.play_circle_fill),
                                    label: const Text('Open Video'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFFfb7e02),
                                      foregroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
    );
  }
}
