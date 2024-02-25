import 'dart:io';

import 'package:edumateapp/Data/ZipCodeData.dart';
import 'package:edumateapp/Provider/TokenNotifier.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerTabScreen.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:edumateapp/Widgets/UserImagePicker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class TutorRegistration extends StatefulWidget {
  final VoidCallback onSaved;
  const TutorRegistration({super.key, required this.onSaved});

  @override
  State<TutorRegistration> createState() => _TutorRegistrationState();
}

class _TutorRegistrationState extends State<TutorRegistration> {
  final _formKey = GlobalKey<FormState>();
  var _enteredFirstName = '';
  var _enteredLastName = '';
  var _enteredDate = '';
  var _enteredMobileNumer = '';
  var _enteredAddress = '';
  var _enteredZip = '';
  var _enteredState = '';
  var _enteredCity = '';
  var _enteredAboutme = '';
  var _enteredQualification = 'Diploma';
  var _gender = 'Male';

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _enteredAboutmeController = TextEditingController();

  var _isLoading = false;
  File? _selectedImageFile;
  File? _selectedCertification;
  String? _selectedCertificationName;

  var _isValid = false;

  final List<String> _genderTypes = ['Male', 'Female'];
  final List<String> _qualificationType = [
    "Diploma",
    "Bachelor's degree",
    "Master's Degree",
    "Ph.D."
  ];

