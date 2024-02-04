import 'package:flutter/material.dart';

class AvailabilitySlot extends StatelessWidget {
  final Map<String, dynamic> availability;
  final VoidCallback onRemoved;
  final VoidCallback onStartTimeChanged;
  final VoidCallback onEndTimeChanged;

  const AvailabilitySlot({
    Key? key,
    required this.availability,
    required this.onRemoved,
    required this.onStartTimeChanged,
    required this.onEndTimeChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: DropdownButtonFormField<String>(
              value: availability['day'],
              decoration: InputDecoration(
                labelText: 'Week day',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
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
                availability['day'] = newValue;
              },
            ),
          ),
          IconButton(
            icon: Icon(Icons.remove_circle_outline, color: Colors.red),
            onPressed: onRemoved,
          ),
          InkWell(
            onTap: onStartTimeChanged,
            child: Text(
              availability['startTime'] != null
                  ? availability['startTime'].format(context)
                  : 'Start time',
              style: TextStyle(color: Colors.blue),
            ),
          ),
          SizedBox(width: 8),
          InkWell(
            onTap: onEndTimeChanged,
            child: Text(
              availability['endTime'] != null
                  ? availability['endTime'].format(context)
                  : 'End time',
              style: TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }
}
