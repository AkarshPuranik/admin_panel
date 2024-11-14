// lib/event_screen.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EventScreen extends StatefulWidget {
  @override
  _EventScreenState createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  final _eventTitleController = TextEditingController();
  final _eventContentController = TextEditingController();
  DateTime? _eventDate;
  TimeOfDay? _eventTime;

  Future<void> _createEvent() async {
    if (_eventTitleController.text.isNotEmpty && _eventDate != null && _eventTime != null) {
      final eventDateTime = DateTime(
        _eventDate!.year,
        _eventDate!.month,
        _eventDate!.day,
        _eventTime!.hour,
        _eventTime!.minute,
      );
      await FirebaseFirestore.instance.collection('events').add({
        'title': _eventTitleController.text,
        'content': _eventContentController.text,
        'datetime': eventDateTime,
        'timestamp': FieldValue.serverTimestamp(),
      });
      _eventTitleController.clear();
      _eventContentController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Event created successfully')),
      );
    }
  }

  Future<void> _pickDate() async {
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (selectedDate != null) setState(() => _eventDate = selectedDate);
  }

  Future<void> _pickTime() async {
    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) setState(() => _eventTime = selectedTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Event')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _eventTitleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _eventContentController,
              decoration: InputDecoration(
                labelText: 'Event Content',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            SizedBox(height: 20),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickDate,
                  child: Text(_eventDate == null ? 'Pick Date' : '${_eventDate!.toLocal()}'.split(' ')[0]),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickTime,
                  child: Text(_eventTime == null ? 'Pick Time' : '${_eventTime!.format(context)}'),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _createEvent,
              child: Text('Create Event'),
            ),
          ],
        ),
      ),
    );
  }
}
