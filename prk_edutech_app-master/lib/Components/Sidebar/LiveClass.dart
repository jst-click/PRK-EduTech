import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';

class LiveClassPage extends StatefulWidget {
  const LiveClassPage({super.key});

  @override
  State<LiveClassPage> createState() => _LiveClassPageState();
}

class _LiveClassPageState extends State<LiveClassPage> {
  List<Map<String, dynamic>> _onlineClasses = <Map<String, dynamic>>[];
  bool _loading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchOnlineClasses();
  }

  Future<void> _fetchOnlineClasses() async {
    setState(() {
      _loading = true;
      _errorMessage = '';
    });

    try {
      final response = await http.get(Uri.parse(buildApiUrl('online-classes')));
      if (response.statusCode != 200) {
        throw Exception('Failed to load online classes');
      }

      final dynamic decoded = json.decode(response.body);
      final List<Map<String, dynamic>> parsed = decoded is List
          ? decoded.whereType<Map<String, dynamic>>().toList()
          : <Map<String, dynamic>>[];

      setState(() {
        _onlineClasses = parsed;
        _loading = false;
      });
    } catch (error) {
      setState(() {
        _loading = false;
        _errorMessage = error.toString();
      });
    }
  }

  String _resolveImageUrl(String raw) {
    if (raw.isEmpty) return '';
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return buildBaseUrl(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Online Class',
          style:
              TextStyle(color: Color(0xFF000435), fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _fetchOnlineClasses,
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
              : _onlineClasses.isEmpty
                  ? const Center(
                      child: Text(
                        'No online class available',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(10),
                      itemCount: _onlineClasses.length,
                      itemBuilder: (context, index) {
                        final item = _onlineClasses[index];
                        final title = (item['title'] ?? '').toString();
                        final description =
                            (item['description'] ?? '').toString();
                        final date = (item['date'] ?? '').toString();
                        final time = (item['time'] ?? '').toString();
                        final imageUrl =
                            _resolveImageUrl((item['img'] ?? '').toString());

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
                                if (imageUrl.isNotEmpty)
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 9,
                                      child: Image.network(
                                        imageUrl,
                                        fit: BoxFit.cover,
                                        errorBuilder: (_, __, ___) => Container(
                                          color: const Color(0xFF000435)
                                              .withOpacity(0.08),
                                          child: const Center(
                                            child: Icon(
                                                Icons.image_not_supported,
                                                color: Color(0xFF000435)),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (imageUrl.isNotEmpty)
                                  const SizedBox(height: 10),
                                Text(
                                  title.isEmpty
                                      ? 'Untitled Online Class'
                                      : title,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    color: Color(0xFF000435),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Date: ${date.isEmpty ? '-' : date}   Time: ${time.isEmpty ? '-' : time}',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  description.isEmpty ? '-' : description,
                                  style: const TextStyle(
                                      fontSize: 14, height: 1.4),
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
