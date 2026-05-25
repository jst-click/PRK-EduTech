import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:testing1/constants.dart';

String timeAgo(DateTime date) {
  Duration difference = DateTime.now().difference(date);

  if (difference.inDays > 0) {
    return "${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago";
  } else if (difference.inHours > 0) {
    return "${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago";
  } else if (difference.inMinutes > 0) {
    return "${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago";
  } else {
    return "Just now";
  }
}

Future<void> showNotifications(BuildContext context) async {
  final url = Uri.parse(buildBaseUrl('questions'));
  final response = await http.get(url);

  if (response.statusCode == 200) {
    List<dynamic> data = json.decode(response.body);
    List<Map<String, dynamic>> notifications = data
        .where((item) => item['type'] == 'Notification') // Filter notifications
        .map((item) {
      DateTime createdAt = DateTime.parse(item['createdAt']);
      String formattedDate = timeAgo(createdAt);
      return {
        'question': item['question'],
        'answer': item['answer'],
        'createdAt': formattedDate,
      };
    })
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Notifications"),
          content: notifications.isEmpty
              ? const Text("No notifications available")
              : SizedBox(
            width: 300,
            height: 400,
            child: ListView.builder(
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final item = notifications[index];
                return ListTile(
                  title: Text(item['question'], style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item['answer']),
                      Text(
                        item['createdAt'],
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  } else {
    print("Failed to load notifications");
  }
}