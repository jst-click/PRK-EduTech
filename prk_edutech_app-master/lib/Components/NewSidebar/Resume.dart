import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import 'package:testing1/constants.dart';
import 'package:testing1/Auth/TokenManager.dart';
import 'dart:io';

class Education {
  String degree = '';
  String college = '';
  String location = '';
  String gpa = '';
  String coursework = '';
  String title = '';
}

class Experience {
  String company = '';
  String position = '';
  String startDate = '';
  String endDate = '';
  String location = '';
  String description = '';
}
class ResumeBuilderApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Resume Builder',
      theme: ThemeData(
        primaryColor: Color(0xFF000435),
        colorScheme: ColorScheme.light(
          primary: Color(0xFF000435),
          secondary: Color(0xFFFB7E02),
        ),
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
          titleTextStyle: TextStyle(color: Color(0xFF000435), fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Color(0xFF000435)),
        ),
        scaffoldBackgroundColor: Colors.white,
      ),
      home: ResumeBuilderHome(),
    );
  }
}

class ResumeBuilderHome extends StatefulWidget {
  @override
  _ResumeBuilderHomeState createState() => _ResumeBuilderHomeState();
}

class _ResumeBuilderHomeState extends State<ResumeBuilderHome> {
  final _formKey = GlobalKey<FormState>();

  // Basic Info
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _summaryController = TextEditingController();

  // Lists for dynamic fields
  List<Education> educationList = [Education()];
  List<Experience> experienceList = [Experience()];
  List<String> skillsList = [''];
  List<String> hobbiesList = [''];

  String _resumeId = '';
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Resume Builder'),
        backgroundColor: Colors.white,
        iconTheme: IconThemeData(color: Color(0xFF000435)),
        actions: [
          if (_resumeId.isNotEmpty)
            IconButton(
              icon: Icon(Icons.download, color: Color(0xFFFB7E02)),
              onPressed: _generatePdf,
            ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: Color(0xFFFB7E02)))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle('Personal Information'),
              _buildTextField(_nameController, 'Full Name', Icons.person),
              _buildTextField(_phoneController, 'Phone Number', Icons.phone),
              _buildTextField(_addressController, 'Address', Icons.home),
              _buildTextField(_emailController, 'Email ID', Icons.email),

              _buildSectionTitle('Professional Summary'),
              _buildTextField(_summaryController, 'Summary', Icons.description,
                  maxLines: 4),

              _buildSectionTitle('Education'),
              ...educationList
                  .map((edu) => _buildEducationFields(edu))
                  .toList(),
              _buildAddButton('Add Education', () {
                setState(() {
                  educationList.add(Education());
                });
              }),

              _buildSectionTitle('Experience'),
              ...experienceList
                  .map((exp) => _buildExperienceFields(exp))
                  .toList(),
              _buildAddButton('Add Experience', () {
                setState(() {
                  experienceList.add(Experience());
                });
              }),

              _buildSectionTitle('Key Skills'),
              ...skillsList
                  .asMap()
                  .entries
                  .map((entry) {
                return _buildListItemField(
                  entry.value,
                      (value) {
                    skillsList[entry.key] = value;
                  },
                  'Skill',
                  Icons.star,
                  onRemove: entry.key > 0
                      ? () {
                    setState(() {
                      skillsList.removeAt(entry.key);
                    });
                  }
                      : null,
                );
              }).toList(),
              _buildAddButton('Add Skill', () {
                setState(() {
                  skillsList.add('');
                });
              }),

              _buildSectionTitle('Hobbies & Interests'),
              ...hobbiesList
                  .asMap()
                  .entries
                  .map((entry) {
                return _buildListItemField(
                  entry.value,
                      (value) {
                    hobbiesList[entry.key] = value;
                  },
                  'Hobby or Interest',
                  Icons.favorite,
                  onRemove: entry.key > 0
                      ? () {
                    setState(() {
                      hobbiesList.removeAt(entry.key);
                    });
                  }
                      : null,
                );
              }).toList(),
              _buildAddButton('Add Hobby', () {
                setState(() {
                  hobbiesList.add('');
                });
              }),

