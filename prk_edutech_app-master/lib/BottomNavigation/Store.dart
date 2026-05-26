import 'package:flutter/material.dart';

class Course {
  final String name;
  final String image;

  Course({required this.name, required this.image});
}

class Store extends StatefulWidget {
  @override
  _StoreState createState() => _StoreState();
}

class _StoreState extends State<Store> {
  final List<Course> courses = [
    Course(name: 'Physics', image: 'https://media.istockphoto.com/id/525409405/photo/rear-view-of-teenage-students-raising-hands-in-classroom.jpg?s=612x612&w=0&k=20&c=iae_uTM77vK3N1J6q0Zi7kvfOTjlirp2P5MIVswbxmo='),
    Course(name: 'Chemistry', image: 'https://media.istockphoto.com/id/1353890525/photo/young-man-is-working-on-laptop.jpg?s=612x612&w=0&k=20&c=CeU7BOpOoom1841CoZ3i8tFtalQdUi-nBzlLSFMrxR4='),
    Course(name: 'Mathematics', image: 'https://media.istockphoto.com/id/1358014313/photo/group-of-elementary-students-having-computer-class-with-their-teacher-in-the-classroom.jpg?s=612x612&w=0&k=20&c=3xsykmHXFa9ejL_sP2Xxiow7zdtmKvg15UxXFfgR98Q='),
  ];

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    List<Course> filteredCourses = courses.where((course) => course.name.toLowerCase().contains(searchQuery.toLowerCase())).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF3E0),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search for a course...',
                prefixIcon: Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[200],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (query) {
                setState(() {
                  searchQuery = query;
                });
              },
            ),
            SizedBox(height: 16),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: filteredCourses.length,
            //     itemBuilder: (context, index) {
            //       return Card(
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(15),
            //         ),
            //         elevation: 5,
            //         margin: EdgeInsets.only(bottom: 16),
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             ClipRRect(
            //               borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            //               child: Image.network(
            //                 filteredCourses[index].image,
            //                 height: 180,
            //                 width: double.infinity,
            //                 fit: BoxFit.cover,
            //               ),
            //             ),
            //             Padding(
            //               padding: const EdgeInsets.all(16.0),
            //               child: Column(
            //                 crossAxisAlignment: CrossAxisAlignment.start,
            //                 children: [
            //                   Text(
            //                     filteredCourses[index].name,
            //                     style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            //                   ),
            //                   SizedBox(height: 8),
            //                   Text('Progress: 75%'),
            //                   SizedBox(height: 4),
            //                   LinearProgressIndicator(
            //                     value: 0.75,
            //                     backgroundColor: Colors.grey[300],
            //                     color: Colors.amber,
            //                   ),
            //                 ],
            //               ),
            //             ),
            //           ],
            //         ),
            //       );
            //     },
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}