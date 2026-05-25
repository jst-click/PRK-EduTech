// import 'package:flutter/material.dart';
//
// class AllNotesPage extends StatefulWidget {
//   const AllNotesPage({Key? key}) : super(key: key);
//
//   @override
//   State<AllNotesPage> createState() => _AllNotesPageState();
// }
//
// class _AllNotesPageState extends State<AllNotesPage> {
//   String? _selectedCourse;
//   String? _selectedTopic;
//
//   // Sample data - replace with actual data from your backend
//   final List<String> courses = [
//     'UPSC Civil Services',
//     'Banking Exams',
//     'SSC Exams',
//     'Railway Exams',
//     'Teaching Exams',
//   ];
//
//   final Map<String, List<String>> topicsByCourse = {
//     'UPSC Civil Services': [
//       'Indian Polity',
//       'Geography',
//       'Economics',
//       'History',
//       'Environment',
//     ],
//     'Banking Exams': [
//       'Quantitative Aptitude',
//       'Logical Reasoning',
//       'English Language',
//       'Banking Awareness',
//       'Computer Knowledge',
//     ],
//     'SSC Exams': [
//       'General Intelligence',
//       'General Awareness',
//       'Quantitative Aptitude',
//       'English Comprehension',
//     ],
//     'Railway Exams': [
//       'General Awareness',
//       'Mathematics',
//       'General Intelligence',
//       'Technical Ability',
//     ],
//     'Teaching Exams': [
//       'Teaching Methods',
//       'Child Development',
//       'Educational Psychology',
//       'Current Affairs in Education',
//     ],
//   };
//
//   final Map<String, Map<String, String>> noteContents = {
//     'UPSC Civil Services': {
//       'Indian Polity': 'Detailed notes about Indian Constitution, Fundamental Rights, Directive Principles, Union and State Legislatures, Judiciary, etc.',
//       'Geography': 'Notes covering Physical Geography, Indian Geography, World Geography, Economic Geography, etc.',
//       'Economics': 'Content about Indian Economy, Economic Reforms, Budgeting, Planning, etc.',
//       'History': 'Ancient, Medieval, Modern Indian History, World History, Art and Culture, etc.',
//       'Environment': 'Environmental Issues, Policies, Conservation, Biodiversity, Climate Change, etc.',
//     },
//     // Add other courses and their topics
//   };
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Course Notes'),
//         backgroundColor: const Color(0xFFFB7F03),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Step 1: Select Course
//             Container(
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(8),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.grey.withOpacity(0.2),
//                     spreadRadius: 1,
//                     blurRadius: 4,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text(
//                     'Step 1: Select Course',
//                     style: TextStyle(
//                       fontSize: 16,
//                       fontWeight: FontWeight.bold,
//                       color: Color(0xFF000435),
//                     ),
//                   ),
//                   const SizedBox(height: 12),
//                   DropdownButtonFormField<String>(
//                     value: _selectedCourse,
//                     decoration: InputDecoration(
//                       filled: true,
//                       fillColor: Colors.grey[100],
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                         borderSide: BorderSide.none,
//                       ),
//                       hintText: 'Select a course',
//                       contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                     ),
//                     items: courses.map((String course) {
//                       return DropdownMenuItem<String>(
//                         value: course,
//                         child: Text(course),
//                       );
//                     }).toList(),
//                     onChanged: (String? newValue) {
//                       setState(() {
//                         _selectedCourse = newValue;
//                         _selectedTopic = null;
//                       });
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             const SizedBox(height: 16),
//
//             // Step 2: Select Topic (only show if course is selected)
//             if (_selectedCourse != null)
//               Container(
//                 padding: const EdgeInsets.all(16),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(8),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.grey.withOpacity(0.2),
//                       spreadRadius: 1,
//                       blurRadius: 4,
//                       offset: const Offset(0, 2),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Step 2: Select Topic',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.bold,
//                         color: Color(0xFF000435),
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     DropdownButtonFormField<String>(
//                       value: _selectedTopic,
//                       decoration: InputDecoration(
//                         filled: true,
//                         fillColor: Colors.grey[100],
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(8),
//                           borderSide: BorderSide.none,
//                         ),
//                         hintText: 'Select a topic',
//                         contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
//                       ),
//                       items: topicsByCourse[_selectedCourse]?.map((String topic) {
//                         return DropdownMenuItem<String>(
//                           value: topic,
//                           child: Text(topic),
//                         );
//                       }).toList() ?? [],
//                       onChanged: (String? newValue) {
//                         setState(() {
//                           _selectedTopic = newValue;
//                         });
//                       },
//                     ),
//                   ],
//                 ),
//               ),
//
//             const SizedBox(height: 16),
//
//             // Step 3: Display Notes (only if topic is selected)
//             if (_selectedCourse != null && _selectedTopic != null)
//               Expanded(
//                 child: Container(
//                   padding: const EdgeInsets.all(16),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(8),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.grey.withOpacity(0.2),
//                         spreadRadius: 1,
//                         blurRadius: 4,
//                         offset: const Offset(0, 2),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Row(
//                         children: [
//                           const Text(
//                             'Step 3: Complete Details',
//                             style: TextStyle(
//                               fontSize: 16,
//                               fontWeight: FontWeight.bold,
//                               color: Color(0xFF000435),
//                             ),
//                           ),
//                           const Spacer(),
//                           IconButton(
//                             icon: const Icon(Icons.download, color: Color(0xFFFB7F03)),
//                             onPressed: () {
//                               // Download functionality
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Downloading notes...')),
//                               );
//                             },
//                           ),
//                           IconButton(
//                             icon: const Icon(Icons.share, color: Color(0xFFFB7F03)),
//                             onPressed: () {
//                               // Share functionality
//                               ScaffoldMessenger.of(context).showSnackBar(
//                                 const SnackBar(content: Text('Sharing notes...')),
//                               );
//                             },
//                           ),
//                         ],
//                       ),
//                       const SizedBox(height: 16),
//                       Expanded(
//                         child: SingleChildScrollView(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 _selectedTopic!,
//                                 style: const TextStyle(
//                                   fontSize: 20,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF000435),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               const Divider(),
//                               const SizedBox(height: 8),
//                               Text(
//                                 noteContents[_selectedCourse]?[_selectedTopic] ??
//                                 'Notes content for $_selectedTopic will be displayed here. This section would typically contain detailed text, diagrams, and other educational content.',
//                                 style: const TextStyle(
//                                   fontSize: 16,
//                                   color: Color(0xFF000435),
//                                 ),
//                               ),
//                               // Add more widgets as needed for formatted content
//                               const SizedBox(height: 20),
//                               const Text(
//                                 'Key Points:',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF000435),
//                                 ),
//                               ),
//                               const SizedBox(height: 8),
//                               _buildKeyPoint('Important concept 1 with detailed explanation'),
//                               _buildKeyPoint('Important concept 2 with detailed explanation'),
//                               _buildKeyPoint('Important concept 3 with detailed explanation'),
//                               _buildKeyPoint('Important concept 4 with detailed explanation'),
//                               const SizedBox(height: 20),
//                               const Text(
//                                 'Diagrams & Illustrations:',
//                                 style: TextStyle(
//                                   fontSize: 18,
//                                   fontWeight: FontWeight.bold,
//                                   color: Color(0xFF000435),
//                                 ),
//                               ),
//                               const SizedBox(height: 12),
//                               Center(
//                                 child: Container(
//                                   height: 200,
//                                   width: double.infinity,
//                                   color: Colors.grey[200],
//                                   child: const Center(
//                                     child: Text('Diagram/Illustration Placeholder'),
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//
//             if (_selectedCourse == null || _selectedTopic == null)
//               Expanded(
//                 child: Center(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Icon(Icons.menu_book, size: 80, color: Colors.grey[300]),
//                       const SizedBox(height: 16),
//                       Text(
//                         _selectedCourse == null
//                             ? 'Please select a course to continue'
//                             : 'Please select a topic to view notes',
//                         style: TextStyle(
//                           fontSize: 16,
//                           color: Colors.grey[600],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildKeyPoint(String text) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           const Icon(Icons.check_circle, size: 16, color: Color(0xFFFB7F03)),
//           const SizedBox(width: 8),
//           Expanded(
//             child: Text(
//               text,
//               style: const TextStyle(
//                 fontSize: 14,
//                 color: Color(0xFF000435),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }