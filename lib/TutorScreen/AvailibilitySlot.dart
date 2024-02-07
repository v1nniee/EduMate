import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:edumateapp/Widgets/PageHeader.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AvailabilitySlot extends StatefulWidget {
  const AvailabilitySlot({super.key});
  @override
  State<AvailabilitySlot> createState() => _AvailabilitySlotState();
}

class _AvailabilitySlotState extends State<AvailabilitySlot> {
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
  List<Map<String, dynamic>> _availability = [];
  var _isLoading = false;
  var _isValid = false;

  void _submit() async {
    print("Hi");
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

      Map<String, dynamic> AvailibilitySlotData = {
        'TeacherAvailability': formattedAvailability,
      };

      try {
        await FirebaseFirestore.instance
            .collection('Tutor')
            .doc(userId)
            .collection('AvailibilitySlot')
            .add(AvailibilitySlotData);

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
          child: Form( // Wrap your column in a Form widget
          key: _formKey,
          child: Column(
            children: <Widget>[
              PageHeader(
                  backgroundColor: Color.fromARGB(255, 255, 116, 36),
                  headerTitle: "Tutor Add Post"),
              SizedBox(
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
                    padding: EdgeInsets.only(right: 16.0),
                    child: ElevatedButton(
                      onPressed: _addAvailability,
                      style: ElevatedButton.styleFrom(
                        primary:
                            Colors.transparent, // Use your theme color here
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
                              .map((String value) => DropdownMenuItem<String>(
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
                                onTap: () => _selectTime(context,
                                    _availability.indexOf(slot), 'startTime'),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    _formatTimeOfDay(slot['startTime']),
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: InkWell(
                                onTap: () => _selectTime(context,
                                    _availability.indexOf(slot), 'endTime'),
                                child: Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Text(
                                    _formatTimeOfDay(slot['endTime']),
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              _removeAvailability(_availability.indexOf(slot)),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
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
    ),);
  }
}