              SizedBox(height: 20),
              _buildSubmitButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 16.0, bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Color(0xFF000435),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller,
      String label,
      IconData icon, {
        int maxLines = 1,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: Color(0xFF000435)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: Color(0xFF000435), width: 2.0),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildListItemField(String initialValue,
      Function(String) onChanged,
      String label,
      IconData icon, {
        Function()? onRemove,
      }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            child: TextFormField(
              initialValue: initialValue,
              onChanged: onChanged,
              decoration: InputDecoration(
                labelText: label,
                prefixIcon: Icon(icon, color: Color(0xFF000435)),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide(color: Color(0xFF000435), width: 2.0),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter $label';
                }
                return null;
              },
            ),
          ),
          if (onRemove != null)
            IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: onRemove,
            ),
        ],
      ),
    );
  }

  Widget _buildEducationFields(Education education) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Education Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000435),
                  ),
                ),
                if (educationList.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        educationList.remove(education);
                      });
                    },
                  ),
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: education.degree,
              decoration: InputDecoration(
                labelText: 'Degree',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => education.degree = value,
              validator: (value) =>
              value!.isEmpty
                  ? 'Please enter degree'
                  : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: education.college,
              decoration: InputDecoration(
                labelText: 'College/University',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => education.college = value,
              validator: (value) =>
              value!.isEmpty
                  ? 'Please enter college'
                  : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: education.location,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => education.location = value,
              validator: (value) =>
              value!.isEmpty
                  ? 'Please enter location'
                  : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: education.gpa,
              decoration: InputDecoration(
                labelText: 'GPA',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => education.gpa = value,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: education.coursework,
              decoration: InputDecoration(
                labelText: 'Coursework',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => education.coursework = value,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: education.title,
              decoration: InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => education.title = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExperienceFields(Experience experience) {
    return Card(
      margin: EdgeInsets.only(bottom: 16.0),
      elevation: 2.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Experience Details',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF000435),
                  ),
                ),
                if (experienceList.length > 1)
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () {
                      setState(() {
                        experienceList.remove(experience);
                      });
                    },
                  ),
              ],
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: experience.company,
              decoration: InputDecoration(
                labelText: 'Company',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => experience.company = value,
              validator: (value) =>
              value!.isEmpty
                  ? 'Please enter company'
                  : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: experience.position,
              decoration: InputDecoration(
                labelText: 'Position',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => experience.position = value,
              validator: (value) =>
              value!.isEmpty
                  ? 'Please enter position'
                  : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: experience.startDate,
              decoration: InputDecoration(
                labelText: 'Start Date',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => experience.startDate = value,
              validator: (value) =>
              value!.isEmpty
                  ? 'Please enter start date'
                  : null,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: experience.endDate,
              decoration: InputDecoration(
                labelText: 'End Date (or "Present")',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => experience.endDate = value,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: experience.location,
              decoration: InputDecoration(
                labelText: 'Location',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              onChanged: (value) => experience.location = value,
            ),
            SizedBox(height: 10),
            TextFormField(
              initialValue: experience.description,
              decoration: InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
              ),
              maxLines: 3,
              onChanged: (value) => experience.description = value,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton(String label, Function() onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextButton.icon(
        icon: Icon(Icons.add, color: Color(0xFFFB7E02)),
        label: Text(
          label,
          style: TextStyle(color: Color(0xFFFB7E02)),
        ),
        onPressed: onPressed,
        style: TextButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
            side: BorderSide(color: Color(0xFFFB7E02)),
          ),
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Container(
      width: double.infinity,
      height: 50.0,
      child: ElevatedButton(
        onPressed: _submitForm,
        child: Text('Save Resume', style: TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFFFB7E02),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
    );
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final token = await TokenManager.getToken();
        if (token == null || token.isEmpty) {
          throw Exception('Please login again');
        }

        // Clean up skills and hobbies lists (remove empty items)
        skillsList = skillsList.where((skill) => skill.isNotEmpty).toList();
        hobbiesList = hobbiesList.where((hobby) => hobby.isNotEmpty).toList();

        // Create resume data
        final resumeData = {
          'name': _nameController.text,
          'phone': _phoneController.text,
          'address': _addressController.text,
          'email': _emailController.text,
          'summary': _summaryController.text,
          'education': educationList.map((edu) =>
          {
            'degree': edu.degree,
            'college': edu.college,
            'location': edu.location,
            'gpa': edu.gpa,
            'coursework': edu.coursework,
            'title': edu.title,
          }).toList(),
          'experience': experienceList.map((exp) =>
          {
            'company': exp.company,
            'position': exp.position,
            'startDate': exp.startDate,
            'endDate': exp.endDate,
            'location': exp.location,
            'description': exp.description,
          }).toList(),
          'skills': skillsList,
          'hobbies': hobbiesList,
        };

        // Send data to server
        final response = await http.post(
          Uri.parse(buildApiUrl('resumes')),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $token',
          },
          body: jsonEncode(resumeData),
        );

        if (response.statusCode == 201) {
          final responseData = jsonDecode(response.body);
          setState(() {
            _resumeId = responseData['_id'];
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Resume saved successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          final responseData = jsonDecode(response.body);
          final message = responseData is Map<String, dynamic>
              ? (responseData['message']?.toString() ?? 'Failed to save resume')
              : 'Failed to save resume';
          throw Exception(message);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _generatePdf() async {
    setState(() => _isLoading = true);

    try {
      final token = await TokenManager.getToken();
      if (token == null || token.isEmpty) {
        throw Exception('Please login again');
      }

      final response = await http.get(
        Uri.parse(buildApiUrl('resumes/$_resumeId')),
        headers: {
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode != 200) {
        final responseData = jsonDecode(response.body);
        final message = responseData is Map<String, dynamic>
            ? (responseData['message']?.toString() ?? 'Failed to fetch resume data')
            : 'Failed to fetch resume data';
        throw Exception(message);
      }

      final resume = jsonDecode(response.body);
      final pdf = pw.Document();

      final headingStyle = pw.TextStyle(
        fontSize: 14,
        fontWeight: pw.FontWeight.bold,
        color: PdfColor.fromHex('fb7e02'),
      );

      final sectionDivider = pw.Divider(color: PdfColor.fromHex('000435'));

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Container(
                  padding: const pw.EdgeInsets.all(16),
                  color: PdfColor.fromHex('000435'),
                  width: double.infinity,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.center,
                    children: [
                      pw.Text(
                        resume['name'],
                        style: pw.TextStyle(
                          fontSize: 24,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.white,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.center,
                        children: [
                          pw.Text(resume['email'], style: pw.TextStyle(
                              fontSize: 10, color: PdfColors.white)),
                          pw.Text(' | ', style: pw.TextStyle(color: PdfColors
                              .white)),
                          pw.Text(resume['phone'], style: pw.TextStyle(
                              fontSize: 10, color: PdfColors.white)),
                          pw.Text(' | ', style: pw.TextStyle(color: PdfColors
                              .white)),
                          pw.Text(resume['address'], style: pw.TextStyle(
                              fontSize: 10, color: PdfColors.white)),
                        ],
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 16),

                // Summary
                pw.Text('SUMMARY', style: headingStyle),
                sectionDivider,
                pw.SizedBox(height: 4),
                pw.Text(resume['summary']),
                pw.SizedBox(height: 16),

                // Education
                pw.Text('EDUCATION', style: headingStyle),
                sectionDivider,
                pw.SizedBox(height: 4),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: List<pw.Widget>.from(
                    (resume['education'] as List).map((edu) =>
                        pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  pw.Text(edu['degree'], style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                                  if (edu['gpa'] != null && edu['gpa'] != '') pw
                                      .Text('GPA: ${edu['gpa']}'),
                                ],
                              ),
                              pw.Text('${edu['college']}, ${edu['location']}'),
                              if (edu['coursework']?.isNotEmpty ?? false) pw
                                  .Text('Coursework: ${edu['coursework']}'),
                              if (edu['title']?.isNotEmpty ?? false) pw.Text(
                                  edu['title']),
                            ],
                          ),
                        )),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Experience
                pw.Text('EXPERIENCE', style: headingStyle),
                sectionDivider,
                pw.SizedBox(height: 4),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: List<pw.Widget>.from(
                    (resume['experience'] as List).map((exp) =>
                        pw.Container(
                          margin: const pw.EdgeInsets.only(bottom: 8),
                          child: pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Row(
                                mainAxisAlignment: pw.MainAxisAlignment
                                    .spaceBetween,
                                children: [
                                  pw.Text(exp['position'], style: pw.TextStyle(
                                      fontWeight: pw.FontWeight.bold)),
                                  pw.Text(
                                      '${exp['startDate']} - ${exp['endDate'] ??
                                          'Present'}'),
                                ],
                              ),
                              pw.Text('${exp['company']}${exp['location']
                                  ?.isNotEmpty == true
                                  ? ', ${exp['location']}'
                                  : ''}'),
                              if (exp['description']?.isNotEmpty ?? false) pw
                                  .Text(exp['description']),
                            ],
                          ),
                        )),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Skills
                pw.Text('SKILLS', style: headingStyle),
                sectionDivider,
                pw.SizedBox(height: 4),
                pw.Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: List<pw.Widget>.from(
                    (resume['skills'] as List).map((skill) =>
                        pw.Container(
                          padding: const pw.EdgeInsets.all(4),
                          decoration: pw.BoxDecoration(
                            border: pw.Border.all(color: PdfColor.fromHex(
                                '000435')),
                            borderRadius: pw.BorderRadius.circular(4),
                          ),
                          child: pw.Text(skill),
                        )),
                  ),
                ),
                pw.SizedBox(height: 16),

                // Hobbies
                pw.Text('HOBBIES & INTERESTS', style: headingStyle),
                sectionDivider,
                pw.SizedBox(height: 4),
                pw.Text((resume['hobbies'] as List).join(', ')),

                // // Footer
                // pw.Spacer(),
                // pw.Align(
                //   alignment: pw.Alignment.center,
                //   child: pw.Text(
                //     'Resume generated on ${DateTime
                //         .now()
                //         .toLocal()
                //         .toIso8601String()
                //         .split('T')
                //         .first}',
                //     style: pw.TextStyle(
                //         fontSize: 8, color: PdfColor.fromHex('000435')),
                //   ),
                // ),
              ],
            );
          },
        ),
      );

      final output = await getTemporaryDirectory();
      final filename = 'resume_${resume['name']
          .toString()
          .toLowerCase()
          .replaceAll(' ', '_')}.pdf';
      final file = File('${output.path}/$filename');
      await file.writeAsBytes(await pdf.save());

      await OpenFile.open(file.path);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Resume PDF generated successfully!'),
            backgroundColor: Colors.green),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error generating PDF: $e'),
            backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }
}