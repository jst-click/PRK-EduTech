// import 'package:flutter/material.dart';
//
// class BatchScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Center(
//             child: Column(
//               children: [
//                 Image.asset(
//                   'assets/logo.png', // Replace with actual image asset
//                   height: 120,
//                 ),
//                 SizedBox(height: 10),
//                 Text(
//                   'No Batches to Display',
//                   style: TextStyle(
//                     fontSize: 18,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 SizedBox(height: 5),
//                 Text(
//                   'OR',
//                   style: TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.w500,
//                     color: Colors.grey,
//                   ),
//                 ),
//                 SizedBox(height: 10),
//                 ElevatedButton(
//                   onPressed: () {},
//                   style: ElevatedButton.styleFrom(
//                     backgroundColor: Color(0xFF000435),
//                     padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                   ),
//                   child: Text(
//                     'View free study material',
//                     style: TextStyle(fontSize: 16, color: Colors.white),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: () {
//           showDialog(
//             context: context,
//             builder: (context) => AlertDialog(
//               title: Text('Enter Batch Code'),
//               content: TextField(
//                 decoration: InputDecoration(
//                   hintText: 'Batch Code',
//                 ),
//               ),
//               actions: [
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: Text('Cancel'),
//                 ),
//                 TextButton(
//                   onPressed: () {
//                     // Handle batch code submission
//                     Navigator.pop(context);
//                   },
//                   child: Text('Submit'),
//                 ),
//               ],
//             ),
//           );
//         },
//         backgroundColor: Color(0xFF000435),
//         child: Icon(Icons.add, color: Colors.white),
//       ),
//     );
//   }
// }
