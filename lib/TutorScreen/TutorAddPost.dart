
//select start time, and select how many hours in registration. - should be in one time availibility section, not in tutor post

import 'dart:io';
import 'package:edumateapp/TutorScreen/AvailibilitySlot.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';


class TutorAddPost extends StatefulWidget {
  const TutorAddPost({super.key});

  @override
  State<TutorAddPost> createState() => _TutorAddPostState();
}

class _TutorAddPostState extends State<TutorAddPost> {
  @override
  void initState() {
    super.initState();
    // Initialize with one availability slot
    _availability.add({
      'day': null,
      'startTime': null,
      'endTime': null,
    });
  }

  final _formKey = GlobalKey<FormState>();
  var _subject = 'Lower Primary Science';
  var _level = 'Beginner';
  var _ratePerHour = '';
  List<Map<String, dynamic>> _availability = [];

  final _ratePerHourController = TextEditingController();

  List<File> _selectedDocuments = [];


  var _isLoading = false;
  var _isValid = false;

  final List<String> _SubjectsList = [
    'Lower Primary Bahasa Melayu',
    'Lower Primary English',
    'Lower Primary Tamil',
    'Lower Primary Mandarin',
    'Lower Primary Moral',
    'Lower Primary Science',
    'Lower Primary Mathematics',
    'Upper Primary Bahasa Melayu',
    'Upper Primary English',
    'Upper Primary Tamil',
    'Upper Primary Mandarin',
    'Upper Primary Moral',
    'Upper Primary Science',
    'Upper Primary Mathematics',
    'Upper Primary Sejarah',
    'Lower Secondary Bahasa Melayu',
    'Lower Secondary English',
    'Lower Secondary Moral',
    'Lower Secondary Sejarah',
    'Lower Secondary Mathematics',
    'Lower Secondary Science',
    'Upper Secondary Bahasa Melayu',
    'Upper Secondary English',
    'Upper Secondary Moral',
    'Upper Secondary Science',
    'Upper Secondary Mathematics',
    'Upper Secondary Sejarah',
    'Upper Secondary Physics',
    'Upper Secondary Chemistry',
    'Upper Secondary Biology',
    'Upper Secondary Additional Math',
    'Upper Secondary Accounting',
    'Upper Secondary Business Studies',
  ];

  final List<String> _TeachingLevel = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  Future<List<String>> _uploadFiles() async {
  List<String> downloadUrls = [];

  for (var file in _selectedDocuments) {
    String fileName = basename(file.path);
    Reference storageRef = FirebaseStorage.instance.ref().child('TutorExperience/$fileName');

    // Upload the file to Firebase Storage
    UploadTask uploadTask = storageRef.putFile(file);

    // Retrieve download URL
    String downloadUrl = await (await uploadTask).ref.getDownloadURL();
    downloadUrls.add(downloadUrl);
  }

  return downloadUrls;
}


  void _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      setState(() {
        _isLoading = true;
      });

      // Format availability for storage
      List<Map<String, dynamic>> formattedAvailability =
          _availability.map((slot) {
        return {
          'day': slot['day'],
          'startTime': slot['startTime'] != null
              ? DateFormat('HH:mm').format(
                  DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    slot['startTime'].hour,
                    slot['startTime'].minute,
                  ),
                )
              : null,
          'endTime': slot['endTime'] != null
              ? DateFormat('HH:mm').format(
                  DateTime(
                    DateTime.now().year,
                    DateTime.now().month,
                    DateTime.now().day,
                    slot['endTime'].hour,
                    slot['endTime'].minute,
                  ),
                )
              : null,
        };
      }).toList();

      List<String> fileUrls = await _uploadFiles();

      Map<String, dynamic> TutorPostData = {
        'SubjectsToTeach': _subject,
        'LevelofTeaching': _level,
        'RatePerHour': _ratePerHour,
        'Experience': fileUrls, 
        'TeacherAvailability': formattedAvailability,
      };

      try {
        await FirebaseFirestore.instance
            .collection('Tutor')
            .doc(userId)
            .collection('TutorPost')
            .add(TutorPostData);

        setState(() {
          _isLoading = false;
        });

        //widget.onSaved();
      } catch (error) {
        print('Error saving tutor post: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No user signed in');
    }
  }

  Future<void> _pickDocument() async {
  FilePickerResult? result = await FilePicker.platform.pickFiles(allowMultiple: true);

  if (result != null) {
    List<File> files = result.paths.map((path) => File(path!)).toList();
    setState(() {
      _selectedDocuments.addAll(files); // This adds the newly picked files to the existing list.
    });
  }
}


  // Method to add a new availability slot
  void _addAvailability() {
    setState(() {
      _availability.add({
        'day': null,
        'startTime': null,
        'endTime': null,
      });
    });
  }