  Future<void> _pickDocument() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      setState(() {
        _selectedCertification = File(file.path!);
        _selectedCertificationName = file.name;
      });
    } else {
      // User canceled the picker
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No file selected'),
      ));
    }
  }

  void _submit() async {
    final isDocumentSelected = _selectedCertification != null;
    if (!_formKey.currentState!.validate() || !isDocumentSelected) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please fill all fields and upload a document.')),
      );
      return;
    }

    _formKey.currentState!.save();

    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      setState(() {
        _isLoading = true;
      });

      String? imageURL;

      if (_selectedImageFile != null) {
        String fileName = 'TutorProfileImages';
        Reference storageRef =
            FirebaseStorage.instance.ref().child(fileName).child('$userId.jpg');

        try {
          UploadTask uploadTask = storageRef.putFile(_selectedImageFile!);
          // Wait for the upload to complete
          TaskSnapshot taskSnapshot = await uploadTask;

          // After upload is complete, get the download URL
          imageURL = await taskSnapshot.ref.getDownloadURL();

          print(imageURL); // This is your image URL
        } on FirebaseException catch (error) {
          print('Error uploading image: $error');
        }
      }

      Map<String, dynamic> userProfileData = {
        'Name': _enteredFirstName + ' ' + _enteredLastName,
        'DOB': _enteredDate,
        'Gender': _gender,
        'MobileNumber': _enteredMobileNumer,
        'Address': _enteredAddress,
        'ZipCode': _enteredZip,
        'State': _enteredState,
        'City': _enteredCity,
        'AboutMe': _enteredAboutme,
        'Rating': 0.1,
        'NumberOfRating': 0,
        'HighestQualification': _enteredQualification,
        'Status': 'Unverified',
        if (imageURL != null) 'ImageUrl': imageURL else 'ImageUrl': null,
      };


      try {

        if (_selectedCertification != null) {
          String docFileName =
              'TutorCertificationDocuments/${userId}_${DateTime.now().millisecondsSinceEpoch}.pdf';
          Reference storageRef =
              FirebaseStorage.instance.ref().child(docFileName);

          UploadTask uploadTask = storageRef.putFile(_selectedCertification!);
          TaskSnapshot taskSnapshot = await uploadTask;
          String docURL = await taskSnapshot.ref.getDownloadURL();

          userProfileData['DocumentUrl'] = docURL;
        }

        await FirebaseFirestore.instance
            .collection('Admin')
            .doc("IlRy3c7wNpWuvfVeCkLPbHGhg1W2")
            .collection('TutorRegistrationRequest')
            .doc(userId)
            .set(userProfileData, SetOptions(merge: true));
        
        await FirebaseFirestore.instance
            .collection('Tutor')
            .doc(userId)
            .collection('UserProfile')
            .doc(userId)
            .set(userProfileData, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('Tutor')
            .doc(userId)
            .set({'Name': userProfileData['Name']}, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('Tutor')
            .doc(userId)
            .set({'UserType': "New Tutor"}, SetOptions(merge: true));
        setState(() {
          _isLoading = false;
        });

        setState(() {
          _isLoading = false;
        });
        
        widget.onSaved();
      } catch (error) {
        print('Error saving profile: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No user signed in');
    }
  }

  void searchAndAutoFill(String zipCode) {
    bool found = false;

    for (var stateData in ZipCodeData['state']) {
      for (var state in stateData['state']) {
        for (var city in state['city']) {
          if (city['postcode'].contains(zipCode)) {
            setState(() {
              _stateController.text = state['name'];
              _cityController.text = city['name'];
            });
            found = true;
            return;
          }
        }
      }
    }

    if (!found) {
      // Zip code not found
      setState(() {
        _stateController.clear();
        _cityController.clear();
      });

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Zip code not found')));
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null && pickedDate != DateTime.now()) {
      setState(() {
        _dateController.text = "${pickedDate.toLocal()}".split(' ')[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: const Color.fromARGB(255, 255, 116, 36),
        elevation: 0,
        toolbarHeight: screenHeight * 0.05,
      ),
      backgroundColor: const Color.fromARGB(255, 255, 203, 173),
      body: Scrollbar(
        thumbVisibility: true,
        thickness: 6.0,
        radius: Radius.circular(10.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const PageHeader(
                  backgroundColor: const Color.fromARGB(255, 255, 116, 36),
                  headerTitle: "Tutor Profile"),
              Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.155,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: UserImagePicker(onPickImage: (pickedImage) {
                  setState(() {
                    _selectedImageFile = pickedImage;
                    print(_selectedImageFile!.path.split('/').last);
                  });
                }),
              ),
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
                        const Text("Basic Information",
                            style: TextStyle(fontSize: 20)),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: 'First Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid first name.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredFirstName = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: 'Last Name',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          autocorrect: false,
                          textCapitalization: TextCapitalization.none,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid last name.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredLastName = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _dateController,
                          decoration: InputDecoration(
                            labelText: 'Date of Birth',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          onTap: () {
                            FocusScope.of(context).requestFocus(
                                new FocusNode()); // to prevent opening the keyboard
                            _pickDate(context);
                          },
                          readOnly: true,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please pick a date.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredDate = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField<String>(
                          value: _gender,
                          decoration: InputDecoration(
                            labelText: 'Gender',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          items: _genderTypes.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _gender = newValue!;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _mobileNumberController,
                          decoration: InputDecoration(
                            labelText: 'Mobile Number',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid mobile number.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredMobileNumer = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _addressController,
                          decoration: InputDecoration(
                            labelText: 'Address',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid address.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredAddress = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _zipController,
                          decoration: InputDecoration(
                            labelText: 'Zip Code',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid zip code.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredZip = value!;
                          },
                          onFieldSubmitted: (value) async {
                            searchAndAutoFill(value);
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _cityController,
                          decoration: InputDecoration(
                            labelText: 'City',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid city.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredCity = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _stateController,
                          decoration: InputDecoration(
                            labelText: 'State',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter a valid state.';
                            }
                            return null;
                          },
                          onSaved: (value) {
                            _enteredState = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _enteredAboutmeController,
                          decoration: InputDecoration(
                            labelText: 'About Me',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          onSaved: (value) {
                            _enteredAboutme = value!;
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        DropdownButtonFormField<String>(
                          value: _enteredQualification,
                          decoration: InputDecoration(
                            labelText: 'Highest Qualification',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          items: _qualificationType.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _enteredQualification = newValue!;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        ElevatedButton.icon(
                          onPressed: _pickDocument,
                          icon: Icon(Icons.upload_file),
                          label: Text("Upload Document"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                          ),
                        ),
                        if (_selectedCertificationName != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child:
                                Text("Uploaded: $_selectedCertificationName"),
                          ),
                        if (_isValid) SizedBox(height: 12),
                        if (!_isValid)
                          if (_isLoading) const CircularProgressIndicator(),
                        if (!_isLoading)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 116, 36),
                            ),
                            child: const Text("Save"),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _dateController.dispose();
    _mobileNumberController.dispose();
    _addressController.dispose();
    _zipController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    super.dispose();
  }
}
