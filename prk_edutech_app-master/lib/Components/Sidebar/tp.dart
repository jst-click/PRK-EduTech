import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:testing1/constants.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
      ),
    );

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Video Learning Platform',
      theme: ThemeData(
        primaryColor: const Color(0xFF000435),
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: const Color(0xFF000435),
          secondary: const Color(0xFFfb7e02),
        ),
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const VideoListScreen(),
    );
  }
}

class VideoListScreen extends StatefulWidget {
  const VideoListScreen({Key? key}) : super(key: key);

  @override
  State<VideoListScreen> createState() => _VideoListScreenState();
}

class _VideoListScreenState extends State<VideoListScreen> {
  List<VideoModel> videos = [];
  List<VideoModel> filteredVideos = [];
  bool isLoading = true;
  bool filterLive = false;
  bool filterYoutubeLive = false;
  bool filterFree = false;

  @override
  void initState() {
    super.initState();
    fetchVideos();
  }

  Future<void> fetchVideos() async {
    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.get(Uri.parse(buildBaseUrl('videos/')));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          videos = data.map((json) => VideoModel.fromJson(json)).toList();
          filteredVideos = List.from(videos);
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        _showErrorSnackbar("Failed to load videos. Server error.");
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      _showErrorSnackbar("Failed to load videos. ${e.toString()}");
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  // void applyFilters() {
  //   setState(() {
  //     filteredVideos = videos.where((video) {
  //       bool matchLive = !filterLive || video.isLive == filterLive;
  //       bool matchYoutubeLive = !filterYoutubeLive || video.isYoutubeLive == filterYoutubeLive;
  //       bool matchFree = !filterFree || video.isFree == filterFree;
  //
  //       return matchLive && matchYoutubeLive && matchFree;
  //     }).toList();
  //   });
  // }

  void applyFilters() {
    setState(() {
      filteredVideos =
          videos.where((video) => video.isLive && video.isYoutubeLive).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 5,
        title: const Text(
          'Learning Videos',
          style:
              TextStyle(color: Color(0xFF000435), fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFFFFF3E0),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchVideos,
          ),
        ],
      ),
      body: Column(
        children: [
          buildFilterSection(),
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFfb7e02),
                    ),
                  )
                : filteredVideos.isEmpty
                    ? const Center(
                        child: Text(
                          'No videos found with the selected filters',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : buildVideoList(),
          ),
        ],
      ),
    );
  }

  Widget buildFilterSection() {
    return Container(
      color: const Color(0xFF000435).withOpacity(0.05),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Filter Videos',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF000435),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                FilterChip(
                  label: Text(
                    'Live',
                    style: TextStyle(
                      color: filterLive
                          ? Colors.white
                          : const Color(
                              0xFFfb7e02), // White when selected, Orange otherwise
                      fontWeight:
                          FontWeight.bold, // Optional for better visibility
                    ),
                  ),
                  selected: filterLive,
                  backgroundColor: const Color(0xFFFFF3E0),
                  selectedColor: const Color(0xFFfb7e02)
                      .withOpacity(0.8), // Adjust opacity for a better look
                  checkmarkColor: Colors.white, // White checkmark when selected
                  onSelected: (selected) {
                    setState(() {
                      filterLive = selected;
                      applyFilters();
                    });
                  },
                ),
                FilterChip(
                  label: Text(
                    'YouTube Live',
                    style: TextStyle(
                      color: filterYoutubeLive
                          ? Colors.white
                          : const Color(0xFFfb7e02),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: filterYoutubeLive,
                  backgroundColor: const Color(0xFFFFF3E0),
                  selectedColor: const Color(0xFFfb7e02).withOpacity(0.8),
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    setState(() {
                      filterYoutubeLive = selected;
                      applyFilters();
                    });
                  },
                ),
                FilterChip(
                  label: Text(
                    'Free',
                    style: TextStyle(
                      color:
                          filterFree ? Colors.white : const Color(0xFFfb7e02),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  selected: filterFree,
                  backgroundColor: const Color(0xFFFFF3E0),
                  selectedColor: const Color(0xFFfb7e02).withOpacity(0.8),
                  checkmarkColor: Colors.white,
                  onSelected: (selected) {
                    setState(() {
                      filterFree = selected;
                      applyFilters();
                    });
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildVideoList() {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: filteredVideos.length,
      itemBuilder: (context, index) {
        final video = filteredVideos[index];
        return VideoCard(video: video);
      },
    );
  }
}

class VideoCard extends StatelessWidget {
  final VideoModel video;

  const VideoCard({Key? key, required this.video}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VideoDetailScreen(video: video),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: buildThumbnail(video.thumbnailUrl),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          video.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF000435),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (video.isLive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Chapter: ${video.chapterName}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'By ${video.author}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: video.isFree
                              ? const Color(0xFF000435).withOpacity(0.1)
                              : const Color(0xFFfb7e02).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          video.isFree ? 'Free' : 'Premium',
                          style: TextStyle(
                            color: video.isFree
                                ? const Color(0xFF000435)
                                : const Color(0xFFfb7e02),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (video.isYoutubeLive)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.play_circle_outline,
                                size: 14,
                                color: Colors.red[700],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'YouTube Live',
                                style: TextStyle(
                                  color: Colors.red[700],
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
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

  Widget buildThumbnail(String thumbnailUrl) {
    if (thumbnailUrl.startsWith('data:image')) {
      // Handle base64 image
      try {
        // Extract the base64 string (remove the prefix)
        final base64String = thumbnailUrl.split(',')[1];
        return Image.memory(
          base64Decode(base64String),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return thumbnailFallback();
          },
        );
      } catch (e) {
        return thumbnailFallback();
      }
    } else {
      // Handle normal URL
      return Image.network(
        thumbnailUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return thumbnailFallback();
        },
      );
    }
  }

  Widget thumbnailFallback() {
    return Container(
      color: const Color(0xFF000435).withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.video_library,
          size: 50,
          color: const Color(0xFF000435).withOpacity(0.3),
        ),
      ),
    );
  }
}

class VideoDetailScreen extends StatefulWidget {
  final VideoModel video;

  const VideoDetailScreen({Key? key, required this.video}) : super(key: key);

  @override
  State<VideoDetailScreen> createState() => _VideoDetailScreenState();
}

class _VideoDetailScreenState extends State<VideoDetailScreen> {
  late YoutubePlayerController _controller;
  bool _isPlayerReady = false;

  @override
  void initState() {
    super.initState();
    final videoId = _extractVideoId(widget.video.videoUrl);

    _controller = YoutubePlayerController(
      initialVideoId: videoId ?? '',
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        enableCaption: true,
      ),
    )..addListener(_listener);
  }

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {});
    }
  }

  String? _extractVideoId(String url) {
    RegExp regExp = RegExp(
      r'(?:youtube\.com\/(?:[^\/]+\/.+\/|(?:v|e(?:mbed)?)\/|.*[?&]v=)|youtu\.be\/)([^"&?\/\s]{11})',
    );

    Match? match = regExp.firstMatch(url);
    return match?.group(1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFFFFF3E0),
        title: Text(
          widget.video.title,
          style: const TextStyle(color: Color(0xFF000435)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF000435)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            YoutubePlayerBuilder(
              player: YoutubePlayer(
                controller: _controller,
                showVideoProgressIndicator: true,
                progressIndicatorColor: const Color(0xFFfb7e02),
                progressColors: const ProgressBarColors(
                  playedColor: Color(0xFFfb7e02),
                  handleColor: Color(0xFF000435),
                ),
                onReady: () {
                  _isPlayerReady = true;
                },
              ),
              builder: (context, player) {
                return Column(
                  children: [
                    player,
                  ],
                );
              },
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.video.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000435),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: widget.video.isFree
                              ? const Color(0xFF000435).withOpacity(0.1)
                              : const Color(0xFFfb7e02).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          widget.video.isFree ? 'Free' : 'Premium',
                          style: TextStyle(
                            color: widget.video.isFree
                                ? const Color(0xFF000435)
                                : const Color(0xFFfb7e02),
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (widget.video.isLive)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'LIVE',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (widget.video.isYoutubeLive)
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'YouTube Live',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF000435).withOpacity(0.05),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.book,
                              size: 18,
                              color: Color(0xFF000435),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Chapter: ${widget.video.chapterName}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF000435),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.person,
                              size: 18,
                              color: Color(0xFF000435),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Instructor: ${widget.video.author}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF000435),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 18,
                              color: Color(0xFF000435),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Published: ${_formatDate(widget.video.createdTime)}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color(0xFF000435),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF000435),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: const Color(0xFF000435).withOpacity(0.1),
                      ),
                    ),
                    child: Text(
                      widget.video.description,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                        color: Colors.black87,
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

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}

class VideoModel {
  final String id;
  final String title;
  final String videoUrl;
  final String description;
  final String author;
  final String chapterName;
  final String thumbnailUrl;
  final bool isFree;
  final bool isLive;
  final bool isYoutubeLive;
  final String createdTime;

  VideoModel({
    required this.id,
    required this.title,
    required this.videoUrl,
    required this.description,
    required this.author,
    required this.chapterName,
    required this.thumbnailUrl,
    required this.isFree,
    required this.isLive,
    required this.isYoutubeLive,
    required this.createdTime,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['_id'] ?? '',
      title: json['title'] ?? '',
      videoUrl: json['videoUrl'] ?? '',
      description: json['description'] ?? '',
      author: json['author'] ?? '',
      chapterName: json['chapterName'] ?? '',
      thumbnailUrl: json['thumbnailUrl'] ?? '',
      isFree: json['isFree'] ?? true,
      isLive: json['isLive'] ?? false,
      isYoutubeLive: json['isYoutubeLive'] ?? false,
      createdTime: json['createdTime'] ?? '',
    );
  }
}
