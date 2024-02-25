//if the zip code is wrong?
//date of birth is not logic?
//all the value validation


import 'dart:io';

import 'package:edumateapp/Data/ZipCodeData.dart';
import 'package:edumateapp/Provider/TokenNotifier.dart';
import 'package:edumateapp/TutorSeekerScreen/TutorSeekerTabScreen.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:edumateapp/Widgets/UserImagePicker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';

class TutorSeekerRegistration extends StatefulWidget {
  final VoidCallback onSaved;
  const TutorSeekerRegistration({super.key, required this.onSaved});

  @override
  State<TutorSeekerRegistration> createState() =>
      _TutorSeekerRegistrationState();
}

class _TutorSeekerRegistrationState extends State<TutorSeekerRegistration> {
  final _formKey = GlobalKey<FormState>();
  var _enteredFirstName = '';
  var _enteredLastName = '';
  var _enteredDate = '';
  var _enteredMobileNumer = '';
  var _enteredAddress = '';
  var _enteredZip = '';
  var _enteredState = '';
  var _enteredCity = '';
  var _enteredRequirement = '';

  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _zipController = TextEditingController();
  final _stateController = TextEditingController();
  final _cityController = TextEditingController();
  final _requirementController = TextEditingController();

  var _isLoading = false;
  File? _selectedImageFile;
  var _isValid = false;
  var _gender = 'Male';
  final List<String> _userTypes = ['Male', 'Female'];
  var _grade = 'Primary Year 1';
  final List<String> _gradeList = [
    'Primary Year 1',
    'Primary Year 2',
    'Primary Year 3',
    'Primary Year 4',
    'Primary Year 5',
    'Primary Year 6',
    'Secondary Year 1',
    'Secondary Year 2',
    'Secondary Year 3',
    'Secondary Year 4',
    'Secondary Year 5'
  ];

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

      String? imageURL;

      if (_selectedImageFile != null) {
        String fileName = 'TutorSeekerProfileImages';
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
        'Grade': _grade,
        if (_enteredRequirement != null && _enteredRequirement.isNotEmpty)
          'Requirement': _enteredRequirement
        else
          'Requirement': null,
        if (imageURL != null) 'ImageUrl': imageURL else 'ImageUrl': null,
      };


      try {
        await FirebaseFirestore.instance
            .collection('Tutor Seeker')
            .doc(userId)
            .collection('UserProfile')
            .doc(userId) 
            .set(userProfileData, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection('Tutor Seeker')
            .doc(userId)
            .set({'Name': userProfileData['Name']}, SetOptions(merge: true));
        setState(() {
          _isLoading = false;
        });

        await FirebaseFirestore.instance
            .collection('Tutor Seeker')
            .doc(userId)
            .set({'UserType': "Tutor Seeker"}, SetOptions(merge: true));
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
        backgroundColor: const Color.fromARGB(255, 255, 255, 115),
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
                  backgroundColor: Color.fromARGB(255, 255, 255, 115),
                  headerTitle: "Tutor Seeker Profile"),
              Container(
                width: screenWidth * 0.9,
                height: screenHeight * 0.155,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
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
                          items: _userTypes.map((String value) {
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
                        DropdownButtonFormField<String>(
                          value: _grade,
                          decoration: InputDecoration(
                            labelText: 'Grade',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          items: _gradeList.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _grade = newValue!;
                            });
                          },
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        TextFormField(
                          controller: _requirementController,
                          decoration: InputDecoration(
                            labelText: 'Requirement',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                          ),
                          onSaved: (value) {
                            _enteredRequirement = value!;
                          },
                        ),
                        if (_isValid) SizedBox(height: 12),
                        if (!_isValid)
                          if (_isLoading) const CircularProgressIndicator(),
                        if (!_isLoading)
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor:
                                  const Color.fromARGB(255, 255, 255, 115),
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
    _requirementController.dispose();
    super.dispose();
  }
}
