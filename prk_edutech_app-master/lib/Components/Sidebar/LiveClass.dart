import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class LiveClassPage extends StatefulWidget {
  const LiveClassPage({super.key});

  @override
  State<LiveClassPage> createState() => _LiveClassPageState();
}

class _LiveClassPageState extends State<LiveClassPage> {
  static const Color _primaryColor = Color(0xFF4B2EE8);

  List<Map<String, dynamic>> _onlineClasses = <Map<String, dynamic>>[];
  final Set<String> _savedClassKeys = <String>{};
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

  String _formatDateDisplay(String value) {
    if (value.trim().isEmpty) return '';
    final DateTime? parsed = DateTime.tryParse(value);
    if (parsed == null) return value;
    const List<String> months = <String>[
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${parsed.day} ${months[parsed.month - 1]} ${parsed.year}';
  }

  String _normalizeDuration(String value) {
    final String trimmed = value.trim();
    final RegExp durationExp = RegExp(r'^\d{1,2}:\d{2}$');
    if (durationExp.hasMatch(trimmed)) return trimmed;
    return '03:00';
  }

  Future<void> _openClassLink(String link) async {
    if (link.trim().isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Video link not available')),
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

  Widget _buildImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return Container(
        color: const Color(0xFF000435).withOpacity(0.08),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Color(0xFF000435)),
        ),
      );
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        color: const Color(0xFF000435).withOpacity(0.08),
        child: const Center(
          child: Icon(Icons.image_not_supported, color: Color(0xFF000435)),
        ),
      ),
    );
  }

  Widget _buildOnlineClassCard(Map<String, dynamic> item) {
    final String id = (item['_id'] ?? '').toString();
    final String title = (item['title'] ?? '').toString();
    final String description = (item['description'] ?? '').toString();
    final String date = (item['date'] ?? '').toString();
    final String time = (item['time'] ?? '').toString();
    final String link = (item['link'] ?? item['videoUrl'] ?? '').toString();
    final String imageUrl = _resolveImageUrl((item['img'] ?? '').toString());
    final String key = id.isEmpty ? '$title-$date-$time' : id;
    final bool isSaved = _savedClassKeys.contains(key);
    final String dateText = _formatDateDisplay(date);
    final String meta = dateText.isEmpty
        ? ''
        : '$dateText${time.trim().isEmpty ? '' : '  |  $time'}';

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
                    _buildImage(imageUrl),
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
                        child: Text(
                          _normalizeDuration(time),
                          style: const TextStyle(
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
                            color: _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Online Class',
                            style: TextStyle(
                              color: _primaryColor,
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
                      title.isEmpty ? 'Untitled Online Class' : title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1E3B),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    if (meta.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        meta,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      description.isEmpty ? '-' : description,
                      maxLines: 1,
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
                              onPressed: () => _openClassLink(link),
                              icon: const Icon(Icons.play_circle_fill, size: 18),
                              label: const Text(
                                'Watch Now',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: _primaryColor,
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
                                _savedClassKeys.remove(key);
                              } else {
                                _savedClassKeys.add(key);
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
                              color: isSaved ? _primaryColor : Colors.grey.shade700,
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
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Online Class',
          style:
              TextStyle(color: Color(0xFF000435), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFF9FAFC),
        actions: [
          IconButton(
            onPressed: _fetchOnlineClasses,
            icon: const Icon(Icons.refresh, color: _primaryColor),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _primaryColor))
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
                      padding: const EdgeInsets.fromLTRB(10, 10, 10, 16),
                      itemCount: _onlineClasses.length,
                      itemBuilder: (context, index) {
                        final item = _onlineClasses[index];
                        return _buildOnlineClassCard(item);
                      },
                    ),
    );
  }
}
