
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


  final _formKey = GlobalKey<FormState>();
  var _subject = 'Lower Primary Science';
  var _level = 'Beginner';
  var _ratePerHour = '';

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

      

      List<String> fileUrls = await _uploadFiles();

      Map<String, dynamic> TutorPostData = {
        'SubjectsToTeach': _subject,
        'LevelofTeaching': _level,
        'RatePerHour': _ratePerHour,
        'Experience': fileUrls, 
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
