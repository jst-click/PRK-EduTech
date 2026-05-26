import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:testing1/constants.dart';

class CurrentAffairsPage extends StatefulWidget {
  const CurrentAffairsPage({Key? key}) : super(key: key);

  @override
  _CurrentAffairsPageState createState() => _CurrentAffairsPageState();
}

class TestimonialModel {
  final String id;
  final String question;
  final String answer;
  final String img;
  final String source;
  final DateTime? publishedAt;

  TestimonialModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.img,
    required this.source,
    required this.publishedAt,
  });

  factory TestimonialModel.fromJson(Map<String, dynamic> json) {
    final rawDate = (json['publishedAt'] ?? json['createdAt'] ?? '').toString();
    final parsedDate = DateTime.tryParse(rawDate);
    return TestimonialModel(
      id: (json['_id'] ?? '').toString(),
      question: (json['question'] ?? 'Question coming soon').toString(),
      answer: (json['answer'] ?? 'Answer coming soon').toString(),
      img: (json['img'] ?? '').toString(),
      source: (json['source'] ?? '').toString(),
      publishedAt: parsedDate,
    );
  }
}

class _CurrentAffairsPageState extends State<CurrentAffairsPage> {
  List<TestimonialModel> _testimonials = [];
  bool _isLoading = true;
  String _error = '';
  bool _isDayWise = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchTestimonials();
  }

  Future<void> _fetchTestimonials() async {
    try {
      final response = await http.get(
        Uri.parse(buildApiUrl('current-affairs')),
      );

      if (response.statusCode == 200) {
        final decoded = json.decode(response.body);
        final List<dynamic> jsonResponse = decoded is List
            ? decoded
            : (decoded is Map<String, dynamic> && decoded['data'] is List)
                ? decoded['data'] as List<dynamic>
                : <dynamic>[];

        setState(() {
          _testimonials = jsonResponse
              .whereType<Map<String, dynamic>>()
              .map(TestimonialModel.fromJson)
              .toList();
          _selectedDate =
              _availableDates.isNotEmpty ? _availableDates.first : null;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to load Current Affairs';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  List<DateTime> get _availableDates {
    final unique = <String, DateTime>{};
    for (final item in _testimonials) {
      final date = item.publishedAt ?? DateTime.now();
      final normalized = DateTime(date.year, date.month, date.day);
      unique['${normalized.year}-${normalized.month}-${normalized.day}'] =
          normalized;
    }
    final values = unique.values.toList()..sort((a, b) => b.compareTo(a));
    return values;
  }

  List<TestimonialModel> get _visibleItems {
    final sorted = [..._testimonials]..sort((a, b) {
        final aDate = a.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.publishedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

    if (!_isDayWise || _selectedDate == null) return sorted;

    return sorted.where((item) {
      final date = item.publishedAt;
      if (date == null) return false;
      return date.year == _selectedDate!.year &&
          date.month == _selectedDate!.month &&
          date.day == _selectedDate!.day;
    }).toList();
  }

  String _formatTime(DateTime? date) {
    if (date == null) return '';
    final hour = date.hour % 12 == 0 ? 12 : date.hour % 12;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'Date unavailable';
    const months = [
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
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  String _formatChipWeekday(DateTime date) {
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return weekdays[date.weekday - 1];
  }

  String _resolveImageUrl(String raw) {
    final value = raw.trim();
    if (value.isEmpty) return '';
    if (value.startsWith('http://') || value.startsWith('https://'))
      return value;
    return buildBaseUrl(value);
  }

  Widget _buildBannerCard() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          colors: [Color(0xFFEFE9FF), Color(0xFFF6F2FF)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Daily dose of',
                  style: TextStyle(
                    color: Color(0xFF595B72),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Knowledge,\nPower & Awareness',
                  style: TextStyle(
                    color: Color(0xFF1D1D34),
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Read top news and stay ahead in your preparation.',
                  style: TextStyle(
                    color: Color(0xFF6A6D85),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.auto_stories_rounded,
                color: Color(0xFF6A4BE8), size: 44),
          ),
        ],
      ),
    );
  }

  Widget _buildDateChips() {
    final dates = _availableDates;
    if (dates.isEmpty) return const SizedBox.shrink();

    return SizedBox(
      height: 84,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = _selectedDate != null &&
              date.year == _selectedDate!.year &&
              date.month == _selectedDate!.month &&
              date.day == _selectedDate!.day;
          return InkWell(
            onTap: () => setState(() => _selectedDate = date),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: 78,
              decoration: BoxDecoration(
                color: isSelected ? const Color(0xFFECE7FF) : Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF6A4BE8)
                      : const Color(0xFFE5E6EF),
                ),
              ),
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    date.day.toString().padLeft(2, '0'),
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF5A3DE1)
                          : const Color(0xFF25263B),
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Text(
                    _formatChipWeekday(date),
                    style: TextStyle(
                      color: isSelected
                          ? const Color(0xFF5A3DE1)
                          : const Color(0xFF7A7D95),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
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

  Widget _buildNewsCard(TestimonialModel item) {
    final imageUrl = _resolveImageUrl(item.img);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: imageUrl.isNotEmpty
                ? Image.network(
                    imageUrl,
                    width: 120,
                    height: 90,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 120,
                      height: 90,
                      color: const Color(0xFFEAE9F8),
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined,
                          color: Color(0xFF8E90A8)),
                    ),
                  )
                : Container(
                    width: 120,
                    height: 90,
                    color: const Color(0xFFEAE9F8),
                    alignment: Alignment.center,
                    child: const Icon(Icons.newspaper_rounded,
                        color: Color(0xFF6A4BE8)),
                  ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.source.trim().isNotEmpty)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF4FF),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      item.source.trim(),
                      style: const TextStyle(
                        color: Color(0xFF4D6BC5),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (item.source.trim().isNotEmpty) const SizedBox(height: 6),
                Text(
                  item.question,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF1E1F35),
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.answer,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Color(0xFF666A82),
                    fontSize: 13.5,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.access_time_rounded,
                        size: 14, color: Color(0xFF7A7D95)),
                    const SizedBox(width: 4),
                    Text(
                      _formatTime(item.publishedAt),
                      style: const TextStyle(
                        color: Color(0xFF7A7D95),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 14),
                    const Icon(Icons.bookmark_border_rounded,
                        size: 15, color: Color(0xFF7A7D95)),
                    const SizedBox(width: 4),
                    const Text(
                      'Save',
                      style: TextStyle(
                        color: Color(0xFF7A7D95),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7FC),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6A4BE8)),
              ),
            )
          : _error.isNotEmpty
              ? Center(
                  child: Text(
                    _error,
                    style: const TextStyle(color: Color(0xFF1E1F35)),
                  ),
                )
              : _testimonials.isEmpty
                  ? const Center(
                      child: Text(
                        'Coming soon',
                        style: TextStyle(
                          color: Color(0xFF6A4BE8),
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )
                  : SafeArea(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Current Affairs',
                                  style: TextStyle(
                                    color: Color(0xFF17182E),
                                    fontSize: 28,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  'Stay updated with the latest important news',
                                  style: TextStyle(
                                    color: Color(0xFF7A7D95),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                _buildBannerCard(),
                                const SizedBox(height: 14),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEBEAF3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () =>
                                              setState(() => _isDayWise = true),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 11),
                                            decoration: BoxDecoration(
                                              color: _isDayWise
                                                  ? const Color(0xFF6A4BE8)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'Day Wise',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: _isDayWise
                                                    ? Colors.white
                                                    : const Color(0xFF6E7189),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () => setState(
                                              () => _isDayWise = false),
                                          child: AnimatedContainer(
                                            duration: const Duration(
                                                milliseconds: 180),
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 11),
                                            decoration: BoxDecoration(
                                              color: !_isDayWise
                                                  ? const Color(0xFF6A4BE8)
                                                  : Colors.transparent,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Text(
                                              'Month Wise',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: !_isDayWise
                                                    ? Colors.white
                                                    : const Color(0xFF6E7189),
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                if (_isDayWise) ...[
                                  const SizedBox(height: 12),
                                  _buildDateChips(),
                                ],
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
                              children: [
                                Text(
                                  _isDayWise
                                      ? _formatDate(_selectedDate)
                                      : 'All Current Affairs',
                                  style: const TextStyle(
                                    color: Color(0xFF17182E),
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                if (_visibleItems.isEmpty)
                                  const Padding(
                                    padding: EdgeInsets.only(top: 28),
                                    child: Center(
                                      child: Text(
                                        'No current affairs for selected date',
                                        style: TextStyle(
                                          color: Color(0xFF7A7D95),
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  )
                                else
                                  ..._visibleItems.map(_buildNewsCard),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
    );
  }
}
