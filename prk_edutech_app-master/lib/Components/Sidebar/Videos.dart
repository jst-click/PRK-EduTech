import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';
import 'package:url_launcher/url_launcher.dart';

class AllVideosPage extends StatefulWidget {
  const AllVideosPage({super.key});

  @override
  State<AllVideosPage> createState() => _AllVideosPageState();
}

class _AllVideosPageState extends State<AllVideosPage> {
  static const Color _primaryColor = Color(0xFF4B2EE8);
  static const Color _youtubeColor = Color(0xFFFF7A00);

  List<_AllVideoItem> _items = <_AllVideoItem>[];
  final Set<String> _savedVideoKeys = <String>{};
  _VideoFilter _selectedFilter = _VideoFilter.all;
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAllVideos();
  }

  Future<void> _fetchAllVideos() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    final List<_AllVideoItem> allItems = <_AllVideoItem>[];
    final List<String> errors = <String>[];

    try {
      allItems.addAll(await _fetchOnlineClasses());
    } catch (_) {
      errors.add('online classes');
    }

    try {
      allItems.addAll(await _fetchYoutubeLinks());
    } catch (_) {
      errors.add('youtube videos');
    }

    if (!mounted) return;

    setState(() {
      _items = allItems;
      _isLoading = false;
      if (_items.isEmpty && errors.isNotEmpty) {
        _errorMessage =
            'Failed to load ${errors.join(' and ')}. Please try again.';
      }
    });
  }

  Future<List<_AllVideoItem>> _fetchOnlineClasses() async {
    final http.Response response =
        await http.get(Uri.parse(buildApiUrl('online-classes')));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch online classes');
    }

    final dynamic decoded = json.decode(response.body);
    final List<Map<String, dynamic>> parsed = decoded is List
        ? decoded.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    return parsed.map(_AllVideoItem.fromOnlineClass).toList();
  }

  Future<List<_AllVideoItem>> _fetchYoutubeLinks() async {
    final http.Response response =
        await http.get(Uri.parse(buildApiUrl('youtube-links')));

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch youtube links');
    }

    final dynamic decoded = json.decode(response.body);
    final List<Map<String, dynamic>> parsed = decoded is List
        ? decoded.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    return parsed.map(_AllVideoItem.fromYoutubeLink).toList();
  }

  List<_AllVideoItem> get _visibleItems {
    switch (_selectedFilter) {
      case _VideoFilter.all:
        return _items;
      case _VideoFilter.onlineClass:
        return _items
            .where((item) => item.type == _VideoType.onlineClass)
            .toList();
      case _VideoFilter.youtube:
        return _items.where((item) => item.type == _VideoType.youtube).toList();
      case _VideoFilter.saved:
        return _items
            .where((item) => _savedVideoKeys.contains(item.uniqueKey))
            .toList();
    }
  }

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
      if (queryId != null && queryId.isNotEmpty) return queryId;

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

  Future<void> _openLink(String link) async {
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

  void _toggleSave(_AllVideoItem item) {
    setState(() {
      if (_savedVideoKeys.contains(item.uniqueKey)) {
        _savedVideoKeys.remove(item.uniqueKey);
      } else {
        _savedVideoKeys.add(item.uniqueKey);
      }
    });
  }

  Widget _buildThumbnail(_AllVideoItem item) {
    if (item.type == _VideoType.youtube) {
      final String? videoId = _extractYoutubeVideoId(item.link);
      if (videoId != null) {
        return Image.network(
          'https://img.youtube.com/vi/$videoId/hqdefault.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _thumbnailFallback(),
        );
      }
    }

    if (item.thumbnailUrl.isNotEmpty) {
      return Image.network(
        item.thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _thumbnailFallback(),
      );
    }

    return _thumbnailFallback();
  }

  Widget _thumbnailFallback() {
    return Container(
      color: const Color(0xFF000435).withOpacity(0.08),
      child: const Center(
        child: Icon(
          Icons.video_library_outlined,
          size: 38,
          color: Color(0xFF000435),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
    Color accentColor = _primaryColor,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accentColor.withOpacity(0.12) : Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? accentColor.withOpacity(0.3) : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 18,
              color: selected ? accentColor : Colors.grey.shade700,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: selected ? accentColor : Colors.grey.shade800,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCard(_AllVideoItem item) {
    final bool isSaved = _savedVideoKeys.contains(item.uniqueKey);
    final bool isYoutube = item.type == _VideoType.youtube;
    final Color actionColor = isYoutube ? _youtubeColor : _primaryColor;

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
                    _buildThumbnail(item),
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
                          item.durationLabel,
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
                            color: isYoutube
                                ? Colors.red.withOpacity(0.1)
                                : _primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            isYoutube ? 'YouTube' : 'Online Class',
                            style: TextStyle(
                              color: isYoutube ? Colors.red.shade700 : _primaryColor,
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
                      item.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF1A1E3B),
                        fontWeight: FontWeight.w700,
                        fontSize: 30 / 2,
                      ),
                    ),
                    if (item.dateOrMetaText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.dateOrMetaText,
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
                      item.description,
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
                              onPressed: () => _openLink(item.link),
                              icon: const Icon(Icons.play_circle_fill, size: 18),
                              label: Text(
                                isYoutube ? 'Open Video' : 'Watch Now',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                              ),
                              style: ElevatedButton.styleFrom(
                                elevation: 0,
                                backgroundColor: actionColor,
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
                          onTap: () => _toggleSave(item),
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

  Widget _buildListFooter() {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 14),
      padding: const EdgeInsets.symmetric(vertical: 26, horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F6FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE7E2FF)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.ondemand_video_rounded,
            color: _primaryColor.withOpacity(0.35),
            size: 34,
          ),
          const SizedBox(height: 10),
          const Text(
            'No more videos',
            style: TextStyle(
              fontSize: 30 / 2,
              color: Color(0xFF1A1E3B),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'You\'ve reached the end of the list.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<_AllVideoItem> visibleItems = _visibleItems;

    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF9FAFC),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1E3B)),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: _primaryColor),
            onPressed: _fetchAllVideos,
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'All Videos',
                style: TextStyle(
                  fontSize: 34 / 2,
                  color: Color(0xFF1A1E3B),
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Explore and learn with our curated videos',
                style: TextStyle(
                  color: Colors.grey.shade700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip(
                      icon: Icons.play_circle_outline,
                      label: 'All Videos',
                      selected: _selectedFilter == _VideoFilter.all,
                      onTap: () {
                        setState(() => _selectedFilter = _VideoFilter.all);
                      },
                    ),
                    _buildFilterChip(
                      icon: Icons.school_outlined,
                      label: 'Online Class',
                      selected: _selectedFilter == _VideoFilter.onlineClass,
                      onTap: () {
                        setState(() => _selectedFilter = _VideoFilter.onlineClass);
                      },
                    ),
                    _buildFilterChip(
                      icon: Icons.smart_display,
                      label: 'YouTube',
                      selected: _selectedFilter == _VideoFilter.youtube,
                      onTap: () {
                        setState(() => _selectedFilter = _VideoFilter.youtube);
                      },
                      accentColor: _youtubeColor,
                    ),
                    _buildFilterChip(
                      icon: Icons.bookmark_border_rounded,
                      label: 'Saved',
                      selected: _selectedFilter == _VideoFilter.saved,
                      onTap: () {
                        setState(() => _selectedFilter = _VideoFilter.saved);
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),
              Expanded(
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(color: _primaryColor),
                      )
                    : _errorMessage.isNotEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20),
                              child: Text(
                                _errorMessage,
                                style: TextStyle(color: Colors.grey.shade700),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : visibleItems.isEmpty
                            ? _buildListFooter()
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 6),
                                itemCount: visibleItems.length + 1,
                                itemBuilder: (BuildContext context, int index) {
                                  if (index == visibleItems.length) {
                                    return _buildListFooter();
                                  }
                                  return _buildVideoCard(visibleItems[index]);
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _VideoType { onlineClass, youtube }

enum _VideoFilter { all, onlineClass, youtube, saved }

class _AllVideoItem {
  final String id;
  final _VideoType type;
  final String title;
  final String description;
  final String thumbnailUrl;
  final String dateOrMetaText;
  final String durationLabel;
  final String link;

  _AllVideoItem({
    required this.id,
    required this.type,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.dateOrMetaText,
    required this.durationLabel,
    required this.link,
  });

  String get uniqueKey {
    if (id.isNotEmpty) return '$type-$id';
    if (link.isNotEmpty) return '$type-$link';
    return '$type-$title-$description';
  }

  factory _AllVideoItem.fromOnlineClass(Map<String, dynamic> json) {
    final String date = (json['date'] ?? '').toString().trim();
    final String time = (json['time'] ?? '').toString().trim();
    final String rawImage = (json['img'] ?? '').toString().trim();
    final String dateText = _formatDateDisplay(date);

    return _AllVideoItem(
      id: (json['_id'] ?? '').toString(),
      type: _VideoType.onlineClass,
      title: (json['title'] ?? 'Untitled Online Class').toString(),
      description: (json['description'] ?? '-').toString(),
      thumbnailUrl: rawImage.isEmpty ? '' : _resolveOnlineClassImage(rawImage),
      dateOrMetaText: dateText.isEmpty
          ? ''
          : '$dateText${time.isEmpty ? '' : '  |  $time'}',
      durationLabel: _normalizeDuration(time),
      link: (json['link'] ?? json['videoUrl'] ?? '').toString(),
    );
  }

  factory _AllVideoItem.fromYoutubeLink(Map<String, dynamic> json) {
    return _AllVideoItem(
      id: (json['_id'] ?? '').toString(),
      type: _VideoType.youtube,
      title: (json['title'] ?? 'Untitled YouTube Video').toString(),
      description: (json['description'] ?? '-').toString(),
      thumbnailUrl: '',
      dateOrMetaText: '',
      durationLabel: '04:35',
      link: (json['link'] ?? '').toString(),
    );
  }

  static String _resolveOnlineClassImage(String raw) {
    if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
    return buildBaseUrl(raw);
  }

  static String _formatDateDisplay(String dateValue) {
    if (dateValue.isEmpty) return '';
    final DateTime? parsed = DateTime.tryParse(dateValue);
    if (parsed == null) return dateValue;
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

  static String _normalizeDuration(String rawValue) {
    final String value = rawValue.trim();
    if (value.isEmpty) return '03:00';
    final RegExp durationExp = RegExp(r'^\d{1,2}:\d{2}$');
    if (durationExp.hasMatch(value)) return value;
    return '03:00';
  }
}