// Method to remove an availability slot
  void _removeAvailability(int index) {
    setState(() {
      _availability.removeAt(index);
    });
  }

  void _updateStartTime(int slotIndex, TimeOfDay? picked) {
    if (picked != null) {
      setState(() {
        _availability[slotIndex]['startTime'] = picked;
      });
    }
  }

  void _updateEndTime(int slotIndex, TimeOfDay? picked) {
    if (picked != null) {
      setState(() {
        _availability[slotIndex]['endTime'] = picked;
      });
    }
  }

  Future<void> _selectTime(
      BuildContext context, int slotIndex, String key) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _availability[slotIndex][key] ?? TimeOfDay.now(),
    );

    if (key == 'startTime') {
      _updateStartTime(slotIndex, picked);
    } else if (key == 'endTime') {
      _updateEndTime(slotIndex, picked);
    }
  }

  String _formatTimeOfDay(TimeOfDay? tod) {
    final now = DateTime.now();
    final dt = DateTime(
        now.year, now.month, now.day, tod?.hour ?? 0, tod?.minute ?? 0);
    final format = DateFormat.jm(); // for AM/PM formatting
    return tod != null ? format.format(dt) : "Select Time";
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
        toolbarHeight: screenHeight * 0.05,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 255, 230),
      body: Scrollbar(
        thumbVisibility: true,
        thickness: 6.0,
        radius: Radius.circular(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const PageHeader(
                  backgroundColor: Color.fromARGB(255, 255, 116, 36),
                  headerTitle: "Tutor Add Post"),
              const SizedBox(
                height: 10,
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                width: screenWidth * 0.9,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: <Widget>[
                        const Text("Professional Details",
                            style: TextStyle(fontSize: 20)),
                        const SizedBox(
                          height: 20,
                        ),
                        DropdownButtonFormField<String>(
                          value: _subject,
                          decoration: InputDecoration(
                            labelText: 'Subject to Teach',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          items: _SubjectsList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _subject = newValue!;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField<String>(
                          value: _level,
                          decoration: InputDecoration(
                            labelText: 'Level of Teaching',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          items: _TeachingLevel.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _level = newValue!;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Experience",
                            style: TextStyle(fontSize: 20)),
                        const SizedBox(
                          height: 10,
                        ),
                        // Section for displaying picked document names
                for (var file in _selectedDocuments)
                  ListTile(
                    title: Text(
                      basename(file.path),
                      style: const TextStyle(fontSize: 16),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          _selectedDocuments.remove(file);
                        });
                      },
                    ),
                  ),

                // Button to pick documents
                TextButton(
                  onPressed: _pickDocument,
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.orange,
                    primary: Colors.white,
                  ),
                  child: const Text('Upload Document'),
                ),
                        
                        const SizedBox(
                          height: 10,
                        ),
                        const Text("Fees", style: TextStyle(fontSize: 20)),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _ratePerHourController,
                          decoration: InputDecoration(
                            labelText: 'Rate per Hour (RM)',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid rate per hour.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _ratePerHour = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(left: 16.0),
                                child: Text(
                                  "Teacher Availability",
                                  style: TextStyle(fontSize: 20),
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(right: 16.0),
                              child: ElevatedButton(
                                onPressed: _addAvailability,
                                style: ElevatedButton.styleFrom(
                                  primary: Colors
                                      .transparent, // Use your theme color here
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                ),
                                child: Text('Add'),
                              ),
                            ),
                          ],
                        ),
                        ..._availability.map((slot) {
                          return Card(
                            margin: const EdgeInsets.all(8.0),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                children: [
                                  DropdownButtonFormField<String>(
                                    value: slot['day'],
                                    decoration: InputDecoration(
                                      labelText: 'Week day',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    items: [
                                      'Monday',
                                      'Tuesday',
                                      'Wednesday',
                                      'Thursday',
                                      'Friday',
                                      'Saturday',
                                      'Sunday'
                                    ]
                                        .map((String value) =>
                                            DropdownMenuItem<String>(
                                              value: value,
                                              child: Text(value),
                                            ))
                                        .toList(),
                                    onChanged: (newValue) {
                                      setState(() {
                                        slot['day'] = newValue;
                                      });
                                    },
                                  ),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _selectTime(
                                              context,
                                              _availability.indexOf(slot),
                                              'startTime'),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(
                                              _formatTimeOfDay(
                                                  slot['startTime']),
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: InkWell(
                                          onTap: () => _selectTime(
                                              context,
                                              _availability.indexOf(slot),
                                              'endTime'),
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: Text(
                                              _formatTimeOfDay(slot['endTime']),
                                              style:
                                                  TextStyle(color: Colors.blue),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _removeAvailability(
                                        _availability.indexOf(slot)),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 12),
              if (_isValid) SizedBox(height: 12),
              if (!_isValid)
                if (_isLoading) const CircularProgressIndicator(),
              if (!_isLoading)
                ElevatedButton(
                  onPressed: _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 255, 255, 115),
                  ),
                  child: const Text("Save"),
                ),
              SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _ratePerHourController.dispose();
    super.dispose();
  }
}
