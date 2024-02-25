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
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  void initState() {
    super.initState();
    // Initialize with one availability slot
    _availability.add({
      'day': null,
      'startTime': null,
      'endTime': null,
    });

    // Fetch existing availability slots
    _fetchExistingAvailabilitySlots();
  }

  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> _availability = [];
  List<Map<String, dynamic>> _existingSlots = [];
  var _isLoading = false;
  var _isValid = false;

  void _fetchExistingAvailabilitySlots() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String userId = user.uid;

      try {
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection('Tutor')
            .doc(userId)
            .collection('AvailibilitySlot')
            .get();

        var fetchedSlots = querySnapshot.docs.map((doc) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          // Assuming 'day', 'startTime', and 'endTime' are stored in the correct formats
          // Convert 'startTime' and 'endTime' from String to TimeOfDay
          return {
            'day': data['day'],
            'startTime': _timeFromString(data['startTime']),
            'endTime': _timeFromString(data['endTime']),
            'status': data['status'],
          };
        }).toList();

        setState(() {
          _availability = fetchedSlots;
        });
      } catch (e) {
        print('Error fetching tutor availability slots: $e');
      }
    } else {
      print('No user signed in');
    }
  }

  TimeOfDay? _timeFromString(String? timeString) {
    if (timeString == null) return null;
    final format = DateFormat('HH:mm'); // Adjust the format if necessary
    DateTime? dateTime = format.parseStrict(timeString);
    return TimeOfDay(hour: dateTime.hour, minute: dateTime.minute);
  }

  void _submit() async {
    if (!_formKey.currentState!.validate() || !_isAvailabilityValid()) {
      // Show an error message if availability is not valid
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fill in all availability slots.'),
          backgroundColor: Colors.red,
        ),
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

      try {
        // Delete existing availability slots
        await _deleteExistingAvailabilitySlots(userId);

        // Save new availability slots
        await _saveAvailabilitySlots(userId);

        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Submission Successful'),
              content: const Text(
                  'Your availability slots have been updated successfully.'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      } catch (error) {
        print('Error saving or deleting tutor availability slots: $error');
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      print('No user signed in');
    }
  }

  Future<void> _deleteExistingAvailabilitySlots(String userId) async {
    try {
      // Fetch existing availability slots
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('Tutor')
          .doc(userId)
          .collection('AvailibilitySlot')
          .get();

      // Delete each existing slot
      for (var doc in querySnapshot.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error deleting existing tutor availability slots: $e');
    }
  }

  Future<void> _saveAvailabilitySlots(String userId) async {
    List<Map<String, dynamic>> formattedAvailability =
        _availability.map((slot) {
      return {
        'day': slot['day'],
        'startTime': slot['startTime'] != null
            ? DateFormat('HH:mm').format(DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                slot['startTime'].hour,
                slot['startTime'].minute,
              ))
            : null,
        'endTime': slot['endTime'] != null
            ? DateFormat('HH:mm').format(DateTime(
                DateTime.now().year,
                DateTime.now().month,
                DateTime.now().day,
                slot['endTime'].hour,
                slot['endTime'].minute,
              ))
            : null,
        'status': slot['status'],
      };
    }).toList();

    // Save each new slot
    for (var slot in formattedAvailability) {
      await FirebaseFirestore.instance
          .collection('Tutor')
          .doc(userId)
          .collection('AvailibilitySlot')
          .add(slot);
    }
  }

  void _addAvailability() {
    setState(() {
      _availability.add({
        'day': null,
        'startTime': null,
        'endTime': null,
        'status': 'available',
      });
    });
  }

  void _removeAvailability(int index) {
    setState(() {
      _availability.removeAt(index);
    });
  }

  void _updateStartTime(int slotIndex, TimeOfDay? picked) {
    if (picked != null) {
      setState(() {
        _availability[slotIndex]['startTime'] = picked;

        // Calculate and set end time as 2 hours after start time
        final int endHour = picked.hour + 2;
        final int endMinute = picked.minute;
        _availability[slotIndex]['endTime'] =
            TimeOfDay(hour: endHour, minute: endMinute);
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

  bool _isAvailabilityValid() {
    for (var slot in _availability) {
      if (slot['day'] == null ||
          slot['startTime'] == null ||
          slot['endTime'] == null) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
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
          child: Form(
            // Wrap your column in a Form widget
            key: _formKey,
            child: Column(
              children: <Widget>[
                PageHeader(
                    backgroundColor: Color.fromARGB(255, 255, 116, 36),
                    headerTitle: "Time Availibility"),
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
                          backgroundColor:
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
                  Color slotColor = slot['status'] == 'unavailable'
                      ? Colors.red
                      : Colors.white;
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    color: slotColor,
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
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select a day';
                              }
                              return null;
                            },
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: InkWell(
                                  onTap: () => _selectTime(context,
                                      _availability.indexOf(slot), 'startTime'),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8.0),
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
                            onPressed: () => _removeAvailability(
                                _availability.indexOf(slot)),
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
      ),
    );
  }
}
